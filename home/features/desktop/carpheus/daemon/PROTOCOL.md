# Orpheus IPC protocol

Transport: Unix socket `$XDG_RUNTIME_DIR/orpheus/coordinator.sock`, mode `0600`.
Framing: newline-delimited UTF-8 JSON. Peer UID is checked with `SO_PEERCRED`;
the socket is never bound to a network address. Requests are bounded and method
names are validated before dispatch.

```json
{"id": 7, "method": "getState", "params": {}}
```

```json
{"id": 7, "ok": true, "result": {"...": "..."}}
```

```json
{"id": 7, "ok": false, "error": {"code": "error", "message": "..."}}
```

## Invariants

- `orpheus-daemon` is the only coordinator and the only owner of mpv.
- mpv is the only audio engine; QML never talks to mpv or Navidrome directly.
- All library reads and writes go through this IPC and the daemon's single
  Subsonic/OpenSubsonic client.
- `state.source` is always `local`; mpv is the only playback engine.
- The coordinator owns queue order, shuffle history and repeat policy. mpv keeps
  the same playlist order so indices in the UI remain meaningful.
- All transport and queue commands are applied to the coordinator-owned session;
  no browser or external Subsonic client can take over playback.
- `reportPlayback` and `savePlayQueue` use `playerName=orpheus`; server
  `nowPlaying` entries are never consumed as local state.
- Scrobbles are sent once per `(song id, queue index)` when a track reaches its
  end or is skipped past the halfway/4-minute mark.
- Signed stream URLs and JWTs are never logged. mpv command logs are redacted.

## Methods

### State and diagnostics

| Method | Params | Result |
|---|---|---|
| `ping` | — | version, backend, connection status, server reachability |
| `getState` | — | full state snapshot |

### Library reads

| Method | Params | Result |
|---|---|---|
| `search` | `query`, `artistOffset`, `albumOffset`, `songOffset`, `artistCount`, `albumCount`, `songCount` | `searchResult3` |
| `getArtists` | optional `id` | `artists` |
| `getAlbumList2` | `type`, `size`, `offset`, optional `genre`, `year`, `fromYear`, `toYear` | `albumList2` |
| `getGenres` | — | `genres` |
| `getSongsByGenre` | `genre`, `count`, `offset` | `songsByGenre` |
| `getStarred2` | `artistCount`, `albumCount`, `songCount` | `starred2` |
| `getAlbum` / `getArtist` / `getSong` | `id` | single library entity |
| `getRandom` | `count` | `randomSongs` |
| `getScanStatus` | — | `scanStatus` |
| `getLyrics` | `id` or `title` + `artist` | Subsonic lyrics payload |
| `getCoverArt` | `id`, `size` | `{ "id", "path" }` in local cache |

Supported `getAlbumList2` types: `alphabeticalByName`, `alphabeticalByArtist`,
`byGenre`, `byYear`, `frequent`, `highest`, `newest`, `random`, `recent`,
`starred`. All list calls are paginated; the UI must not request the whole
library at once.

### Playlists and library writes

| Method | Params | Purpose |
|---|---|---|
| `getPlaylists` | — | list playlists |
| `getPlaylist` | `id` | playlist with songs |
| `createPlaylist` | `name` | create playlist |
| `updatePlaylist` | `id`, optional `name`, `comment`, `public`, `songIdsToAdd`, `songIndexToRemove` | edit playlist |
| `deletePlaylist` | `id` | delete playlist |
| `setFavorite` | `id`, `value` | star/unstar any song |
| `setRating` | `id`, `rating` (0..5) | rate a song |
| `quickScan` | — | start a quick Navidrome scan |

### Playback and queue

| Method | Params | Purpose |
|---|---|---|
| `playTrack` | `id` or `ids` | play one or more songs |
| `playQueue` | `ids`, `index` | replace queue and play |
| `playAlbum` / `playPlaylist` | `id` | play a library collection |
| `queueAdd` | `ids`, optional `next` | append songs or insert after current |
| `playNext` | `ids` | shorthand for `queueAdd` with `next=true` |
| `queueRemove` | `index` or `id` | remove a queue entry |
| `queueMove` | `from`, `to` | reorder queue |
| `queueClear` | — | stop and clear queue |
| `queueShuffle` | — | randomise queue order, keeping current first |
| `play`, `pause`, `togglePlay` | — | transport |
| `stop` | — | stop, report and clear |
| `next`, `previous` | — | queue navigation |
| `seek` | `seconds` | relative seek |
| `seekAbsolute` | `seconds` | absolute seek |
| `setShuffle` | `value` | coordinator-owned shuffle |
| `setRepeat` | `value` | 0=off, 1=all, 2=one |
| `setVolume` | `value` (0..1) | volume; unmutes when >0 |
| `setMute` | optional `value` | mute toggle/set |
| `toggleFavorite` | — | star/unstar current song |

## Events

```json
{"event": "stateChanged", "data": {"...": "..."}}
```

`stateChanged` is broadcast on every state mutation. Clients should ignore
payloads with an older `revision`. The Navidrome SSE connection is used only as
a server-liveness signal; it never mutates local playback state.

## State fields

`revision`, `source`, `status`, `track`, `queue`, `queueIndex`, `history`,
`position`, `duration`, `shuffle`, `repeat`, `volume`, `mute`, `buffering`,
`favorite`, `connectionStatus`, `connectionText`, `backend`, `lastError`,
`version`.

`connectionStatus` is `connecting`, `connected`, `degraded` or `offline`.
`lastError` is cleared as soon as the daemon recovers.
