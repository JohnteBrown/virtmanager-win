/*
WLib.js - A Simple QtScript Window Control Library
*/

function openDialog(dialog) {
    dialog.open();
}

function closeDialog(dialog) {
    dialog.close();
}

function confirmDelete(dialog, vmName) {
    dialog.vmName = vmName;
    dialog.open();
}

function selectVm(listView, index) {
    listView.currentIndex = index;
}

function setWindowTitle(window, title) {
    window.title = title;
}

function isValidVmName(name) {
    return /^[A-Za-z0-9][A-Za-z0-9 _-]{0,47}$/.test(name);
}
