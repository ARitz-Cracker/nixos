# Unrelenter, est. 2023.
# - R9 7950X3D
# - 64 GiB of RAM
# - RTX 4090
{ config, pkgs, ... }: {
	imports = [
		./_common.nix
		../components/boot/secure.nix
		../components/kernel/latest.nix
		../components/avahi.nix
		../components/desktop_auto_update.nix
		../components/desktop_devtools.nix
		../components/desktop.nix
		../components/devtools.nix
		../components/nvidia.nix
		../components/shared_libs.nix
		../components/spotify.nix
		../components/steam.nix
		../components/hardware_workarounds/keychron.nix
		../components/hardware_workarounds/qmk.nix
		../components/wine/development.nix
	];
	networking.hostName = "unrelenter";
	users.users.aritz = {
		isNormalUser = true;
		description = "Aritz Beobide-Cardinal";
		extraGroups = [ "networkmanager" "wheel" "dialout" "libvirtd" ];
		packages = with pkgs; [];
	};
	environment.systemPackages = with pkgs; [
		jdk
		go # need this to isntall packwiz
		s3fs
	];
	networking.firewall.allowedTCPPorts = [ 25565 ];
	networking.firewall.allowedUDPPorts = [ 25565 ];
	boot.kernelParams = [
		# The Intel I225 2.5G LAN on my Asus ROG STRIX X670E-E likes to kill itself after a couple hours without
		# these params. While that was with Debian 13, I doubt things have changed much since then.
		"pcie_port_pm=off"
		"pcie_aspm.policy=performance"
	];
}
