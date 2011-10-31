import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.0

Page {
    id: settingsPage
//    tools: commonTools
    orientationLock: PageOrientation.LockPortrait
    property string currentTheme: ""

    Config {
        id: config
    }
    InfoBanner {// info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }

    Component.onCompleted: { refreshConfig(); currentTheme =  JS.getCurrent("theme"); console.log("set currentTheme: " + currentTheme); offlineSwitchInit() }
    Rectangle {     // dark background
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        Image { source: config.bgImage ; fillMode: Image.Center; anchors.fill: parent; }
    }
    TumblerButton {
        id: themeButton
        text: "Theme"
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        onClicked: {
            themesModel.clear()
            loadThemesNames()
            themeDialog.open()
        }
    }
    TumblerButton {
        id: networkingButton
        text: "Networking"
        anchors.top: themeButton.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        onClicked: {
            networkingDialog.open()
        }
    }
    Button {
        id: resetButton
        anchors.top : networkingButton.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        text: "Reset database"
        onClicked: {
            JS.cleanAll()
            JS.initDB()
            JS.loadConfig(config)
            showError("Database cleaned")
        }
    }
    Row {
        id: lineGroupRow
        height: 40
        anchors.top : resetButton.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        spacing: 20
        Text {
            width: 350
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            text: "Groupe same line directions"
            font.pixelSize: 25
            color: config.textColor
        }

        Switch {
            id: lineGroupSwitch
            anchors.verticalCenter: parent.verticalCenter
            checked: config.lineGroup
            onCheckedChanged: {
                if (checked == true) {
                    JS.setCurrent("lineGroup", "true")
                    pageStack.find(function(page) {
                                       page.refreshConfig();
                    })
                } else {
                    JS.setCurrent("lineGroup", "false")
                    pageStack.find(function(page) {
                                       page.refreshConfig();
                    })
                }
            }
        }
    }
//----------------------------------------------------------------------------//
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
             console.log("selectedIndex: " + selectedIndex + "; previous currentTheme value: " + currentTheme)
             if (currentTheme != selectedIndex) {
                currentTheme = themesModel.get(selectedIndex).name
                JS.setTheme(currentTheme)
                pageStack.find(function(page) {
                    page.refreshConfig();
                })
             }
         }
    }
    ListModel {
        id: networkingModel
        ListElement { name: "Full offline: don't use network" }
        ListElement { name: "Partly online: online schedules" }
        ListElement { name: "Full online: always use network" }
    }
    SelectionDialog {
         id: networkingDialog
         titleText: "Networking"
         selectedIndex: JS.getCurrent("networking")
         model: networkingModel
         onSelectedIndexChanged: {
             if (config.networking != selectedIndex) {
                 JS.setCurrent("networking",selectedIndex)
                 config.networking = selectedIndex
             }
         }
    }
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
                        if (rs.rows.item(i).theme == currentTheme) {
                            console.log("THEME: currentIndex is" + i + "; themeName is " + currentTheme)
                            themeDialog.selectedIndex = i
                        }
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
