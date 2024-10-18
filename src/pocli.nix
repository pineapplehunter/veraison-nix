{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pocli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "veraison";
    repo = "pocli";
    rev = "v${version}";
    hash = "sha256-QAYKIxC/vywMn6VPCeRt1aRdaOEcjIlOMIN/lAdbSBs=";
  };

  vendorHash = "sha256-Sal0rHRaCrCasYDnj0Fd17FD8EzXAdcQPAvIl/IfsRw=";

  meta.mainProgram = "pocli";
}
