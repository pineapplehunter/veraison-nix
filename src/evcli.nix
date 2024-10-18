{
  buildGoModule,
  fetchFromGitHub,
  stdenv,
  lib,
  mockgen_1_6,
}:
buildGoModule rec {
  pname = "evcli";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "veraison";
    repo = "evcli";
    rev = "v${version}";
    hash = "sha256-GP/C/01U7eGL98eSw9Rjvmx6Z+cXopORlKmHPbpXA/g=";
  };

  vendorHash = "sha256-BAWi2DyOi3N6WHdupqHlu4e7c5x8ezdoTELFbP0JFcI=";

  postPatch = ''
    make SHELL=${stdenv.shell} MOCKGEN=${lib.getExe mockgen_1_6} _mocks
  '';

  checkPhase = ''
    runHook preCheck
    make SHELL=${stdenv.shell} MOCKGEN=${lib.getExe mockgen_1_6} test
    runHook postCheck
  '';

  meta.mainProgram = "evcli";
}
