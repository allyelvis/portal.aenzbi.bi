{ pkgs }: {
  deps = [
    pkgs.run
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.man
  ];
}