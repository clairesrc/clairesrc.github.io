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
