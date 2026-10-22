import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "components"
import "v4/qtscript/WLib.js" as WLib

Window {
    id: mainWindow

    width: 1080
    height: 720
    minimumWidth: 780
    minimumHeight: 520
    visible: true
    title: "VirtManager-Win"
    color: "#f2f5f3"

    property string feedbackMessage: vmManager.message
    property bool feedbackIsError: false
    property var selectedVm: vmList.currentItem ? vmList.currentItem.vmData : null

    Component.onCompleted: WLib.setWindowTitle(mainWindow, "VirtManager-Win")

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ToolbarWidget {
            Layout.fillWidth: true
            onNewVmRequested: WLib.openDialog(newVmDialog)
            onRefreshRequested: vmManager.refresh()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 290
                Layout.fillHeight: true
                color: "#e8eeeb"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "VIRTUAL MACHINES"
                            color: "#43514d"
                            font.bold: true
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: vmManager.vms.length
                            color: "#62716d"
                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#d3ddda"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: vmList
                            anchors.fill: parent
                            clip: true
                            spacing: 6
                            model: vmManager.vms

                            delegate: ItemDelegate {
                                id: vmDelegate
                                required property var modelData
                                required property int index
                                property var vmData: modelData
                                width: ListView.view.width
                                height: 68
                                highlighted: ListView.isCurrentItem
                                onClicked: WLib.selectVm(vmList, index)

                                background: Rectangle {
                                    radius: 4
                                    color: vmDelegate.down ? "#d6e2dd"
                                        : vmDelegate.highlighted ? "#dce8e3" : "transparent"
                                    border.color: vmDelegate.highlighted ? "#a9c2b7" : "transparent"
                                }

                                contentItem: RowLayout {
                                    spacing: 10

                                    Rectangle {
                                        Layout.preferredWidth: 8
                                        Layout.preferredHeight: 8
                                        radius: 4
                                        color: vmDelegate.vmData.state === "Running" ? "#2f8b68" : "#89948f"
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3

                                        Label {
                                            Layout.fillWidth: true
                                            text: vmDelegate.vmData.name
                                            color: "#1d2926"
                                            font.pixelSize: 14
                                            elide: Text.ElideRight
                                        }

                                        Label {
                                            text: vmDelegate.vmData.state
                                            color: "#65726e"
                                            font.pixelSize: 12
                                        }
                                    }
                                }
                            }
                        }

                        Label {
                            anchors.centerIn: parent
                            width: parent.width - 20
                            visible: vmManager.vms.length === 0
                            text: "No virtual machines yet.\nCreate one to get started."
                            color: "#72807b"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f8faf9"

                Item {
                    anchors.fill: parent
                    anchors.margins: 42

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, 560)
                        spacing: 12
                        visible: mainWindow.selectedVm === null

                        Label {
                            text: "Your virtual machines"
                            color: "#1c2925"
                            font.pixelSize: 28
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "Select a machine to view its settings, or create a new QEMU disk to begin."
                            color: "#64716d"
                            font.pixelSize: 15
                            wrapMode: Text.WordWrap
                        }

                        Button {
                            text: "＋  Create virtual machine"
                            highlighted: true
                            onClicked: WLib.openDialog(newVmDialog)
                        }
                    }

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 24
                        visible: mainWindow.selectedVm !== null

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Label {
                                    Layout.fillWidth: true
                                    text: mainWindow.selectedVm ? mainWindow.selectedVm.name : ""
                                    color: "#1c2925"
                                    font.pixelSize: 26
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    text: "QEMU virtual machine"
                                    color: "#64716d"
                                    font.pixelSize: 14
                                }
                            }

                            Rectangle {
                                radius: 4
                                color: mainWindow.selectedVm && mainWindow.selectedVm.state === "Running" ? "#e0f1e9" : "#e9eeec"
                                implicitWidth: stateLabel.implicitWidth + 20
                                implicitHeight: stateLabel.implicitHeight + 12

                                Label {
                                    id: stateLabel
                                    anchors.centerIn: parent
                                    text: mainWindow.selectedVm ? mainWindow.selectedVm.state : ""
                                    color: mainWindow.selectedVm && mainWindow.selectedVm.state === "Running" ? "#256b4e" : "#55625d"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#dce4e0"
                        }

                        Label {
                            text: "RESOURCES"
                            color: "#53615c"
                            font.bold: true
                            font.pixelSize: 12
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: 22
                            rowSpacing: 10

                            Repeater {
                                model: [
                                    { label: "MEMORY", value: mainWindow.selectedVm ? (mainWindow.selectedVm.memoryMb / 1024) + " GB" : "" },
                                    { label: "CPU CORES", value: mainWindow.selectedVm ? mainWindow.selectedVm.cpus : "" },
                                    { label: "DISK CAPACITY", value: mainWindow.selectedVm ? mainWindow.selectedVm.diskSizeGb + " GB" : "" }
                                ]

                                delegate: ColumnLayout {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Label {
                                        text: modelData.label
                                        color: "#74817c"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Label {
                                        text: modelData.value
                                        color: "#27332f"
                                        font.pixelSize: 17
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#dce4e0"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Button {
                                text: "Start"
                                highlighted: true
                                enabled: mainWindow.selectedVm && mainWindow.selectedVm.state === "Stopped"
                                onClicked: vmManager.startVm(mainWindow.selectedVm.name)
                            }

                            Button {
                                text: "Stop"
                                enabled: mainWindow.selectedVm && (mainWindow.selectedVm.state === "Running" || mainWindow.selectedVm.state === "Starting")
                                onClicked: vmManager.stopVm(mainWindow.selectedVm.name)
                            }

                            Item { Layout.fillWidth: true }

                            Button {
                                text: "Delete"
                                enabled: mainWindow.selectedVm && mainWindow.selectedVm.state === "Stopped"
                                onClicked: WLib.confirmDelete(deleteDialog, mainWindow.selectedVm.name)
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "Starting a VM opens the QEMU display window. An operating system image must be installed separately."
                            color: "#75817d"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 34
            color: "#e8eeeb"

            Label {
                anchors.fill: parent
                anchors.leftMargin: 18
                verticalAlignment: Text.AlignVCenter
                text: mainWindow.feedbackMessage
                color: mainWindow.feedbackIsError ? "#a63e33" : "#5a6863"
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
    }

    NewVMwidget {
        id: newVmDialog
        anchors.centerIn: Overlay.overlay
        onCreateRequested: function(vmName, memoryMb, cpuCount, diskSizeGb) {
            vmManager.createVm(vmName, memoryMb, cpuCount, diskSizeGb)
        }
    }

    Dialog {
        id: deleteDialog
        property string vmName: ""
        title: "Delete virtual machine"
        modal: true
        width: 400
        anchors.centerIn: Overlay.overlay
        padding: 24

        contentItem: Label {
            text: 'Delete the disk for "' + deleteDialog.vmName + '"? This cannot be undone.'
            wrapMode: Text.WordWrap
        }

        footer: RowLayout {
            Item { Layout.fillWidth: true }

            Button {
                text: "Cancel"
                onClicked: WLib.closeDialog(deleteDialog)
            }

            Button {
                text: "Delete disk"
                highlighted: true
                onClicked: {
                    var vmName = deleteDialog.vmName
                    WLib.closeDialog(deleteDialog)
                    vmManager.deleteVm(vmName)
                }
            }
        }
    }

    Connections {
        target: vmManager

        function onMessageChanged() {
            mainWindow.feedbackMessage = vmManager.message
            mainWindow.feedbackIsError = false
        }

        function onOperationError(message) {
            mainWindow.feedbackMessage = message
            mainWindow.feedbackIsError = true
        }
    }
}