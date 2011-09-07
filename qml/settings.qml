import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
import "lineInfo.js" as JS
import com.nokia.extras 1.0

Page {
    id: settingsPage
    tools: commonTools
    orientationLock: PageOrientation.LockPortrait
    property string currentTheme: ""

    Item {
        id: config
        property string bgColor: ""
        property string textColor: ""
        property string highlightColor: ""
        property string bgImage: ""
        property string highlightColorBg: ""
    }

    Component.onCompleted: { JS.loadConfig(config); currentTheme =  JS.getCurrent("theme") }
    Rectangle {     // dark background
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        Image { source: config.bgImage ; fillMode: Image.Center; anchors.fill: parent; }
    }
    Button {
        text: "Theme"
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        onClicked: {
            themesModel.clear()
            loadThemesNames()
            themeDialog.open()
        }
    }
    ListModel {
        id: themesModel
        ListElement { name: "" }
    }
    SelectionDialog {
         id: themeDialog
         titleText: "Theme"
         selectedIndex: 0
         model: themesModel
         onSelectedIndexChanged: {
             if (currentTheme != selectedIndex) {
                currentTheme = themesModel.get(selectedIndex).name
                JS.setTheme(currentTheme)
                JS.loadConfig(config)
             }
         }
    }

    function loadThemesNames() {
        JS.__db().transaction(
            function(tx) {
                try {
                    var rs = tx.executeSql("SELECT DISTINCT theme FROM Config");
                }
                catch(e) {
                    console.log("EXCEPTION: " + e);
                }
                if (rs.rows.length > 0) {
                    for (var i=0;i<rs.rows.length;++i) {
                        console.log("found " + rs.rows.item(i).theme)
                        if (rs.rows.item(i).theme == currentTheme) {
                            themeDialog.selectedIndex = i
                        }
                        themesModel.append({"name" : rs.rows.item(i).theme})
                    }
                }
            }
        )
    }


}
