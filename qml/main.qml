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
             iconId: "toolbar-back"
             platformIconId: "toolbar-back"
             onClicked: {
                 pageStack.pop()
                 backTool.visible = pageStack.currentPage==mainPage ? false : true
             }
             visible: false
        }
        ToolIcon {
             platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: "Offline mode" }
        }
    }
}
