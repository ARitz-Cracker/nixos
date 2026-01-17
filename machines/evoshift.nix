# Evoshift, my 2025 Framework 16. 
{ config, pkgs, ... }: {
	imports = [
		./_common.nix
		../components/boot/secure.nix
		# https://lore.kernel.org/all/20260102200315.290015-1-zbowling@gmail.com/T/#r010d4bf7c3d867178148254b46fa6ba2cbdef50a
		../components/kernel/latest.nix
		../components/avahi.nix
		../components/desktop_auto_update.nix
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
		extraGroups = [ "networkmanager" "wheel" "dialout" "libvirtd" ];
		packages = with pkgs; [];
	};
}
