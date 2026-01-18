{ config, pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		gcc_multi
		gitFull
		nodejs_24
	];
	virtualisation.libvirtd = {
		enable = true;
		qemu = {
			package = pkgs.qemu_kvm;
			runAsRoot = true;
			swtpm.enable = true;
		};
	};
}
