.pragma library

// Pure data helpers for the notification center. No QML, no filesystem, no timers.
// Every notification is stored as a plain validated row and is never removed by
// this module: only explicit user actions in NotificationStore change status.

var VERSION = 1;
var STATUSES = ["unread", "read", "archived", "dismissed"];
var CATEGORIES = ["personal", "system"];

function finite(value, fallback) {
  var number = Number(value);
  return isFinite(number) ? number : fallback;
}

function str(value, max) {
  var text = value === undefined || value === null ? "" : String(value);
  if (max > 0 && text.length > max) text = text.slice(0, max);
  return text;
}

function cleanStatus(value) {
  var status = str(value, 24).toLowerCase();
  return STATUSES.indexOf(status) >= 0 ? status : "unread";
}

function cleanCategory(value) {
  var category = str(value, 24).toLowerCase();
  return CATEGORIES.indexOf(category) >= 0 ? category : "system";
}

function cleanUrgency(value) {
  var urgency = str(value, 24).toLowerCase();
  if (urgency === "low" || urgency === "critical") return urgency;
  return "normal";
}

function urgencyFromApi(value) {
  // NotificationUrgency is Low=0, Normal=1, Critical=2 in Quickshell 0.3.0.
  var number = Number(value);
  if (number === 0) return "low";
  if (number === 2) return "critical";
  return "normal";
}

function hintsObject(value) {
  var out = {};
  if (!value || typeof value !== "object" || Array.isArray(value)) return out;
  var keys = ["sender", "chat", "title", "message", "message-id", "x-telegram-chat",
              "x-telegram-from", "x-telegram-message-id"];
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i];
    if (value[key] !== undefined && value[key] !== null) out[key] = str(value[key]);
  }
  return out;
}

function appIdOf(row) {
  var desktop = str(row && row.desktopEntry, 240).trim().toLowerCase();
  if (desktop) return desktop;
  var app = str(row && row.appName, 240).trim().toLowerCase();
  return app || "unknown-app";
}

function makeKey(row, sequence, existing) {
  var base = appIdOf(row) + "|" + str(row && row.timestamp, 32) + "|" +
             str(row && row.summary, 256) + "|" + str(row && row.body, 512);
  var key = base.replace(/[^A-Za-z0-9._|:-]/g, "_").slice(0, 900) + "|" + Math.floor(finite(sequence, 0));
  if (!existing || existing.indexOf(key) === -1) return key;
  var n = Math.floor(finite(sequence, 0)) + 1;
  while (existing.indexOf(key) !== -1) {
    key = base.replace(/[^A-Za-z0-9._|:-]/g, "_").slice(0, 860) + "|" + n;
    n++;
  }
  return key;
}

function splitSender(summary, body) {
  var text = str(body);
  var title = str(summary).trim();
  var match = text.match(/^([A-Za-z0-9._\u00C0-\u024F\u0400-\u04FF\u0900-\u097F -]{1,24}):[ \t]+([\s\S]+)$/);
  var candidate = match ? match[1].trim() : "";
  if (candidate && candidate.split(/\s+/).length <= 3 && !/^(https?|ftp|mailto)$/i.test(candidate)) {
    return { sender: candidate, chat: title, body: text };
  }
  return { sender: "", chat: title, body: text };
}

var PERSONAL_APPS = [
  "telegram", "telegramdesktop", "org.telegram.desktop", "ayugram", "ru.ayu.gram",
  "discord", "com.discordapp.discord", "matrix", "element", "org.matrix.element",
  "signal", "org.signal.signal", "whatsapp", "messenger", "slack", "teams",
  "thunderbird", "evolution", "geary", "kmail", "gmail", "outlook", "mail",
  "telegram-cli", "tdesktop", "tox", "session", "wire", "viber", "line"
];

