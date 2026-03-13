import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell

Menu {
    id: moreMenu
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    
    // Properties passed from ClipboardItem
    property color fgColor: "black"
    property color cardColor: "white"
    property color cardHover: "#f5f5f5"
    property color dangerColor: "#e81123"
    property color shadowColor: "#20000000"
    property string themeName: "Dark"
    property bool isDarkTheme: themeName !== "Light"
    
    property bool isPinned: false
    property bool isUrl: false
    property bool isImage: false
    property string itemContent: ""

    // Signals
    signal pinToggled(bool value)
    signal deleteRequested()
    signal openUrlRequested(string url)
    signal imagePreviewRequested(string filepath)
    
    background: Rectangle {
        implicitWidth: 140
        color: moreMenu.cardColor
        border.color: moreMenu.isDarkTheme ? "#333" : "#ddd"
        border.width: 1
        radius: 8
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: moreMenu.shadowColor
            shadowBlur: 0.8
            shadowVerticalOffset: 4
        }
    }

    MenuItem {
        text: "Open in Browser"
        visible: moreMenu.isUrl
        height: visible ? 36 : 0
        onTriggered: {
            let url = moreMenu.itemContent.trim()
            if (!url.startsWith("http://") && !url.startsWith("https://")) {
                url = "https://" + url
            }
            moreMenu.openUrlRequested(url)
        }
        contentItem: Text {
            text: parent.text
            color: moreMenu.fgColor
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.hovered ? moreMenu.cardHover : "transparent"
            radius: 4
            anchors.fill: parent
            anchors.margins: 4
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    MenuItem {
        text: "Preview Image"
        visible: moreMenu.isImage
        height: visible ? 36 : 0
        onTriggered: moreMenu.imagePreviewRequested(moreMenu.itemContent)
        contentItem: Text {
            text: parent.text
            color: moreMenu.fgColor
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.hovered ? moreMenu.cardHover : "transparent"
            radius: 4
            anchors.fill: parent
            anchors.margins: 4
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    MenuItem {
        text: moreMenu.isPinned ? "Unpin" : "Pin"
        onTriggered: moreMenu.pinToggled(!moreMenu.isPinned)
        height: 36
        contentItem: Text {
            text: parent.text
            color: moreMenu.fgColor
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.hovered ? moreMenu.cardHover : "transparent"
            radius: 4
            anchors.fill: parent
            anchors.margins: 4
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    MenuItem {
        text: "Delete"
        onTriggered: moreMenu.deleteRequested()
        height: 36
        contentItem: Text {
            text: parent.text
            color: moreMenu.dangerColor
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.hovered ? moreMenu.cardHover : "transparent"
            radius: 4
            anchors.fill: parent
            anchors.margins: 4
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
