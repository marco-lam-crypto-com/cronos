{ dockerTools, runCommandLocal, cronos-matrix, testground-testcase }:
let
  patched-cronosd = cronos-matrix.cronosd.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches or [ ] ++ [
      ./testground-cronosd.patch
    ];
  });
in
let
  tmpDir = runCommandLocal "tmp" { } ''
    mkdir -p $out/tmp/
  '';
  outputDir = runCommandLocal "output" { } ''
    mkdir -p $out/output/
  '';
in
dockerTools.buildLayeredImage {
  name = "cronos-testground";
  created = "now";
  contents = [
    testground-testcase
    patched-cronosd
    tmpDir
    outputDir
  ];
  config = {
    Expose = [ 9090 26657 26656 1317 26658 26660 26659 30000 ];
    Cmd = [ "/bin/testground-testcase" ];
    Env = [
      "PYTHONUNBUFFERED=1"
    ];
  };
}
