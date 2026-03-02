{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.katvan;
  
  katvanSrc = pkgs.fetchFromGitHub {
    owner = "IgKh";
    repo = "katvan";
    rev = "d286eeaef61b91ecb5c0d9e926833267dc769c51";  # commit для v0.12.0
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";  # нужно заменить
  };
  
  # Сборка из исходников (более надёжный способ, чем AppImage)
  katvanPackage = pkgs.libsForQt5.callPackage (
    { stdenv, cmake, pkg-config, qtbase, qttools, rustPlatform
    , hunspell, libarchive, typst, makeWrapper
    }:
    
    stdenv.mkDerivation rec {
      pname = "katvan";
      version = "0.12.0";
      
      src = katvanSrc;
      
      nativeBuildInputs = [
        cmake
        pkg-config
        qttools
        makeWrapper
      ];
      
      buildInputs = [
        qtbase
        hunspell
        libarchive
        typst
      ];
      
      # Rust dependencies
      cargoDeps = rustPlatform.importCargoLock {
        lockFile = "${katvanSrc}/Cargo.lock";
      };
      
      buildInputs = with rustPlatform; [
        rust.cargo
        rust.rustc
      ] ++ buildInputs;
      
      cmakeFlags = [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DUSE_BUNDLED_CORROSION=OFF"
      ];
      
      postInstall = ''
        wrapProgram $out/bin/katvan \
          --prefix PATH : ${lib.makeBinPath [ typst ]}
      '';
      
      meta = with lib; {
        description = "A bare-bones editor for Typst files, with a bias for Right-to-Left editing";
        homepage = "https://github.com/IgKh/katvan";
        license = licenses.gpl3Only;
        platforms = platforms.linux;
        maintainers = with maintainers; [ ];
      };
    }
  ) {};
in
{
  options.modules.home.katvan = {
    enable = mkEnableOption "Katvan Typst editor";
  };

  config = mkIf cfg.enable {
    # Устанавливаем Katvan и typst
    home.packages = with pkgs; [
      katvanPackage
      typst  # нужен для работы Katvan
    ];
    
    # Алиас для удобства
    home.shellAliases = {
      katvan = "katvan";
    };
  };
}
