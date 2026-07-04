---
canonical: https://claire.zone/2026/07/03/toucan-firmware-with-a-local-llm.html
meta-description: Porting a ZMK split keyboard to Zephyr 4.1 and chasing down a stubborn trackpad bug, end to end, with a self-hosted MiniMax-M3 and the Oh My Pi harness, no cloud.
meta-og:description: Porting a ZMK split keyboard to Zephyr 4.1 and chasing down a stubborn trackpad bug, end to end, with a self-hosted MiniMax-M3 and the Oh My Pi harness, no cloud.
meta-og:title: Vibe-coding keyboard firmware with a local LLM
meta-og:type: article
meta-twitter:card: summary_large_image
meta-twitter:title: Vibe coding keyboard firmware with a local LLM
title: Vibe coding keyboard firmware with a local LLM
---

# Vibe coding keyboard firmware with a local LLM

Porting a ZMK split keyboard to Zephyr 4.1 and chasing down a stubborn trackpad bug, end to end, with a self-hosted MiniMax-M3 and the Oh My Pi harness, no cloud.

## The keyboard

<img width="800" height="800" alt="Toucan42 keyboard" src="https://github.com/user-attachments/assets/d1f17e5a-40fa-4599-a990-f9e4bcd9736f" />

I'd had a good run with a Sofle split, and when I wanted something smaller to throw in a bag, the [beekeeb Toucan](https://beekeeb.com/toucan-keyboard/) caught my eye. It's a 42-key column-stagger split, on the compact side, and it comes with the toys: a small status display on the left half and a Cirque trackpad on the right. It's become my travel and commute board.

