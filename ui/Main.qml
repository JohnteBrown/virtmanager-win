import QtQuick
import QtQuick.Window

Window {
    id: mainWindow
    width: 640
    height: 480
    visible: true
    title: "VirtManager-Win"

    Rectangle {
        id: main
        anchors.fill: parent
        color: "white"

        Text {
            text: "Main Window"
            anchors.centerIn: parent
            color: "black"
            font.pixelSize: 24
        }
        ToolbarWidget {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            color: "white"
        }
    }
}
