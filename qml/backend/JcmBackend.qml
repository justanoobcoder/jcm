import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: backendRoot

    property string themeName: "Dark"
    property color bgColor: "#1a1b26"
    property color fgColor: "#ffffff"
    property color cardColor: "#24283b"
    property color cardHover: "#2f334d"
    property color accentColor: "#0067c0"
    property color dangerColor: "#f7768e"
    property color shadowColor: "#000000"
    property bool isAutoDelete: false
    property bool isPasteRightAway: false
    property bool isPaused: false
    property string typeFilter: "all"
    property var themeList: []
    
    // Model reference passed from UI
    property ListModel targetModel: null
    property Item listView: null

    Process {
        id: initThemeName
        command: ["jcm-daemon", "config", "get", "theme"]
        running: true
        stdout: SplitParser {
            onRead: data => { 
                let t = data.trim()
                if (t === "") t = "Dark"
                backendRoot.themeName = t 
            }
        }
    }

    Process {
        id: initThemeList
        command: ["jcm-daemon", "theme", "list"]
        running: true
        stdout: SplitParser {
            onRead: data => { 
                try {
                    backendRoot.themeList = JSON.parse(data)
                } catch (e) {}
            }
        }
    }

    Process {
        id: initThemeColors
        command: ["jcm-daemon", "theme", "get"]
        running: true
        stdout: SplitParser {
            onRead: data => { 
                try {
                    let t = JSON.parse(data)
                    backendRoot.bgColor = t.bgColor
                    backendRoot.fgColor = t.fgColor
                    backendRoot.cardColor = t.cardColor
                    backendRoot.cardHover = t.cardHover
                    backendRoot.accentColor = t.accentColor
                    backendRoot.dangerColor = t.dangerColor
                    backendRoot.shadowColor = t.shadowColor
                } catch (e) {}
            }
        }
    }
    
    Process {
        id: initAutoDelete
        command: ["jcm-daemon", "config", "get", "auto_delete"]
        running: true
        stdout: SplitParser {
            onRead: data => { backendRoot.isAutoDelete = (data.trim() === "true") }
        }
    }
    
    Process {
        id: initPaste
        command: ["jcm-daemon", "config", "get", "paste_right_away"]
        running: true
        stdout: SplitParser {
            onRead: data => { backendRoot.isPasteRightAway = (data.trim() === "true") }
        }
    }

    Process {
        id: initPauseState
        command: ["jcm-daemon", "config", "get", "is_paused"]
        running: true
        stdout: SplitParser {
            onRead: data => { backendRoot.isPaused = (data.trim() === "true") }
        }
    }

    Process {
        id: listProc
        command: {
            let effectiveType = backendRoot.typeFilter;
            if (effectiveType === "color" || effectiveType === "link") effectiveType = "text";
            return ["jcm-daemon", "list", "--search", searchInputText, "--type-filter", effectiveType]
        }
        property string searchInputText: ""
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (!backendRoot.targetModel) return;
                let items = []
                try { 
                    items = JSON.parse(data) 
                    if (backendRoot.typeFilter === "color") {
                        let colorRegex = /^(#([A-Fa-f0-9]{3,4}){1,2}|(rgb|rgba)\(.*\))$/i;
                        items = items.filter(i => colorRegex.test(i.content.trim()))
                    } else if (backendRoot.typeFilter === "link") {
                        let urlRegex = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i;
                        items = items.filter(i => urlRegex.test(i.content.trim()))
                    }
                } catch (e) { return }
                
                let currentModel = backendRoot.targetModel
                for (let i = currentModel.count - 1; i >= 0; i--) {
                    let oldId = currentModel.get(i).id
                    if (!items.some(n => n.id === oldId)) {
                        currentModel.remove(i)
                    }
                }
                
                for (let i = 0; i < items.length; i++) {
                    let newItem = items[i]
                    let existingIndex = -1
                    for (let j = i; j < currentModel.count; j++) {
                        if (currentModel.get(j).id === newItem.id) {
                            existingIndex = j
                            break
                        }
                    }
                    
                    if (existingIndex === i) {
                        let m = currentModel.get(i)
                        if (m.timestamp !== newItem.timestamp) currentModel.setProperty(i, "timestamp", newItem.timestamp)
                        if (m.pinned !== newItem.pinned) currentModel.setProperty(i, "pinned", newItem.pinned)
                        if (m.content !== newItem.content) currentModel.setProperty(i, "content", newItem.content)
                    } else if (existingIndex !== -1) {
                        currentModel.move(existingIndex, i, 1)
                        let m = currentModel.get(i)
                        if (m.timestamp !== newItem.timestamp) currentModel.setProperty(i, "timestamp", newItem.timestamp)
                        if (m.pinned !== newItem.pinned) currentModel.setProperty(i, "pinned", newItem.pinned)
                        if (m.content !== newItem.content) currentModel.setProperty(i, "content", newItem.content)
                    } else {
                        currentModel.insert(i, newItem)
                    }
                }

                if (currentModel.count > 0 && backendRoot.listView && backendRoot.listView.currentIndex === -1) {
                    backendRoot.listView.currentIndex = 0
                }
            }
        }
    }

    Process {
        id: getProc
        property int targetId: -1
        command: targetId >= 0 ? ["jcm-daemon", "get", targetId.toString()] : ["echo"]
        running: false
        onExited: (exitCode, exitStatus) => {
            if (targetId !== -1) {
                targetId = -1
                Qt.quit()
            }
        }
    }

    Process {
        id: actionProc
        command: []
        running: false
        onExited: (exitCode, exitStatus) => { loadData() }
    }

    Process {
        id: setThemeProc
        command: []
        running: false
        onExited: (exitCode, exitStatus) => {
            if (initThemeColors.running) initThemeColors.running = false
            initThemeColors.running = true
        }
    }

    Process {
        id: silentProc
        command: []
        running: false
    }

    function loadData() {
        if (listProc.running) listProc.running = false
        listProc.running = true
    }
    
    function search(text) {
        listProc.searchInputText = text
        loadData()
    }
    
    function copyItem(id) {
        getProc.targetId = id
        getProc.running = true
    }
    
    function deleteItem(id) {
        actionProc.command = ["jcm-daemon", "delete", id.toString()]
        actionProc.running = true
    }
    
    function pinItem(id, isPinned) {
        actionProc.command = ["jcm-daemon", isPinned ? "pin" : "unpin", id.toString()]
        actionProc.running = true
    }
    
    function clearHistory() {
        actionProc.command = ["jcm-daemon", "clear"]
        actionProc.running = true
    }
    
    function setTheme(val) {
        backendRoot.themeName = val
        setThemeProc.command = ["jcm-daemon", "config", "set", "theme", val]
        setThemeProc.running = true
    }
    
    function setAutoDelete(val) {
        backendRoot.isAutoDelete = val
        silentProc.command = ["jcm-daemon", "config", "set", "auto_delete", val ? "true" : "false"]
        silentProc.running = true
    }
    
    function setPasteRightAway(val) {
        backendRoot.isPasteRightAway = val
        silentProc.command = ["jcm-daemon", "config", "set", "paste_right_away", val ? "true" : "false"]
        silentProc.running = true
    }
    
    function setPaused(val) {
        backendRoot.isPaused = val
        silentProc.command = ["jcm-daemon", "config", "set", "is_paused", val ? "true" : "false"]
        silentProc.running = true
    }

    property alias refreshTimer: refreshTimer
    Timer {
        id: refreshTimer
        interval: 3000
        repeat: true
        running: true
        onTriggered: backendRoot.loadData()
    }

    function init() {
        loadData()
    }

    function cleanup() {
        refreshTimer.stop()
        listProc.running = false
        actionProc.running = false
        getProc.running = false
        setThemeProc.running = false
        silentProc.running = false
        initThemeName.running = false
        initThemeList.running = false
        initThemeColors.running = false
        initAutoDelete.running = false
        initPaste.running = false
        initPauseState.running = false
    }
}
