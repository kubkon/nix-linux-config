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

  # pinentry-gnome3 and the SSH askpass fall back to the terminal unless the
  # agent that launches them has WAYLAND_DISPLAY, which only exists once the
  # graphical session has imported it.
  systemd.user.services.yubikey-agent = {
    wantedBy = lib.mkForce [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
  };

  systemd.user.services.gcr-ssh-agent = {
    wantedBy = lib.mkForce [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    environment = {
      SSH_ASKPASS = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
      SSH_ASKPASS_REQUIRE = "force";
    };
  };
}
