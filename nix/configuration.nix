{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./hosts.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.ognev = import ./home.nix;

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
    ];
  
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];
  
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos-Leonid";

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Novosibirsk";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ognev = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.fish = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  users.defaultUserShell = pkgs.fish;

  system.stateVersion = "25.11";

  # programs.firefox.enable = true;

  programs.firefox = {
    enable = true;
    preferences = {
      "media.eme.enabled" = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    ranger
    curl
    git
    python3
    uv
    kitty
    tmux
    rofi
    waybar
    ripgrep
    fzf
    fish
    lolcat
    materialgram
    eww
    matugen
    swww
    pywal
    wallust
    zoxide
    gcc
    clang
    clang-tools
    zip
    unzip
    eza
    ripdrag
    bash
    pavucontrol
    spotify-player
    spotify
    pokemon-colorscripts
    cava
    cbonsai
    cmatrix
    grim
    slurp
    fastfetch
    neofetch
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-wlr
    xrandr
    killall
    swaynotificationcenter
    pywalfox-native
    libnotify
    cargo
    rustc
    bear
    cmake
    gnumake
    dbus
    blueman
    htop
    btop
    ncdu
    nyancat
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  programs.amnezia-vpn.enable = true;

  systemd.services.amnezia-vpn = {
    description = "AmneziaVPN Service";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "always";
      User = "ognev";
    };
    wantedBy = [ "multi-user.target" ];
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}
