import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "components"

Window {
    id: mainWindow
    width: 1000
    height: 650
    minimumWidth: 800
    minimumHeight: 500
    visible: true
    title: "VirtManager-Win"

    color: "#f5f5f5"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Top toolbar
        ToolBar {
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                Label {
                    text: "VirtManager-Win"
                    font.bold: true
                    font.pixelSize: 18
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "New VM"
                }
            }
        }

        // Main content
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // VM list / sidebar
            Rectangle {
                Layout.preferredWidth: 240
                Layout.fillHeight: true
                color: "#eaeaea"

                Label {
                    anchors.centerIn: parent
                    text: "Virtual Machines"
                    font.pixelSize: 16
                }
            }

            // Selected VM details
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#ffffff"

                Label {
                    anchors.centerIn: parent
                    text: "Select a virtual machine"
                    color: "#777777"
                    font.pixelSize: 20
                }
            }
        }
    }
}