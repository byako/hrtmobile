import QtQuick 1.0
import com.nokia.meego 1.0

Item {                   // busy indicator
    property int linesToSave: 0
    property int linesSaved: 0
    property int stopsToSave: 0
    property int stopsSaved: 0
    Rectangle {
        anchors.fill: parent
        color:"#333333"
        opacity: 0.7
    }
    BusyIndicator {
        id: busy
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        platformStyle: BusyIndicatorStyle { size : "large"; inverted: true }
        running: true
    }
    Row {
        id: linesProgressLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: busy.bottom
        anchors.topMargin: 20
        width: 400
        Label {
            text: "Saving lines"
            width: 300
            color: "#A0A0FF"
        }
        Label {
            text: linesToSave
            color: "#8080FF"
        }
        visible: linesToSave > 0 ? true : false
    }
    Row {
        id: stopsProgressLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: linesProgressLabel.bottom
        anchors.topMargin: 20
        width: 400
        Label {
            text: "Saving stops"
            width: 300
            color: "#A0A0FF"
        }
        Label {
            text: stopsToSave
            color: "#8080FF"
        }
        visible: stopsToSave > 0 ? true : false
    }
}
