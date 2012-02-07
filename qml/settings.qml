import QtQuick 1.1
import com.nokia.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.1

Item {
    id: settingsPage
    objectName: "SettingsPageItem"
    property string currentTheme: ""
    signal dbclean()
    width: 480
    height: 745

    InfoBanner {// info banner
        id: infoBanner
        text: "info description here"
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
                JS.cleanAll()
                JS.initDB()
                settingsPage.dbclean()
                showError("Database cleaned")
            }
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "HRTMobile version 0.6.7 (20120122)"
            color: "#cdd9ff"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Address for feedback"
            color: "#cdd9ff"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "alexey.fomenko@gmail.com"
            color: "#cdd9ff"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "This is free software distributed under\n GPLv3 license. Data charges may apply"
            color: "#cdd9ff"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Sources: git://[git-address].git"
            color: "#cdd9ff"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "stopsShowAll : FALSE"
            color: "#cdd9ff"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "linesShowAll : FALSE"
            color: "#cdd9ff"
        }
    }
//----------------------------------------------------------------------------//
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
}
