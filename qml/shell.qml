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

                FilterBar {
                    isDarkMode: backend.isDarkMode
                    isPaused: backend.isPaused
                    fgColor: mainWindow.fgColor
                    cardColor: mainWindow.cardColor
                    cardHover: mainWindow.cardHover
                    accentColor: mainWindow.accentColor
                    
                    onFilterActivated: type => {
                        backend.typeFilter = type
                        backend.loadData()
                    }
                    
                    onPauseToggled: val => {
                        backend.setPaused(val)
                    }
                    
                    onClearAllRequested: {
                        confirmClearDialog.visible = true
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

