{ config, pkgs, ... }:

{
  home.username = "ognev";
  home.homeDirectory = "/home/ognev";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    XCURSOR_SIZE = "32";
  };

  programs.git = {
    enable = true;
    userName = "Leonid";
    userEmail = "penguin.ognev@gmail.com";
  };

  # home.pointerCursor = {
  #   package = pkgs.apple-cursor;
  #   name = "Cursor";
  #   size = 24;
  # 
  #   hyprcursor = {
  #     enable = true;
  #     size = config.home.pointerCursor.size;
  #   };
  # 
  #   gtk.enable = true;
  # };
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 32;
  };
}
