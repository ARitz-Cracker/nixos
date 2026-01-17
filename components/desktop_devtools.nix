{ config, pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		vscode
		zed-editor
		virt-manager
		pkgs.d-spy
	];
}
