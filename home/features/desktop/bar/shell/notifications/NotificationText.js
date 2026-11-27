.pragma library

// Rich text is built deliberately: all sender/app/message content is escaped,
// then only safe http(s) URLs are turned into anchors. This keeps full text,
// wrapping, Unicode and emoji without trusting arbitrary notification markup.

function escapeHtml(value) {
  return String(value === undefined || value === null ? "" : value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

function safeUrl(raw) {
  var text = String(raw === undefined || raw === null ? "" : raw).trim();
  if (!/^https?:\/\//i.test(text)) return "";
  if (/[\s<>"']/.test(text)) return "";
  return text;
}

function linkifyEscaped(text, linkColor) {
  var color = linkColor || "#66FF99";
  return String(text || "").replace(/https?:\/\/[^\s<>"'&]+(?:(?:&amp;)[^\s<>"'&]*)*/gi, function(url) {
    var real = url.replace(/&amp;/g, "&");
    var safe = safeUrl(real);
    return safe ? '<a href="' + escapeHtml(safe) + '" style="color:' + color + '">' + url + "</a>" : url;
  });
}

function formatBody(value, linkColor) {
  var text = String(value === undefined || value === null ? "" : value);
  text = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  return linkifyEscaped(escapeHtml(text), linkColor).replace(/\n/g, "<br>");
}

function cardText(row, colors) {
  var palette = colors || {};
  var senderColor = palette.sender || "#66FF99";
  var chatColor = palette.chat || "#C4A0FF";
  var linkColor = palette.link || senderColor;
  var sender = escapeHtml((row && row.sender) || (row && row.appName) || "Notification");
  var chat = row && row.chat ? escapeHtml(row.chat) : "";
  var heading = chat && chat !== sender
    ? sender + ' <span style="color:' + chatColor + '">' + chat + '</span>'
    : sender;
  return '<span style="color:' + senderColor + '; font-weight:600">' + heading + '</span><br>' +
    formatBody(row && row.body, linkColor);
}

function compactText(row, colors) {
  var palette = colors || {};
  var senderColor = palette.sender || "#66FF99";
  var linkColor = palette.link || senderColor;
  var sender = escapeHtml((row && row.sender) || (row && row.appName) || "Notification");
  return '<span style="color:' + senderColor + '; font-weight:600">' + sender + '</span> ' +
    formatBody(row && row.body, linkColor);
}
