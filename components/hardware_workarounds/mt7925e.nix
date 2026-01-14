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
	# I'm not sure if this is the "best" way to apply kernel patches, but it werks! Takes a long time to build, though.
	# I've only tried these patches on 6.18.4 so far via pkgs.linuxPackages_latest.
	boot.kernelPatches = [
		{
			name = "0001-wifi-mt76-mt7925-fix-NULL-pointer-dereference-in-vif.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0001-wifi-mt76-mt7925-fix-NULL-pointer-dereference-in-vif.patch";
				sha256 = "sha256-D0rzxdBcVdMlYHXCUw8ZzdCkZJekJcIzhC3WVBeVwYQ=";
			};
		}
		{
			name = "0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
				sha256 = "sha256-gOWJJxaHR5i0UMWWo51B6aAHEzCaBmatN+SeOyD7Yik=";
			};
		}
		{
			name = "0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
				sha256 = "sha256-fQA8vM5CSd+mUOXfuM6XSCx+JAe3AIRln8k+g6+ZCQQ=";
			};
		}
		{
			name = "0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-functions.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-functions.patch";
				sha256 = "sha256-tBtLs9luVFqVuH0vgCuTscgX3/6PrRnPZ/OOw485C4w=";
			};
		}
		{
			name = "0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-mlink.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-mlink.patch";
				sha256 = "sha256-SfxZfA2O+gN2Dzc9uBzFYvT6hwrX0r3+JLGxwK5r8YA=";
			};
		}
		{
			name = "0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-commands.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-commands.patch";
				sha256 = "sha256-SF0dOFCT9NXA4+g9jbntre6Gg+IYDMkup5FuA7Loce4=";
			};
		}
		{
			name = "0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-sta_add.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-sta_add.patch";
				sha256 = "sha256-RwbUOxiQCmtB8FWETdjNnvCjxCHwPMCe9LJSqyXoMXM=";
			};
		}
		{
			name = "0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-key-setup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-key-setup.patch";
				sha256 = "sha256-6nnMLxhA1hD0YHGQqoQAjg8eNxybBTb+qKmkPfd8YzI=";
			};
		}
		{
			name = "0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-chanctx.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-chanctx.patch";
				sha256 = "sha256-VdxvR3bvOxHj5zu9M5EcugeIR5dgYiRUvKWaZrUOGKU=";
			};
		}
		{
			name = "0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-path.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-path.patch";
				sha256 = "sha256-+NofU2q0XKzqos+ntXsXgdNU0ysEyBVtFjisQfh6cyY=";
			};
		}
		{
			name = "0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
				sha256 = "sha256-9B0GzRFH7vNrkYb9F2ApbPoz1jLlhO3Jf9MIGTmiV7k=";
			};
		}
		{
			name = "0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
				sha256 = "sha256-/+w6PsJjW08hX8a7OC9Q95bNRNqYQ5KwnVNjUDPX3lQ=";
			};
		}
		# These 3 patches seem to fail on linux-6.18.4
		# {
		# 	name = "0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
		# 	patch = pkgs.fetchurl {
		# 		url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
		# 		sha256 = "sha256-8lxoOVmXWDKlD5Oi/yzi7GC7wazXdth24YkRsCpsgPo=";
		# 	};
		# }
		# {
		# 	name = "0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointers-in-MCU.patch";
		# 	patch = pkgs.fetchurl {
		# 		url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointers-in-MCU.patch";
		# 		sha256 = "sha256-ZYxADmS+ravwuFajpXzaHxsZhrzHx7Nvti+xuUDK9ds=";
		# 	};
		# }
		# {
		# 	name = "0015-wifi-mt76-mt792x-fix-firmware-reload-after-failed-load.patch";
		# 	patch = pkgs.fetchurl {
		# 		url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0015-wifi-mt76-mt792x-fix-firmware-reload-after-failed-load.patch";
		# 		sha256 = "sha256-4B0j2Y14YI119JOxMUKB0v/nQ9pl7G1IkjR6QBMib9k=";
		# 	};
		# }
		{
			name = "0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
				sha256 = "sha256-wGiU/sMiJIqyfq+/czEJRyRlp5+7N7ZGZJ+Bq6gDzic=";
			};
		}
		{
			name = "0017-wifi-mt76-mt7925-add-NULL-checks-and-error-handling.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/5ce83ccbb68a5bc09cac7c625b0692b4ad35ac01/patches/mt7925/0017-wifi-mt76-mt7925-add-NULL-checks-and-error-handling.patch";
				sha256 = "sha256-/vTyuK3Ffx09Pr00YmVJUjVnbnFRQDOAlWHSW0Z8v0c=";
			};
		}
	];
}
