# DisplayLink is a magical technology to be able to use displays through a non-display connection, like USB or ethernet
# Drivers for it are absolutely propiatary tho, first time you run nixos-rebuild you gotta accept the EULA.
# Only seems to work with the Linux v6.12 at the time of writing
{ config, pkgs, ... }: {
	boot = {
	extraModulePackages = [ config.boot.kernelPackages.evdi ];
		initrd = {
			kernelModules = [
				"evdi"
			];
		};
	};
	environment.systemPackages = [
		pkgs.displaylink
	];
	# The Displaylink package needs a custom-defined service for some reason
	systemd.services.displaylink-server = {
		enable = true;
		# Ensure it starts after udev has done its work
		requires = [ "systemd-udevd.service" ];
		after = [ "systemd-udevd.service" ];
		wantedBy = [ "multi-user.target" ]; # Start at boot
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
			User = "root";
			Group = "root";
			Restart = "always";
			RestartSec = 5; # Wait 5 seconds before restarting
		};
	};
}
