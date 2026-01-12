{ config, pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		gitFull
		rustup
	];
}
