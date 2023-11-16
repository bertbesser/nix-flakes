{
  description = "REW is free software for room acoustic measurement, loudspeaker measurement and audio device measurement.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    with pkgs;
    {
      packages.${system}.default = stdenv.mkDerivation rec {
        pname = "roomeqwizard";
        version = "5_20_13";
        name = "${pname}-${version}";

        src = fetchurl {
          url = "https://www.roomeqwizard.com/installers/REW_linux_no_jre_${version}.sh";
          hash = "sha256-6zaBDOmQlyMRQ84j64oS7TMwcctT1PSbuQOUYY9QjvY=";
        };

        phases = [ "installPhase" ];
        nativeBuildInputs = [ makeWrapper ];
        buildInputs = [ jre8 ];
        installPhase = ''
          mkdir -p $out/lib $out/bin

          sh $src -q -dir $out/lib

          ln -s $out/lib/roomeqwizard $out/bin/${pname}
          wrapProgram $out/bin/${pname} --prefix PATH : ${lib.makeBinPath [ jre8 ]}
        '';

        meta = {
          homepage = "https://www.roomeqwizard.com";
          description = "REW is free software for room acoustic measurement, loudspeaker measurement and audio device measurement.";
          platforms = pkgs.lib.platforms.linux;
        };
      };
    };
}
