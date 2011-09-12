import QtQuick 1.1
import com.nokia.meego 1.0
import "lineInfo.js" as JS

QueryDialog {
    acceptButtonText: "Go online"
    rejectButtonText: "Keep offline"
    message: "Offline mode enabled.\nGo online?\n(Data charges may apply)"
    titleText: "Offline mode"
    onAccepted: {
        JS.setCurrent("offline","false")
    }
    onRejected: {
        console.log("User declined to go online")
    }
}
