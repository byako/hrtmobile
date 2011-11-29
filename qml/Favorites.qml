import QtQuick 1.0
import "database.js" as JS
import com.nokia.meego 1.0

Item {
//    objectName: "favoritesPage"
//    id: favoritesPageItem
    width: 480
    height: 745
    Component.onCompleted: { loadLines(); loadStops(); }
    // -================================ STOPS ==================================-
    ListModel {              // recent stops list
        id: recentModel
        ListElement{
            stopName: "No favorite stops yet"
            stopIdShort: ""
            stopAddress: "Try Stop page -> search tool button"
            stopCity: ""
        }
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
                        text: stopName
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
                    // TODO
                }
            }
        }
    }

    // -================================ LINES ==================================-

    ListModel {     // lineInfo list model
        id:lineInfoModel
        ListElement {
            lineTypeName: "No favorite lines yet"
            lineStart: "Try Line page"
            lineEnd: "Search tool button"
        }
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
                    text: lineTypeName
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
                }
            }
        }
    }

    //-==========================================================================-
    Rectangle {                   // scheduleView rect
        id: stopInfoRect
        anchors.top: parent.top
        width: parent.width
        height: 370
        color: "#002050"
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
            height: 350
            width: parent.width
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:"#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
    }
    Rectangle {
        id: lineInfoRect
        anchors.top : stopInfoRect.bottom
        width: parent.width
        height: 375
        color: "#005020"
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
            height: 355
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
    function loadLines() {
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql('SELECT lineIdLong, lineIdShort, lineName, lineStart, lineEnd, lineType, favorite FROM Lines WHERE favorite=?', ["true"]); }
                catch (e) { console.log ("favorites: loadLines exception: " + e) }
                if (rs.rows.length > 0) lineInfoModel.clear()
                for (var ii=0; ii<rs.rows.length; ++ii) {
                    lineInfoModel.append({"lineIdLong" : rs.rows.item(ii).lineIdLong, "lineIdShort" : rs.rows.item(ii).lineIdShort,
                                             "lineStart" : rs.rows.item(ii).lineStart, "lineEnd" : rs.rows.item(ii).lineEnd,
                                             "lineName" : rs.rows.item(ii).lineName, "lineType" : rs.rows.item(ii).lineType,
                                        "lineTypeName" : JS.getLineType(rs.rows.item(ii).lineType) + rs.rows.item(ii).lineIdShort,
                                             "favorite" : rs.rows.item(ii).favorite
                                         })
                }
            }
        )
    }
    function loadStops() {
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql('SELECT * FROM Stops WHERE favorite=?', ["true"]); }
                catch (e) { console.log ("favorites: loadStops exception: " + e) }
                if (rs.rows.length > 0) recentModel.clear()
                for (var ii=0; ii<rs.rows.length; ++ii) {
                    recentModel.append(rs.rows.item(ii))
                }
            }
        )
    }
}
