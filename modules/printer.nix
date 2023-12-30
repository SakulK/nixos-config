{ pkgs, ... }:

let printerIp = "192.168.100.15";
in {
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
