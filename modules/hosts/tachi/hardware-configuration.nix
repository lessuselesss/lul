# Hardware configuration for tachi
# Intel 11th Gen i7-1165G7 laptop
{
  flake.modules.nixos.tachi = {

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];

    boot.kernelModules = [ "kvm-intel" ];

    # Enable Intel integrated graphics
    hardware.graphics.enable = true;

    # Enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

  };
}
