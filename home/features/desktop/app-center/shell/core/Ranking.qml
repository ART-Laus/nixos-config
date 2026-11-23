pragma Singleton
import QtQuick

QtObject {
    property real frequencyWeight: 0.6
    property real recencyWeight: 0.4
    property real recentBoost: 0.12
    property real halfLifeDays: 14
    property real frequencyCap: 6

    function usageScore(usage, nowMs) {
        var now = typeof nowMs === "number" && isFinite(nowMs) ? nowMs : Date.now();
        var launches = usage && typeof usage.launches === "number" && isFinite(usage.launches)
                ? Math.max(0, usage.launches) : 0;
        var lastUsed = usage && typeof usage.lastUsed === "number" && isFinite(usage.lastUsed)
                ? usage.lastUsed : NaN;

        var cap = isFinite(frequencyCap) && frequencyCap > 0 ? frequencyCap : 6;
        var frequency = Math.min(Math.log(1 + launches) / Math.LN2, cap);

        var recency = 0;
        var boost = 0;
        if (!isNaN(lastUsed) && lastUsed > 0) {
            var halfLife = isFinite(halfLifeDays) && halfLifeDays > 0 ? halfLifeDays : 14;
            var ageDays = (now - lastUsed) / 86400000;
            if (ageDays < 0) ageDays = 0;
            recency = Math.pow(0.5, ageDays / halfLife);
            if (now - lastUsed >= 0 && now - lastUsed <= 7200000) {
                boost = isFinite(recentBoost) && recentBoost > 0 ? recentBoost : 0;
            }
        }

        var fw = isFinite(frequencyWeight) && frequencyWeight > 0 ? frequencyWeight : 0;
        var rw = isFinite(recencyWeight) && recencyWeight > 0 ? recencyWeight : 0;
        return fw * frequency + rw * recency + boost;
    }

    function compare(a, b, nowMs) {
        var scoreA = usageScore(a, nowMs);
        var scoreB = usageScore(b, nowMs);
        if (scoreA > scoreB) return -1;
        if (scoreA < scoreB) return 1;

        var lastA = a && typeof a.lastUsed === "number" && isFinite(a.lastUsed) ? a.lastUsed : -Infinity;
        var lastB = b && typeof b.lastUsed === "number" && isFinite(b.lastUsed) ? b.lastUsed : -Infinity;
        if (lastA > lastB) return -1;
        if (lastA < lastB) return 1;

        var countA = a && typeof a.launches === "number" && isFinite(a.launches) ? a.launches : 0;
        var countB = b && typeof b.launches === "number" && isFinite(b.launches) ? b.launches : 0;
        if (countA > countB) return -1;
        if (countA < countB) return 1;

        return 0;
    }
}
