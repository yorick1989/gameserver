[![License](https://img.shields.io/github/license/yorick1989/gameserver?style=for-the-badge&color=green "License")](https://github.com/yorick1989/gameserver/blob/main/LICENSE)[![Amount of contributers](https://img.shields.io/github/contributors/yorick1989/gameserver?style=for-the-badge&color=blue "Amount of contributers")](https://github.com/yorick1989/gameserver/graphs/contributors)[![Amount of downloads](https://img.shields.io/github/downloads/yorick1989/gameserver/total?style=for-the-badge&color=blue "Amount of downloads")](https://github.com/yorick1989/gameserver)[![Forks](https://img.shields.io/github/forks/yorick1989/gameserver?style=for-the-badge&color=blue "Forks")](https://github.com/yorick1989/gameserver/forks)  \
[![Last commit](https://img.shields.io/github/last-commit/yorick1989/gameserver?style=for-the-badge "Last commit")](https://github.com/yorick1989/gameserver/commits/main)[![Latest tag](https://img.shields.io/github/v/tag/yorick1989/gameserver?style=for-the-badge "Latest Tag")](https://github.com/yorick1989/gameserver/tags)[![Latest release](https://img.shields.io/github/v/release/yorick1989/gameserver?style=for-the-badge "Latest release")](https://github.com/yorick1989/gameserver/releases/latest)[![State of the latest release build](https://img.shields.io/github/actions/workflow/status/yorick1989/gameserver/release.yml?style=for-the-badge "State of the latest release build")](https://github.com/yorick1989/gameserver/actions/workflows/release.yml) \
[![Commit activity](https://img.shields.io/github/commit-activity/m/yorick1989/gameserver?style=for-the-badge "Commit activity")](https://github.com/yorick1989/gameserver/graphs/commit-activity)[![Open issues](https://img.shields.io/github/issues/yorick1989/gameserver?style=for-the-badge "Open issues")](https://github.com/yorick1989/gameserver/issues)[![Open Pull Requests](https://img.shields.io/github/issues-pr/yorick1989/gameserver?style=for-the-badge "Open Pull Requests")](https://github.com/yorick1989/gameserver/pulls)

# Containerized gameservers

## Introduction
This repository maintains gameservers that run in containers. It's only tested with (unprivileged) Podman.

### Supported gameservers
| Game | Pull URL | Note |
| :---: | :---: | :---: |
| [Loya](https://store.steampowered.com/app/2271150/Loya/) | [ghcr.io/yorick1989/gameserver:loya](ghcr.io/yorick1989/gameserver:loya) | This gameserver runs in Wine because, at this moment, the gameserver is only supported for Windows |

### The state of this project
I will add/update gameservers on my own pace. Feel free to contribute to the repository.

## Installation
You can use this application by compiling it yourself or use the container image instead.

### Compilation
You can compile the application by downloading this repository and run the `make all` command.

### Container image
You can download the container image and run the server with, for example, `podman`:
```bash
podman run \
 -ti --rm --replace \
 --pull newer \
 --name gameserver \
 --env STEAMCMD_LOGIN \
 --volume ${GS_PATH:-./loya}:/gameserver/loya:rw \
 --userns keep-id \
 --publish "${GS_IP:-0.0.0.0}:${GS_PORT:-15010}:15010" \
 ghcr.io/yorick1989/gameserver:loya
```

## Automatically update and start with OS
In case you're using `podman`, make sure you create a user on your server that is allowed to run containers using `podman`. In the following instructions we will use `gameserver` as the user that will run the container.

If necessary, create an environment variables file for the SystemD unit file (as root).
```bash
cat << EOF > ~gameserver/.gameserver-loya.env
STEAMCMD_LOGIN="steamcmd_username steamcmd_password"
GS_PATH=~gameserver/loya
EOF
```

Install the `systemd` unit file with the following command (as root):
```bash
cat << 'EOF' > /etc/systemd/system/gameserver-loya.service && systemctl daemon-reload && systemctl --now enable gameserver-loya.service
[Unit]
Description=Loya gameserver
After=network-online.target
     
[Service]
Type=exec
User=gameserver
Restart=always
RestartSec=60
EnvironmentFile=/home/gameserver/.gameserver-loya.env
ExecStart=/bin/bash -c "/usr/bin/podman run \
    -ti --rm --replace \
    --pull newer \
    --name gameserver \
    --env STEAMCMD_LOGIN \
    --volume ${GS_PATH:-/home/gameserver/gameservers/loya}:/gameserver/loya:rw \
    --userns keep-id \
    --publish "${GS_IP:-0.0.0.0}:${GS_PORT:-15010}:15010" \
    ghcr.io/yorick1989/gameserver:loya"
ExecStop=/usr/bin/podman stop gameserver --ignore
ExecStopPost=/usr/bin/podman system prune \
    --filter "label=org.opencontainers.image.title=Loya gameserver" \
    --force

[Install]
WantedBy=multi-user.target
EOF
``` 

### Available options for the application

#### Loya gameserver
| Option | Default | Description |
| :---: | :---: | :---: |
| --name | Default | The name of the world (leave this as-is) |
| --ip | 0.0.0.0 | The gameserver bind IP address (leave this as-is) |
| --port | 15010 | The gameserver port (leave this as-is) |
| --description | Default world. | The (host)name of the world |
| --difficulty | 1 | The difficulty |
| --worldsize | 1000.0 | The world size |
| --visibility | 2 | The gameserver visibility |

## Contact
[![My Discord](https://img.shields.io/badge/My-Discord-%235865F2.svg)](https://discord.com/users/370120292665917443)
