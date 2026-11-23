pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config
import qs.scripthub

QtObject {
    id: root

    property var tasks: []
    property var lastTask: ({})
    property int timeoutCheckInterval: 1000

    signal tasksUpdated()
    signal taskFinished(var task)

    property Component taskComponent: Component {
        QtObject {
            id: task

            property string id: ""
            property string name: ""
            property string status: "queued"
            property string commandDisplay: ""
            property string stdoutText: ""
            property string stderrText: ""
            property string workingDirectory: ""
            property var command: []
            property bool cancelled: false
            property bool timedOut: false
            property bool killing: false
            property bool detached: false
            property int processIdValue: 0
            property int exitCodeValue: -1
            property int startedAt: 0
            property int endedAt: 0
            property int timeoutMs: 0
            property Process process: Process {
                id: taskProcess
                command: task.command
                workingDirectory: task.workingDirectory
                stdout: StdioCollector {
                    id: taskOut
                    onStreamFinished: function () {
                        task.stdoutText = this.text;
                    }
                }
                stderr: StdioCollector {
                    id: taskErr
                    onStreamFinished: function () {
                        task.stderrText = this.text;
                    }
                }
                onStarted: function () {
                    task.processIdValue = taskProcess.processId || 0;
                    task.startedAt = Date.now();
                    task.status = "running";
                    root.tasksUpdated();
                }
                onExited: function (code, status) {
                    task.exitCodeValue = code;
                    task.endedAt = Date.now();
                    task.forceTimer.stop();
                    if (task.timedOut) task.status = "timeout";
                    else if (task.cancelled || task.killing) task.status = "cancelled";
                    else task.status = code === 0 ? "success" : "failed";
                    root.finishTask(task);
                }
            }
            property Timer forceTimer: Timer {
                id: forceTimer
                interval: 1200
                repeat: false
                onTriggered: function () {
                    task.killing = true;
                    if (taskProcess.running) taskProcess.signal(9);
                }
            }

            function start() {
                task.startedAt = Date.now();
                task.status = "starting";
                taskProcess.running = true;
            }

            function startDetached() {
                task.startedAt = Date.now();
                task.endedAt = Date.now();
                task.detached = true;
                task.status = "detached";
                taskProcess.startDetached();
                root.finishTask(task);
            }

            function stop() {
                if (!taskProcess.running || task.endedAt > 0) return;
                task.cancelled = true;
                task.status = "stopping";
                taskProcess.running = false;
                task.forceTimer.start();
                root.tasksUpdated();
            }
        }
    }

    property Timer timeoutTimer: Timer {
        id: timeoutTimer
        interval: root.timeoutCheckInterval
        repeat: true
        running: root.tasks.length > 0
        onTriggered: function () {
            var now = Date.now();
            for (var i = 0; i < root.tasks.length; i++) {
                var task = root.tasks[i];
                if (!task.timeoutMs || task.endedAt > 0 || task.status !== "running") continue;
                if (now - task.startedAt > task.timeoutMs) {
                    task.timedOut = true;
                    task.stop();
                }
            }
        }
    }

    function parseValues(value, definition) {
        var type = String(definition.type || "text");
        if (type === "boolean") return [definition.trueValue !== undefined ? String(definition.trueValue) : "true"];
        if (type === "flag") return [definition.flag || "--" + definition.name];
        if (Array.isArray(value)) return value.map(function (entry) { return String(entry); });
        if (value === undefined || value === null) {
            if (definition.default === undefined || definition.default === null || definition.default === "") return [];
            return parseValues(definition.default, definition);
        }
        if (typeof value === "object") {
            var keys = [];
            for (var key in value) {
                if (value[key]) keys.push(key);
            }
            return keys;
        }
        var text = String(value);
        if (!text.trim()) return [];
        if (definition.argv) {
            var result = [];
            for (var i = 0; i < definition.argv.length; i++) {
                result.push(String(definition.argv[i]).replace("{value}", text).replace("{values}", text));
            }
            return result;
        }
        if (type === "file" || type === "files" || type === "directory" || type === "directories") {
            return text.split(/[\r\n]+/).map(function (entry) { return entry.trim(); }).filter(function (entry) { return entry.length > 0; });
        }
        if (definition.raw) return [text];
        if (definition.prefix) return [String(definition.prefix) + text];
        return text.split(/\s+/).filter(function (entry) { return entry.length > 0; });
    }

    function buildCommand(script, values) {
        var command = script.command || script.path;
        var argv = command ? [String(command)] : [];
        var definitions = Array.isArray(script.arguments) ? script.arguments : [];
        var supplied = values && typeof values === "object" ? values : ({});
        for (var i = 0; i < definitions.length; i++) {
            var definition = definitions[i];
            if (!definition || !definition.name) continue;
            var value = supplied[definition.name] !== undefined ? supplied[definition.name] : definition.default;
            argv = argv.concat(root.parseValues(value, definition));
        }
        return argv;
    }

    function validate(script, values) {
        var definitions = Array.isArray(script.arguments) ? script.arguments : [];
        var supplied = values && typeof values === "object" ? values : ({});
        for (var i = 0; i < definitions.length; i++) {
            var definition = definitions[i];
            if (!definition || !definition.required || !definition.name) continue;
            var value = supplied[definition.name];
            if (value === undefined || value === null || String(value).trim() === "") {
                return "Missing required argument: " + (definition.label || definition.name);
            }
        }
        return "";
    }

    function activeFor(id) {
        if (!id) return null;
        for (var i = 0; i < root.tasks.length; i++) {
            var task = root.tasks[i];
            if (task.id === id && task.endedAt === 0) return task;
        }
        return null;
    }

    function syncTasks() {
        var rows = [];
        for (var i = 0; i < root.tasks.length; i++) rows.push(root.tasks[i]);
        root.tasks = rows;
        root.tasksUpdated();
    }

    function finishTask(task) {
        if (!task.endedAt) task.endedAt = Date.now();
        if (!task.stdoutText && task.process.stdout) task.stdoutText = task.process.stdout.text || "";
        if (!task.stderrText && task.process.stderr) task.stderrText = task.process.stderr.text || "";
        root.lastTask = task;
        ScriptStore.recordHistory({
            id: task.id,
            name: task.name,
            startedAt: task.startedAt,
            endedAt: task.endedAt,
            duration: Math.max(0, task.endedAt - task.startedAt),
            status: task.status,
            exitCode: task.exitCodeValue
        });
        root.syncTasks();
        root.taskFinished(task);
    }

    function run(script, values) {
        if (!script || !script.launchable) return null;
        var validation = root.validate(script, values);
        if (validation) return validation;
        var allowMultiple = !!script.allowMultipleInstances;
        if (!allowMultiple && root.activeFor(script.id)) return "Script is already running";
        var argv = root.buildCommand(script, values);
        if (argv.length === 0) return "No command to run";
        var mode = String(script.executionMode || "normal");
        var task = root.taskComponent.createObject(root, {
            id: script.id,
            name: script.name || script.filename || script.id,
            command: argv,
            commandDisplay: argv.join(" "),
            workingDirectory: script.workingDirectory || "",
            timeoutMs: Number(script.timeout || 0) * 1000,
            status: "queued"
        });
        if (!task) return "Failed to create task";
        root.tasks.push(task);
        ScriptStore.recordLaunch(script.id, script.name);
        root.syncTasks();
        if (mode === "detached") task.startDetached();
        else task.start();
        return "";
    }

    function stop(id) {
        var task = root.activeFor(id);
        if (!task) return;
        task.stop();
    }

    function stopAll() {
        for (var i = root.tasks.length - 1; i >= 0; i--) root.tasks[i].stop();
    }

    function clearFinished() {
        var rows = [];
        for (var i = 0; i < root.tasks.length; i++) {
            if (root.tasks[i].endedAt === 0) rows.push(root.tasks[i]);
        }
        root.tasks = rows;
        root.tasksUpdated();
    }
}