var SYSTEM_APPS = [
  "systemd", "upower", "networkmanager", "bluetooth", "blueman", "udiskie",
  "nix", "nixos", "hyprland", "pipewire", "pulseaudio", "wireplumber", "elogind",
  "dbus", "cron", "backup", "update", "packagekit", "fwupd", "screenshot",
  "screenshots", "battery", "power", "disk", "mount", "notification-daemon"
];

var PERSONAL_TITLE_RE = /(^|[^a-z])(message|chat|reply|mention|direct message|new post)([^a-z]|$)/i;
var SYSTEM_TITLE_RE = /(^|[^a-z])(update|battery|power|disk|network|bluetooth|error|warning|failed|critical|backup|login|security|system)([^a-z]|$)/i;

function includesAny(haystack, needles) {
  var lower = str(haystack, 1200).toLowerCase();
  for (var i = 0; i < needles.length; i++) if (lower.indexOf(needles[i]) >= 0) return true;
  return false;
}

function classify(row, overrides) {
  var app = appIdOf(row);
  var rules = (overrides && overrides[app]) || (overrides && overrides[str(row && row.appName, 240).toLowerCase()]);
  if (rules && rules.category) return cleanCategory(rules.category);

  if (includesAny(app + " " + str(row && row.desktopEntry, 240), PERSONAL_APPS)) return "personal";
  if (includesAny(app + " " + str(row && row.desktopEntry, 240), SYSTEM_APPS)) return "system";

  var text = str(row && row.summary, 600) + " " + str(row && row.body, 1200);
  if (PERSONAL_TITLE_RE.test(text) && !SYSTEM_TITLE_RE.test(text)) return "personal";
  if (SYSTEM_TITLE_RE.test(text)) return "system";

  // Unknown senders default to System, which is less intrusive than assuming chat.
  return "system";
}

function fromNotification(notif, nowMs, sequence, existing, overrides) {
  var appName = str(notif && notif.appName, 240) || "Notification";
  var desktopEntry = str(notif && notif.desktopEntry, 240);
  var summary = str(notif && notif.summary);
  var body = str(notif && notif.body);
  var parsed = splitSender(summary, body);
  var hints = hintsObject(notif && notif.hints);

  var row = {
    appName: appName,
    desktopEntry: desktopEntry,
    appIcon: str(notif && notif.appIcon, 400),
    summary: summary,
    body: parsed.body,
    sender: str(hints.sender || hints["x-telegram-from"] || parsed.sender),
    chat: str(hints.chat || hints["x-telegram-chat"] || parsed.chat || summary || appName),
    image: str(notif && notif.image, 600),
    urgency: urgencyFromApi(notif && notif.urgency),
    timestamp: Math.max(1, Math.floor(finite(nowMs, Date.now()))),
    hints: hints
  };
  row.appId = appIdOf(row);
  row.category = classify(row, overrides);
  if (row.category === "personal" && !row.sender && row.summary &&
      row.summary.toLowerCase() !== appName.toLowerCase()) {
    row.sender = row.summary;
  }
  row.status = "unread";
  row.key = makeKey(row, sequence, existing);
  row.sourceId = str(notif && notif.id, 64);
  return row;
}

function payloadSignature(row) {
  return appIdOf(row) + "|" + str(row && row.summary) + "|" + str(row && row.body) +
         "|" + str(row && row.urgency, 24) + "|" + str(row && row.image, 600);
}

function isReloadDuplicate(entries, notif, nowMs) {
  if (!notif || !notif.lastGeneration) return false;
  var signature = payloadSignature({
    appId: str(notif.appName, 240).toLowerCase(),
    desktopEntry: str(notif.desktopEntry, 240),
    summary: str(notif.summary),
    body: str(notif.body),
    urgency: urgencyFromApi(notif.urgency),
    image: str(notif.image, 600)
  });
  var id = str(notif.id, 64);
  for (var i = 0; i < entries.length; i++) {
    var row = entries[i];
    if (row && (row.sourceId === id || payloadSignature(row) === signature) &&
        Math.abs(nowMs - finite(row.timestamp, 0)) < 15 * 60 * 1000) {
      return true;
    }
  }
  return false;
}

