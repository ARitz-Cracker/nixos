# nvidia config for desktop computers
{ config, lib, pkgs, ... }:
{
	hardware.nvidia = {
		# nvidia seems to reccommend prod or beta for 20-series and 40-series.
		# package = config.boot.kernelPackages.nvidiaPackages.production;
		package = config.boot.kernelPackages.nvidiaPackages.beta;

		# Modesetting is required.
		modesetting.enable = true;

		# Nvidia power management. Experimental, and can cause sleep/suspend to fail.
		# Enable this if you have graphical corruption issues or application crashes after waking
		# up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
		# of just the bare essentials.
		powerManagement.enable = false;

		# Fine-grained power management. Turns off GPU when not in use.
		# Experimental and only works on modern Nvidia GPUs (Turing or newer).
		powerManagement.finegrained = false;

		# https://unix.stackexchange.com/questions/799102/nvidia-proprietary-vs-open-drivers-differences
		# According to the above, there shouldn't be any functional difference between nvidia's open drivers and the
		# closed one. I'll have to experiment what works best.
		open = false;

		# Enable the Nvidia settings menu,
		# accessible via `nvidia-settings`.
		nvidiaSettings = true;
	};
	# Enable OpenGL
	hardware.graphics = {
		enable = true;
	};
	# Load nvidia driver for Xorg and Wayland
	services.xserver.videoDrivers = ["nvidia"];
}
