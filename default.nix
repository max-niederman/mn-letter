{ pkgs ? import <nixpkgs> { } }:

let
  prince = pkgs.stdenv.mkDerivation {
    name = "prince";
    version = "15.2";

    src = pkgs.fetchurl {
      url = "https://www.princexml.com/download/prince-15.2-linux-generic-x86_64.tar.gz";
      sha256 = "sha256-EMc/m8GZJNa6DgRZ0X0jJS6oNOitmSz0g6SfrvHpz7o=";
    };

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    buildInputs = with pkgs; [ fontconfig.lib ];

    installPhase = ''
      ./install.sh $out
    '';
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "mn-letter";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.ripgrep
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r images $out
    rg --passthru "images" -r "$out/images" letter.html > $out/letter.html

    makeWrapper ${pkgs.pandoc}/bin/pandoc $out/bin/${pname} \
      --prefix PATH : ${prince}/bin \
      --add-flags "--standalone --to=html --pdf-engine=prince --template=$out/letter.html"
  '';
}
