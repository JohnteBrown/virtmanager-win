import subprocess
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


def main():
    """Main application entry point"""
    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()

    # Get the path to the QML file
    qml_file = Path(__file__).parent / "App" / "Main.qml"

    # Ensure QML file exists
    if not qml_file.exists():
        print(f"Error: QML file not found: {qml_file}")
        return 1

    # Load the QML file
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    # Check if loading was successful
    if not engine.rootObjects():
        print("Error: Failed to load QML file")
        return 1

    # Run the application
    return_code = app.exec()

    # Log the program status
    subprocess.run(["echo", "Program is running!!", ">>", "log/main.log"])

    return return_code


if __name__ == "__main__":
    sys.exit(main())
