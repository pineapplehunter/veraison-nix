{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "veraison-services";
  version = "0.0.2410";

  src = fetchFromGitHub {
    owner = "veraison";
    repo = "services";
    rev = "v${version}";
    hash = "sha256-rqshKj4Ya6m6ptQE796AjAKvmZFBUq4yzuI79lo5EFo=";
  };

  vendorHash = "sha256-GYMu0qhHQG5vD4F0llN0gbp7Gyb5ZEXtBuU6ssHBnR0=";

  # prevent network access
  doCheck = false;
}
