import QtQuick 1.1
import com.nokia.meego 1.0
import "updateDatabase.js" as Updater

Page {
    id: updatePage
    objectName: "UpdatePage"
    tools: null
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: {
        console.log("finished loading updatePage")
    }

    Rectangle{      // dark background
        color: "#000000"
        anchors.fill: parent
    }
    Column {
        anchors.fill: parent
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Update database"
            font.pixelSize: 40
            style: LabelStyle {inverted: true}
        }
        Button {
            style: ButtonStyle {inverted: true}
            text: "Update"
            onClicked: {
                update();
                pageStack.pop()
            }
        }
        Button {
            style: ButtonStyle {inverted: true}
            text: "Next time"
            onClicked: {
                pageStack.pop()
                appWindow.pushMainPage();
            }
        }
    }
    function update() {
        console.log("updating DB")
        Updater.getTimestamps();
    }
}
