final: prev: {
  mihomo = final.buildGoModule rec {
    pname = "mihomo";
    version = "1.19.26";

    src = final.fetchFromGitHub {
      owner = "MetaCubeX";
      repo = "mihomo";
      rev = "v${version}";
      hash = "sha256-As0MqIGHs1Gn+aUWpeFsC231n9v7lBNmGlQdAwVWcJs=";
    };

    vendorHash = "sha256-ySpBMR/djPPs1aTw7yiCrCFxDFsvRfTJEChg8v1C408=";

    excludedPackages = [ "./test" ];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/metacubex/mihomo/constant.Version=${version}"
    ];

    tags = [
      "with_gvisor"
    ];

    doCheck = false;
  };
}
