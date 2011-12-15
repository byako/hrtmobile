import QtQuick 1.0
import com.nokia.meego 1.0

Dialog {
    id: searchDialog

    property Item page: null

    title: Text {
        id: titleText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        font.pixelSize: 35
        color: "#cdd9ff"
        text: (page.objectName == "stopInfoPage") ? "Stop Search" : (page.objectName == "lineInfoPage") ? "Line Search" : "Map object search"
    }

    content: Item {
        height: 150
        width: parent.width
        anchors.fill: parent

        Rectangle {  // search field
                width: 260
                height: 40
                color: "#333333"
                radius: 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                TextInput{
                    id: searchInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    maximumLength: 64
                    onFocusChanged: {
                        focus == true ? openSoftwareInputPanel() : closeSoftwareInputPanel()
                        focus == true ? text = qsTr("") : null
                    }
                    onAccepted:  { searchDialog.accept() }
                    font.pixelSize: 30
                    text: "Search"
                    color: "#FFFFFF"
                }
        }
    }

    buttons: Button {
        style: ButtonStyle {
            inverted: true
        }
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Search"
        onClicked: { searchDialog.accept(); }
    }
    onStatusChanged: {
        if (status == DialogStatus.Opened) {
            console.log("changing focus")
            searchInput.focus = true
        }
    }

    onAccepted: {
        searchInput.focus = false
        page.searchString = searchInput.text
        page.buttonClicked()
    }

    onRejected: {
        searchInput.focus = false
    }
}
