#### Ollama + Open WebUI using an AMD card on NixOS 

I've been experimenting with local LLMs recently, and one of my test setups has been on a NixOS box running an AMD RX 6800XT.

For a long time I had assumed LLMs were only really practical on Nvidia cards, but I was wrong -- modern LLM environments support ROCM just fine.

Here's what I needed to add to my system configuration in order to get a fully-featured LLM workstation using AMD hardware on NixOS:

```
  services.ollama = {
    enable = true;
    loadModels = [
      "qwen3:14b"
      "nomic-embed-text"
      ];
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0";
  };
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
  };
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    ];
  nixpkgs.config.rocmSupport = true;
  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.amdvlk.enable = true;
  services.xserver.videoDrivers = [ "radeon" ];
```

After applying the above changes I pulled up http://localhost:8080 and set up Open Web UI. 
I was able to run a test conversation with the model I'd asked it to preload:
<img width="100%" alt="screenshot of open webui set up correctly" src="https://github.com/user-attachments/assets/630b23b1-6806-432d-b7a8-4f85d76646a0" />

After a short test conversation, I was able to use `btop` and `ollama ps` to confirm the inferencing was running on my GPU, not the CPU: 
<img width="100%" alt="screenshot of system dashboard and ollama process metrics indicating the AI workload is running on the GPU" src="https://github.com/user-attachments/assets/4f59cef4-c45d-4bf2-8d6e-3a583ca85398" />
