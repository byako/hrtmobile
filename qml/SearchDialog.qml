import QtQuick 1.0
import com.meego 1.0

Dialog {
    id: searchDialog

    property Item page: null
    property bool exactSearch: false

    title: Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: "Search"
    }

    QueryDialog {
        id: infoDialog
        acceptButtonText: "OK"
        message: "Use exact search if you know exact ID of the vechile/stop. Example: 1011"
        titleText: "Exact search"
    }

    content: Item {
        height: 350
        width: parent.width
        anchors.fill: parent
        Column {
            id: mainColumnt
            spacing: 40
            anchors.fill: parent
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    style: ButtonStyle {
                        inverted: true
                    }
                    width: 40
//                    iconSource: "image://theme/icon-m-toolbar-frequent-used"
                    text: "i"
                    onClicked: {
                        infoDialog.open()
                    }
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    style: LabelStyle {
                        inverted: true
                    }
                    font.pixelSize: 30
                    width: 200
                    height: 40
                        text: "Exact search"
                }
                Switch {
                    style: SwitchStyle {
                        inverted: true
                    }
                    checked: false
                    onCheckedChanged: {
                        exactSearch = checked
                    }
                }
            }
            Rectangle {  // search field
                width: 260
                height: 40
                color: "#333333"
                radius: 20
                anchors.horizontalCenter: parent.horizontalCenter
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
    }

    buttons: Button {
        style: ButtonStyle {
            inverted: true
        }
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
