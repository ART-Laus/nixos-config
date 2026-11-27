# Orpheus music subsystem

Orpheus is the single persistent music engine for this desktop. It has no launcher,
dock icon, or standalone window: the Quickshell bar is the only UI.

## Shape

- `orpheus-daemon.service` (user systemd) starts with `hyprland-session.target`.
- The daemon owns exactly one `mpv` process with ReplayGain enabled.
- Quickshell is a thin IPC client (`OrpheusClient.qml` → `orpheus-ipc`).
- Navidrome is the only library source; all reads/writes go through its Subsonic API.
- MPRIS name: `org.mpris.MediaPlayer2.orpheus`.
- There is no browser bridge: Quickshell is the only music user interface.

Runtime paths:

- IPC: `$XDG_RUNTIME_DIR/orpheus/coordinator.sock` (mode `0600`, peer UID checked)
- mpv IPC: `$XDG_RUNTIME_DIR/orpheus/mpv.sock`
- state: `$XDG_STATE_HOME/orpheus/state.sqlite`
- logs: `journalctl --user -u orpheus-daemon.service`

## Secrets

Navidrome credentials live in `~/.config/carpheus/navidrome.env`, outside the Nix
store. Keys intentionally retain the historical `CARPPHEUS_*` prefix:

- `CARPPHEUS_NAVIDROME_URL`
- `CARPPHEUS_NAVIDROME_USER`
- `CARPPHEUS_NAVIDROME_PASSWORD`

Signed stream URLs and JWTs are never written to logs. Service logs contain only
endpoint names and exception type names.

## Common operations

```sh
systemctl --user status orpheus-daemon.service
systemctl --user restart orpheus-daemon.service

orpheus-ipc call "$XDG_RUNTIME_DIR/orpheus/coordinator.sock" getState '{}'
orpheus-ipc subscribe "$XDG_RUNTIME_DIR/orpheus/coordinator.sock"

busctl --user list | grep orpheus
playerctl -p org.mpris.MediaPlayer2.orpheus status
```

Migrations and build/switch:

```sh
cd ~/nixos-config
nix build .#homeConfigurations.artlaus.activationPackage --no-link --print-out-paths
home-manager switch --flake .#artlaus
```

## Playback behavior

- The coordinator owns the queue, shuffle history, repeat policy and saved state.
- `reportPlayback` and `savePlayQueue` keep Navidrome up to date for `orpheus`.
- Queue order, shuffle, repeat, position, volume, and favourite state are persisted.
- `previous` restarts the current track when position is over four seconds.
- If mpv exits unexpectedly it is restarted and the saved session restored.

See `PROTOCOL.md` for the exact IPC contract.
