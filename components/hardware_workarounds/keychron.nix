# Make VIA work with keychron keyboards
{ config, pkgs, ... }:
let
	udev-rules-keychron = pkgs.writeTextFile {
		name = "99-keychron.rules";
		text = ''
			KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0361", MODE="0660", GROUP="wheel", TAG+="uaccess", TAG+="udev-acl"
		'';
		destination = "/lib/udev/rules.d/99-keychron.rules";
	};
in
{
	services.udev.packages = [ udev-rules-keychron ];
}
