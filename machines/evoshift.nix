# Evoshift, my 2025 Framework 16. 
{ config, pkgs, ... }: {
	imports = [
		./_common.nix
		../components/boot/secure.nix
		# The latest kernel seems eventually hang anything that touches the network stack for some reason.
		# This creates the annoying scenario where wpa-supplicant and NetworkManager freeze in a way where SIGKILL
		# doesn't save me. Maybe the mt7925e is to blame?
		../components/kernel/lts.nix
		../components/avahi.nix
		../components/desktop_devtools.nix
		../components/desktop.nix
		../components/devtools.nix
		../components/spotify.nix
		../components/steam.nix
		../components/hardware_workarounds/framework_input_modules.nix
		../components/hardware_workarounds/framework_keyboard.nix
		../components/hardware_workarounds/mt7925e.nix
		../components/hardware_workarounds/qmk.nix
	];
	networking.hostName = "evoshift";
	users.users.aritz = {
		isNormalUser = true;
		description = "Aritz Beobide-Cardinal";
		extraGroups = [ "networkmanager" "wheel" "dialout" ];
		packages = with pkgs; [];
	};
}
