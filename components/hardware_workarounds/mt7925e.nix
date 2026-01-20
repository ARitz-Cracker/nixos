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
			name = "0001-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0001-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
				sha256 = "sha256-FEeeF7SfXWCXaSPGuyTtR7UAPcT19APdzjG7GxLUOjQ=";
			};
		}
		{
			name = "0002-wifi-mt76-mt792x-fix-NULL-pointer-and-firmware-reloa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0002-wifi-mt76-mt792x-fix-NULL-pointer-and-firmware-reloa.patch";
				sha256 = "sha256-Euxo1Nqd6iadA1AcuL3VCKW5eCTWfBMUCxC5ClNAROQ=";
			};
		}
		{
			name = "0003-wifi-mt76-mt7921-add-mutex-protection-in-critical-pa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0003-wifi-mt76-mt7921-add-mutex-protection-in-critical-pa.patch";
				sha256 = "sha256-epsOtE+Ly7MonLsLCkl2OB5gjFXUZlANJj8yqLnexXU=";
			};
		}
		{
			name = "0004-wifi-mt76-mt7921-fix-deadlock-in-sta-removal-and-sus.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0004-wifi-mt76-mt7921-fix-deadlock-in-sta-removal-and-sus.patch";
				sha256 = "sha256-ASTl3ErKikURFTEb+IvwGr0NyXwqB/Of+F8EbFMm0PI=";
			};
		}
		{
			name = "0005-wifi-mt76-mt7925-add-comprehensive-NULL-pointer-prot.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0005-wifi-mt76-mt7925-add-comprehensive-NULL-pointer-prot.patch";
				sha256 = "sha256-pDRNQRK/ErQwUgGmg29KLyIaktbwmPct8oTcwA6GwjU=";
			};
		}
		{
			name = "0006-wifi-mt76-mt7925-add-mutex-protection-in-critical-pa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0006-wifi-mt76-mt7925-add-mutex-protection-in-critical-pa.patch";
				sha256 = "sha256-L/p0vzxrx5NbIWPTWtEzon2FYkUfgw+/Vdx+0YgWTC8=";
			};
		}
		{
			name = "0007-wifi-mt76-mt7925-add-MCU-command-error-handling.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0007-wifi-mt76-mt7925-add-MCU-command-error-handling.patch";
				sha256 = "sha256-Ex0PGBLRWsfaSSpzbKrmho2ZqrKqT2RHh19kEkZG1ZY=";
			};
		}
		{
			name = "0008-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0008-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
				sha256 = "sha256-Foi7I/pQMBc8LyIchvKlZycQKSH9fo/rHvrN+aaTa2Q=";
			};
		}
		{
			name = "0009-wifi-mt76-mt7925-fix-MLO-roaming-and-ROC-setup-issue.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0009-wifi-mt76-mt7925-fix-MLO-roaming-and-ROC-setup-issue.patch";
				sha256 = "sha256-ThwEZQQh64B+lxcYoem0sIn9LzDc8YcfxVVk+NlkRsg=";
			};
		}
		{
			name = "0010-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0010-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
				sha256 = "sha256-0p3+1KIV85p7sH9YETgrrIKmaVhSbAvqLhR9KaO0cj4=";
			};
		}
		{
			name = "0011-wifi-mt76-mt7925-fix-ROC-deadlocks-and-race-conditio.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/f83fbd3b16de09d532e67fd3d14189a817aa4e7c/kernels/6.18/0011-wifi-mt76-mt7925-fix-ROC-deadlocks-and-race-conditio.patch";
				sha256 = "sha256-utAvjD4xklZYr40yOn0qhpQH21kSOsm5vO/7zwLIQIA=";
			};
		}
	];
}
