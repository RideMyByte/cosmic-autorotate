# cosmic-autorotate

Automatic screen rotation for the [COSMIC desktop](https://system76.com/cosmic) (e.g. Pop!_OS 24.04) on convertibles and 2-in-1 laptops.

COSMIC does not rotate the screen based on the accelerometer yet (see [cosmic-epoch#2103](https://github.com/pop-os/cosmic-epoch/issues/2103)). This small script fills the gap until native support lands: it listens to `iio-sensor-proxy` and rotates the internal display with `cosmic-randr`.

- Auto-detects the internal display and its current mode
- Full rotation or tent mode only (normal ↔ 180°)
- Runs as a systemd user service, no root daemon

## Requirements

- COSMIC desktop (`cosmic-randr` is preinstalled)
- `iio-sensor-proxy` (installed by `install.sh` on apt-based systems)
- A laptop with an accelerometer the kernel recognises

## 1. Check the sensor

```bash
sudo apt install iio-sensor-proxy
monitor-sensor --accel
```

Rotate the device. You should see lines like `Accelerometer orientation changed: bottom-up`.

If it hangs at `Waiting for iio-sensor-proxy to appear`: **reboot once.** `iio-sensor-proxy` is a static systemd unit that udev starts only when it tags a sensor, which usually does not happen right after installing the package. The message `iio-sensor-proxy.service is a disabled or a static unit, not starting it` during installation is normal.

Still nothing after a reboot? Check whether the kernel sees a sensor:

```bash
cat /sys/bus/iio/devices/*/name
```

No `accel_3d` (or similar) there means missing kernel support; this script cannot help in that case.

## 2. Install

```bash
git clone https://github.com/RideMyByte/cosmic-autorotate.git
cd cosmic-autorotate
./install.sh
```

That's it. The service starts now and on every login.

## Settings

`~/.config/cosmic-autorotate.conf`:

| Option     | Default | Meaning |
|------------|---------|---------|
| `ONLY_180` | `0`     | `1` = only normal ↔ 180° (tent mode), ignore portrait |
| `SWAP_90`  | `0`     | `1` = swap the portrait orientations if they are upside down |
| `NATIVE_ROTATION` | `normal` | Compensate for native screen tilt: `normal`, `rotate90`, `rotate180`, `rotate270` |
| `OUTPUT`   | auto    | Display name, e.g. `eDP-1` (see `cosmic-randr list`) |
| `WIDTH` / `HEIGHT` / `REFRESH` | auto | Fixed mode, only if auto-detection fails |

### Native Rotation Compensation

Some devices (e.g., Chuwi MinibookX) have the screen natively tilted or rotated. Use `NATIVE_ROTATION` to compensate:

- **Determine the native tilt**: Hold the device in normal position and check how the OS sees the screen orientation without this script.
- **Set the inverse**: If the screen is naturally rotated 90° clockwise, set `NATIVE_ROTATION="rotate270"` (the inverse rotation).
- Example: Chuwi MinibookX screen is tilted left → `NATIVE_ROTATION="rotate90"` and `SWAP_90=1`

Apply changes with `systemctl --user restart cosmic-autorotate`.

## Usage

```bash
systemctl --user stop cosmic-autorotate      # pause auto-rotation
systemctl --user start cosmic-autorotate     # resume
systemctl --user status cosmic-autorotate    # status
journalctl --user -u cosmic-autorotate -b    # log
```

## Uninstall

```bash
./uninstall.sh
```

Once COSMIC ships native auto-rotation, uninstall this so the two don't fight each other.

## Known limitations

- Touchscreen input mapping is left to COSMIC; please report if touch is misaligned after rotating.
- Only the internal display is rotated.
- COSMIC's XDG autostart (`~/.config/autostart`) did not start the script in testing, hence the systemd user service.

## Tested on

- Dell XPS 2-in-1, Pop!_OS 24.04 (COSMIC), kernel 7.1

Works on your device? A PR adding it here is welcome.

## License

MIT
