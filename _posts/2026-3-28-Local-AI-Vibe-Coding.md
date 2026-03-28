# Vibe coding a full-stack app without the cloud
## Self-hosted AI on consumer hardware with NixOS

OK, “consumer hardware” is a stretch. I have more GPU horsepower than most consumers do:

- A 3090 I bought around the time of its initial release, because I wanted a future-proofed card to play games on
- An RX 6800 XT I bought a few years later for my Linux workstation after I settled into started working from home full-time
- And most recently, a second 3090 I bought to help balance my AI workloads.

Especially after the latest round of price hikes, the economic benefits of running a setup like this over just paying a monthly cloud fee are dubious. But I’m not really in it for the money. 

## The tipping point

I’ve been an enthusiastic user of free and open-source software — from my servers to my laptop — for nearly twenty years. When LLMs first stated to get good, I was pretty dismissive because it seemed unlikely that we’d ever be able to run anything comparable on our own hardware. Eventually, LLMs became so good that I couldn’t resist trying the major coding agent tools from Google and Anthropic. They were, and continue to be, a mixed bag: even on the most expensive models, they still make mistakes and require human oversight to guide their decisions and validate their work, although they do get better with every new release. Getting a better idea of the tradeoffs at the highest-end helped me keep my expectations grounded, and understand that even though some babysitting is required, there really is an “80/20” window where it becomes worth the trouble, past a certain threshold.

So the question is: has open-source AI on commodity hardware reached that threshold yet?

To answer this question, I decided to put my best foot forward. I’ll hook up my OpenCode harness to my local llamacpp instance, and have it generate something I’m sure has already been demonstrated and documented to death in these models’ training data: a full-stack Python web app for language learning, augmented with AI-generated illustrations and TTS pronunciation samples, created entirely using the GPUs I have at home.

## The stack

When I had less GPU compute available, I had to hot-swap between models and inference runtimes just to be able to get the full spectrum of capabilities for text, vision, sound and image generation. But with 3 somewhat-high-end cards to distribute the loads across, I’m able to serve all models simultaneously through a gateway like LiteLLM, which makes the overall process a lot faster and more reliable.

<img alt="Getting my money's worth out of my 3090s" src="https://github.com/user-attachments/assets/dcdaa80f-b479-467c-b98f-b6860838e7b1" />

### Models

- Code: qwen3.5-35b-a3b, running on llamacpp across both GPUs, 200k context window. I found this provided the best output quality while still running very quickly and preserving a sufficient amount of context for coding tasks. Using unsloth’s Q6 quantized gguf so that I can keep the entire model loaded in vram.
- Vision: Ditto. Since qwen3.5-35b-a3b is multimodal, I get image recognition for free. It performs quite well and doesn’t appear to carry the “vision tax” on text output quality that used to be a major concern with multimodal models.
- TTS: qwen3-tts for realistic, reasonably fast speech synthesis with tight control over expressiveness, locution, and other voice details. If latency were a greater concern I would swap this out for KokoroTTS which runs much faster at the cost of less realistic sounding voices.
- Image generation: qwen-image-2511, mainly because it fits and runs on the RX 6800 XT and is generally good enough for images that don’t involve text (drawing text is still pretty challenging for these smaller diffusion models). Still waiting for the open-weights release of the next-gen Qwen image models which seem to offer a generational leap. Another good option, if I had more VRAM to spare, would be Flux Klein 2 which excels at photorealistic images with great prompt adherence. 

### Software

- OS: This doesn’t really matter, as long as it’s Linux 😉 I find NixOS provides a huge step up in granting AI agents the ability to experiment with and iterate over a system’s software setup, so to my NixOS is indispensable if I want to be able to move fast.
- Inference: llamacpp —  this is what “runs” my models on my GPUs. vLLM looked compelling as well, but may be overkill for what I have… And from what I can see, it seems considerably more complicated. For a while I ran everything through Ollama but grew frustrated with its relative delay in supporting the newest cutting-edge models, as well as its lack of configurability compared to alternatives. I found llama.cpp provides the best balance between ease of use for small-scale self-hosters like myself and flexibility.
  Llamaswap provides a nice layer above llamacpp to allow me to dynamically switch the model parameters at runtime. I can easily swap between a faster Instruct configuration and a slower but more thorough thinking/reasoning mode, on the same base model, which grants a lot of flexibility.
