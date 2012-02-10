import QtQuick 1.0
import com.nokia.meego 1.0
import com.nokia.extras 1.1

Page {
    id: about;
    tools: commonTools
    objectName: "aboutPage"
    width: 480
    height: 745
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }
Column {
    spacing: 20
    anchors.horizontalCenter: parent.horizontalCenter
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "HRTMobile version 0.6.7 (20120122)"
        color: "#cdd9ff"
    }
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Address for feedback"
        color: "#cdd9ff"
    }
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "alexey.fomenko@gmail.com"
        color: "#cdd9ff"
    }
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "This is free software distributed under\n GPLv3 license. Data charges may apply"
        color: "#cdd9ff"
    }
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Sources: git://[git-address].git"
        color: "#cdd9ff"
    }
    Button {
        style: ButtonStyle {inverted: true }
        anchors.horizontalCenter: parent.horizontalCenter
        id: back
        text: "OK"
        onClicked: pageStack.pop()
    }
}
}
