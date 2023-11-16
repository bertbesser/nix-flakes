{
  description = "This Python script moves the window with focus on an adjacent monitor.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "259f010b432a8e4080a93d274a592a5bec95cfa9";
      meta = {
        homepage = "https://github.com/calandoa/movescreen/tree/${version}";
        description = "This Python script moves the window with focus on an adjacent monitor.";
        platforms = pkgs.lib.platforms.linux;
      };
    in
    {
      packages.${system}.default =
        with pkgs;
        let
          name = "movescreen-${version}.py";
          movescreen = stdenv.mkDerivation {
            inherit name;

            src = fetchurl {
              url = "https://raw.githubusercontent.com/calandoa/movescreen/${version}/movescreen.py";
              hash = "sha256-hh3120tWD1pGsd89XuohmU3U/0lw5xKOFYN+Ebd75N0=";
            };

            phases = [ "installPhase" ];
            installPhase = ''
              install -D $src $out/bin/${name}
            '';

            inherit meta;
          };
        in
        writeShellApplication {
          name = "movescreen";
          runtimeInputs = [
            python3
            xorg.xprop
            xorg.xrandr
            xdotool
            xorg.xwininfo
            wmctrl
          ];
          text = ''
            python "${movescreen}/bin/${name}" "$@"
          '';
        };
    };
}
