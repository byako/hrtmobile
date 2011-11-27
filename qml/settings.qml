import QtQuick 1.1
import com.nokia.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.0

Item {
    id: settingsPage
    objectName: "SettingsPageItem"
    property string currentTheme: ""
    signal updateConfig()
    width: 480
    height: 745

    InfoBanner {// info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    Component.onCompleted: {
        offlineSwitchInit()
    }
    Rectangle {     // dark background
        color: "#000000";
        anchors.fill: parent
        width: parent.width
        height:  parent.height
//        Image { source: config.bgImage ; fillMode: Image.Center; anchors.fill: parent; }
    }

    Column {
        spacing: 20
/*        TumblerButton {
            style: TumblerButtonStyle {
                inverted: true
            }
            id: themeButton
            text: "Theme"
            onClicked: {
                if (themesModel.count == 0) loadThemesNames()
                themeDialog.open()
            }
        }*/
        Button {
            style: ButtonStyle {
                inverted: true
            }
            id: resetButton
            text: "Reset database"
            onClicked: {
                JS.cleanAll()
                JS.initDB()
                settingsPage.updateConfig()
                showError("Database cleaned")
            }
        }
        Row {
            id: lineGroupRow
            height: 40
            Text {
                width: 350
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                text: "Groupe same line directions"
                font.pixelSize: 25
                color: "#cdd9ff"
            }

            Switch {
                style: SwitchStyle {
                    inverted: true
                }
                id: lineGroupSwitch
                anchors.verticalCenter: parent.verticalCenter
                checked: config.lineGroup
                onCheckedChanged: {
                    if (checked == true) {
                        JS.setCurrent("lineGroup", "true")
                    } else {
                        JS.setCurrent("lineGroup", "false")
                    }
                    settingsPage.updateConfig()
                }
            }
        }
    }
//----------------------------------------------------------------------------//
/*    ListModel {
        id: themesModel
//        ListElement { name: "" }
    }
    SelectionDialog {
         id: themeDialog
         titleText: "Themes"
//         selectedIndex: -1
         model: themesModel
         onSelectedIndexChanged: {
             console.log("selectedIndex: " + selectedIndex + "; previous currentTheme value: " + currentTheme + ": in model: " + themesModel.count)
             if (currentTheme != themesModel.get(selectedIndex).name) {
                currentTheme = themesModel.get(selectedIndex).name
                titleText = "Current: " + currentTheme
                JS.setTheme(currentTheme)
                settingsPage.updateConfig()
             }
         }
    }*/
//----------------------------------------------------------------------------//
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function loadThemesNames() {
        JS.__db().transaction(
            function(tx) {
                try {
                    var rs = tx.executeSql("SELECT DISTINCT theme FROM Config ORDER BY theme ASC");
                }
                catch(e) {
                    console.log("EXCEPTION: " + e);
                }
                if (rs.rows.length > 0) {
                    for (var i=0;i<rs.rows.length;++i) {
                        console.log("found " + rs.rows.item(i).theme)
                        themesModel.append({"name" : rs.rows.item(i).theme})
                    }
                }
            }
        )
    }
    function offlineSwitchInit() {
        var offlineSwitchState = JS.getCurrent("offline")
        if (offlineSwitchState == "true") {
            switchComponent.checked = true
        }
    }
    function refreshConfig() {
        JS.loadConfig(config)
    }
}
