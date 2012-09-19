import QtQuick 1.0
import "database.js" as JS
import com.nokia.meego 1.0

Item {
//    objectName: "favoritesPage"
    id: favoritesPage
    signal finishedLoad()
    signal loadStop(string stopIdLong)
    signal loadLine(string lineIdLong)
    width: 480
    height: 745
//    Component.onCompleted: {  }
    // -================================ STOPS ==================================-
    ListModel {              // recent stops list
        id: recentModel
    }
    Component {              // recent stops delegate
        id: recentDelegate
        Item {
            width: stopsView.width
            height: 70
            Column {
                height: parent.height
                width: parent.width
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 20
                    Text{
                        text: (NickName == "" ? stopName : NickName)
                        font.pixelSize: 35
                        color: "#cdd9ff"
                        width: 340
                    }
                    Text{
                        text: stopIdShort
                        font.pixelSize: 35
                        color: "#cdd9ff"
                    }
                }
                Row {
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.left: parent.left
                    spacing: 20
                    Text{
                        text: stopAddress
                        font.pixelSize: 20
                        color: "#cdd9ff"
                        width: 340
                    }
                    Text{
                        text: stopCity
                        font.pixelSize: 20
                        color: "#cdd9ff"
                    }
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    stopsView.currentIndex = index
                    favoritesPage.loadStop(stopIdLong)
                    stopsView.currentIndex = -1
                }
            }
        }
    }

    // -================================ LINES ==================================-

    ListModel {     // lineInfo list model
        id:lineInfoModel
    }
    Component {     // lineInfo delegate
        id:lineInfoDelegate
        Item {
            width: linesView.width;
            height: 70
            Column {
                height: parent.height
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: lineTypeName + " " + lineIdShort
                    font.pixelSize: 35
                    color: "#cdd9ff"
                }
                Text{
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: lineStart + " -> " + lineEnd;
                    font.pixelSize: 25;
                    color: "#cdd9ff"
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    linesView.currentIndex = index
                    favoritesPage.loadLine(lineIdLong)
                    linesView.currentIndex = -1
                }
            }
        }
    }

    //-==========================================================================-
    Rectangle {                   // stops view rect
        id: stopInfoRect
        anchors.top: parent.top
        width: parent.width
        height: 370
        color: "#000000"
        Label {
            id: stopsLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: "Favorite stops"
            color: "#cdd9ff"
            height: 20
        }
        ListView {  // stopsView
            id: stopsView
            spacing: 10
            anchors.top: stopsLabel.bottom
            anchors.topMargin: 10
            height: 340
            width: parent.width
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:"#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
    }
    Rectangle {                   // lines view rect
        id: lineInfoRect
        anchors.top : stopInfoRect.bottom
        width: parent.width
        height: 375
        color: "#000000"
        Label {
            id: linesLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: "Favorite lines"
            color: "#cdd9ff"
            height: 20
        }
        ListView {  // linesView
            id: linesView
            anchors.top: linesLabel.bottom
            anchors.topMargin: 10
            height: 345
            spacing: 10
            width: parent.width
            delegate: lineInfoDelegate
            model: lineInfoModel
            highlight: Rectangle { color: "#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
    }
    //-===========================================================================-
    function _init() {
        loadLines();
        loadStops();
        favoritesPage.finishedLoad()
    }
    function loadLines() {
        JS.__db().transaction(
            function(tx) {
                        try { var rs = tx.executeSql("SELECT lineIdLong, lineIdShort, lineStart, lineEnd," +
                                                     " Lines.lineType, LineTypes.lineTypeName FROM Lines OUTER LEFT JOIN LineTypes" +
                                                     " on Lines.lineType=LineTypes.lineType WHERE favorite=\"true\"" +
                                                     "ORDER BY lineIdShort ASC"); }
                catch (e) { console.log ("favorites: loadLines exception: " + e) }
                if (rs.rows.length > 0) {
                    lineInfoModel.clear()
                } else {
                    lineInfoModel.clear()
                    lineInfoModel.append({"lineTypeName": "No favorite lines yet",
                                             "lineIdLong":"",
                                             "lineStart": "Try Line page",
                                             "lineEnd": "Search tool button",
                                             "lineIdShort":""});
                }

                for (var ii=0; ii<rs.rows.length; ++ii) {
                    lineInfoModel.append(rs.rows.item(ii))
                }
            }
        )
    }
    function loadStops() {
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql("SELECT Stops.stopIdLong, stopIdShort, stopName, stopAddress, stopCity, NickName FROM Stops LEFT OUTER JOIN StopNickNames ON Stops.stopIdLong=StopNickNames.stopIdLong WHERE favorite=\"true\" ORDER BY stopName ASC"); }
                catch (e) { console.log ("favorites: loadStops exception: " + e) }
                if (rs.rows.length > 0) {
                    recentModel.clear();
                } else {
                    recentModel.clear();
                    recentModel.append({"stopName":"No favorite stops yet",
                                           "stopIdLong":"",
                                           "NickName":"",
                                           "stopCity":"",
                                           "stopIdShort":"",
                                          "stopAddress": "Try Stop page -> search tool button"});
                }

                for (var ii=0; ii<rs.rows.length; ++ii) {
                    recentModel.append(rs.rows.item(ii))
                }
            }
        )
    }
}
