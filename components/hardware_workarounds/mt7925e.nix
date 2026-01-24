{ config, pkgs, ... }: {
	# At the time of writing, the WiFi chip that comes with frame.work computers prevents the system from falling asleep
	# A workaround that seems to work is to just disable the WiFi driver on sleep, at least on the LTS kernel.
	systemd.services.mt7925e-suspend-workaround = {
		enable = true;
		description = "Unload mt7925e driver on suspend";
		before = [ "suspend.target" "hibernate.target" ];
		wantedBy = [ "suspend.target" "hibernate.target" ];
		# If niether suspend.target nor hibernate.target is active, ExecStop should be called
		unitConfig.StopWhenUnneeded = "yes";
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = "yes";
			ExecStart = "${pkgs.kmod}/bin/modprobe -r mt7925e";
			ExecStop = "${pkgs.kmod}/bin/modprobe mt7925e";
		};
	};
	# Additionally, the driver is apparently just completely broken on 6.12.x and 6.18.x.
	# Zac Bowling amazingly worked on some patches, but they haven't been merged upstream yet. He's not sure if his
	# patches fix the sleep issue, so I'm keeping the above workaround for now.
	# See https://community.frame.work/t/kernel-panic-from-wifi-mediatek-mt7925-nullptr-dereference/79301
	# TODO: This would go a lot faster if I built the DKMS instead, I should figure out how to do that.
	# See https://github.com/zbowling/mt7925/tree/main/dkms
	boot.kernelPatches = [
		{
			name = "0001-wifi-mt76-mt7925-fix-potential-deadlock-in-mt7925_ro.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0001-wifi-mt76-mt7925-fix-potential-deadlock-in-mt7925_ro.patch";
				sha256 = "sha256-gKXixC+7avlJKO0fdp0QV9sNS5gOtD9OW9gdRHLwRnI=";
			};
		}
		{
			name = "0002-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0002-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
				sha256 = "sha256-i5ZnuWqds9MoZSMPnNsC7s1amR3Kc5nSvYax7WRbwSA=";
			};
		}
		{
			name = "0003-wifi-mt76-mt792x-fix-NULL-pointer-and-firmware-reloa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0003-wifi-mt76-mt792x-fix-NULL-pointer-and-firmware-reloa.patch";
				sha256 = "sha256-oid8kSIWYqahkhV4myy6sP+jMI1SMHyRDrKLdZ7FVCg=";
			};
		}
		{
			name = "0004-wifi-mt76-mt7921-add-mutex-protection-in-critical-pa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0004-wifi-mt76-mt7921-add-mutex-protection-in-critical-pa.patch";
				sha256 = "sha256-iRRqJ0E06Df0rUz3pyxXeMPzeRn89L2qZxdCI66gsG0=";
			};
		}
		{
			name = "0005-wifi-mt76-mt7925-add-comprehensive-NULL-pointer-prot.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0005-wifi-mt76-mt7925-add-comprehensive-NULL-pointer-prot.patch";
				sha256 = "sha256-BfO4HEeWxGNXx7efPaFFcbAGkcMQCbN0nAzUhrlxrB8=";
			};
		}
		{
			name = "0006-wifi-mt76-mt7925-add-mutex-protection-in-critical-pa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0006-wifi-mt76-mt7925-add-mutex-protection-in-critical-pa.patch";
				sha256 = "sha256-cUlQoyUrRZUuRXpkLV7gcvQWgWTjC9WmXuvujWhFPtU=";
			};
		}
		{
			name = "0007-wifi-mt76-mt7925-add-MCU-command-error-handling.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0007-wifi-mt76-mt7925-add-MCU-command-error-handling.patch";
				sha256 = "sha256-08/86bLgmXH3BYw4VgwK0L3hwB130feR8qeKtawGgXU=";
			};
		}
		{
			name = "0008-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0008-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
				sha256 = "sha256-kJSCoYNqkeUVwGuyaUzcEHGMYxIaZSF4kK8kzJSYYJQ=";
			};
		}
		{
			name = "0009-wifi-mt76-mt7925-fix-MLO-roaming-and-ROC-setup-issue.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0009-wifi-mt76-mt7925-fix-MLO-roaming-and-ROC-setup-issue.patch";
				sha256 = "sha256-+pHxkdw8iFDUfQYILdvFGW++uL5j53j1/S0Emw4qLe4=";
			};
		}
		{
			name = "0010-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0010-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
				sha256 = "sha256-QJJgewPxRTqaMvhRTQ5tXFe6sNx7eVtBu7k+rWSnVk4=";
			};
		}
		{
			name = "0011-wifi-mt76-mt7925-fix-ROC-deadlocks-and-race-conditio.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0011-wifi-mt76-mt7925-fix-ROC-deadlocks-and-race-conditio.patch";
				sha256 = "sha256-8bRFyCCZ3AZuWkwDTGfeS8U/3o0pCRRX/PeY2nx4OCo=";
			};
		}
		{
			name = "0012-wifi-mt76-mt7925-fix-double-wcid-initialization-race.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/a00b48b86fc230437e88a798719b27631df18e9a/kernels/6.18/0012-wifi-mt76-mt7925-fix-double-wcid-initialization-race.patch";
				sha256 = "sha256-Ro4zxZ162iPNi20Kkwk5qWrqqpx7XuUfC+O+EFg78dY=";
			};
		}
	];
}
