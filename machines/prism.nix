# Prism, est. 2018?
# - Some Zen1 or Zen2 CPU, no TPM
# - 16GB of RAM
# - RTX 2060Super
{ config, pkgs, ... }: {
	imports = [
		./_common.nix
		../components/boot/insecure.nix
		../components/kernel/latest.nix
		../components/avahi.nix
		../components/desktop_auto_update.nix
		../components/desktop.nix
		../components/nvidia.nix
		../components/shared_libs.nix
		../components/spotify.nix
		../components/steam.nix
		../components/hardware_workarounds/keychron.nix
		../components/hardware_workarounds/qmk.nix
		../components/wine/development.nix
	];
	networking.hostName = "prism";
	users.users.snow = {
		isNormalUser = true;
		description = "Snow Lou";
		extraGroups = [ "networkmanager" "wheel" "dialout" ];
		packages = with pkgs; [];
	};
	boot.kernelParams = [];
}
