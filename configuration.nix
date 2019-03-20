# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  urxvt = import ./urxvt/urxvt.nix { 
    inherit pkgs;
  };
  i3-config = import ./i3wm/config.nix {
    inherit pkgs;
    terminal = urxvt;
  };
  i3-config-file = pkgs.writeTextFile {
    name = "i3.conf";
    text = i3-config;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    enableIPv6 = true;
    #networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      pkgs.fira-code
      pkgs.font-awesome-ttf
    ];

    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "FiraCode-Retina" ];
      dpi = 180;
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    systemPackages = with pkgs; [
      anki
      aria2
      atom
      bash-completion
      borgbackup
      chromium
      curl
      dropbox
      ffmpeg
      firefox
      gcc
      ghostscript
      gitAndTools.gitFull
      gnupg
      google-chrome
      hstr
      htop
      httpie
      imagemagick
      keybase
      keybase-gui
      meld
      mupdf
      networkmanager
      nix-repl
      nmap
      nnn
      ripgrep
      rlwrap
      rxvt_unicode-with-plugins
      scrot
      slack
      spotify
      steam
      steam-run
      tldr
      tmux
      unzip
      vim
      vlc
      vscode
      weechat
      wget
      wireshark
      xclip
      xorg.xbacklight
    ];

    variables = {
      EDITOR = "vim";
      GIT_PS1_SHOWUPSTREAM = "true";
      GIT_PS1_SHOWDIRTYSTATE = "true";
      GIT_PS1_SHOWUNTRACKEDFILES = "true";
    };
  };

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
   
    chromium = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
      # enableWideVine = true;
      # commandLineArgs = "--force-device-scale-factor=2";
    };
    
    firefox = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    bash = with pkgs; rec {
      enableCompletion = true;
      promptInit = ''
        source ${pkgs.gitAndTools.gitFull}/share/git/contrib/completion/git-completion.bash
        source ${pkgs.gitAndTools.gitFull}/share/git/contrib/completion/git-prompt.sh
        export PS1="\[\033[0;35m\]\u@\h\[\033[0;33m\] \w\[\033[00m\]\$(__git_ps1 \" (%s)\") "
      '';
      shellAliases = {
        ls = "ls --color --group-directories-first";
        nix-list-system-generations = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
        restart-x = "sudo systemctl restart display-manager.service"; 
      };
    };

    # mtr.enable = true;
    # gnupg.agent = { enable = true; enableSSHSupport = true; };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    autorun = true;
    dpi = 150;
    # xkbOptions = "eurosign:e";

    # Enable touchpad support.
    libinput = {
      enable = true;
      clickMethod = "clickfinger";
      disableWhileTyping = true;
      naturalScrolling = true;
      scrollMethod = "twofinger";
      tapping = false;
      tappingDragLock = false;
    };
    
    synaptics.enable = false;
    
    # Enable the KDE Desktop Environment.
    # displayManager.sddm.enable = true;
    # desktopManager.plasma5.enable = true;
   
    # i3 with lightdm
    displayManager.lightdm.enable = true;
    windowManager.i3 = {
      enable = true;
      configFile = i3-config-file; 
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.sean = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}
