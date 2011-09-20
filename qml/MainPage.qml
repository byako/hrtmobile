import QtQuick 1.1
import com.meego 1.0
import "lineInfo.js" as JS

Page {
    id: mainPage
    tools: commonTools
    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait

    Item {
        id: config
        property string bgColor: ""
        property string textColor: ""
        property string highlightColor: ""
        property string bgImage: ""
        property string highlightColorBg: ""
        property int networking: 5  // default
    }
    Component.onCompleted: { JS.loadConfig(config)}
    Rectangle{    // dark background
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        Image { source: config.bgImage; fillMode: Image.Center; anchors.fill: parent; }
    }
    Label {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:  parent.top
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
        height: 100
        anchors.topMargin: 50
        text: qsTr("Line info")
        onClicked: {
            searchButton.visible = true
            pageStack.push(Qt.resolvedUrl("lineInfo.qml"))
            backTool.visible=true
        }
    }
    Button{
        id:stopInfoButton
        anchors.horizontalCenter : parent.horizontalCenter
        anchors.top : lineInfoButton.bottom
        anchors.topMargin: 10
        text: qsTr("Stop info")
        height: 100
        onClicked: {
            searchButton.visible = true
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
        height: 100
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
        height: 100
        onClicked: {
            pageStack.push(Qt.resolvedUrl("realtimeSchedule.qml"))
            backTool.visible=true
        }
    }
    Item {  // lines page icon
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.topMargin: 10
        height: 274
        width: 80
        visible: false
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("lineInfo.qml"))
                backTool.visible=true
            }
        }
        Image { source: ":/images/icon_transport.png"; fillMode: Image.Center; anchors.fill: parent; opacity: 50 }
    }
}