function cleanRow(raw) {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return null;
  var key = str(raw.key, 960);
  if (!key) return null;
  var row = {
    key: key,
    sourceId: str(raw.sourceId, 64),
    appId: str(raw.appId, 240) || appIdOf(raw),
    appName: str(raw.appName, 240) || "Notification",
    desktopEntry: str(raw.desktopEntry, 240),
    appIcon: str(raw.appIcon, 400),
    summary: str(raw.summary),
    body: str(raw.body),
    sender: str(raw.sender),
    chat: str(raw.chat) || str(raw.summary) || "Notification",
    image: str(raw.image, 600),
    urgency: cleanUrgency(raw.urgency),
    timestamp: Math.max(1, Math.floor(finite(raw.timestamp, Date.now()))),
    category: cleanCategory(raw.category),
    status: cleanStatus(raw.status),
    hints: hintsObject(raw.hints)
  };
  if (!row.appId) row.appId = appIdOf(row);
  return row;
}

function historyLooksValid(text) {
  var raw = String(text || "");
  if (!raw) return false;
  var data;
  try { data = JSON.parse(raw); } catch (error) { return false; }
  return !!data && typeof data === "object" && (Array.isArray(data) || Array.isArray(data.entries));
}

function parseHistory(text) {
  var raw = String(text || "");
  if (!raw) return [];
  var data;
  try { data = JSON.parse(raw); } catch (error) { return []; }
  if (!data || typeof data !== "object") return [];
  var source = Array.isArray(data) ? data : data.entries;
  if (!Array.isArray(source)) return [];
  var out = [];
  for (var i = 0; i < source.length; i++) {
    var row = cleanRow(source[i]);
    if (row) out.push(row);
  }
  out.sort(function(a, b) { return b.timestamp - a.timestamp; });
  return out;
}

function serialiseEntry(row) {
  return {
    key: str(row.key, 960),
    sourceId: str(row.sourceId, 64),
    appId: str(row.appId, 240),
    appName: str(row.appName, 240),
    desktopEntry: str(row.desktopEntry, 240),
    appIcon: str(row.appIcon, 400),
    summary: str(row.summary),
    body: str(row.body),
    sender: str(row.sender),
    chat: str(row.chat),
    image: str(row.image, 600),
    urgency: cleanUrgency(row.urgency),
    timestamp: Math.max(1, Math.floor(finite(row.timestamp, Date.now()))),
    category: cleanCategory(row.category),
    status: cleanStatus(row.status),
    hints: hintsObject(row.hints)
  };
}

function serialiseHistory(entries) {
  var rows = [];
  var source = entries || [];
  for (var i = 0; i < source.length; i++) {
    if (source[i]) rows.push(serialiseEntry(source[i]));
  }
  return JSON.stringify({ version: VERSION, entries: rows }, null, 2) + "\n";
}

function formatTime(timestamp) {
  var then = new Date(Math.max(1, finite(timestamp, Date.now())));
  var now = new Date();
  var pad = function (value) { return value < 10 ? "0" + value : String(value); };
  var time = pad(then.getHours()) + ":" + pad(then.getMinutes());
  if (then.toDateString() === now.toDateString()) return time;
  return then.getDate() + "." + (then.getMonth() + 1) + " " + time;
}

function parseState(text) {
  var out = { version: VERSION, expandedGroups: {}, view: { category: "all", status: "inbox" } };
  var raw = String(text || "");
  if (!raw) return out;
  var data;
  try { data = JSON.parse(raw); } catch (error) { return out; }
  if (!data || typeof data !== "object") return out;
  if (data.expandedGroups && typeof data.expandedGroups === "object" && !Array.isArray(data.expandedGroups))
    out.expandedGroups = data.expandedGroups;
  if (data.view && typeof data.view === "object") {
    var category = str(data.view.category, 24);
    var status = str(data.view.status, 24);
    out.view.category = category === "personal" || category === "system" ? category : "all";
    out.view.status = status === "archived" || status === "dismissed" || status === "all" ? status : "inbox";
  }
  return out;
}

