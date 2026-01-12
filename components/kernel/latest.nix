{ config, pkgs, ... }: {
	imports = [
		./_common.nix
	];
	# Uses the latest kernel
	boot.kernelPackages = pkgs.linuxPackages_latest;
}
