import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
import "lineInfo.js" as JS

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    MainPage{id: mainPage}

    HrtmConfig {id: config}

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
            console.log("User declined proposition. Kill")
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
            id: addFavoriteTool
            platformIconId: "toolbar-add"
            anchors.right: favoriteTool.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                 switch (pageStack.currentPage.objectName) {
                    case "stopInfoPage": {
                        console.log("Ok, I'm on stop info page")
                        addFavoriteConfirm.open()
                        break;
                    }
                    case "lineInfoPage": {
                        console.log("Ok, I'm on line info page")
                        addFavoriteConfirm.open();
                        break;
                    }
                    default: {
                        console.log("Ok, I don't know what page is it")
                    }
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
        ToolIcon {
            id: favoriteTool
            platformIconId: "toolbar-favorite-mark"
            anchors.right: menuTool.left
            onClicked: {
                switch (pageStack.currentPage.objectName) {
                   case "stopInfoPage": {
                       (stopsMenu.status == DialogStatus.Closed) ? stopsMenu.open() : stopsMenu.close()
                       break;
                   }
                   case "lineInfoPage": {
                       (linesMenu.status == DialogStatus.Closed) ? linesMenu.open() : linesMenu.close()
                       break;
                   }
                   case "placeInfoPage": {
                       (linesMenu.status == DialogStatus.Closed) ? linesMenu.open() : linesMenu.close()
                       break;
                   }
                   case "routeInfoPage": {
                       (linesMenu.status == DialogStatus.Closed) ? linesMenu.open() : linesMenu.close()
                       break;
                   }
                   default: {
                       (favoriteMenu.status == DialogStatus.Closed) ? favoriteMenu.open() : favoriteMenu.close()
                   }
               }
            }
        }
        ToolIcon {
             id: menuTool
             platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: {
                 (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
             }
        }
    }

    Menu {
        id: myMenu
        MenuLayout {
            MenuItem {
                text: "Clean DB"
                onClicked: {
                    JS.cleanAll()
                    JS.initDB()
                }
            }
            MenuItem { text: "Offline Mode" }
            MenuItem { text: "Options" }
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
                text: "Selct category"
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
                text: "Selct category"
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
                text: "Selct category"
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
                text: "Selct category"
                onClicked: {
                    routesMenu.close()
                    favoriteMenu.open()
                }
            }
        }
    }
    Menu { // main favorites
        id: favoriteMenu
        MenuLayout {
            MenuItem {
                text: "Stops"
                onClicked: stopsMenu.open()
            }
            MenuItem {
                text: "Lines"
                onClicked: linesMenu.open()
            }
            MenuItem {
                text: "Places"
                onClicked: placesMenu.open()
            }
            MenuItem {
                text: "Routes"
                onClicked: routesMenu.open()
            }
        }
    }
}
