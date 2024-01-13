{...}: {
  security = {
    sudo.execWheelOnly = true;
    polkit.enable = true;
    rtkit.enable = true;
  };
}
