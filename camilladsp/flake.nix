{
  description = "A tool to create audio processing pipelines for applications such as active crossovers or room correction.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in

      pkgs.stdenv.mkDerivation rec {
        version = "v1.0.3";
        name = "camilladsp-${version}";

        src = pkgs.fetchzip {
          url = "https://github.com/HEnquist/camilladsp/releases/download/v1.0.3/camilladsp-linux-amd64.tar.gz";
          hash = "sha256-zWOyPmaHRi2VIRvzFpS02tPlXNn90ogU2Q/YRx7l6eI=";
        };

        phases = [
          "installPhase"
          "preFixup"
        ];
        installPhase = ''
          install -D $src/camilladsp $out/bin/camilladsp
        '';
        preFixup =
          let
            libPath = pkgs.lib.makeLibraryPath [
              pkgs.alsaLib
              pkgs.pulseaudio
            ];
          in
          ''
            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath "${libPath}" \
              $out/bin/camilladsp
          '';

        meta = with pkgs.lib; {
          homepage = "https://github.com/HEnquist/camilladsp";
          description = "A tool to create audio processing pipelines for applications such as active crossovers or room correction.";
          platforms = platforms.linux;
        };
      };
  };
}
