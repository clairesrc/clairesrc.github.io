---
layout: post
title: "Redesigning my site with Open Design and self-hosted Qwen 3.6"
date: 2026-05-25
description: Overhauling a Jekyll site using open-source design tooling and locally-hosted AI models, no cloud required.
permalink: /2026/05/25/redesigning-with-open-design-and-self-hosted-qwen.html
---

# Redesigning my site with Open Design and self-hosted Qwen 3.6

My personal site had been running the same cobbled-together Jekyll template for years. It worked, but it looked like what it was: a developer's first pass at a custom theme, built with more enthusiasm than design sense. I'd been meaning to redo it for a while, and two things finally pushed me over the edge: [Open Design](https://github.com/nexu-io/open-design) (an open-source alternative to Claude Design) got good enough to try seriously, and Qwen dropped [Qwen 3.6-27B](https://huggingface.co/Qwen/Qwen3.6-27B), which runs circles around anything else in its weight class.

## The setup

My AI rig hasn't changed much since [my last post about local AI]({% post_url 2026-3-28-Local-AI-Vibe-Coding %}): a couple of 3090s and an RX 6800 XT across a few machines, all running NixOS, with LiteLLM as a gateway and llamacpp as the inference backend.

For this project I used two models:

- **Qwen 3.6-27B** as the primary model for Open Design's design and coding workflow. 27B dense, multimodal, 262k context window. I run it on a single 3090 and it flies. 77.2% on SWE-bench Verified, competitive with models many times its size. For web design work, more than enough.
- **Gemma 4 26B-E4B** as a sub-agent on a separate machine. I use it for narrower scoped tasks that benefit from running in parallel: copy refinement, consistency checks, that kind of thing. Having two models running simultaneously through LiteLLM means I can keep the main workflow moving on Qwen while delegating smaller tasks without queueing.

The tool chain:

- [OpenCode](https://opencode.ai) as my agent harness, running on a home server accessible over my LAN
- Open Design wired into OpenCode as a skill layer
- LiteLLM proxying all requests to my local inference nodes

End result: I replicated Claude Code + Claude Design using only my own hardware. No API keys, no usage limits, no sending my design preferences to a third party.

## Open Design

[Open Design](https://github.com/nexu-io/open-design) is an open-source, local-first alternative to Anthropic's Claude Design. It doesn't ship its own agent. Instead, it detects whatever coding agent CLI you have on your PATH (Claude Code, OpenCode, Gemini CLI, Codex, etc.) and wires it into a skill-driven design workflow with composable design systems and structured prompts.

What I like about it is that it treats design as a discipline. It ships with 70+ brand-grade design systems (Linear, Stripe, Vercel, etc.), structured skill templates for different output types (landing pages, dashboards, mobile prototypes), and a five-dimensional self-critique system that catches common AI design mistakes before they reach you.

It's still being polished. I ran into some rough edges around skill template defaults and had to iterate a few times to get the output to match my existing brand tokens. But it works, it's moving fast, and the conversational approach to web design works better than I expected. You describe what you want, pick a visual direction, and get structured output with proper design tokens and responsive layouts. For getting a polished prototype from a description to working HTML in minutes, I haven't found anything else that comes close. It won't replace Figma for complex design work.

## Qwen 3.6-27B

Worth calling out separately because this model caught me off guard.

Qwen 3.6-27B is a 27B dense model with a 262k context window, multimodal capabilities, and a hybrid architecture that mixes gated DeltaNet layers with traditional attention. It scores 77.2% on SWE-bench Verified and 59.3% on Terminal-Bench 2.0, which puts it in the same conversation as models 10x its size.

What mattered for this project:

It understood my existing brand spec (colors, typography, spacing) and applied it consistently across multiple layouts without being told twice. The CSS it writes is clean: proper custom properties, clamp() for responsive type scales, logical property grouping, no inline style soup. With a 262k window it held the full context of my prototype files, existing posts, and brand spec at the same time; I never had to re-paste anything. And on a single 3090, it generates fast enough that the design iteration loop feels like a conversation rather than a compile step.

I've been running Qwen models since the 2.5 days. Each generation has been a clear step up at the things I actually need: following design instructions, maintaining consistency across files, and producing output that doesn't need to be completely rewritten.

## The design workflow

I've loved graphic design and web development since I was a kid. I remember prototyping web designs in Photoshop when I was 12. To this day I use tools like Penpot (the open-source, self-hosted Figma alternative) to visualize design ideas before I build anything. I'm fiercely protective of the traditional graphic design workflow: mood boards, type exploration, color studies, iterative refinement. That process exists for a reason.

So I was skeptical of the conversational approach. What I found is that Open Design doesn't skip the design process, it structures it. Before generating anything, it walks through a discovery form that locks down the brief: surface, audience, tone, brand context. Then you pick from curated visual directions with deterministic palettes and font stacks. The model works within guardrails rather than freestyling.

The output wasn't perfect out of the box. I still needed to refine spacing, adjust the type scale, and tighten up some responsive breakpoints. But it got me to a 90% solution in a fraction of the time it would have taken from a blank canvas, and the structured approach meant I could iterate on specific decisions (change this color, adjust this radius) without the model going off the rails on unrelated elements.

I'll continue to use this tool.

## What changed

For anyone reading this on the actual site: the whole thing was rebuilt. New layouts, new CSS, new about page, updated dependencies. Jekyll 4.4, proper SEO plugins, web manifest, lazy loading. The blog post content stayed the same, but the presentation layer is entirely new.

The full source is at [github.com/clairesrc/clairesrc.github.io](https://github.com/clairesrc/clairesrc.github.io) if you want to poke around.
