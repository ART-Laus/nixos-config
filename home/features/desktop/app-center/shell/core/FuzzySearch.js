.pragma library

var MATCH_BONUS = 10;
var WORD_START_BONUS = 8;
var CONSECUTIVE_BONUS = 6;
var PREFIX_BONUS = 12;
var GAP_PENALTY = 0.6;
var LENGTH_PENALTY = 0.08;

function normalize(s) {
    if (s === null || s === undefined) return "";
    return String(s).trim().toLowerCase();
}

function _fold(s) {
    if (s === null || s === undefined) return [];
    var chars = Array.from(String(s));
    var out = new Array(chars.length);
    for (var i = 0; i < chars.length; i++) {
        var lower = Array.from(chars[i].toLowerCase());
        out[i] = lower.length > 0 ? lower[0] : chars[i];
    }
    return out;
}

function _isSeparator(c) {
    return c === " " || c === "-" || c === "_" || c === "/" || c === ".";
}

function _startScore(text, index) {
    var s = MATCH_BONUS;
    if (index === 0) s += PREFIX_BONUS;
    return s - GAP_PENALTY * index;
}

function _wordStart(text, index) {
    return index === 0 || _isSeparator(text[index - 1]);
}

function score(query, text) {
    var q = _fold(normalize(query));
    var t = _fold(text);
    var qlen = q.length;
    var tlen = t.length;
    if (qlen === 0 || tlen === 0 || qlen > tlen) return null;

    var backs = new Array(qlen + 1);
    var prevRow = null;

    for (var i = 1; i <= qlen; i++) {
        var row = new Array(tlen + 1);
        var back = new Array(tlen + 1);
        for (var j = 0; j <= tlen; j++) {
            row[j] = -Infinity;
            back[j] = 0;
        }
        var gapBest = -Infinity;
        var gapBestK = 0;

        for (var pos = 1; pos <= tlen; pos++) {
            if (q[i - 1] === t[pos - 1]) {
                var best = _startScore(t, pos - 1);
                var from = 0;

                if (prevRow !== null && pos >= 2 && isFinite(prevRow[pos - 1])) {
                    var consecutive = prevRow[pos - 1] + CONSECUTIVE_BONUS;
                    if (consecutive > best) {
                        best = consecutive;
                        from = pos - 1;
                    }
                }

                if (gapBest !== -Infinity) {
                    var gapped = gapBest - GAP_PENALTY * (pos - 1);
                    if (gapped > best) {
                        best = gapped;
                        from = gapBestK;
                    }
                }

                if (_wordStart(t, pos - 1)) best += WORD_START_BONUS;

                row[pos] = best;
                back[pos] = from;
            }

            var k = pos - 1;
            if (prevRow !== null && k >= 1 && isFinite(prevRow[k])) {
                var candidate = prevRow[k] + GAP_PENALTY * k;
                if (candidate > gapBest) {
                    gapBest = candidate;
                    gapBestK = k;
                }
            }
        }

        backs[i] = back;
        prevRow = row;
    }

    var lastIndex = 0;
    var bestScore = -Infinity;
    for (var m = 1; m <= tlen; m++) {
        if (prevRow[m] > bestScore) {
            bestScore = prevRow[m];
            lastIndex = m;
        }
    }
    if (lastIndex === 0 || !isFinite(bestScore)) return null;

    var indices = new Array(qlen);
    var cursor = lastIndex;
    for (var n = qlen; n >= 1; n--) {
        indices[n - 1] = cursor - 1;
        cursor = backs[n][cursor];
        if (n > 1 && cursor === 0) return null;
    }

    bestScore -= Math.max(0, tlen - 12) * LENGTH_PENALTY;
    return { score: bestScore, indices: indices };
}

function best(query, fields) {
    if (!fields || typeof fields.length !== "number") return null;

    var topScore = -Infinity;
    var topIndices = null;
    var topField = -1;

    for (var i = 0; i < fields.length; i++) {
        var field = fields[i];
        if (!field || field.text === null || field.text === undefined) continue;

        var match = score(query, field.text);
        if (match === null) continue;

        var weight = field.weight;
        if (typeof weight !== "number" || !isFinite(weight)) weight = 1;
        if (weight < 0) weight = 0;

        var weighted = match.score * weight;
        if (weighted > topScore) {
            topScore = weighted;
            topIndices = match.indices;
            topField = i;
        }
    }

    if (topField < 0) return null;
    return { score: topScore, indices: topIndices, fieldIndex: topField };
}

function _escapeChar(c) {
    if (c === "&") return "&amp;";
    if (c === "<") return "&lt;";
    if (c === ">") return "&gt;";
    if (c === "\"") return "&quot;";
    if (c === "'") return "&#39;";
    return c;
}

function marked(text, indices) {
    var chars = Array.from(text === null || text === undefined ? "" : String(text));
    var hits = {};

    if (indices && typeof indices.length === "number") {
        for (var i = 0; i < indices.length; i++) {
            var idx = indices[i];
            if (typeof idx === "number" && idx >= 0 && idx < chars.length && Math.floor(idx) === idx) {
                hits[idx] = true;
            }
        }
    }

    var out = "";
    var pos = 0;
    while (pos < chars.length) {
        if (hits[pos]) {
            var run = "";
            while (pos < chars.length && hits[pos]) {
                run += _escapeChar(chars[pos]);
                pos++;
            }
            out += "<b style=\"color:#66FF99\">" + run + "</b>";
        } else {
            out += _escapeChar(chars[pos]);
            pos++;
        }
    }
    return out;
}
