{ config, pkgs, ... }: {
	imports = [
		./_common.nix
	];
	# Uses the latest LTS Linux kernel
	boot.kernelPackages = pkgs.linuxPackages;
}
