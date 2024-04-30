## Fixing audio delays in desktop Linux

I've been experiencing a weird issue lately with several of my Arch Linux desktop machines: a short delay when audio starts playing. It appears to persist across different desktop environments and sound outputs so I suspect there is a software issue somewhere.

The source still isn't clear to me and I tried various solutions I'd looked around online for but they didn't help. Eventually I found this post: https://unix.stackexchange.com/questions/362223/short-audio-playback-is-muted-requires-warming-up-or-secondary-audio-in-backgro

I hate that this is what it came to, but I can only hope it can get fixed upstream.

Install sox: `sudo pacman -S sox`

Paste this into the file `~/.config/systemd/user/continuous-silence.service`:
```
[Unit]
Description=Continuous silence

[Service]
ExecStart=/usr/bin/play -qn

[Install]
WantedBy=default.target
``` 

Run: `systemctl --user enable --now continuous-silence`

That should do it. A horrible workaround, but the sound delay was getting really annoying as it disrupts the flow of videos I watch and music I play.

