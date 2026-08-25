# USBGuard Whitelisting & Policy Management

USBGuard controls access to USB devices. All permanent device policies are fully managed inside encrypted SOPS secrets (`sops-nix`) to prevent hardware cloning/spoofing attacks on public dotfiles repositories.

---

## 1. Show USB Devices

To show connected USB devices and find device IDs or serial numbers:

```bash
# Show all USB devices in USBGuard
run0 usbguard list-devices

# Show USB devices on the bus
lsusb
```

Example `usbguard list-devices` output:

```text
15: allow id 1050:0407 serial "0008123456" name "YubiKey OTP+FIDO+CCID" ...
18: block id 18d1:4ee1 serial "12345678" name "Pixel 9" ...
```

## 2. Managing the Whitelist Policy

All allowed devices and system defaults are defined inside `secrets/global.yaml` under `services/usbguard/rules`:

1. Open global SOPS secrets:
   ```bash
   sops secrets/global.yaml
   ```
2. Define the complete rule policy under the `services/usbguard/rules` key:
   ```yaml
   services:
     usbguard:
       rules: |
         allow id 0000:0000
   ```

## 3. Allow Devices Temporarily

To allow a blocked USB device during your current session:

```bash
# Allow the device by ID number from 'usbguard list-devices'
run0 usbguard allow-device 18
```
