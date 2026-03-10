import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: rootTitle
    signal searchChanged(string text)
    signal settingsClicked()

    readonly property alias searchFocused: searchFocus.activeFocus
    signal searchFinished()
    
    function forceSearchFocus() {
        searchFocus.forceActiveFocus()
    }

    property color fgColor: "black"
    property color cardColor: "#ffffff"
    property color cardHover: "#f3f3f3"
    property color accentColor: "#0067c0"
    property bool isDarkMode: false

    spacing: 12

    // Clipboard Title & Settings
    RowLayout {
        Layout.fillWidth: true
        
        Text {
            text: "Clipboard"
            font.pixelSize: 18
            font.bold: true
            color: rootTitle.fgColor
        }
        
        Item { Layout.fillWidth: true }
        
        // Settings button
        Rectangle {
            width: 30
            height: 30
            radius: 4
            color: gearBtn.containsMouse ? (rootTitle.isDarkMode ? "#333333" : "#e0e0e0") : "transparent"
            Text { anchors.centerIn: parent; text: "⚙️"; font.pixelSize: 16 }
            MouseArea {
                id: gearBtn
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: settingsClicked()
            }
        }
    }

    // Third Row: Search Box
    Rectangle {
        Layout.fillWidth: true
        height: 36
        color: rootTitle.isDarkMode ? "#2d2d2d" : "#f9f9f9"
        border.color: searchFocus.activeFocus ? rootTitle.accentColor : (rootTitle.isDarkMode ? "#444" : "#ddd")
        border.width: searchFocus.activeFocus ? 2 : 1
        radius: 6
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            
            Text { 
                text: "🔍"
                opacity: 0.5
                color: rootTitle.fgColor 
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
            }
            
            TextField {
                id: searchFocus
                Layout.fillWidth: true
                placeholderText: "Search..."
                color: rootTitle.fgColor
                verticalAlignment: TextInput.AlignVCenter
                padding: 0
                leftPadding: 4
                background: Item {}
                onTextChanged: searchChanged(text)
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        searchFinished()
                        event.accepted = true
                    }
                }
            }
        }
    }
}
