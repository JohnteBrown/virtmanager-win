// v4/qtscript/WLib.js
// Created using Gemini & Modified by me (@JohnteBrown)

function toggleToolbarVisibility(toolbarObject) {
    // Toggles the visibility of the toolbar passed from QML
    toolbarObject.visible = !toolbarObject.visible;
    console.log("Toolbar visibility is now:", toolbarObject.visible);
}

function createToolbarButton(parentLayout, rootWindow) {
    // Define raw QML code for a new button
    var qmlString = 'import QtQuick.Controls 2.15; Button { text: "JS Button"; onClicked: console.log("Dynamic button clicked!") }';
    
    try {
        var newButton = Qt.createQmlObject(qmlString, parentLayout, "dynamicButton");
        console.log("Successfully added a new button via JS!");
    } catch (e) {
        console.log("Error creating dynamic QML object:", e.message);
    }
}

function handleAction(actionType, rootWindow) {
    if (actionType === "New") {
        rootWindow.title = "New Document Created";
    }
}
