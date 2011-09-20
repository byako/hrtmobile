import QtQuick 1.0

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
        width: 180
        height: 180
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: ":/images/loading.png"
        NumberAnimation on rotation {
            from: 0; to: 360; running: loading.visible == true; loops: Animation.Infinite; duration: 900
        }
    }
}
