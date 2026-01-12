# At the time of writing, the WiFi chip that comes with frame.work computers prevents the system from falling asleep
# A workaround that seems to work is to just disable the WiFi driver on sleep, at least on the LTS kernel.
# In addition to this, perhaps disabling some power management feature will prevent the system from hanging?
# See https://forum.garudalinux.org/t/mediatek-mt7925e-wifi-speed-very-slow-on-close-to-fresh-install-and-some-updates/41845/
{ config, pkgs, ... }: {
	systemd.services.mt7925e-suspend-workaround = {
		enable = true;
		description = "Unload mt7925e driver on suspend";
		before = [ "suspend.target" "hibernate.target" ];
		wantedBy = [ "suspend.target" "hibernate.target" ];
		# If niether suspend.target nor hibernate.target is active, ExecStop should be called
		unitConfig.StopWhenUnneeded = "yes";
		serviceConfig = {
			Type = "oneshot";
			StandardOutput = "syslog";
			RemainAfterExit = "yes";
			ExecStart = "modprobe -r mt7925e";
			ExecStop = "modprobe mt7925e";
		};
	};
}
