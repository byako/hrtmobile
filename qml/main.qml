import QtQuick 1.1
import com.meego 1.0
import "lineInfo.js" as JS

PageStackWindow {
    id: appWindow

    initialPage: mainPage

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
            Rectangle {
                width: 260
                height: 40
                color: "#333333"
                radius: 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
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

    ToolBarLayout {
        id: commonTools
        visible: true
        ToolIcon {
             id: backTool
             platformIconId: "toolbar-back"
             onClicked: {
                 pageStack.pop()
                 backTool.visible = pageStack.currentPage==mainPage ? false : true
             }
             visible: false
        }
        ToolIcon {
            id: searchButton
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
    }

    Menu {
        id: myMenu
        MenuLayout {
/*            MenuItem {
                text: "Clean DB"
                onClicked: {
                    JS.cleanAll()
                    JS.initDB()
                }
            }
            MenuItem { text: "Offline Mode" } */
            MenuItem {
                text: "Options"
                onClicked:  {
                    pageStack.push(Qt.resolvedUrl("settings.qml"))
                    backTool.visible=true
                }
            }
        }
    }
}
