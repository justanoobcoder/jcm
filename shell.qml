import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import QtQuick.Window

ShellRoot {
    id: root

    property bool isDarkMode: false
    property bool isAutoDelete: false
    property bool isPasteRightAway: false
    property string typeFilter: "all"

    property string bgDark: "#121212"
    property string bgLight: "#f0f2f5"
    property string fgDark: "#e8eaed"
    property string fgLight: "#202124"
    property string accentColor: isDarkMode ? "#8ab4f8" : "#1a73e8"
    property string dangerColor: isDarkMode ? "#f28b82" : "#d93025"

    property color bgColor: isDarkMode ? bgDark : bgLight
    property color fgColor: isDarkMode ? fgDark : fgLight
    property color cardColor: isDarkMode ? "#1e1e1e" : "#ffffff"
    property color cardHover: isDarkMode ? "#2c2c2c" : "#f8f9fa"
    property color shadowColor: isDarkMode ? "#000000" : "#20000000"

    // Backend Processes
    Process {
        id: initTheme
        command: ["jcm-daemon", "config", "get", "dark_mode"]
        running: true
        stdout: SplitParser {
            onRead: data => { root.isDarkMode = (data.trim() === "true") }
        }
    }
    Process {
        id: initAutoDelete
        command: ["jcm-daemon", "config", "get", "auto_delete"]
        running: true
        stdout: SplitParser {
            onRead: data => { root.isAutoDelete = (data.trim() === "true") }
        }
    }
    Process {
        id: initPaste
        command: ["jcm-daemon", "config", "get", "paste_right_away"]
        running: true
        stdout: SplitParser {
            onRead: data => { root.isPasteRightAway = (data.trim() === "true") }
        }
    }

    Process {
        id: listProc
        command: {
            let effectiveType = root.typeFilter;
            if (effectiveType === "color" || effectiveType === "link") effectiveType = "text";
            return ["jcm-daemon", "list", "--search", searchInputText, "--type-filter", effectiveType]
        }
        property string searchInputText: ""
        running: false
        stdout: SplitParser {
            onRead: data => {
                let items = []
                try { 
                    items = JSON.parse(data) 
                    if (root.typeFilter === "color") {
                        let colorRegex = /^(#([A-Fa-f0-9]{3,4}){1,2}|(rgb|rgba)\(.*\))$/i;
                        items = items.filter(i => colorRegex.test(i.content.trim()))
                    } else if (root.typeFilter === "link") {
                        let urlRegex = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i;
                        items = items.filter(i => urlRegex.test(i.content.trim()))
                    }
                } catch (e) { return }
                
                for (let i = listModel.count - 1; i >= 0; i--) {
                    let oldId = listModel.get(i).id
                    if (!items.some(n => n.id === oldId)) {
                        listModel.remove(i)
                    }
                }
                
                for (let i = 0; i < items.length; i++) {
                    let newItem = items[i]
                    let existingIndex = -1
                    for (let j = i; j < listModel.count; j++) {
                        if (listModel.get(j).id === newItem.id) {
                            existingIndex = j
                            break
                        }
                    }
                    
                    if (existingIndex === i) {
                        let m = listModel.get(i)
                        if (m.timestamp !== newItem.timestamp) listModel.setProperty(i, "timestamp", newItem.timestamp)
                        if (m.pinned !== newItem.pinned) listModel.setProperty(i, "pinned", newItem.pinned)
                        if (m.content !== newItem.content) listModel.setProperty(i, "content", newItem.content)
                    } else if (existingIndex !== -1) {
                        listModel.move(existingIndex, i, 1)
                        let m = listModel.get(i)
                        if (m.timestamp !== newItem.timestamp) listModel.setProperty(i, "timestamp", newItem.timestamp)
                        if (m.pinned !== newItem.pinned) listModel.setProperty(i, "pinned", newItem.pinned)
                        if (m.content !== newItem.content) listModel.setProperty(i, "content", newItem.content)
                    } else {
                        listModel.insert(i, newItem)
                    }
                }

                if (listModel.count > 0 && listView.currentIndex === -1) {
                    listView.currentIndex = 0
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
        id: silentProc
        command: []
        running: false
    }

    function loadData() {
        if (listProc.running) listProc.running = false
        listProc.running = true
    }

    Timer {
        id: refreshTimer
        interval: 3000
        repeat: true
        running: true
        onTriggered: loadData()
    }

    Component.onCompleted: {
        loadData()
    }

    Component.onDestruction: {
        refreshTimer.stop()
        listProc.running = false
        actionProc.running = false
        getProc.running = false
        silentProc.running = false
        initTheme.running = false
        initAutoDelete.running = false
        initPaste.running = false
    }

    FloatingWindow {
        id: mainWindow
        implicitWidth: Math.min(440, Screen.desktopAvailableWidth * 0.9)
        implicitHeight: Math.min(700, Screen.desktopAvailableHeight * 0.9)
        visible: true
        color: "transparent"

        onClosed: Qt.quit()

        Component.onCompleted: {
            listView.forceActiveFocus()
        }

        Shortcut {
            sequence: "Esc"
            onActivated: {
                if (titleBar.searchFocused) {
                    listView.forceActiveFocus()
                } else {
                    Qt.quit()
                }
            }
        }

        Shortcut {
            sequence: "/"
            onActivated: titleBar.forceSearchFocus()
        }

        Shortcut {
            sequence: "q"
            enabled: !titleBar.searchFocused
            onActivated: Qt.quit()
        }

        Rectangle {
            id: mainRect
            anchors.fill: parent
            color: root.bgColor
            radius: 12
            border.color: root.isDarkMode ? "#333" : "#ddd"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                TitleBar {
                    id: titleBar
                    isDarkMode: root.isDarkMode
                    fgColor: root.fgColor
                    cardColor: root.cardColor
                    cardHover: root.cardHover
                    accentColor: root.accentColor

                    onSearchChanged: text => {
                        listProc.searchInputText = text
                        loadData()
                    }
                    onSearchFinished: listView.forceActiveFocus()
                    onSettingsClicked: settingsDrawer.visible = true
                }

                RowLayout {
                    Layout.fillWidth: true

                    ComboBox {
                        id: typeFilterBox
                        model: ["All", "Text", "Image", "Color", "Link"]
                        currentIndex: 0
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 32

                        onActivated: (index) => {
                            if (index === 0) root.typeFilter = "all"
                            else if (index === 1) root.typeFilter = "text"
                            else if (index === 2) root.typeFilter = "image"
                            else if (index === 3) root.typeFilter = "color"
                            else if (index === 4) root.typeFilter = "link"
                            loadData()
                        }

                        contentItem: Text {
                            text: typeFilterBox.displayText
                            color: root.fgColor
                            font.pixelSize: 13
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }
                        indicator: Text {
                            x: typeFilterBox.width - width - 8
                            y: typeFilterBox.topPadding + (typeFilterBox.availableHeight - height) / 2
                            text: "▾"
                            color: root.fgColor
                            font.pixelSize: 14
                        }
                        background: Rectangle {
                            color: typeFilterBox.hovered ? (root.isDarkMode ? "#333" : "#e6e6e6") : (root.isDarkMode ? "#222" : "#f5f5f5")
                            radius: 6
                            border.color: typeFilterBox.hovered ? root.accentColor : (root.isDarkMode ? "#444" : "#ccc")
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                        popup: Popup {
                            y: typeFilterBox.height + 4
                            width: typeFilterBox.width
                            padding: 4
                            background: Rectangle {
                                color: root.cardColor
                                border.color: root.isDarkMode ? "#333" : "#ddd"
                                radius: 8
                            }
                            contentItem: ListView {
                                implicitHeight: contentHeight
                                model: typeFilterBox.delegateModel
                                clip: true
                            }
                        }
                        delegate: ItemDelegate {
                            width: typeFilterBox.width - 8
                            height: 32
                            contentItem: Text {
                                text: modelData
                                color: root.fgColor
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.hovered ? root.cardHover : "transparent"
                                radius: 4
                            }
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        flat: true
                        Layout.preferredHeight: 28
                        contentItem: Text {
                            text: "Clear all"
                            font.pixelSize: 12
                            color: clearBtnMouse.containsMouse ? root.accentColor : root.fgColor
                            opacity: clearBtnMouse.containsMouse ? 1.0 : 0.6
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 4
                            color: clearBtnMouse.containsMouse ? (root.isDarkMode ? "#333" : "#eee") : "transparent"
                            border.color: clearBtnMouse.containsMouse ? "#ddd" : "transparent"
                        }
                        MouseArea {
                            id: clearBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                confirmClearDialog.visible = true
                            }
                        }
                    }
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    clip: true
                    focus: true
                    currentIndex: -1
                    model: ListModel { id: listModel }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_J) {
                            listView.incrementCurrentIndex()
                        } else if (event.key === Qt.Key_K) {
                            listView.decrementCurrentIndex()
                        } else if (event.key === Qt.Key_D) {
                            if (listView.currentItem) {
                                listView.currentItem.deleteRequested()
                            }
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (listView.currentItem) {
                                listView.currentItem.copyRequested()
                            }
                        }
                    }

                    delegate: ClipboardItem {
                        width: listView.width
                        type: model.type
                        content: model.content
                        timestamp: model.timestamp
                        pinned: model.pinned
                        isCurrent: ListView.isCurrentItem

                        fgColor: root.fgColor
                        cardColor: root.cardColor
                        cardHover: root.cardHover
                        accentColor: root.accentColor
                        dangerColor: root.dangerColor
                        shadowColor: root.shadowColor
                        isDarkMode: root.isDarkMode

                        onPinToggled: (val) => {
                            actionProc.command = ["jcm-daemon", val ? "pin" : "unpin", model.id.toString()]
                            actionProc.running = true
                        }
                        onDeleteRequested: {
                            actionProc.command = ["jcm-daemon", "delete", model.id.toString()]
                            actionProc.running = true
                        }
                        onCopyRequested: {
                            getProc.targetId = model.id
                            getProc.running = true
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }

            SettingsDrawer {
                id: settingsDrawer
                isDarkMode: root.isDarkMode
                isAutoDelete: root.isAutoDelete
                isPasteRightAway: root.isPasteRightAway
                fgColor: root.fgColor
                bgColor: root.cardColor
                accentColor: root.accentColor

                onDarkModeToggled: val => {
                    root.isDarkMode = val
                    silentProc.command = ["jcm-daemon", "config", "set", "dark_mode", val ? "true" : "false"]
                    silentProc.running = true
                }
                onAutoDeleteToggled: val => {
                    root.isAutoDelete = val
                    silentProc.command = ["jcm-daemon", "config", "set", "auto_delete", val ? "true" : "false"]
                    silentProc.running = true
                }
                onPasteRightAwayToggled: val => {
                    root.isPasteRightAway = val
                    silentProc.command = ["jcm-daemon", "config", "set", "paste_right_away", val ? "true" : "false"]
                    silentProc.running = true
                }
                onClearHistoryRequested: {
                    actionProc.command = ["jcm-daemon", "clear"]
                    actionProc.running = true
                    visible = false
                }
                onCloseRequested: visible = false
            }

            ConfirmClearDialog {
                id: confirmClearDialog
                isDarkMode: root.isDarkMode
                fgColor: root.fgColor
                bgColor: root.cardColor
                accentColor: root.accentColor
                dangerColor: root.dangerColor
                
                onConfirmed: {
                    actionProc.command = ["jcm-daemon", "clear"]
                    actionProc.running = true
                    visible = false
                }
                onCanceled: visible = false
            }
        }
    }
}

