{ config, pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		vscode
		nodejs_24
		zed-editor
		virt-manager
	];
}
