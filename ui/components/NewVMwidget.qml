import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../v4/qtscript/WLib.js" as WLib

Dialog {
    id: dialog

    signal createRequested(string vmName, int memoryMb, int cpuCount, int diskSizeGb)

    title: "Create virtual machine"
    modal: true
    width: 430
    padding: 24

    function submit() {
        var vmName = nameField.text.trim()
        if (!WLib.isValidVmName(vmName)) {
            validationLabel.text = "Enter a valid name using letters, numbers, spaces, hyphens, or underscores."
            return
        }

        validationLabel.text = ""
        createRequested(vmName, memoryField.value, cpuField.value, diskField.value)
        WLib.closeDialog(dialog)
    }

    contentItem: ColumnLayout {
        spacing: 16

        Label {
            Layout.fillWidth: true
            text: "Create a local QEMU virtual machine. An operating system installer is not included."
            wrapMode: Text.WordWrap
            color: "#53615e"
        }

        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "Virtual machine name"
            maximumLength: 48
            selectByMouse: true
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 20
            rowSpacing: 12

            Label { text: "Memory" }
            SpinBox {
                id: memoryField
                from: 512
                to: 131072
                stepSize: 512
                value: 2048
                editable: true
                textFromValue: function(value) { return value + " MB" }
                valueFromText: function(text) { return parseInt(text, 10) || 512 }
            }

            Label { text: "CPU cores" }
            SpinBox {
                id: cpuField
                from: 1
                to: 64
                value: 2
            }

            Label { text: "Disk size" }
            SpinBox {
                id: diskField
                from: 1
                to: 4096
                value: 10
                textFromValue: function(value) { return value + " GB" }
                valueFromText: function(text) { return parseInt(text, 10) || 1 }
            }
        }

        Label {
            id: validationLabel
            Layout.fillWidth: true
            color: "#ad3e32"
            wrapMode: Text.WordWrap
        }
    }

    footer: RowLayout {
        spacing: 10

        Item { Layout.fillWidth: true }

        Button {
            text: "Cancel"
            onClicked: WLib.closeDialog(dialog)
        }

        Button {
            text: "Create VM"
            highlighted: true
            onClicked: dialog.submit()
        }
    }
}