import QtQuick 1.0

Item {
    Rectangle {
        width: 80
        height: 80
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color:"#FFFFFF"
        opacity: 0.7
    }
    Image {
        id: loadingImage
        width: 80
        height: 80
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: ":/images/loading.png"
        NumberAnimation on rotation {
            from: 0; to: 360; running: loading.visible == true; loops: Animation.Infinite; duration: 900
        }
    }
}
