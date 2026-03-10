import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: filterBarRoot
    Layout.fillWidth: true

    property color fgColor: "black"
    property color cardColor: "white"
    property color cardHover: "#f5f5f5"
    property color accentColor: "#0067c0"
    property bool isDarkMode: false
    
    // Callbacks to interact with backend/UI
    signal filterActivated(string filterType)
    signal clearAllRequested()

    ComboBox {
        id: typeFilterBox
        model: ["All", "Text", "Image", "Color", "Link"]
        currentIndex: 0
        Layout.preferredWidth: 100
        Layout.preferredHeight: 32

        onActivated: (index) => {
            let type = "all"
            if (index === 1) type = "text"
            else if (index === 2) type = "image"
            else if (index === 3) type = "color"
            else if (index === 4) type = "link"
            filterBarRoot.filterActivated(type)
        }

        contentItem: Text {
            text: typeFilterBox.displayText
            color: filterBarRoot.fgColor
            font.pixelSize: 13
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }
        indicator: Text {
            x: typeFilterBox.width - width - 8
            y: typeFilterBox.topPadding + (typeFilterBox.availableHeight - height) / 2
            text: "▾"
            color: filterBarRoot.fgColor
            font.pixelSize: 14
        }
        background: Rectangle {
            color: typeFilterBox.hovered ? (filterBarRoot.isDarkMode ? "#333" : "#e6e6e6") : (filterBarRoot.isDarkMode ? "#222" : "#f5f5f5")
            radius: 6
            border.color: typeFilterBox.hovered ? filterBarRoot.accentColor : (filterBarRoot.isDarkMode ? "#444" : "#ccc")
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
                color: filterBarRoot.cardColor
                border.color: filterBarRoot.isDarkMode ? "#333" : "#ddd"
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
                color: filterBarRoot.fgColor
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: parent.hovered ? filterBarRoot.cardHover : "transparent"
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
            color: clearBtnMouse.containsMouse ? filterBarRoot.accentColor : filterBarRoot.fgColor
            opacity: clearBtnMouse.containsMouse ? 1.0 : 0.6
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 4
            color: clearBtnMouse.containsMouse ? (filterBarRoot.isDarkMode ? "#333" : "#eee") : "transparent"
            border.color: clearBtnMouse.containsMouse ? "#ddd" : "transparent"
        }
        MouseArea {
            id: clearBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                filterBarRoot.clearAllRequested()
            }
        }
    }
}