- API gateway and reverse proxy: LiteLLM (yes, I know about the security compromise and no, fortunately I never ran an affected version) and nginx. LiteLLM makes it easy to provide a single entry point for all kinds of different types of AI workloads across all modalities. You can expose locally-hosted and paid/hosted models alike, and routing them through this interface allows you to take advantage of observability solutions like LangFuse pretty painlessly. 
- Some glue code to proxy between the APIs exposed by Qwen’s TTS and image generation stacks and LiteLLM. LiteLLM exposes a standard OpenAI-compatible API, and expects its upstream routes to be exposed in the same way. Some AI stacks are not designed for that particular API, which means you have to write a simple proxy layer to ensure everything is hooked up correctly. This sounds worse than it really is, in reality it’s mainly just passing along some base64 and json and the proxy code itself can be generated in a matter of minutes by basically any coding agent out there.
- Agent harness: I like OpenCode because it provides a polished Web UI that I can run on one of my home servers using systemd, expose to my LAN and access remotely over my VPN for session continuity across devices and networks. When I leave the house, I like to bring my iPad with me, as it includes a VPN client and allows me to keep vibe coding on-the-go. You can imagine my friends and family think it’s hilarious. A good agent harness for coding tasks is critical: while chat UIs like Open-WebUI also provide “terminal usage” tools, you really do need features like dynamic context compaction in order to empower your local model to see through a relatively “long-horizon” task like this to completion. <img alt="OpenCode" src="https://github.com/user-attachments/assets/c6315496-062d-4868-98e2-38dedb752134" />
- Barking orders into my computer, because typing is so 2010s: Due to the dialectical nature of vibe coding and the near-instant feedback it brings, I have sometimes found typing speed to be my biggest bottleneck. It feels sort of silly, because I put a lot of research into the mechanical keyboards rabbit hole, only so that I could render my keyboard collection largely obsolete. I built an extension for Vicinae (an app launcher for Linux that is designed for compatibility with Raycast) which allows me to run speech recognition using the Parakeet instance on my AI cluster over the network: <https://github.com/clairesrc/whisper-dictation-remote> Parakeet tends to perform better and faster than Whisper, and it does a pretty good job at recognizing my programmer jargon.

## What Qwen built

Recently a family member expressed interest in learning French. I decided to have my local Qwen models create a custom app tailored to their needs for use as a study aid.

I intentionally gave it a vague prompt so I could see how well it could decipher my requirements and determine the correct acceptance criteria. I didn’t bother to review the generated code too closely since I understand vibe coding is best for functional prototypes rather than production-ready apps. Considering that, I actually think it came up with something pretty impressive: 

<img alt="It runs and does what I asked it to do" src="https://github.com/user-attachments/assets/4cfefaa0-4d38-4620-9f93-f8fc8dde07cf" />

You can check the source here if you’re inclined: <https://github.com/clairesrc/french-study-aid>

Of course, a quick look at the source code shows us how unpolished this really is — lots of hardcoded magic and vendored libraries for no reason, which is typical from a relatively dumb AI model operating with insufficient direction. Due to a limitation of my setup (I only bothered to set up 1 voice in qwen3-tts) all the generated audio is spoken with an American accent rather than as if it were from a real Francophone, which renders the TTS feature basically pointless. And the AI images just aren’t very good, both in terms of how well they represent a given concept and in terms of how the image works. However, it is easy to imagine a more polished overall experience given some additional time and effort towards providing adequate guidance to the model.

## So, can you replace Claude Code with this setup? My impression

For many AI tasks, I think we’re getting pretty close. 

Speech recognition and synthesis are where I’ve been most impressed: Parakeet has been an excellent solution for quickly transcribing audio, and I’m consistently impressed with the realistic output from Qwen3-TTS. 

As far as my needs are concerned, summarization, classification, and most vision tasks are a solved problem as well. In my experience, modern language models in the “small to medium” size class (say under 70b) can substitute paid cloud providers for those specific types of workloads in many situations.

For code… Of course, GLM-5, Kimi K2.5 etc are the super-star open-source LLMs right now, but looking at their sizes…. Yeah, I’m not running those on my home cluster, But what about the smaller parameter sizes or lower quants? The recent Qwen3.5 release is very exciting; the variety of parameter sizes and MOE architecture availability gives a lot of flexibility for maximizing the output quality you can get out of a consumer graphics card. Open source inference runtimes like llamacpp and vllm make it possible to optimize to your heart’s content with tensor parallelism and CPU offloading. 

<img alt="Let's be honest: this isn't great" src="https://github.com/user-attachments/assets/8b216c1f-c8de-4ad1-944c-892d90bd4d35" />

Image generation is where I’m least impressed as the resource demands for a high-quality model go beyond what I can reasonably run at home alongside everything else. But even then, it’s often good enough, particularly if you generate several candidates and have your vision model pick the best one.

Overall: I’m not going to be canceling my hosted code agent subscriptions yet. The skill and reasoning gap between something like Claude Opus 4.6 and my relatively tiny Qwen is immediately apparent. But, I do think we’re at a point where I *could* run sub-agents with more clearly-scoped tasks with my local model. Local qwen3.5 is good enough as a code monkey, you just have to prompt it correctly. This would provide the benefit of solving well-defined problems orchestrated by a larger hosted model while reducing the overall spend on input and output tokens from the hosted provider — a win any way I look at it. 

Of course… even the highest-quality, state of the art hosted models still struggle with CSS inheritance, as well as with writing comments that are actually useful. You can probably see from my screenshots that this is also the case for my local model.

I don’t like to make bets based on future promise. I evaluate a technology based on what it can do today. And as of today, the usefulness of AI, local or not, is undeniable, even though it’s not perfect.

I hope you’ve enjoyed this tour through my local/self-hosted AI setup. Have you tried solutions I didn’t consider here? Do your experiences of vibe coding with a local model differ from mine? Send me your impressions and reactions over Email or Linkedin.
