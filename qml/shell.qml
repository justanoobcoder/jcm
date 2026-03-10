import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import QtQuick.Window
import "backend"
import "ui"

ShellRoot {
    id: root

    JcmBackend {
        id: backend
        targetModel: listModel
        listView: listView
    }
    
    Component.onCompleted: {
        backend.init()
    }
    
    Component.onDestruction: {
        backend.cleanup()
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

        property color bgColor: backend.isDarkMode ? "#121212" : "#f0f2f5"
        property color fgColor: backend.isDarkMode ? "#e8eaed" : "#202124"
        property color cardColor: backend.isDarkMode ? "#1e1e1e" : "#ffffff"
        property color cardHover: backend.isDarkMode ? "#2c2c2c" : "#f8f9fa"
        property color shadowColor: backend.isDarkMode ? "#000000" : "#20000000"
        property color accentColor: backend.isDarkMode ? "#8ab4f8" : "#1a73e8"
        property color dangerColor: backend.isDarkMode ? "#f28b82" : "#d93025"

        Shortcut {
            sequence: "q"
            enabled: !titleBar.searchFocused
            onActivated: Qt.quit()
        }

        Rectangle {
            id: mainRect
            anchors.fill: parent
            color: mainWindow.bgColor
            radius: 12
            border.color: backend.isDarkMode ? "#333" : "#ddd"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                TitleBar {
                    id: titleBar
                    isDarkMode: backend.isDarkMode
                    fgColor: mainWindow.fgColor
                    cardColor: mainWindow.cardColor
                    cardHover: mainWindow.cardHover
                    accentColor: mainWindow.accentColor

                    onSearchChanged: text => {
                        backend.search(text)
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
                            if (index === 0) backend.typeFilter = "all"
                            else if (index === 1) backend.typeFilter = "text"
                            else if (index === 2) backend.typeFilter = "image"
                            else if (index === 3) backend.typeFilter = "color"
                            else if (index === 4) backend.typeFilter = "link"
                            backend.loadData()
                        }

                        contentItem: Text {
                            text: typeFilterBox.displayText
                            color: mainWindow.fgColor
                            font.pixelSize: 13
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }
                        indicator: Text {
                            x: typeFilterBox.width - width - 8
                            y: typeFilterBox.topPadding + (typeFilterBox.availableHeight - height) / 2
                            text: "▾"
                            color: mainWindow.fgColor
                            font.pixelSize: 14
                        }
                        background: Rectangle {
                            color: typeFilterBox.hovered ? (backend.isDarkMode ? "#333" : "#e6e6e6") : (backend.isDarkMode ? "#222" : "#f5f5f5")
                            radius: 6
                            border.color: typeFilterBox.hovered ? mainWindow.accentColor : (backend.isDarkMode ? "#444" : "#ccc")
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
                                color: mainWindow.cardColor
                                border.color: backend.isDarkMode ? "#333" : "#ddd"
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
                                color: mainWindow.fgColor
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.hovered ? mainWindow.cardHover : "transparent"
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
                            color: clearBtnMouse.containsMouse ? mainWindow.accentColor : mainWindow.fgColor
                            opacity: clearBtnMouse.containsMouse ? 1.0 : 0.6
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 4
                            color: clearBtnMouse.containsMouse ? (backend.isDarkMode ? "#333" : "#eee") : "transparent"
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

                        fgColor: mainWindow.fgColor
                        cardColor: mainWindow.cardColor
                        cardHover: mainWindow.cardHover
                        accentColor: mainWindow.accentColor
                        dangerColor: mainWindow.dangerColor
                        shadowColor: mainWindow.shadowColor
                        isDarkMode: backend.isDarkMode

                        onPinToggled: (val) => {
                            backend.pinItem(model.id, val)
                        }
                        onDeleteRequested: {
                            backend.deleteItem(model.id)
                        }
                        onCopyRequested: {
                            backend.copyItem(model.id)
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }

            SettingsDrawer {
                id: settingsDrawer
                isDarkMode: backend.isDarkMode
                isAutoDelete: backend.isAutoDelete
                isPasteRightAway: backend.isPasteRightAway
                fgColor: mainWindow.fgColor
                bgColor: mainWindow.cardColor
                accentColor: mainWindow.accentColor

                onDarkModeToggled: val => { backend.setDarkMode(val) }
                onAutoDeleteToggled: val => { backend.setAutoDelete(val) }
                onPasteRightAwayToggled: val => { backend.setPasteRightAway(val) }
                onClearHistoryRequested: {
                    backend.clearHistory()
                    visible = false
                }
                onCloseRequested: visible = false
            }

            ConfirmClearDialog {
                id: confirmClearDialog
                isDarkMode: backend.isDarkMode
                fgColor: mainWindow.fgColor
                bgColor: mainWindow.cardColor
                accentColor: mainWindow.accentColor
                dangerColor: mainWindow.dangerColor
                
                onConfirmed: {
                    backend.clearHistory()
                    visible = false
                }
                onCanceled: visible = false
            }
        }
    }
}

