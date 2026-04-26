build_loya_ubuntu:
	podman build -f ./Containerfile-loya_ubuntu  -t ghcr.io/yorick1989/gameserver:loya-ubuntu

build_loya:
	podman build -f ./Containerfile-loya  -t ghcr.io/yorick1989/gameserver:loya

run_loya:
	podman run -ti --rm --name "gameserver-loya" --env STEAMCMD_LOGIN --volume $${GS_PATH:-./loya}:/gameserver/loya:rw --userns=keep-id --publish "$${GS_IP:-0.0.0.0}:$${GS_PORT:-15010}:15010" ghcr.io/yorick1989/gameserver:loya

gs_loya: build_loya run_loya

all: gs_loya

.PHONY: all