function serialiseState(state) {
  return JSON.stringify({
    version: VERSION,
    expandedGroups: (state && state.expandedGroups) || {},
    view: (state && state.view) || { category: "all", status: "inbox" }
  }, null, 2) + "\n";
}

function parseRules(text) {
  var raw = String(text || "");
  if (!raw) return {};
  var data;
  try { data = JSON.parse(raw); } catch (error) { return {}; }
  if (!data || typeof data !== "object") return {};
  var overrides = (data.overrides && typeof data.overrides === "object" && !Array.isArray(data.overrides))
    ? data.overrides : {};
  var out = {};
  for (var key in overrides) {
    if (!/^[A-Za-z0-9._@:+/-]{1,240}$/.test(key)) continue;
    var category = cleanCategory(overrides[key] && overrides[key].category);
    out[key.toLowerCase()] = { category: category };
  }
  return out;
}

function setStatus(entries, key, status) {
  var statusValue = cleanStatus(status);
  var out = entries.slice();
  for (var i = 0; i < out.length; i++) {
    if (out[i] && out[i].key === key) {
      var next = out[i];
      next.status = statusValue;
      out[i] = next;
      return out;
    }
  }
  return entries;
}

function setManyStatus(entries, keys, status) {
  var statusValue = cleanStatus(status);
  var wanted = {};
  for (var i = 0; i < keys.length; i++) wanted[keys[i]] = true;
  var out = entries.slice();
  for (var j = 0; j < out.length; j++) {
    if (out[j] && wanted[out[j].key]) {
      var next = out[j];
      next.status = statusValue;
      out[j] = next;
    }
  }
  return out;
}

function remove(entries, key) {
  var out = [];
  for (var i = 0; i < entries.length; i++) if (entries[i] && entries[i].key !== key) out.push(entries[i]);
  return out;
}

function unreadCount(entries) {
  var count = 0;
  for (var i = 0; i < entries.length; i++) if (entries[i] && entries[i].status === "unread") count++;
  return count;
}

function groupKey(row) {
  return row.category + "|" + row.appId + "|" + str(row.chat, 300).toLowerCase();
}

function visibleEntries(entries, view) {
  var category = view && view.category ? view.category : "all";
  var status = view && view.status ? view.status : "inbox";
  var out = [];
  for (var i = 0; i < entries.length; i++) {
    var row = entries[i];
    if (!row) continue;
    if (category !== "all" && row.category !== category) continue;
    if (status === "inbox" && (row.status !== "unread" && row.status !== "read")) continue;
    if (status === "archived" && row.status !== "archived") continue;
    if (status === "dismissed" && row.status !== "dismissed") continue;
    out.push(row);
  }
  return out;
}

function groupRows(entries, expanded) {
  var groups = [];
  var index = {};
  for (var i = 0; i < entries.length; i++) {
    var row = entries[i];
    var key = groupKey(row);
    if (!index[key]) {
      var group = {
        key: key,
        appId: row.appId,
        appName: row.appName,
        appIcon: row.appIcon,
        chat: row.chat,
        category: row.category,
        count: 0,
        unread: 0,
        latest: row,
        rows: []
      };
      index[key] = group;
      groups.push(group);
    }
    var target = index[key];
    target.rows.push(row);
    target.count++;
    if (row.status === "unread") target.unread++;
    if (row.timestamp > target.latest.timestamp) target.latest = row;
  }
  for (var j = 0; j < groups.length; j++) {
    groups[j].open = !!(expanded && expanded[groups[j].key]);
    groups[j].rows.sort(function(a, b) { return b.timestamp - a.timestamp; });
  }
  return groups;
}