The Toucan is designed around ZMK, a highly customizable firmware you build yourself. Beekeeb provides a forked config repo, which includes a `prospector-dongle` branch meant to pair the halves with a [Prospector display dongle](https://github.com/carrefinho/prospector), a wireless BLE-USB receiver that shows battery and layer info on a screen. Out of the box that branch doesn't even build: it pins a third-party module whose upstream branch was deleted, so `west update` just dies. I wanted the dongle's newer status screens, which only exist on the Zephyr 4.1 / ZMK `main` track, and the whole thing was sitting there unbuildable on the older 3.5 line.

So: get it building, migrate it to Zephyr 4.1, get the new screens working, and somewhere in there fix a trackpad that had ideas of its own.

## The setup

My AI rig is the same NixOS cluster I wrote about [last time](/2026/05/25/redesigning-with-open-design-and-self-hosted-qwen.html), with LiteLLM as the gateway. After some hardware reconfigurations and RAM upgrades, I swapped a new model onto the GPU box I call `bakery`, replacing the qwen3.6-27b that lived there before:

- **Model:** MiniMax-M3, a 428B-parameter Mixture-of-Experts model with 23B active parameters, on Unsloth's `Q4_K_S` quant (~248 GB) with an unquantized f16 KV cache and a 178k context window. It's a hybrid architecture (a few dense layers on top of a deep MoE stack), which is why the serving setup below looks the way it does.
- **Inference:** [ik_llama.cpp](https://github.com/ikawrakow/ik_llama.cpp) rather than upstream llama.cpp. ik_llama's faster CPU matmul kernels for the MoE experts are the only reason a model this size is tolerable on my hardware. The weights sit in system RAM (`--mlock`), the MoE experts run on the CPU (`--cpu-moe`), and the attention and dense layers plus the KV cache live on a pair of RTX 3090s, split across both cards with the graph tensor-split mode. On the i9-9980XE in that box it does around 7.5 to 7.9 tokens/second, roughly 5-6x what upstream llama.cpp managed on the same quant. Usable for a coding session, if not snappy.
- **Gateway:** LiteLLM, exposing the model to anything that speaks the OpenAI API.

That's the part I'm used to. The interesting choice this time was the application: I wanted to try to stretch the abilities of my local model by choosing a project I found compelling, but might have seemed too intimidating to attempt without any assistance. Keyboard firmware and embedded development in general are pretty far removed from the kind of work I'm used to, and there's a lot of room to experiment and explore with a tight feedback loop that allowed me to direct the model toward the features I cared about the most.

## Why Oh My Pi instead of OpenCode

For coding work I normally reach for [OpenCode](https://opencode.ai), running on a dedicated server and exposing a web UI so I can resume a session from any device. But firmware has a physical loop: build the UF2, double-tap reset, drag the file onto the bootloader mount, test it on real hardware, repeat. That loop gets old fast when your agent lives on a server in another room and the keyboard is sitting on your desk.

So for this one I ran [Oh My Pi](https://github.com/oh-my-pi) locally on my personal Framework 12 laptop, the machine the keyboard was plugged into. OMP is a set of plugins for the popular Pi harness, which sits at the minimalist end of the agent spectrum; its stock system prompt is well under a thousand tokens where something like OpenCode or Claude Code burns ten thousand-plus, which leaves more of the context window for the actual problem. It also has the pieces that matter for this kind of work: native file, search, and AST tools, hash-anchored edits that don't get tripped up by whitespace, LSP, a real debugger, and a tree-structured history so you can branch on a hypothesis and back out cleanly when it's wrong. The philosophy is "change the harness, not your workflow," and for a long, fiddly debugging session where I wanted to be wrong out loud and recover fast, that fit.

The practical win was just having the agent on the same machine as the keyboard. Build, flash, test, read the result back to the model, all in one place.

## What the model actually did

The honest answer is that it did essentially all of it. I pointed it at the repo and described the goal; it read the codebase, worked out the build system, stood up a Docker-based ZMK build environment from scratch, and started iterating. I was steering (confirming direction, validating on the hardware, deciding scope), but the model did the reading, the debugging, the C, even the git work.

Some of it was the migration work you'd expect: drop the deleted upstream module, retarget the board from `seeeduino_xiao_ble` to the new `xiao_ble//zmk`, swap the old third-party Cirque trackpad driver for Zephyr 4.1's now-built-in one (which collided on Kconfig and had to be reconciled), adapt the devicetree to the mainline binding, and rework the display widgets that broke in the LVGL 8 to 9 jump.

Then there was the trackpad, which is where I want to be honest, because it's the part that could have sunk the whole thing.

The halves are split peripherals that relay input to the dongle over Bluetooth. After the migration, tap-to-click worked but horizontal cursor movement was broken, while vertical was fine. Chasing it took real iterations: an X-axis inversion here, a framing change there, a couple of wrong turns. The actual root cause was subtle. Once you turn on tap detection, the mainline Cirque driver emits a button event on every single trackpad sample, and each one becomes its own BLE notify that floods the link and degrades the X reporting. The fix wasn't a config toggle; the model wrote a small custom ZMK input-processor module that makes each movement frame commit at the right point and drops the redundant per-sample button events, so tap-to-click and smooth movement coexist.

That's the kind of bug where a less capable model hands you a plausible patch that papers over the symptom and calls it done. This one did great at following my suggestions and feedback throughout the investigation and implementation process. It traced the data path through the split transport and the input listener and fixed it at the source.

By the end of an afternoon I had the new prospector status screens on the dongle, a working display on the left half, a nav-layer tap for right-click, and media keys, all built and flashed and validated on the actual hardware, then committed and pushed to [my fork](https://github.com/clairesrc/zmk-keyboard-toucan).

<img width="3843" height="1486" alt="Prospector Dongle" src="https://github.com/user-attachments/assets/a2863575-faf1-4a78-b335-a3f550f43399" />

## So, can a local model do this?

I went in skeptical, the way I always do, and came out genuinely impressed.

MiniMax-M3 is a big model; 428B parameters, even with only 23B active, is a lot of capacity. But it's running entirely on my own hardware behind my own gateway, and it took a real embedded-systems debugging problem from "doesn't build" to "flashed and working" in an afternoon. It was very slow at times. ik_llama on a hybrid CPU/GPU split is fast for what it is, but it isn't the sub-second latency of a hosted frontier model, and there were stretches where I was just waiting on tokens. And I'd be lying if I said no human oversight was involved; I was still reading diffs, testing on hardware, and course-correcting the whole way.

Two things made this go as smoothly as it did. Aided by the harness's context compaction mechanism, the model could actually hold the whole problem in its 178k context (build system, devicetree overlays, split transport) without me re-explaining anything. And ZMK is a mature project with a strong community, which means the answers were mostly already in the codebase for a model patient enough to read them. 

The bar is moving, and it's moving on consumer hardware I own. I'm not canceling my GLM plan quite yet. But the gap between the big hosted models and what I can run at home is narrower than it was a year ago, and projects like this are where I feel it most.

Have you tried driving real hardware or firmware work with a local model? I'd like to hear how it went, over Email or LinkedIn.

