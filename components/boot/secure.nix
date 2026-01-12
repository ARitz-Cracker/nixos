# Steps for enabling secure-boot
# 1. use `insecure.nix`, but with sbctl installed
# 2. `sudo sbctl create-keys`
# 3. `nixos-rebuild switch` with `secure.nix`
# 4. use `sbctl verify` to verify that your UKI is signed, it's fine that the kernel itself isn't.
# 5. Reboot, follow https://github.com/nix-community/lanzaboote/blob/master/docs/getting-started/enable-secure-boot.md
# Personally I ommitted the `--microsoft` option, I'm booted into MY KERNEL and MY KERNEL ONLY!!
{ config, pkgs, ... }:
let
	sources = import ../../sources/lon.nix;
	lanzaboote = import sources.lanzaboote {
		inherit pkgs;
	};
in
{
	imports = [
		./_common.nix
		lanzaboote.nixosModules.lanzaboote
	];
	# Lanzaboote currently replaces the systemd-boot module.
	boot.loader.systemd-boot.enable = false;
	boot.lanzaboote = {
		enable = true;
		pkiBundle = "/var/lib/sbctl";
	};
	environment.systemPackages = with pkgs; [
		# Manages the keys used to sign for secure-boot
    	sbctl
	]
}
