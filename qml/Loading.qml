import QtQuick 1.0
import com.meego 1.0

Item {                   // busy indicator
    Rectangle {
        anchors.fill: parent
        color:"#333333"
        opacity: 0.7
    }
    BusyIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        platformStyle: BusyIndicatorStyle { size : "large"; inverted: true }
        running: true
    }
}
