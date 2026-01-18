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
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0001-wifi-mt76-mt7925-fix-NULL-pointer-dereference-in-vif.patch";
				sha256 = "sha256-lYJQu9F85/LzAUCpZCdxZ9ISc2ARUZutN9hwq+rMm7M=";
			};
		}
		{
			name = "0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
				sha256 = "sha256-GNCiDSx0G/t+UbTGFqUIL8xB86B6iX1IRCI3p/IiepM=";
			};
		}
		{
			name = "0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
				sha256 = "sha256-tjTxp0aRoDdkFMe0Mfgw6zKqY9MschrvZk8iy1fexbc=";
			};
		}
		{
			name = "0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-func.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-func.patch";
				sha256 = "sha256-U1THENdRkXwjS6iAGtsmX9QbBG/7ReVIOn++QA+ZL2I=";
			};
		}
		{
			name = "0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-m.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-m.patch";
				sha256 = "sha256-VixRyx/ekScF+PWW/GhLvd4eOFV/OtPWrFfSVfn1Ves=";
			};
		}
		{
			name = "0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-co.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-co.patch";
				sha256 = "sha256-r97PHsTQgVPyFwcERRmHjMirqSBK+/OjXfHQE5dKlWk=";
			};
		}
		{
			name = "0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-MCU.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-MCU.patch";
				sha256 = "sha256-/sZgXR9lpbnyY0TREi663h+lHmsQnFnWEsf+6058XBw=";
			};
		}
		{
			name = "0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-.patch";
				sha256 = "sha256-K5SnlTArc0WMqrNGs/ygGToV2AGklWN21yCsyOetTag=";
			};
		}
		{
			name = "0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-cha.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-cha.patch";
				sha256 = "sha256-pWtXse/x1tMWtoQxXFmlGcm0gbLNF3tEiO4sh9EZxPE=";
			};
		}
		{
			name = "0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-.patch";
				sha256 = "sha256-GjlYX6YCNFqLIH+Gk867XceU9AtkEwEJABSn893veQI=";
			};
		}
		{
			name = "0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
				sha256 = "sha256-mB6Erev1080sJAItseREZ2RKKXxmyWqygdez6oez4LQ=";
			};
		}
		{
			name = "0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
				sha256 = "sha256-YRiVwDLdi1nPvPkraY5bUe4OIqqtiXWHRwl0l93S4vE=";
			};
		}
		{
			name = "0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
				sha256 = "sha256-8QtArn25JfNALUiy1wngL8wTGUq91uW66aozoVu2hmE=";
			};
		}
		{
			name = "0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointe.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointe.patch";
				sha256 = "sha256-Ho0Sm1HoMHAkkY+ocTaGhvbk2aMEHahsp5ABa0DDQ8k=";
			};
		}
		{
			name = "0015-wifi-mt76-mt792x-fix-firmware-reload-failure-after-p.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0015-wifi-mt76-mt792x-fix-firmware-reload-failure-after-p.patch";
				sha256 = "sha256-20fBhc3Qs2sNSV7G8T5tHdb8FSXhUqpGI4RBAwhwIaA=";
			};
		}
		{
			name = "0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
				sha256 = "sha256-vIWu8/ye+W5HVEJRpnedGm4KNPATHji6k+DivnEEkI4=";
			};
		}
		{
			name = "0017-wifi-mt76-mt7925-add-NULL-checks-for-link-pointers-i.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0017-wifi-mt76-mt7925-add-NULL-checks-for-link-pointers-i.patch";
				sha256 = "sha256-FnsuL8Ij03+U7RRInHQGJ56j+wXf0y16y+682I2kyqs=";
			};
		}
		{
			name = "0018-wifi-mt76-mt7921-fix-mutex-handling-in-multiple-path.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0018-wifi-mt76-mt7921-fix-mutex-handling-in-multiple-path.patch";
				sha256 = "sha256-Zdht5Tv68eJVVDrz/yFGU1vcCZV4CflEWoEKFsD4o58=";
			};
		}
		{
			name = "0019-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0019-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
				sha256 = "sha256-Fdfx+Agl7PdwvC5qUJPd64mHlWCV7Lrkah2ZFwEzeMg=";
			};
		}
		{
			name = "0020-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0020-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
				sha256 = "sha256-Aj53UBe2ZMJnminipn5vRzvFv7963VHgSfL+44tJuRM=";
			};
		}
		{
			name = "0021-wifi-mt76-mt7925-fix-deadlock-in-sta-removal-ROC-abo.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/c2fa57c1415d4091f3a0720656ed6d4bce43d677/kernels/6.18/0021-wifi-mt76-mt7925-fix-deadlock-in-sta-removal-ROC-abo.patch";
				sha256 = "sha256-q7cImyYrPwoDLeNKF6+ZRHDGw3p5unCvAnESPwYAtRo=";
			};
		}
	];
}
