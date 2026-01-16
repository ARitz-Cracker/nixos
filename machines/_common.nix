{ config, pkgs, ... }: {
	# I'm a pragmatist (and I own nvidia hardware)
  nixpkgs.config.allowUnfree = true;
	networking.networkmanager.enable = true;

	# Canadian, eh?
	time.timeZone = "America/Toronto";
	i18n.defaultLocale = "en_CA.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_CA.UTF-8";
		LC_IDENTIFICATION = "en_CA.UTF-8";
		LC_MEASUREMENT = "en_CA.UTF-8";
		LC_MONETARY = "en_CA.UTF-8";
		LC_NAME = "en_CA.UTF-8";
		LC_NUMERIC = "en_CA.UTF-8";
		LC_PAPER = "en_CA.UTF-8";
		LC_TELEPHONE = "en_CA.UTF-8";
		LC_TIME = "en_CA.UTF-8";
	};
	environment.systemPackages = with pkgs; [
		lon
		wget
	];
}
