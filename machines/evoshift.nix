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
		../components/shared_libs.nix
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
	environment.systemPackages = with pkgs; [
		s3fs
		discord
	];
	swapDevices = [{
		device = "/var/lib/swapfile";
		size = 72 * 1024; # 72 GB
	}];
	# Enable hibernation
	boot.kernelParams = [
		# location of /var/lib/swapfile
		"resume_offset=282624"
	];
	boot.resumeDevice = "/dev/disk/by-uuid/85d4b4c8-9f75-4b3d-bb53-2a22aaa295f3";
	powerManagement.enable = true;
}
