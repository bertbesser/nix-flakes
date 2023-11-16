{
  description = "A tool to create audio processing pipelines for applications such as active crossovers or room correction.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "v1.0.3";
      meta = {
        homepage = "https://github.com/HEnquist/camilladsp/tree/${version}";
        description = "A tool to create audio processing pipelines for applications such as active crossovers or room correction.";
        platforms = pkgs.lib.platforms.linux;
      };
    in
    with pkgs;
    {
      packages.${system} = {
        default =
          stdenv.mkDerivation rec {
            name = "camilladsp-${version}";

            src = fetchzip {
              url = "https://github.com/HEnquist/camilladsp/releases/download/${version}/camilladsp-linux-amd64.tar.gz";
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
                libPath = lib.makeLibraryPath [
                  alsaLib
                  pulseaudio
                ];
              in
              ''
                patchelf \
                  --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                  --set-rpath "${libPath}" \
                  $out/bin/camilladsp
              '';

            inherit meta;
          };

        translate_rew_xml =
          let
            python = (python3.withPackages (ps: [ ps.pyyaml ]));
          in
          stdenv.mkDerivation {
            name = "camilladsp-${version}-translate_rew_xml.py";

            src = fetchurl {
              url = "https://raw.githubusercontent.com/HEnquist/camilladsp/${version}/translate_rew_xml.py";
              hash = "sha256-3pO1g08eu0tM1WiWYxfvZzEhczYPSEchslDd+2jTPSo=";
            };

            phases = [ "installPhase" ];
            buildInputs = [ python ];
            installPhase = ''
              install -D $src $out/bin/translate_rew_xml.py

              SCRIPT="$out/bin/translate_rew_xml"
              (
                echo '#!/usr/bin/env bash'
                echo "${lib.makeBinPath[ python ]}/python $out/bin/translate_rew_xml.py" '$@'
              ) > "''${SCRIPT}"
              chmod +x "''${SCRIPT}"
            '';

            inherit meta;
          };
      };
    };
}
