import QtQuick 1.1
import com.nokia.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.1

Item {
    id: settingsPage
    objectName: "SettingsPageItem"
    property string currentTheme: ""
    signal updateConfig
    signal dbclean()
    width: 480
    height: 745

    Component.onCompleted: { refreshConfig(); }
    Config { id: config }

    WorkerScript {           // database clean finished
        id: resetDatabase
        source: "resetDatabase.js"
        onMessage: {
            if (messageObject.clean == "done") {
                settingsPage.dbclean()
                refreshConfig()
                showError("Database cleaned")
            }
        }
    }

    InfoBanner {// info banner
        id: infoBanner
        text: ""
        z: 10
        opacity: 1.0
    }
    Rectangle {     // dark background
        color: "#000000";
        anchors.fill: parent
        width: parent.width
        height:  parent.height
    }

    Column {
        spacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "HUOMIO! ATTENTION!\nACHTUNG! ВНИМАНИЕ!"
            color: "#cdd9ff"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Press this button only if real need\nIt will wipe all HRT R&S saved data"
            color: "#cdd9ff"
        }
        Button {
            style: ButtonStyle {
                inverted: true
            }
            anchors.horizontalCenter: parent.horizontalCenter
            id: resetButton
            text: "Reset database"
            onClicked: {
                resetDatabase.sendMessage("")
            }
        }

        Row {
            Label {
                text: "Show all saved lines"
                color: "#cdd9ff"
                width: 380
            }
            Switch {
                style: SwitchStyle {
                    inverted: true
                }
                id: linesShowAllSwitch
                anchors.verticalCenter: parent.verticalCenter
                checked: config.linesShowAll
                onCheckedChanged: {
                    if (checked == true) {
                        JS.setConfigValue("linesShowAll", "true")
                    } else {
                        JS.setConfigValue("linesShowAll", "false")
                    }
                    settingsPage.updateConfig()
                }
            }
        }
        Row {
            Label {
                text: "Show all saved stops"
                color: "#cdd9ff"
                width: 380
            }
            Switch {
                style: SwitchStyle {
                    inverted: true
                }
                id: stopsShowAllSwitch
                anchors.verticalCenter: parent.verticalCenter
                checked: config.stopsShowAll
                onCheckedChanged: {
                    if (checked == true) {
                        JS.setConfigValue("stopsShowAll", "true")
                    } else {
                        JS.setConfigValue("stopsShowAll", "false")
                    }
                    settingsPage.updateConfig()
                }
            }
        }

        Button {
            style: ButtonStyle {inverted: true }
            anchors.horizontalCenter: parent.horizontalCenter
            id: aboutButton
            text: "About"
            onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
        }
    }
//----------------------------------------------------------------------------//
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function refreshConfig() {
        JS.loadConfig(config)
    }
}
