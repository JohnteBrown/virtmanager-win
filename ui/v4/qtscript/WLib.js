// v4/qtscript/WLib.js
// Created using Gemini & Modified by me (@JohnteBrown)

// Example 1: Directly modifying properties of the ToolBar component
function toggleToolbarVisibility(toolbarObject) {
    // Toggles the visibility of the toolbar passed from QML
    toolbarObject.visible = !toolbarObject.visible;
    console.log("Toolbar visibility is now:", toolbarObject.visible);
}

// Example 2: Dynamically generating a new button inside the toolbar layout
function createToolbarButton(parentLayout, rootWindow) {
    // Define raw QML code for a new button
    var qmlString = 'import QtQuick.Controls 2.15; Button { text: "JS Button"; onClicked: console.log("Dynamic button clicked!") }';
    
    try {
        // Create the object dynamically and attach it to the Row container
        var newButton = Qt.createQmlObject(qmlString, parentLayout, "dynamicButton");
        console.log("Successfully added a new button via JS!");
    } catch (e) {
        console.log("Error creating dynamic QML object:", e.message);
    }
}

// Example 3: Handling menu or toolbar action logic globally
function handleAction(actionType, rootWindow) {
    if (actionType === "New") {
        rootWindow.title = "New Document Created";
    }
}
