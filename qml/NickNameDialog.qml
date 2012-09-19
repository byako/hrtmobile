import QtQuick 1.0
import com.nokia.meego 1.0

Dialog {
    id: nickNameDialog

//    property Item page: null
    property string stopCodeAndName: ""
    property string oldNick: ""
    title: Text {
        id: stopCodeAndNameText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        font.pixelSize: 35
        color: "#cdd9ff"
        text: stopCodeAndName
    }

    content: Item {
        height: 150
        width: parent.width
        anchors.fill: parent

        Rectangle {  // nick name edit field
                width: 260
                height: 40
                color: "#333333"
                radius: 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                TextInput{
                    id: nickNameInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    maximumLength: 64
                    onFocusChanged: {
                        focus == true ? openSoftwareInputPanel() : closeSoftwareInputPanel()
                    }
                    onAccepted:  { nickNameDialog.accept() }
                    font.pixelSize: 30
                    text: oldNick
                    color: "#FFFFFF"
                }
        }
    }

    buttons: Button {
        style: ButtonStyle {
            inverted: true
        }
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Save"
        onClicked: {
            accept()
        }
    }
    onStatusChanged: {
        if (status == DialogStatus.Open ) {
            nickNameInput.text = "" + oldNick
            nickNameInput.focus = true
        }
    }

    onAccepted: {
        nickNameInput.focus = false
        console.log("trying to save nick:" + nickNameInput.text + ";");
        if (nickNameInput.text != oldNick) {
            stopInfoPage.setNickName(nickNameInput.text)
        }
        oldNick = ""
        nickNameInput.text = ""
    }

    onRejected: {
        nickNameInput.focus = false
        nickNameInput.text = ""
        oldNick = ""
    }
}
