{ pkgs, ... }:

let printerIp = "192.168.1.13";
in {
  imports = [
    <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
  ];

  services.printing.enable = true;
  hardware.printers.ensurePrinters = [{
    name = "DCP-T710W";
    model = "everywhere";
    deviceUri = "ipp://${printerIp}/";
  }];

  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "DCP-T710W";
          ip = printerIp;
        };
      };
    };
  };
}
