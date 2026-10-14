const testmsg = "1"; // if printed, the component has properly loaded.

function safeLog(testmsg) {
    try {
        console.log(testmsg);
    } 
    catch (error) {
        fallbackErrorHandling("Failed to print message: " + error.testmsg);
    }
};

function fallbackErrorHandling(errorMessage) {
    throw new Error(errorMessage);
};

function toolbarLogic() {
    // Primary Logic for toolbars using WLib.js
    function handleAction(toolbar, actionType) {
    if (actionType === "save") {
        console.info("Saving document from toolbar logic...");
        // WIP
    }
  }
};