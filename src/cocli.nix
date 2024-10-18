{
  buildGoModule,
  fetchFromGitHub,
  stdenv,
  lib,
  mockgen_1_6,
}:
buildGoModule {
  pname = "cocli";
  version = "0-unstable-2024-10-09";

  src = fetchFromGitHub {
    owner = "veraison";
    repo = "cocli";
    rev = "4eada92594c009380a5ad73a2db6d76e671d62bd";
    hash = "sha256-6FTCfQIR2ULIZfyK9pKqYwOOCpSrfmKR7N7TZSsrPOc=";
  };

  vendorHash = "sha256-wLW1CbO3rHLl53S/9oe1sIaP5CsRisyvDO3wJbqv7y4=";

  postPatch = ''
    make SHELL=${stdenv.shell} MOCKGEN=${lib.getExe mockgen_1_6} _mocks
  '';

  checkPhase = ''
    runHook preCheck
    make SHELL=${stdenv.shell} MOCKGEN=${lib.getExe mockgen_1_6} test
    runHook postCheck
  '';

  meta.mainProgram = "cocli";
}
