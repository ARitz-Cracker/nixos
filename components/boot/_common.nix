{ config, pkgs, ... }:
{
	boot.loader.efi.canTouchEfiVariables = true;
	boot.tmp.cleanOnBoot = true;
}
