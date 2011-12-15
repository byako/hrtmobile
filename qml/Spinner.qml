import QtQuick 1.1
import com.nokia.extras 1.1
import com.meego 1.0

Item {
    Rectangle {
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color:"#FFFFFF"
        opacity: 0.7
    }
    Image {
        id: loadingImage
        width: parent.width > 180 ? 180 : parent.width
        height: parent.height > 180 ? 180 : parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: ":/images/loading.png"
        NumberAnimation on rotation {
            from: 0; to: 360; running: loading.visible == true; loops: Animation.Infinite; duration: 900
        }
    }
}
