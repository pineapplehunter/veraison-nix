{
  runCommand,
  veraison-services,
  makeWrapper,
  lib,
  openssl,
  evcli,
  pocli,
  cocli,
}:
runCommand "veraison"
  {
    pname = "veraison";
    inherit (veraison-services) src version;
    nativeBuildInputs = [ makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    cp $src/deployments/native/bin/veraison $out/bin
    substituteInPlace $out/bin/veraison \
      --replace-fail ''\'''${_bin_dir}/pocli' "${lib.getExe pocli}" \
      --replace-fail ''\'''${_bin_dir}/evcli' "${lib.getExe evcli}" \
      --replace-fail ''\'''${_bin_dir}/cocli' "${lib.getExe cocli}"
    wrapProgram $out/bin/veraison \
      --suffix PATH : ${lib.makeBinPath [ openssl ]}
  ''
