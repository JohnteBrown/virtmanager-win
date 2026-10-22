import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: toolbar

    signal newVmRequested()
    signal refreshRequested()

    background: Rectangle {
        color: "#172321"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 22
        anchors.rightMargin: 18
        spacing: 12

        Label {
            text: "VIRT / MANAGER"
            color: "#f4f7f5"
            font.bold: true
            font.pixelSize: 16
        }

        Label {
            text: "QEMU for Windows"
            color: "#a8b8b3"
            font.pixelSize: 12
        }

        Item { Layout.fillWidth: true }

        ToolButton {
            text: "Refresh"
            palette.buttonText: "#eef4f1"
            onClicked: toolbar.refreshRequested()
        }

        Button {
            text: "+  New VM"
            highlighted: true
            onClicked: toolbar.newVmRequested()
        }
    }
}