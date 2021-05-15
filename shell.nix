{ pkgs ? (
   let 
    hostPkgs = import <nixpkgs> {};
    pinnedPkgs = hostPkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "2620ac69c01adfca54c66730eb3dbbe07e6a3024";
      sha256 = "08cibk8n7cg3az94yhhbl04hrqbxqhgz7g73fbrr9bydpf0k9in1";
    };
  in
  import pinnedPkgs {}
 )
}:
let
  objects-src = pkgs.fetchFromGitHub {
    owner = "OpenRCT2";
    repo = "objects";
    rev = "v1.2";
    sha256 = "0crjzkdhcddlg3nlxnz0p4li54whx8yl6w7i968xhl0ph5zj6j2y";
  };

  title-sequences-src = pkgs.fetchFromGitHub {
    owner = "OpenRCT2";
    repo = "title-sequences";
    rev = "v0.1.2c";
    sha256 = "1qdrm4q75bznmgdrpjdaiqvbf3q4vwbkkmls45izxvyg1djrpsdf";
};
in
pkgs.stdenv.mkDerivation {
  name = "openrct2";
  src = ./.;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RELWITHDEBINFO"
    "-DDOWNLOAD_OBJECTS=OFF"
    "-DDOWNLOAD_TITLE_SEQUENCES=OFF"
    "-DDISABLE_GOOGLE_BENCHMARK=ON"
  ];

  postUnpack = ''
    cp -r ${objects-src}         $sourceRoot/data/object
    cp -r ${title-sequences-src} $sourceRoot/data/sequence
  '';

  preFixup = "ln -s $out/share/openrct2 $out/bin/data";

  makeFlags = ["all" "g2"];

  buildInputs = [
	pkgs.SDL2
	pkgs.cmake
	pkgs.curl
  pkgs.discord-rpc
  pkgs.duktape
	pkgs.fontconfig
	pkgs.freetype
	pkgs.icu
	pkgs.jansson
  pkgs.libiconv
  pkgs.libpng
	pkgs.libGLU
	pkgs.libzip
  pkgs.nlohmann_json
	pkgs.openssl
	pkgs.pkgconfig
	pkgs.speexdsp
	pkgs.xorg.libpthreadstubs
	pkgs.zlib
] ++ (pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.Foundation # osX hacks
    pkgs.darwin.apple_sdk.frameworks.AppKit
    pkgs.darwin.libobjc ]
  );
}
