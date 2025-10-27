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
        color: "green"

        Text {
            text: "Hello World"
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 24
        }
    }
}
