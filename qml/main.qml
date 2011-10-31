import QtQuick 1.1
import com.meego 1.0

PageStackWindow {
    id: appWindow

    initialPage: mainPage
//    property String refreshConfig: "false"
    MainPage{id: mainPage}
    Dialog{
        id: searchDialog
        title: Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: "Search"
        }

        content: Item {
            height: 100
            width: parent.width
            anchors.fill: parent
/*            Label {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Networking mode: Partly online. Only database search"
                visible: config.networking > 1 ? true : false
            }*/
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
            console.log("Starting search")
            pageStack.currentPage.searchString = searchInput.text
            pageStack.currentPage.buttonClicked()
        }
        onRejected: {
            searchInput.focus = false
            console.log("User declined proposition. Kill?")
        }
    }

/*    ToolBarLayout {
        id: commonTools
        visible: true
        ToolIcon {
             id: backTool
             platformIconId: "toolbar-back"
             onClicked: {
                 pageStack.pop()
                 if (pageStack.currentPage == mainPage) {
                     backTool.visible = false
                     searchTool.visible = false
                 } else if (pageStack.currentPage.objectName == "realtimeSchedule") {
                     pageStack.currentPage.fillModel()
                 } else if (pageStack.currentPage.objectName == "lineInfoPage") {
//                     pageStack.currentPage.updateStopReachModel()
                 } else {
                     backTool.visible = true
                     searchTool.visible = true
                 }
             }
             visible: false
        }
        ToolIcon {
            id: searchTool
            platformIconId: "toolbar-search"
            anchors.left: backTool.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                searchDialog.open()
                searchInput.focus = true
            }
            visible: false
        }
        ToolIcon {
             id: menuTool
             platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: {
                 pageStack.push(Qt.resolvedUrl("settings.qml"))
                 backTool.visible=true
//                 (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
             }
        }
    }*/

}
