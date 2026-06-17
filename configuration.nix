# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      /home/ngwx/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos-pc"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";
  programs.hyprland = {
    enable = true; 
    xwayland.enable = true; 
    withUWSM = true;
  }; 
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
  #   keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ngwx = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [	
    gparted
    vscode
    gitkraken
    qemu
    brightnessctl
    pavucontrol 
    wev
    dnsmasq
    swaybg
    hyprshot
    rofi
    kdePackages.kate
    fastfetch
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    foot 
    kitty 
    waybar 
    git 
    #hyprpaper
    kdePackages.dolphin  # Thay đổi ở đây
    unrar 
    pkgs.kdePackages.ark 
    mpv
    spotify
    kdePackages.isoimagewriter	
    brave    
    onlyoffice-desktopeditors	
    auto-cpufreq
  ] ++ lib.optionals (config.networking.hostName == "nixos-pc") [
  pkgs.steam
  ]; 
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "26.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  i18n.inputMethod = {
    type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
      fcitx5-gtk             # alternatively, kdePackages.fcitx5-qt
      pkgs.qt6Packages.fcitx5-unikey
	  # table input method support
      fcitx5-nord            # a color theme
    ];
  };
  programs.bash.interactiveShellInit = "fastfetch";
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  nix.gc = {
    automatic = true; 
    dates = "03:15";
    options = "--max-freed 68719476736";
  };
  programs.bash = { 
  shellAliases = {
    nixos = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw --impure";
    };
  };



#XEON
  hardware.graphics.enable = lib.mkIf (config.networking.hostName == "nixos-pc") true;
  services.xserver.videoDrivers = lib.mkIf (config.networking.hostName == "nixos-pc") [ "nvidia" ];
  hardware.nvidia.open = lib.mkIf (config.networking.hostName == "nixos-pc") true;

  fileSystems."/mnt/steam" = lib.mkIf (config.networking.hostName == "nixos-pc") {
    device = "/dev/disk/by-uuid/59aa4975-62c0-429a-be63-1affaced852e";
    fsType = "ext4";
    options = ["defaults" "noatime"];
  };
  fileSystems."/Documents" = lib.mkIf (config.networking.hostName == "nixos-pc")
    { device = "/dev/disk/by-uuid/2b8c45c9-8314-4921-b418-e2312533bc2a";
      fsType = "ext4";
      options = ["defaults" "user"];
    };

  programs.steam = lib.mkIf (config.networking.hostName == "nixos-pc") {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: 
    if config.networking.hostName == "nixos-pc" 
    then builtins.elem (lib.getName pkg) [ "steam" "steam-unwrapped" ]
    else true;

  programs.gamemode.enable = lib.mkIf (config.networking.hostName == "nixos-pc") true;

  boot.kernelParams = lib.mkIf (config.networking.hostName == "nixos-pc") [ "quiet" "splash" "console=/dev/null" ];
  boot.plymouth.enable = lib.mkIf (config.networking.hostName == "nixos-pc") true;

  programs.gamescope = lib.mkIf (config.networking.hostName == "nixos-pc") {
    enable = true;
    capSysNice = true;
  };
}


