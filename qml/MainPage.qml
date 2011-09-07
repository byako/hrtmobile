import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
import "lineInfo.js" as JS

Page {
    id: mainPage
    tools: commonTools
    Item {
        id: config
        property string bgColor: ""
        property string textColor: ""
        property string highlightColor: ""
        property string bgImage: ""
        property string highlightColorBg: ""
    }
    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait
    Component.onCompleted: { JS.loadConfig(config)}
    Rectangle{
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        Image { source: config.bgImage; fillMode: Image.Center; anchors.fill: parent; }
    }
    Label {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 100
        font.pixelSize: 36
        text: qsTr("Helsinki Regional Transport")
        color: config.textColor;
        visible: true
    }
    Button{
        id: lineInfoButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: label.bottom
        anchors.topMargin: 50
        text: qsTr("Line info")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("lineInfo.qml"))
            backTool.visible=true
        }
    }
    Button{
        id:stopInfoButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: lineInfoButton.bottom
        anchors.topMargin: 10
        text: qsTr("Stop info")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("stopInfo.qml"))
            backTool.visible=true
        }
    }
    Button{
        id:routeButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: stopInfoButton.bottom
        anchors.topMargin: 10
        text: qsTr("Map")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("route.qml"))
            backTool.visible=true
        }
    }
    Button{
        id:realtimeButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: routeButton.bottom
        anchors.topMargin: 10
        text: qsTr("Realtime schedule")
        onClicked: {
//            pageStack.push(Qt.resolvedUrl("route.qml"))
//            backTool.visible=true
        }
    }
    Rectangle{  // lines page icon
        color: config.bgColor;
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.topMargin: 10
        height: 274
        width: 80
        Image { source: ":/images/icon_transport.png"; fillMode: Image.Center; anchors.fill: parent; opacity: 50 }
    }
}
