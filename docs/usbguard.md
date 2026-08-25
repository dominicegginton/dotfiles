# USBGuard Whitelisting & Device Discovery

USBGuard enforces bus-level authorization policies for USB devices. When a new USB device is blocked or needs to be whitelisted permanently, use the following imperative commands to discover its attributes and add it to your NixOS configuration.

## 1. Discovering USB Devices

To inspect connected USB devices and find their vendor/product IDs, serial numbers, or device hashes:

```bash
# List all USB devices tracked by USBGuard (requires elevation)
run0 usbguard list-devices

# Alternatively, list raw USB devices on the bus
lsusb
```

Example `usbguard list-devices` output:
```text
15: allow id 1050:0407 serial "0008123456" name "YubiKey OTP+FIDO+CCID" ...
18: block id 18d1:4ee1 serial "12345678" name "Pixel 9" ...
```

## 2. Whitelisting Devices Declaratively

Once you identify the target device ID (e.g. `18d1:4ee1`), update your host or module configuration.

### Option A: Global or Module Rule (`modules/services/usbguard.nix`)
Add an `allow` rule to `services.usbguard.extraRules`:

```nix
services.usbguard.extraRules = ''
  allow id 18d1:4ee1
'';
```

### Option B: Rule by Serial Number or Interface
For stricter matching:

```nix
services.usbguard.extraRules = ''
  allow id 18d1:4ee1 serial "12345678"
'';
```

## 3. Temporary / Runtime Authorization

To temporarily allow a blocked device during the current session without modifying NixOS config:

```bash
# Allow device by ID number from 'usbguard list-devices'
run0 usbguard allow-device 18
```
