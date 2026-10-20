import QtQuick
import QtQuick.Controls
import "v4/qtscript/WLib.js" as WLib

ApplicationWindow {
    id: window
    width: 320
    height: 260
    visible: true

    header: ToolBar {
        id: mainToolBar
        
        Row {
            id: toolbarRow
            anchors.fill: parent
            spacing: 5
            
            Button {
                text: "Init Controls"
                onClicked: {
                    WLib.toggleToolbarVisibility(mainToolBar); 
                    WLib.createToolbarButton(toolbarRow, window);
                }
            }
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            Action { text: qsTr("&New..."); onClicked: WLib.handleAction("New", window) }
            Action { text: qsTr("&Open...") }
            Action { text: qsTr("&Save") }
            Action { text: qsTr("Save &As...") }
            MenuSeparator {}
            Action { text: qsTr("&Quit"); onClicked: Qt.quit() }
        }
        Menu {
            title: qsTr("&Edit")
            Action { text: qsTr("Cu&t") }
            Action { text: qsTr("&Copy") }
            Action { text: qsTr("&Paste") }
        }
        Menu {
            title: qsTr("&Help")
            Action { text: qsTr("&About") }
        }
    }
}
