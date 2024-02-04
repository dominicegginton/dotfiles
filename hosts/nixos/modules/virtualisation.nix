{...}: {
  virtualisation.vmVariant = {
    users.groups.nixosvmtest = {};
    users.users.nixvmtest = {
      description = "NixOS Test User";
      isNormalUser = true;
      initialPassword = "test";
      group = "nixosvmtest";
    };

    virtualisation = {
      memorySize = 2048;
      cores = 3;
      graphics = false;
    };
  };
}
