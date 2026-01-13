{ config, pkgs, ... }: {
  imports = [
		./_common.nix
	];
	environment.systemPackages = with pkgs; [
		wineWowPackages.unstableFull
	];
}
