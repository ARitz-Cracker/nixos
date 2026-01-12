{ config, pkgs, ... }:
{
	imports = [
		./_common.nix
	];
	boot.loader.systemd-boot.enable = true;
}
