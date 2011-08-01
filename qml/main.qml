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
            onClicked: {
                (favoriteMenu.status == DialogStatus.Closed) ? favoriteMenu.open() : favoriteMenu.close()
            }
        }
        ToolIcon {
            id: addFavoriteTool
            platformIconId: "toolbar-add"
            anchors.right: favoriteTool.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                (favoriteMenu.status == DialogStatus.Closed) ? favoriteMenu.open() : favoriteMenu.close()
                if (pageStack.currentPage.objectName == "stopInfoPage") {
                    console.log("Ok, I'm on stop info page")
                    removeFavoriteTool.visible = true
                } else if (pageStack.currentPage.objectName == "lineInfoPage") {
                    console.log("Ok, I'm on line info page")
                    removeFavoriteTool.visible = true
                } else {
                    console.log("Ok, I don't know what page is it")
                }
            }
            visible: false;
            onVisibleChanged: if (visible == true && removeFavoriteTool.visible == true) removeFavoriteTool.visible = false;
        }
        ToolIcon {
            id: removeFavoriteTool
            platformIconId: "toolbar-delete"
            anchors.right: favoriteTool.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                (favoriteMenu.status == DialogStatus.Closed) ? favoriteMenu.open() : favoriteMenu.close()
                if (pageStack.currentPage.objectName == "stopInfoPage") {
                    console.log("Ok, I'm on stop info page")
                    addFavoriteTool.visible = true
                } else if (pageStack.currentPage.objectName == "lineInfoPage") {
                    console.log("Ok, I'm on line info page")
                    addFavoriteTool.visible = true
                } else {
                    console.log("Ok, I don't know what page is it")
                }
            }
            visible: false;
            onVisibleChanged: if (visible == true && addFavoriteTool.visible == true) addFavoriteTool.visible = false;
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: "Offline mode" }
            MenuItem { text: "Option" }
        }
    }
    Menu {
        id: stopsMenu
        MenuLayout {
            MenuItem {
                id: emptyStopsMenuItem
                text: "No items"
                enabled: false
            }
            MenuItem {
                text: "Back"
                onClicked: {
                    stopsMenu.close()
                    favoriteMenu.open()
                }
            }
        }
    }
    Menu {
        id: linesMenu
        MenuLayout {
            MenuItem {
                id: emptyLinesMenuItem
                text: "No items"
                enabled: false
            }
            MenuItem {
                text: "Back"
                onClicked: {
                    linesMenu.close()
                    favoriteMenu.open()
                }
            }
        }
    }
    Menu {
        id: placesMenu
        MenuLayout {
            MenuItem {
                id: emptyPlacesMenuItem
                text: "No items"
                enabled: false
            }
            MenuItem {
                text: "Back"
                onClicked: {
                    placesMenu.close()
                    favoriteMenu.open()
                }
            }
        }
    }
    Menu {
        id: routesMenu
        MenuLayout {
            MenuItem {
                id: emptyRoutesMenuItem
                text: "No items"
                enabled: false
            }
            MenuItem {
                text: "Back"
                onClicked: {
                    routesMenu.close()
                    favoriteMenu.open()
                }
            }
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
