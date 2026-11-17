{ config, lib, pkgs, ... }:

{
  services.pcscd.enable = true;
  
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-personalization
    yubico-piv-tool
    yubikey-manager
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
  services.yubikey-agent.enable = true;

  # gpg-agent itself stays disabled; the yubikey-agent module reads its
  # pinentry from this option and skips starting the agent when it is null.
  programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-gnome3;

  # pinentry-gnome3 falls back to the terminal unless the agent that launches
  # it has WAYLAND_DISPLAY, which only exists once the graphical session has
  # imported it.
  systemd.user.services.yubikey-agent = {
    wantedBy = lib.mkForce [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
  };

  # yubikey-agent is the only SSH agent: logins, git and jj all use the PIV key
  # of whichever YubiKey is plugged in. gnome-keyring (enabled by niri) would
  # otherwise start gcr's agent and claim SSH_AUTH_SOCK.
  services.gnome.gcr-ssh-agent.enable = false;
  environment.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
}
