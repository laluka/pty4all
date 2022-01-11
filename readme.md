# pty4all

Hey mate, are you:

- Tired of shitty reverse shell?
- Tired of hittinc ^C and loosing your shell?
- Tired of overcomplicated C2?
- In need of a real pty with auto completion and signals?
- In need of a minimalistic payload that spawns a shell?
- In need of easy-peasy persistancy?

Say no more, `pty4all` got you all covered!

By using its cutting edge technology (lolnope), you can now have a persistent multi reverse pty handler!


# Usage

```bash
./socat-multi-handler.sh                                                                                                                                                           130 ↵
# Usage : ./socat-multi-handler.sh --lhost <LHOST> --lport <LPORT> --webport <WEBPORT> [--dnotify <WEBHOOK> ] [--persist]
# Demo 1: ./socat-multi-handler.sh --lhost X.X.X.X --lport 443 --webport 80
# Demo 2: ./socat-multi-handler.sh --lhost X.X.X.X --lport 443 --webport 80 --dnotify https://discord.com/api/webhooks/XXXX/YYYY --persist
```


# Demo

TODO youtube link


# Features

- Fully interactive pty (socat)
- Persistent handler on host (tmux)
- Fully encrypted (self signed https)
- Minimalistic payload (python, curl)
- Persistency on victim (pgrep, crontab)
- Stealth-ish (crontab trick & space before commands to prevent history)
- Push notification (Discord webhook)


# Requirements

- Target must be x64 unix-based with curl installed
- Host must have socat, tmux, python, openssl, and curl installed: `sudo apt update && sudo apt install -y socat tmux curl python openssl`
