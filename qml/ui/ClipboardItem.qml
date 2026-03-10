import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtQuick.Effects

Rectangle {
    id: rootItem
    width: parent ? parent.width : 400
    
    property string type: "text"
    property string content: ""
    property int timestamp: 0
    property var pinned: 0
    readonly property bool isPinned: pinned ? true : false
    
    property color fgColor: "black"
    property color cardColor: "white"
    property color cardHover: "#f5f5f5"
    property color accentColor: "#0067c0"
    property color dangerColor: "#e81123"
    property bool isDarkMode: false

    signal pinToggled(bool value)
    signal deleteRequested()
    signal copyRequested()

    property bool expanded: false
    property bool isCurrent: false
    
    property color shadowColor: "#20000000" // Default light shadow
    
    height: Math.max(60, contentColumn.implicitHeight + 24)
    radius: 8
    color: (itemMouse.containsMouse || rootItem.isCurrent) ? cardHover : cardColor
    border.color: rootItem.isPinned ? accentColor : ((itemMouse.containsMouse || rootItem.isCurrent) ? "#aaa" : "transparent")
    border.width: (rootItem.isPinned || rootItem.isCurrent) ? 2 : 1
    
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: rootItem.shadowColor
        shadowBlur: 0.6
        shadowVerticalOffset: 2
    }

    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on color { ColorAnimation { duration: 150 } }

    // Color code detection
    property color detectedColor: {
        if (rootItem.type !== "text") return "transparent";
        let trimmed = rootItem.content.trim();
        
        // Hex detection is safe for Qt.color()
        let hexRegex = /^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/;
        if (hexRegex.test(trimmed)) {
            let c = Qt.color(trimmed);
            return c.valid ? c : "transparent";
        }
        
        // RGB/RGBA detection - manually parse to avoid console warnings from Qt.color()
        let rgbRegex = /^rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/i;
        let match = trimmed.match(rgbRegex);
        if (match) {
            let r = parseFloat(match[1]) / 255;
            let g = parseFloat(match[2]) / 255;
            let b = parseFloat(match[3]) / 255;
            let a = match[4] !== undefined ? parseFloat(match[4]) : 1.0;
            return Qt.rgba(r, g, b, a);
        }
        
        return "transparent";
    }
    readonly property bool hasColor: detectedColor != Qt.color("transparent")
    
    // URL detection
    readonly property bool isUrl: {
        if (rootItem.type !== "text") return false;
        let urlRegex = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i;
        return urlRegex.test(rootItem.content.trim());
    }

    ColumnLayout {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 8

        // Top row: Content preview & More button
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 10

            // Color Preview Square
            Rectangle {
                visible: rootItem.hasColor
                width: 24; height: 24
                radius: 4
                color: rootItem.detectedColor
                border.color: rootItem.fgColor
                border.width: 1
                opacity: 0.8
                Layout.alignment: Qt.AlignTop
            }

            // Preview Region
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: rootItem.type === "image" ? 100 : (expanded ? textContent.implicitHeight : Math.min(textContent.implicitHeight, 40))
                clip: true

                // Image preview
                Image {
                    visible: rootItem.type === "image"
                    anchors.fill: parent
                    source: rootItem.type === "image" ? "file://" + rootItem.content : ""
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                }

                // Text preview
                Text {
                    id: textContent
                    visible: rootItem.type === "text"
                    anchors.fill: parent
                    text: rootItem.type === "text" ? rootItem.content : ""
                    color: rootItem.fgColor
                    opacity: 0.9
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    elide: expanded ? Text.ElideNone : Text.ElideRight
                    maximumLineCount: expanded ? 100 : 2
                }
            }

            // More button (3-dots)
            Rectangle {
                width: 32; height: 32
                radius: 4
                color: moreBtnMouse.containsMouse ? Qt.rgba(rootItem.fgColor.r, rootItem.fgColor.g, rootItem.fgColor.b, 0.15) : "transparent"
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                
                Text { 
                    anchors.centerIn: parent
                    text: "•••"
                    font.pixelSize: 10
                    color: rootItem.fgColor
                }

                MouseArea {
                    id: moreBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: moreMenu.opened ? moreMenu.close() : moreMenu.open()
                }

                Menu {
                    id: moreMenu
                    y: parent.height + 4
                    x: -width + parent.width
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    
                    background: Rectangle {
                        implicitWidth: 140
                        color: rootItem.cardColor
                        border.color: rootItem.isDarkMode ? "#333" : "#ddd"
                        border.width: 1
                        radius: 8
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: rootItem.shadowColor
                            shadowBlur: 0.8
                            shadowVerticalOffset: 4
                        }
                    }

                    MenuItem {
                        text: "Open in Browser"
                        visible: rootItem.isUrl
                        height: visible ? 36 : 0
                        onTriggered: {
                            let url = rootItem.content.trim()
                            if (!url.startsWith("http://") && !url.startsWith("https://")) {
                                url = "https://" + url
                            }
                            // Rely on PATH to find the daemon
                            openUrlProc.command = ["jcm-daemon", "open-url", url]
                            openUrlProc.running = true
                        }
                        contentItem: Text {
                            text: parent.text
                            color: rootItem.fgColor
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? rootItem.cardHover : "transparent"
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
                        text: rootItem.isPinned ? "Unpin" : "Pin"
                        onTriggered: pinToggled(!rootItem.isPinned)
                        height: 36
                        contentItem: Text {
                            text: parent.text
                            color: rootItem.fgColor
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? rootItem.cardHover : "transparent"
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
                        onTriggered: deleteRequested()
                        height: 36
                        contentItem: Text {
                            text: parent.text
                            color: rootItem.dangerColor
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? rootItem.cardHover : "transparent"
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
            }
        }

        // Bottom row: Expand/Fold & Pin Status & Time
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Expand Button (under the text)
            Rectangle {
                visible: rootItem.type === "text" && (textContent.truncated || rootItem.expanded)
                Layout.preferredHeight: 24
                Layout.preferredWidth: 80
                radius: 4
                color: expandMouse.containsMouse ? (rootItem.isDarkMode ? "#444" : "#e0e0e0") : "transparent"
                border.color: rootItem.isDarkMode ? "#444" : "#ddd"
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { 
                        text: rootItem.expanded ? "See less" : "See more"
                        font.pixelSize: 11
                        color: rootItem.fgColor
                    }
                    Text {
                        text: rootItem.expanded ? "▴" : "▾"
                        font.pixelSize: 10
                        color: rootItem.fgColor
                    }
                }

                MouseArea {
                    id: expandMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: rootItem.expanded = !rootItem.expanded
                }
            }

            Item { Layout.fillWidth: true }

            // Timestamp
            Text {
                text: {
                    let d = new Date(rootItem.timestamp * 1000);
                    let now = new Date();
                    let isToday = d.getDate() === now.getDate() && 
                                  d.getMonth() === now.getMonth() && 
                                  d.getFullYear() === now.getFullYear();
                    
                    let timeStr = d.getHours().toString().padStart(2, '0') + ":" + d.getMinutes().toString().padStart(2, '0');
                    
                    if (isToday) {
                        return timeStr;
                    } else {
                        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                        return months[d.getMonth()] + " " + d.getDate() + ", " + timeStr;
                    }
                }
                color: rootItem.fgColor
                opacity: 0.5
                font.pixelSize: 11
            }

            // Pin Status Icon (Bottom right like in image)
            Text {
                text: "📌"
                font.pixelSize: 12
                opacity: rootItem.isPinned ? 1.0 : (pinMouse.containsMouse ? 1.0 : 0.2)
                visible: rootItem.isPinned || itemMouse.containsMouse || pinMouse.containsMouse
                color: rootItem.isPinned ? rootItem.accentColor : (pinMouse.containsMouse ? rootItem.accentColor : rootItem.fgColor)

                MouseArea {
                    id: pinMouse
                    anchors.fill: parent
                    anchors.margins: -10
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pinToggled(!rootItem.isPinned)
                }
            }
        }
    }

    // Main Click Area (for copying)
    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: copyRequested()
        z: -1
    }

    Process {
        id: openUrlProc
    }

    Component.onDestruction: {
        rootItem.layer.enabled = false
        openUrlProc.running = false
    }

}
