// Small presentation helpers. Text is never modified in storage — these
// functions only format the preview shown in the UI.

function escapeHtml(value) {
    return String(value == null ? "" : value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");
}

function escapeRegex(value) {
    return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function highlight(value, query) {
    var safe = escapeHtml(value);
    var terms = String(query || "").trim().split(/\s+/).filter(function (term) { return term.length > 0; });
    for (var i = 0; i < terms.length; i++) {
        var term = escapeRegex(escapeHtml(terms[i]));
        try {
            safe = safe.replace(new RegExp("(" + term + ")", "gi"), "<b style=\"color:#66FF99\">$1</b>");
        } catch (e) {
            // Ignore malformed user input.
        }
    }
    return safe;
}

function relativeTime(ts) {
    var seconds = Math.max(0, Math.floor(Date.now() / 1000 - Number(ts || 0)));
    if (seconds < 60) return "now";
    if (seconds < 3600) return Math.floor(seconds / 60) + "m ago";
    if (seconds < 86400) return Math.floor(seconds / 3600) + "h ago";
    if (seconds < 604800) return Math.floor(seconds / 86400) + "d ago";
    var date = new Date(Number(ts || 0) * 1000);
    return ("0" + (date.getMonth() + 1)).slice(-2) + "." + ("0" + date.getDate()).slice(-2);
}

function kindLabel(kind) {
    switch (kind) {
        case "image": return "IMAGE";
        case "url": return "LINK";
        case "code": return "CODE";
        case "json": return "JSON";
        case "email": return "EMAIL";
        case "color": return "COLOR";
        case "file": return "FILE";
        default: return "TEXT";
    }
}
