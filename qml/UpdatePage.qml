import QtQuick 1.1
import com.nokia.meego 1.0
import "database.js" as JS
import "updateDatabase.js" as Updater

Page {
    id: updatePage
    objectName: "UpdatePage"
    tools: null
    property int linesToSave: 0
    property int stopsToSave: 0
    property int nickNamesCounter: 0
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: {
        console.log("finished loading updatePage")
    }

    ListModel {
        id: lines
    }
    ListModel {
        id: stops
    }
    ListModel {
        id: nickNames
    }

    WorkerScript {  // line save worker
        id: lineSearchWorker
        source: "lineSearch.js"

        onMessage: {
            if (messageObject.lineIdLong == "failed") {
                console.log("lineInfo.qml: worker lineSaveFailed")
                if (linesToSave > 0) { linesToSave-- }
            } else if (messageObject.lineIdLong == "stopsToSave") {
                console.log("updatePage.qml: line worker sent stops amount to save: " + messageObject.value)
            } else if (messageObject.lineIdLong == "stop") {
                for (var aa=0; aa < stops.count; ++aa) { // removed saved stop from listModel
                    if (stops.get(aa).stopIdLong == messageObject.stopIdLong) {
                        if (stops.get(aa).favorite == "true") {
                            setFavoriteStop(stops.get(aa).stopIdLong)
                        }
                        stops.remove(aa);
                        stopsToSave--;
                        break;
                    }
                }
            } else if (messageObject.lineIdLong == "ERROR") {
                console.log("updatePage.qml: worker got error");
                showError("Server returned ERROR")
            } else if (messageObject.lineIdLong == "FINISH") {
                console.log("updatePage.qml: worker sent FINISH message")
            } else if (messageObject.lineState == "saved") {  // line saved
                linesToSave--;
                console.log("updatePage.qml: worker saved the line:" + messageObject.lineIdLong + ";lines left: " + linesToSave);
                if (linesToSave) {
                    if (lines.get(linesToSave).favorite=="true") { // set saved line favorite if needed
                        setFavoriteLine(messageObject.lineIdLong)
                    }
                    lineSearchWorker.sendMessage({"searchString": lines.get(linesToSave-1).lineIdLong, "save":"true"});
                } else {
                    console.log("debug: lines in stack: " + lines.count)
                    if (lines.get(0).favorite == "true") {
                        console.log("setting favorite");
                        setFavoriteLine(messageObject.lineIdLong);
                    }
                    console.log("updatePage.qml: finished updating lines, checking if any stops are left to update")
                    lines.clear()
                    if (stopsToSave) {
                        console.log("updatePage.qml: stops to save: " + stopsToSave)
                        stopsWorker.sendMessage({"searchString":stops.get(stopsToSave-1).stopIdLong})
                    } else {
                        console.log("updatePage.qml: none, enabling buttons")
                        okButton.visible = true
                    }
                }
            }
        }
    }

    WorkerScript {  // update process worker
        id: updateWorker
        source: "updateWorker.js"

        onMessage: {
            if (messageObject.message == "line") {
                lines.append({"lineIdLong":messageObject.lineIdLong, "favorite":messageObject.favorite})
            } else if (messageObject.message == "stop") {
                stops.append({"stopIdLong":messageObject.stopIdLong, "favorite":messageObject.favorite})
            } else if (messageObject.message == "nickName") {
                nickNames.append({"stopIdLong":messageObject.stopIdLong, "nickName":messageObject.nickName})
            } else if (messageObject.message == "finish") {
                // print everything we got
                console.log("UpdatePage.qml: lines received: " + lines.count)
                console.log("UpdatePage.qml: stops received: " + stops.count)
                console.log("UpdatePage.qml: nickNames received: " + nickNames.count)
                linesToSave = lines.count
                stopsToSave = stops.count
                if (linesToSave > 0) {
                    lineSearchWorker.sendMessage({"searchString": lines.get(linesToSave-1).lineIdLong, "save":"true"});
                } else if (stopsToSave) { // if no lines to update - check if there are any stops
                    console.log("updatePage.qml: stops to save: " + stopsToSave)
                    stopsWorker.sendMessage({"searchString":stops.get(stopsToSave-1).stopIdLong})
                }
            } else {
                // TODO error management
            }
        }
    }

    WorkerScript {  // stop save worker - for manually searched stops, which won't be saved via line save worker
        id: stopsWorker
        source: "stopSearch.js"
        onMessage: {
            console.log("updatePage.qml: stopsWorker reply:" +
                        messageObject.stopIdLong + "; state: " + messageObject.stopState)
            if (messageObject.stopState == "SERVER_ERROR") {
                // TODO error handling
            } else if (messageObject.stopIdLong == "FINISHED" ) { // response for save request
                stopsToSave--;
                if (stops.get(stopsToSave).favorite == "true") {
                    setFavoriteStop(stops.get(stopsToSave).stopIdLong)
                }
                console.log("updatePage.qml: stopSearch saved stop " + messageObject.stopIdLong + "; left " + stopsToSave)
                if (stopsToSave) {
                    stopsWorker.sendMessage({"searchString":stops.get(stopsToSave-1).stopIdLong})
                } else {
                    stops.clear()
                    console.log("updatePage.qml: all stops updated, enabling buttons")
                    okButton.visible = true
                }
            }
        }
    }

    Rectangle{      // dark background
        color: "#000000"
        anchors.fill: parent
    }
    Column {
        id: topColumn
        anchors.top: parent.top
        width: parent.width
        anchors.topMargin: 20
        spacing: 15
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "UPDATE IS NEEDED"
            font.pixelSize: 40
            style: LabelStyle {inverted: true}
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Database can be outdated: schedules or route paths of the traffic lines could be changed"
            horizontalAlignment: Text.AlignJustify
            wrapMode: Text.WordWrap
            font.pixelSize: 40
            style: LabelStyle {inverted: true}
        }
        Button {
            id: updateButton
            anchors.horizontalCenter: parent.horizontalCenter
            style: ButtonStyle {inverted: true}
            text: "Update"
            onClicked: {
                update();
                nextTimeButton.enabled = false
                enabled = false
//                pageStack.pop()
            }
        }
        Button {
            id: nextTimeButton
            anchors.horizontalCenter: parent.horizontalCenter
            style: ButtonStyle {inverted: true}
            text: "Next time"
            onClicked: {
                pageStack.pop()
                appWindow.pushMainPage();
            }
        }
    }

    Column {
        anchors.top: topColumn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: 20
        id: updateStatus
        visible: false
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Label {
                text: "lines to update"
                style: LabelStyle {inverted: true}
            }
            Label {
                text: linesToSave
                style: LabelStyle {inverted: true}
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Label {
                text: "stops to update"
                style: LabelStyle {inverted: true}
            }
            Label {
                text: stopsToSave
                style: LabelStyle {inverted: true}
            }
        }
    }
    Button {
        id: okButton
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: updateStatus.bottom
        anchors.topMargin: 15
        style: ButtonStyle { inverted: true }
        text: "OK"
        onClicked: {
            pageStack.pop()
            appWindow.pushMainPage();
        }
    }

    function update() {
        console.log("UpdatePage.qml: updating DB")
        updateWorker.sendMessage({"1":"0"});
        updateStatus.visible = true
//        Updater.getTimestamps();
    }
    function setFavoriteLine(lineIdLong_) {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {  // TODO
                try { var rs = tx.executeSql("UPDATE Lines SET favorite=\"true\" WHERE lineIdLong=?",[lineIdLong_]); }
                catch(e) { console.log("lineInfo: setFavorite EXCEPTION: " + e) }
            }
        )
    }
    function setFavoriteStop(stopIdLong_) {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {  // TODO
                try { var rs = tx.executeSql("UPDATE Stops SET favorite=\"true\" WHERE stopIdLong=?",[stopIdLong_]); }
                catch(e) { console.log("stopInfo: setFavorite EXCEPTION: " + e) }
            }
        )
    }
}
