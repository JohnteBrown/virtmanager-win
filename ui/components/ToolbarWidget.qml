import QtQuick
import QtQuick.Controls
import "v4/qtscript/WLib.js" as WLib

ApplicationWindow {
    id: window
    width: 320
import "../v4/qtscript/WLib.js" as WLib
    visible: true
ToolBar {
    id: toolbar
            id: toolbarRow
    property var rootWindow
    signal newVmRequested()
    signal refreshRequested()
            Action { text: qsTr("&Open...") }
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
            onClicked: toolbar.refreshRequested()
            palette.buttonText: "#eef4f1"
        }

        Button {
            text: "＋  New VM"
            highlighted: true
            onClicked: toolbar.newVmRequested()
