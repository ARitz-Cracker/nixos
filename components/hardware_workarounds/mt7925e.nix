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
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0001-wifi-mt76-mt7925-fix-potential-deadlock-in-mt7925_ro.patch";
				sha256 = "sha256-rPD+dHxs+vjEYmyUfCUMUeXFpRx3cI/nXeFIvsl1F2E=";
			};
		}
		{
			name = "0002-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0002-wifi-mt76-fix-list-corruption-in-mt76_wcid_cleanup.patch";
				sha256 = "sha256-hOgUo6mM1JnQQwgRphaPkekvJ4NTqXPaYrsjOJmISpY=";
			};
		}
		{
			name = "0003-wifi-mt76-mt792x-fix-NULL-pointer-and-firmware-reloa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0003-wifi-mt76-mt792x-fix-NULL-pointer-and-firmware-reloa.patch";
				sha256 = "sha256-rWzb4MAyGuMA20J4farFKPVEJIPgQyIWcwSqmlcX4ms=";
			};
		}
		{
			name = "0004-wifi-mt76-mt7921-add-mutex-protection-in-critical-pa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0004-wifi-mt76-mt7921-add-mutex-protection-in-critical-pa.patch";
				sha256 = "sha256-lnRixRzo9OewfnmJq9FEGkpXTLx6D2Vz/y3/MUVRcJo=";
			};
		}
		{
			name = "0005-wifi-mt76-mt7921-fix-deadlock-in-sta-removal-and-sus.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0005-wifi-mt76-mt7921-fix-deadlock-in-sta-removal-and-sus.patch";
				sha256 = "sha256-MdW7bYPvUPxNXICdBFSImD38FOJiA7ZWVGJL1vHQ+IU=";
			};
		}
		{
			name = "0006-wifi-mt76-mt7925-add-comprehensive-NULL-pointer-prot.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0006-wifi-mt76-mt7925-add-comprehensive-NULL-pointer-prot.patch";
				sha256 = "sha256-TQZfuhv0iQrPYpM0gP3YYgrHCza1YdvWhwNe+dUvN6Y=";
			};
		}
		{
			name = "0007-wifi-mt76-mt7925-add-mutex-protection-in-critical-pa.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0007-wifi-mt76-mt7925-add-mutex-protection-in-critical-pa.patch";
				sha256 = "sha256-6SIuSgvN96ukkuxiDh9447Tifa3u9FjhPuCrovZo9eA=";
			};
		}
		{
			name = "0008-wifi-mt76-mt7925-add-MCU-command-error-handling.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0008-wifi-mt76-mt7925-add-MCU-command-error-handling.patch";
				sha256 = "sha256-GinXD3TaWgVERZ3lQrjE2Ef1JJOyuLsihcs7xrgo9tI=";
			};
		}
		{
			name = "0009-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0009-wifi-mt76-mt7925-add-lockdep-assertions-for-mutex-ve.patch";
				sha256 = "sha256-EkKggY+2xdIxPw5CRDR4nJJ0p/r/Gubco9Y6O+0mLbI=";
			};
		}
		{
			name = "0010-wifi-mt76-mt7925-fix-MLO-roaming-and-ROC-setup-issue.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0010-wifi-mt76-mt7925-fix-MLO-roaming-and-ROC-setup-issue.patch";
				sha256 = "sha256-JaLBEf3nh5w5mwI6sw40ie03cNDRajBfPuUN0UTb1VY=";
			};
		}
		{
			name = "0011-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0011-wifi-mt76-mt7925-fix-BA-session-teardown-during-beac.patch";
				sha256 = "sha256-aMjtrYiqJ7dGCCImjqtEd+mlwgVu1pdX5dCVUjFR2So=";
			};
		}
		{
			name = "0012-wifi-mt76-mt7925-fix-ROC-deadlocks-and-race-conditio.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0012-wifi-mt76-mt7925-fix-ROC-deadlocks-and-race-conditio.patch";
				sha256 = "sha256-hCFSdTU1G9eqLpAijXdAzTk8iZjKE42Ug2MB7bybI7U=";
			};
		}
		{
			name = "0013-wifi-mt76-mt7925-fix-double-wcid-initialization-race.patch";
			patch = pkgs.fetchurl {
				url = "https://raw.githubusercontent.com/zbowling/mt7925/2f006830e5d48377286ab16bcf539e608676ed47/kernels/6.18/0013-wifi-mt76-mt7925-fix-double-wcid-initialization-race.patch";
				sha256 = "sha256-+XqnKHThDRbjsEmBbc6ARmYGgdgEMs8xgDj6sUm+s3Q=";
			};
		}
	];
}
