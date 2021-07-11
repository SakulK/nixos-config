{
  "org/gnome/desktop/interface" = {
    gtk-theme = "Pop-dark";
    icon-theme = "Pop";
  };

  "org/gnome/shell" = {
    disable-user-extensions = false;
    favorite-apps = [
      "firefox.desktop"
      "idea-community.desktop"
      "kitty.desktop"
      "code.desktop"
    ];
    enabled-extensions = [
      "sound-output-device-chooser@kgshank.net"
      "system-monitor@paradoxxx.zero.gmail.com"
      "gsconnect@andyholmes.github.io"
      "appindicatorsupport@rgcjonas.gmail.com"
      "user-theme@gnome-shell-extensions.gcampax.github.com"
    ];
  };
}
