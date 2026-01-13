{ config, pkgs, ... }: {
  imports = [
		./_common.nix
	];
	environment.systemPackages = with pkgs; [
		wineWowPackages.stableFull # I think this is the "development" branch of wine?
	];
}
