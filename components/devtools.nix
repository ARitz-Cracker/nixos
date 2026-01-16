{ config, pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		gitFull
		rustup
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
