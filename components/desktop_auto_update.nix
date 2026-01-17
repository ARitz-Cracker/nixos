{ config, pkgs, ... }: {
	system.autoUpgrade = {
		enable = true;
		# flags = [];
		dates = "daily";
		randomizedDelaySec = "60min";
		operation = "boot";
		allowReboot = false;
	};
	# Ideally this wouldn't be on a timer, but I'm not sure how to make a user service that triggers when a system
	# serice completes. Ideally we'd start this when the nixos-upgrade.service finishes.
	systemd.user.timers.nixos-upgrade-notifier = {
		enable = true;
		wantedBy = [ "timers.target" ];
		timerConfig = {
			RandomizedDelaySec = 600;
			OnCalendar = "hourly";
			Persistent = true; 
		};
	};
	systemd.user.services.nixos-upgrade-notifier = {
		enable = true;
		after = [ "graphical.target" ];
		wantedBy = [ "graphical.target" ];
		description = "NixOS Upgrade Notifier Service";
		serviceConfig = {
			Type = "simple";
		};
		path = with pkgs; [
			coreutils # readlink
			libnotify # notify-send
			polkit # pkexec
			kdePackages.kdialog # self-explanatory
			kdePackages.qttools # qdbus
			nix
		];
		script = ''
#!/bin/sh
doChosenAction () {
	echo "do action $1"
	case "$1" in
	restart)
		qdbus org.kde.Shutdown /Shutdown logoutAndShutdown
		;;

	switch)
		dbusRef=$(kdialog --title "NixOS system upgrade" --progressbar "Applying upgrades..." 0);
		qdbus $dbusRef showCancelButton false
		if pkexec nixos-rebuild switch; then
			if [ "$current_kernel_image" = "$default_kernel_image" ]; then
				notify-send "--app-name=NixOS system upgrade" "Applications updated successfully." --icon=update-low
			else
				notify-send "--app-name=NixOS system upgrade" "Applications updated successfully." "Kernel and/or drivers will be upgraded on shutdown or restart." --icon=update-medium
			fi;
		else
			kdialog --title "NixOS system upgrade" --sorry "Applications were not updated.";
		fi;
		qdbus $dbusRef close;
		;;
	*)
		notify-send "--app-name=NixOS system upgrade" "Upgrade delayed" "System will complete upgrades on shutdown or restart." --icon=update-low
		;;
	esac
}

# the nixos generation currently running
current_system="$(readlink -f /run/current-system)";
current_kernel_image="$(readlink -f /run/current-system/{initrd,kernel,kernel-modules})"

# the generation that's set to run on restart
default_system="$(readlink -f /nix/var/nix/profiles/system)";
default_kernel_image="$(readlink -f /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

# "nixos-rebuild switch" may have been ran
booted_kernel_image="$(readlink -f /run/booted-system/{initrd,kernel,kernel-modules})"

echo "Checking..."
if [ "$current_system" = "$default_system" ]; then
	# The running system is equal to the default system, so no upgrades were done.
	echo "Current system is default"
	if [ "$booted_kernel_image" != "$current_kernel_image" ]; then
		echo "booted kernel is not current"
		# But the kernel's different, perhaps the system was up for a day
		doChosenAction $(
			notify-send "--app-name=NixOS system upgrade" \
				"Restart required" \
				"A pending kernel or driver upgrade requires a restart to be applied." \
				"--action=restart=Restart" \
				"--action=ignore=Dismiss" \
				--urgency=critical \
				--icon=system-restart-update
		);
	fi
	echo "No updates pending."
	exit 0;
fi;
echo "Getting changes..."
changes="$(nix store diff-closures /run/current-system /nix/var/nix/profiles/system --extra-experimental-features nix-command)";
echo "Got changes..."
update_msg="The following updates are available for your system:
---
$changes
";

if [ "$current_kernel_image" = "$default_kernel_image" ]; then
	echo "Update does not require reboot"
	# --urgency=critical appears to be the only level where the notifications don't disappear
	doChosenAction $(
		notify-send "--app-name=NixOS system upgrade" \
			"System upgrades available" \
			"$update_msg" \
			"--action=switch=Update" \
			"--action=ignore=Dismiss" \
			--urgency=critical \
			--icon=update-low
	);
else
	echo "Update requires reboot"
	doChosenAction $(
		notify-send "--app-name=NixOS system upgrade" \
			"System upgrades available" \
			"$update_msg
---
You may upgrade without restarting, but kernel and driver updates won't be applied." \
			"--action=restart=Restart" \
			"--action=switch=Upgrade apps only" \
			"--action=ignore=Dismiss" \
			--urgency=critical \
			--icon=update-high
	);
fi;
		'';
	};
}
