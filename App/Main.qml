import QtQuick
import QtQuick.Window

Window {
    id: mainWindow
    width: 640
    height: 480
    visible: true
    title: "Virtmanager-Win"

    Rectangle {
        id: main
        anchors.fill: parent
        color: "white"

        Text {
            text: "Test"
            anchors.centerIn: parent
            color: "black"
            font.pixelSize: 24
        }
        ToolbarWidget {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
        }
    }
}
