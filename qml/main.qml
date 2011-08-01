import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    MainPage{id: mainPage}

    HrtmConfig {id: config}

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
             id: menuTool
             platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
        ToolIcon {
            id: favoriteTool
            platformIconId: "toolbar-favorite-mark"
            anchors.right: menuTool.left
            onClicked: { (favoriteMenu.status == DialogStatus.Closed) ? favoriteMenu.open() : favoriteMenu.close() }
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: "Offline mode" }
        }
    }
    Menu {
        id: stopsMenu
        MenuLayout {
            MenuItem { text: "Nelikko" }
        }
    }
    Menu {
        id: linesMenu
        MenuLayout {
            MenuItem { text: "112" }
        }
    }
    Menu {
        id: placesMenu
        MenuLayout {
            MenuItem { text: "Home" }
        }
    }
    Menu {
        id: routesMenu
        MenuLayout {
            MenuItem { text: "Home->Work" }
        }
    }

    Menu {
        id: favoriteMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: "Stops"
//                platformSubItemIndicator: true
                onClicked: stopsMenu.open()
            }
            MenuItem {
                text: "Lines"
//                platformSubItemIndicator: true
                onClicked: linesMenu.open()
            }
            MenuItem {
                text: "Places"
//                platformSubItemIndicator: true
                onClicked: placesMenu.open()
            }
            MenuItem {
                text: "Routes"
//                platformSubItemIndicator: true
                onClicked: routesMenu.open()
            }
        }
    }
}
