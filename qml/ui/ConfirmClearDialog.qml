import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: confirmRoot
    visible: false
    
    property string themeName: "Dark"
    property bool isDarkTheme: themeName !== "Light"
    property color fgColor: "white"
    property color bgColor: "#1a1b26"
    property color accentColor: "#0067c0"
    property color dangerColor: "#e81123"
    
    signal confirmed()
    signal canceled()

    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.4) // Semi-transparent backdrop overlay
    z: 20

    // Catch clicks to prevent passing to underlying layer
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: canceled()
    }

    Rectangle {
        id: dialogBox
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: 180
        color: bgColor
        radius: 12
        border.color: isDarkTheme ? "#333" : "#ddd"
        border.width: 1

        // Consume clicks inside the dialog so it doesn't trigger the background
        MouseArea {
            anchors.fill: parent
            z: -1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: "Clear All Clipboard History?"
                color: fgColor
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: "This action cannot be undone. Pinned items will be kept."
                color: fgColor
                opacity: 0.7
                font.pixelSize: 13
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.fillHeight: true } // Spacer

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    onClicked: confirmRoot.canceled()
                    contentItem: Text {
                        text: parent.text
                        color: fgColor
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 6
                        color: parent.hovered ? (isDarkTheme ? "#333" : "#eee") : "transparent"
                        border.color: isDarkTheme ? "#555" : "#ccc"
                        border.width: 1
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Button {
                    text: "Clear All"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    onClicked: confirmRoot.confirmed()
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
                        color: dangerColor
                        opacity: parent.down ? 0.8 : (parent.hovered ? 0.9 : 1.0)
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
