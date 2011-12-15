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
    }
//----------------------------------------------------------------------------//
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
}
