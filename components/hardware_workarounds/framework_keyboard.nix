# Make VIA work with keychron keyboards
{ config, pkgs, ... }: {
	pkgs.writeTextFile {
		name = "udev-rules-framework-keyboard";
		text = ''
			SUBSYSTEMS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0013", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0018", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0019", TAG+="uaccess"
		'';
		destination = "/lib/udev/rules.d/50-framework-keyboard.rules";
	};
}
