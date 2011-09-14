import QtQuick 1.1
import com.meego 1.0
import "lineInfo.js" as JS

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    MainPage{id: mainPage}
    QueryDialog{
        id: addFavoriteConfirm
        acceptButtonText: "Add"
        rejectButtonText: "Back"
        message: "Add this to the favorites?"
        titleText: "Favorites"
        onAccepted: {
            removeFavoriteTool.visible = true
            console.log("Adding to the favorites")
        }
        onRejected: {
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
                 if (addFavoriteTool.visible == true) {
                     addFavoriteTool.visible = false
                 }
                 if (removeFavoriteTool.visible == true) {
                     removeFavoriteTool.visible = false
                 }
             }
             visible: false
        }
        ToolIcon {
            id: searchButton
            platformIconId: "toolbar-search"
            anchors.left: backTool.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {

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
