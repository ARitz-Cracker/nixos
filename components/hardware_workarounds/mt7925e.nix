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
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0001-wifi-mt76-mt7925-fix-NULL-pointer-dereference-in-vif.patch";
				sha256 = "sha256-rGRGuEcC3OAKvekao1+upqAmENqsHCX8NFIdbuDlJeA=";
			};
		}
		{
			name = "0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0002-wifi-mt76-mt7925-fix-missing-mutex-protection-in-res.patch";
				sha256 = "sha256-grEm95wubDegMRcHIon66ulQsyTWRjEK3SfmyuXapAk=";
			};
		}
		{
			name = "0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0003-wifi-mt76-mt7925-fix-missing-mutex-protection-in-run.patch";
				sha256 = "sha256-uqAoboUoPLid0dqZ26NkxtJIlMSTDYhr0kzSelVW0SM=";
			};
		}
		{
			name = "0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-func.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0004-wifi-mt76-mt7925-add-NULL-checks-in-MCU-STA-TLV-func.patch";
				sha256 = "sha256-6Q/c9P0wvmo7P11igtj4LKreqJX7CB97SGc7e3rGcWQ=";
			};
		}
		{
			name = "0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-m.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0005-wifi-mt76-mt7925-add-NULL-checks-for-link_conf-and-m.patch";
				sha256 = "sha256-LEpASUd+g8fI1ww3uzLR2oIYAy1X5YhDty940LiGK9E=";
			};
		}
		{
			name = "0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-co.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0006-wifi-mt76-mt7925-add-error-handling-for-AMPDU-MCU-co.patch";
				sha256 = "sha256-5vuD7/ecDm7S7JLFsoaiAjY47aRSFCV2NWqAcyl4KKw=";
			};
		}
		{
			name = "0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-MCU.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0007-wifi-mt76-mt7925-add-error-handling-for-BSS-info-MCU.patch";
				sha256 = "sha256-AKOKfeymRpM7Pjwes57lXh/Se+jWuBnlsJqAVvafL7Y=";
			};
		}
		{
			name = "0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0008-wifi-mt76-mt7925-add-error-handling-for-BSS-info-in-.patch";
				sha256 = "sha256-lw0Rb3Igi0+NgD91Wod3nd+zsR8w99ysjtb2gI5/DoY=";
			};
		}
		{
			name = "0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-cha.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0009-wifi-mt76-mt7925-add-NULL-checks-in-MLO-link-and-cha.patch";
				sha256 = "sha256-T9uTxQ5xwT5IPovc8l2k3rAhJGH/LThepnu0nvtvz5A=";
			};
		}
		{
			name = "0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0010-wifi-mt76-mt792x-fix-NULL-pointer-dereference-in-TX-.patch";
				sha256 = "sha256-yVWLnMvB/JOM1YNytvvmxUcA/EMmP6NcXNUlGbSVUVU=";
			};
		}
		{
			name = "0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0011-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
				sha256 = "sha256-4xXv+LPitqRiZIiKncNLfQUrP+ac04/OjDmX+p/mhJw=";
			};
		}
		{
			name = "0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0012-wifi-mt76-mt7925-fix-key-removal-failure-during-MLO-.patch";
				sha256 = "sha256-1+NenG++/bISR+zWw1v89ZfW8q5v9xj8H7XLcBYmATA=";
			};
		}
		{
			name = "0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0013-wifi-mt76-mt7925-fix-kernel-warning-in-MLO-ROC-setup.patch";
				sha256 = "sha256-meFUgzHPWYzPzTb8/125dY50ykLbkuWRjH0svg+qjuI=";
			};
		}
		{
			name = "0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointe.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0014-wifi-mt76-mt7925-add-NULL-checks-for-MLO-link-pointe.patch";
				sha256 = "sha256-xznOFOeJVSGUzIgsxIWfFxwCvaub2dFWjwFarcK0fUk=";
			};
		}
		{
			name = "0015-wifi-mt76-mt792x-fix-firmware-reload-failure-after-p.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0015-wifi-mt76-mt792x-fix-firmware-reload-failure-after-p.patch";
				sha256 = "sha256-WncK66gzI7A1VrDLoZTzKrKAgIsFVlzNsk2WxI37xBU=";
			};
		}
		{
			name = "0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0016-wifi-mt76-mt7925-add-mutex-protection-in-resume-path.patch";
				sha256 = "sha256-xe1rSOmg2izUy/xOwoydITprYoFGCjrOYQVuHlWUUMo=";
			};
		}
		{
			name = "0017-wifi-mt76-mt7925-add-NULL-checks-for-link-pointers-i.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/7c8ae89bd8e17f0d19ce237fd1e106e76d0565fe/kernels/6.18/0017-wifi-mt76-mt7925-add-NULL-checks-for-link-pointers-i.patch";
				sha256 = "sha256-p8N5LQz0PgWKlRqPsdKjZwoplAAxf00B2v5uNDc/CO0=";
			};
		}
	];
}
