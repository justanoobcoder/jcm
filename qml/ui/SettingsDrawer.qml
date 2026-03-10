import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: drawerRoot
    visible: false
    
    property string themeName: "Dark"
    property var themeList: []
    property bool isDarkTheme: themeName !== "Light"
    property bool isAutoDelete: false
    property bool isPasteRightAway: false
    
    property color fgColor: "white"
    property color bgColor: "#1a1b26"
    property color accentColor: "#0067c0"
    
    signal themeChanged(string value)
    signal autoDeleteToggled(bool value)
    signal pasteRightAwayToggled(bool value)
    signal clearHistoryRequested()
    signal closeRequested()

    anchors.fill: parent
    color: bgColor
    radius: 12
    opacity: 1.0 // Use full opacity for modern look, but with a slight border
    border.color: isDarkTheme ? "#333" : "#ddd"
    border.width: 1
    z: 10

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Settings"; color: fgColor; font.pixelSize: 18; font.bold: true }
        }

        Component {
            id: customSwitchStyle
            SwitchDelegate {
                id: control
                indicator: Rectangle {
                    implicitWidth: 36
                    implicitHeight: 20
                    x: control.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 10
                    color: control.checked ? drawerRoot.accentColor : (drawerRoot.isDarkTheme ? "#555" : "#ccc")
                    border.color: control.checked ? drawerRoot.accentColor : (drawerRoot.isDarkTheme ? "#666" : "#bbb")

                    Rectangle {
                        x: control.checked ? parent.width - width - 2 : 2
                        y: 2
                        width: 16
                        height: 16
                        radius: 8
                        color: drawerRoot.isDarkTheme ? "#fff" : "#fff"
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Theme"; color: fgColor; font.pixelSize: 16; Layout.fillWidth: true }
            
            ComboBox {
                id: themeBox
                model: drawerRoot.themeList
                currentIndex: Math.max(0, model.indexOf(drawerRoot.themeName))
                Layout.preferredWidth: 180
                Layout.preferredHeight: 32

                onActivated: (index) => {
                    drawerRoot.themeChanged(model[index])
                }

                contentItem: Text {
                    text: themeBox.displayText
                    color: drawerRoot.fgColor
                    font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                }
                indicator: Text {
                    x: themeBox.width - width - 8
                    y: themeBox.topPadding + (themeBox.availableHeight - height) / 2
                    text: "▾"
                    color: drawerRoot.fgColor
                    font.pixelSize: 14
                }
                background: Rectangle {
                    color: themeBox.hovered ? (drawerRoot.isDarkTheme ? "#333" : "#e6e6e6") : (drawerRoot.isDarkTheme ? "#222" : "#f5f5f5")
                    radius: 6
                    border.color: themeBox.hovered ? drawerRoot.accentColor : (drawerRoot.isDarkTheme ? "#444" : "#ccc")
                    border.width: 1
                    
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                popup: Popup {
                    y: themeBox.height + 4
                    width: themeBox.width
                    padding: 4
                    background: Rectangle {
                        color: drawerRoot.bgColor
                        border.color: drawerRoot.isDarkTheme ? "#333" : "#ddd"
                        radius: 8
                    }
                    contentItem: ListView {
                        implicitHeight: contentHeight
                        model: themeBox.delegateModel
                        clip: true
                    }
                }
                delegate: ItemDelegate {
                    width: themeBox.width - 8
                    height: 32
                    contentItem: Text {
                        text: modelData
                        color: drawerRoot.fgColor
                        font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.hovered ? (drawerRoot.isDarkTheme ? "#333" : "#eee") : "transparent"
                        radius: 4
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Auto Delete Unpinned on Reboot"; color: fgColor; font.pixelSize: 16; Layout.fillWidth: true }
            Switch {
                checked: drawerRoot.isAutoDelete
                onCheckedChanged: autoDeleteToggled(checked)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
                indicator: Rectangle {
                    implicitWidth: 38
                    implicitHeight: 22
                    radius: 11
                    color: parent.checked ? drawerRoot.accentColor : (drawerRoot.isDarkTheme ? "#444" : "#ccc")
                    Rectangle {
                        x: parent.parent.checked ? parent.width - width - 2 : 2
                        y: 2
                        width: 18
                        height: 18
                        radius: 9
                        color: "white"
                        Behavior on x { NumberAnimation { duration: 100 } }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Paste Right Away"; color: fgColor; font.pixelSize: 16; Layout.fillWidth: true }
            Switch {
                checked: drawerRoot.isPasteRightAway
                onCheckedChanged: pasteRightAwayToggled(checked)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
                indicator: Rectangle {
                    implicitWidth: 38
                    implicitHeight: 22
                    radius: 11
                    color: parent.checked ? drawerRoot.accentColor : (drawerRoot.isDarkTheme ? "#444" : "#ccc")
                    Rectangle {
                        x: parent.parent.checked ? parent.width - width - 2 : 2
                        y: 2
                        width: 18
                        height: 18
                        radius: 9
                        color: "white"
                        Behavior on x { NumberAnimation { duration: 100 } }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Button {
            text: "Close"
            Layout.alignment: Qt.AlignHCenter
            onClicked: closeRequested()
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 6
                color: drawerRoot.accentColor
                opacity: parent.down ? 0.8 : (parent.hovered ? 0.9 : 1.0)
                implicitWidth: 200
                implicitHeight: 36
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
    
    // Catch clicks to prevent passing to underlying layer
    MouseArea {
        anchors.fill: parent
        z: -1
    }
}
