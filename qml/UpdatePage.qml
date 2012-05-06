import QtQuick 1.1
import com.nokia.meego 1.0
//import "database.js" as JS

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
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top : parent.top
        text: "Update database"
        font.pixelSize: 40
        style: LabelStyle {inverted: true}
    }
    Button {
        anchors.centerIn: parent
        style: ButtonStyle {inverted: true}
        text: "Done"
        onClicked: {
            pageStack.pop()
            pageStack.currentPage.initPages()
        }
    }
}
