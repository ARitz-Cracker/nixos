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
			name = "0001-wifi-mt76-mt7925-fix-NULL-pointer-dereference-in-vif.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0001-wifi-mt76-mt7925-fix-NULL-pointer-dereference-in-vif.patch";
				sha256 = "sha256-pt31pnEVmFX9t+z2s6yvLGRmnXTjPV4e/Ckq2UFS0Qg=";
			};
		}
		{
			name = "0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
				sha256 = "sha256-2vVgxGXNt3KhJim3JsGT3mKCvOSZ0B/u2rCZcBCdJT4=";
			};
		}
		{
			name = "0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
				sha256 = "sha256-5KNYyseZdU8Dw7Uy3KLTRxNKaYV5xWQ7poiZaRXTb+g=";
			};
		}
		{
			name = "0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-func.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-func.patch";
				sha256 = "sha256-w6ehmbKKs25zsAQAZlQY/LTOZ1ktpFBDVhlmLd/pSek=";
			};
		}
		{
			name = "0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-m.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-m.patch";
				sha256 = "sha256-pZcXOt4eBB8Pbdm2bG9ugMyXFa3q25LrA73PZzT6hjg=";
			};
		}
		{
			name = "0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-co.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-co.patch";
				sha256 = "sha256-uhpKDK+wotK/kdBUsXgqHwD7Em96ycEFNAp5pZiY3ys=";
			};
		}
		{
			name = "0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-MCU.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-MCU.patch";
				sha256 = "sha256-NHWB5/5/nw66VWcEU9M9voj51bMp4tCg/wyYawSBVP0=";
			};
		}
		{
			name = "0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-.patch";
				sha256 = "sha256-vgnY7KORLu0iCMzpXf1epagyrhT9InN6J3ysquBu8vw=";
			};
		}
		{
			name = "0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-cha.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-cha.patch";
				sha256 = "sha256-s9IeHIf+B9adtKi5vdSqTxdGuCioUUrWgtljba8g+Tw=";
			};
		}
		{
			name = "0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-.patch";
				sha256 = "sha256-FGtwWnbZ5UuW6RrnFW/tSWixHrYSS1EaVK+Jr6jFVps=";
			};
		}
		{
			name = "0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
				sha256 = "sha256-/DZKIO5cRt7UszIJ1ZBVBhoDA2o6GjQJDyEJwj7Wwms=";
			};
		}
		{
			name = "0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
				sha256 = "sha256-spITepXYEl/BadLf36Z9dJfEXsMFYtaGbkaa23G2KOg=";
			};
		}
		{
			name = "0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
				sha256 = "sha256-jW01RA93HWttH5IXkVgh2ZZt6+nVNzslI2WqGttYzWE=";
			};
		}
		{
			name = "0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointe.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointe.patch";
				sha256 = "sha256-U3RCCHBRiIhwLp/aeOBE1BWQ0PGhW1vKVQ4CHigRhco=";
			};
		}
		{
			name = "0015-wifi-mt76-mt792x-fix-firmware-reload-failure-after-p.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0015-wifi-mt76-mt792x-fix-firmware-reload-failure-after-p.patch";
				sha256 = "sha256-g6JUoOxWj+CrP93jovfnAPLScnEB/wuFi69D2dPpaeE=";
			};
		}
		{
			name = "0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
				sha256 = "sha256-Gc80l2cX62oSY1nfZFkBqnVjBiJUKuWl9wnrQRaURzA=";
			};
		}
		{
			name = "0017-wifi-mt76-mt7925-add-NULL-checks-for-link-pointers-i.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0017-wifi-mt76-mt7925-add-NULL-checks-for-link-pointers-i.patch";
				sha256 = "sha256-OjqLqX8bUtUTN5/yCExXcj6suRRdphPP20dexrK3VYM=";
			};
		}
		{
			name = "0018-wifi-mt76-mt7921-fix-mutex-handling-in-multiple-path.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0018-wifi-mt76-mt7921-fix-mutex-handling-in-multiple-path.patch";
				sha256 = "sha256-FLfTMNMS3MHgwh3aqADXlD4ZHvDJiUEt7UjJYTf8DTU=";
			};
		}
		{
			name = "0019-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0019-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
				sha256 = "sha256-cvpWqSZf1Fi6xmrrxvSD4rFPNDI3bAGb10TIGP7M+p4=";
			};
		}
		{
			name = "0020-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/83d28091df2c5e48d3e4179715cb46f2310dc5e8/kernels/6.18/0020-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
				sha256 = "sha256-MUJ4vVjYRFI9lF7QRqaVCcnmYcEhsLAt4wrAs/Guuk8=";
			};
		}
	];
}
