import QtQuick 1.1
import com.meego 1.0

Page {
    id: busStopSchedulePage
    tools: commonTools
    Label {
        id: busStopLabel
        anchors.centerIn: parent
        text: qsTr("Bus Stop Schedule")
        visible: false
    }
    TextInput{
        id: stopId
        width: 140
        maximumLength: 16
        color: "#000000"
        onFocusChanged: {
            focus == true ? openSoftwareInputPanel() : closeSoftwareInputPanel()
        }
        selectionColor: "green"
        font.pixelSize: 32
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: "Stop ID"
    }
    Button{
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 20
        text: qsTr("Show Schedule")
        onClicked: {
            busStopLabel.text=qsTr(stopId.text + " Bus Stop Schedule")
            busStopLabel.visible=true
            stopId.selectAll()
            stopId.text="";
            focus = true
        }
    }
}
