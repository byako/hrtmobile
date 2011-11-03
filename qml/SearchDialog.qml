import QtQuick 1.0
import com.meego 1.1

Dialog {
    id: searchDialog

    property Item page: null

    title: Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: "Search"
    }

    content: Item {
        height: 100
        width: parent.width
        anchors.fill: parent
        Rectangle {
            width: 260
            height: 40
            color: "#333333"
            radius: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            TextInput{
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                width: parent.width
                height: parent.height
                maximumLength: 16
                onFocusChanged: {
                    focus == true ? openSoftwareInputPanel() : closeSoftwareInputPanel()
                    focus == true ? text = qsTr("") : null
                }
                onAccepted:  { searchDialog.accept() }
                font.pixelSize: 30
                text: "Enter LineID"
                color: "#FFFFFF"
            }
        }
    }

    buttons: Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Search"
        onClicked: { searchDialog.accept(); }
    }

    onAccepted: {
        searchInput.focus = false
//        console.log("searchDialog: starting search: " + searchInput.text)
        page.searchString = searchInput.text
        page.buttonClicked()
    }

    onRejected: {
        searchInput.focus = false
//        console.log("User declined proposition. Kill?")
    }
}
