with import <nixpkgs> { };

rustPlatform.buildRustPackage rec {
  name = "lcat-${version}";
  version = "0.1.2";
  src = fetchFromGitHub {
    owner = "SakulK";
    repo = "lcat";
    rev = "30b2c7c6148bc2e1807a8f06f14d09412bb6c991";
    sha256 = "0pq96h2nzjyy5ryay3zf5h2fzih6kjwzpjbzp4934ns0nxcpxf2s";
  };

  buildInputs = [ ];

  checkPhase = "";
  cargoSha256 = "sha256:1lywzv8kzcqr7vny96jq08fbcjyw0l0infmgvgg09ark8xl5h395";

  meta = with lib; {
    description =
      "Command line utility to read log files in the logstash json format";
    homepage = "https://github.com/SakulK/lcat";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
