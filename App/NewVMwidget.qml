import QtQuick 2.12
import QtQuick.Controls 2.12

main {
    ScrollIndicator {
        id: scrollIndicator
        anchors.fill: parent
        anchors.margins: 10
        orientation: Qt.Vertical
        visible: contentHeight > height
    }
    Column {
        id: column
        anchors.fill: parent
        spacing: 10
        Repeater {
            model: 10
            delegate: Rectangle {
                width: parent.width
                height: 50
                color: index % 2 ? "lightgray" : "white"
                Text {
                    anchors.centerIn: parent
                    text: "Item " + index
                }
            }
        }
    }
