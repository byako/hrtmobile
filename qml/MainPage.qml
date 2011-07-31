import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0

Page {
    id: mainPage
    tools: commonTools

    HrtmConfig {id: config}

    Rectangle{
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
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
        id:lineScheduleButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: stopInfoButton.bottom
        anchors.topMargin: 10
        text: qsTr("Line schedule")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("lineSchedule.qml"))
            backTool.visible=true
        }
    }
}
