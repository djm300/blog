update-theme:
	git submodule update --remote --merge

build:
	hugo build

serve:
	hugo serve
