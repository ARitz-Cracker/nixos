# This represents what I expect for a non-server to have, DE, apps, etc.
{ config, pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		eza
		discord # Should I just use the flatpak version?
		chezmoi
		thunderbird
		obsidian
		chromium
		# KDE
		kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
		kdePackages.kcalc # Calculator
		kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
		kdePackages.kclock # Clock app
		kdePackages.kcolorchooser # A small utility to select a color
		kdePackages.kolourpaint # Easy-to-use paint program
		kdePackages.ksystemlog # KDE SystemLog Application
		kdePackages.sddm-kcm # Configuration module for SDDM
		kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
		kdePackages.partitionmanager # Optional: Manage the disk devices, partitions and file systems on your computer
		kdiff3 # Compares and merges 2 or 3 files or directories
		# Non-KDE graphical packages
		hardinfo2 # System information and benchmarks for Linux systems
		vlc # Cross-platform media player and streaming server
		wayland-utils # Wayland utilities
		wl-clipboard # Command-line copy/paste utilities for Wayland
		lshw-gui
		dmidecode
	];
	# Install firefox.
	programs.firefox.enable = true;

	# Enable the X11 windowing system.
	# You can disable this if you're only using the Wayland session.
	services.xserver.enable = true;

	# Enable the KDE Plasma Desktop Environment.
	services.displayManager.sddm.enable = true;
	services.displayManager.sddm.wayland.enable = true;
	services.desktopManager.plasma6.enable = true;
	services.desktopManager.plasma6.enableQt5Integration = true;

	# Configure keymap in X11
	services.xserver.xkb = {
		layout = "us";
		variant = "";
	};

	# Enable CUPS to print documents.
	services.printing.enable = true;

	# Enable sound with pipewire.
	services.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;

		# use the example session manager (no others are packaged yet so this is enabled by default,
		# no need to redefine it in your config for now)
		#media-session.enable = true;
	};

	# Enable discover with flatpak
	services.flatpak.enable = true;

	# All the blobs!
	services.fwupd.enable = true;
	
	# Make flatpak apps work
	xdg.portal = {
		wlr.enable = true;
		enable = true;
	};
	environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
}
