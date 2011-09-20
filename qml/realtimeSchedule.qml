import QtQuick 1.1
import com.meego 1.0
import "lineInfo.js" as JS
import com.nokia.extras 1.0

Page {
    id: stopInfoPage
    tools: commonTools
    Item {
        id: config
        property string bgColor: ""
        property string textColor: ""
        property string highlightColor: ""
        property string bgImage: ""
        property string highlightColorBg: ""
        property int networking: 5  // default
    }
    objectName: "stopInfoPage"
    property string stopId: ""
    property string linesCount: "10"
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: { JS.loadConfig(config); fillModel(); }

    InfoBanner {
        id: errorBanner
        text: "Error description here"
        timerShowTime: 5000
        z: 10
    }
    Timer {
        id: refreshTimer
        repeat: true
        onTriggered: {
            scheduleModel.clear()
            getSchedule()
        }
    }
    Rectangle {     // dark background
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        Image { source: config.bgImage ; fillMode: Image.Center; anchors.fill: parent; }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                focus: true
            }
        }
    }

    Item {          // back to recent
        id: backToRecent
        visible: false
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        height: 60
        width: 60
        Rectangle {
            anchors.fill: parent
            radius: 15
            color: config.highlightColorBg
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "<"
            color: config.textColor
            font.pixelSize: 50
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                recentList.visible = true
                list.visible = false
                backToRecent.visible = false
                refresh.visible = false
                refreshTimer.stop()
                stopNameLabel.visible = false
                searchButton.visible = true
            }
        }
    }
    Label {         // stop Name label
        id: stopNameLabel
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        text: "StopName"
        font.pixelSize: 35
        color: config.textColor
    }
    Button{         // search stop button
        id: searchButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        text: qsTr("Search")
        width: 200
        onClicked: {
            pageStack.push(Qt.resolvedUrl("stopInfo.qml"))
        }
    }
    Item {          // refresh time
        id: refresh
        visible: false
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: 60
        width: 60
        Rectangle {
            anchors.fill: parent
            radius: 15
            color: config.highlightColorBg
        }
        Text {
            id: refreshText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "0"
            color: config.textColor
            font.pixelSize: 40
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                refreshDialog.open()
            }
        }
    }

    SelectionDialog {  // refreshDialog
         id: refreshDialog
         titleText: "Refresh timeout"
         selectedIndex: 0
         model: refreshModel
         onSelectedIndexChanged: {
             if (selectedIndex != 0) {
                 refreshTimer.interval = 1000 * refreshModel.get(selectedIndex).name
                 refreshTimer.start()
                 refreshText.text = refreshModel.get(selectedIndex).name
             } else {
                 refreshTimer.stop()
                 refreshText.text = "0"
             }
         }
    }

    ListModel {     // refresh model
        id: refreshModel
        ListElement { name: "0" }
        ListElement { name: "10" }
        ListElement { name: "30" }
        ListElement { name: "60" }
    }
    ListModel {     // stopSchedule
        id: scheduleModel
        ListElement {
            depTime: ""
            depLine: ""
            depDest: ""
        }
    }
    Component {     // stopSchedule delegate
        id: scheduleDelegate
        Item {
            width: recentList.width
            height: 40
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                spacing: 20
                Text{
                    text: depTime
                    font.pixelSize: 35
                    color: config.textColor
                    width: 85
                }
                Text{
                    text: depLine
                    font.pixelSize: 35
                    color: config.textColor
                    width: 100
                }
                Text{
                    text: depDest
                    font.pixelSize: 35
                    color: config.textColor
                }
            }
        }
    }
    Component {     // schedule Header
        id: scheduleHeader
        Item {
            width: recentList.width
            height: 40
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                spacing: 20
                Text{  // time
                    text: "Time"
                    font.pixelSize: 35
                    color: config.textColor
                    width: 85
                }
                Text{  // line
                    text: "Line"
                    font.pixelSize: 35
                    color: config.textColor
                    width: 100
                }
                Text{  // destination
                    text: "Destination"
                    font.pixelSize: 35
                    color: config.textColor
                }
            }
        }
    }
    ListModel {     // recent stops list
        id: recentModel
        ListElement {
            stopIdLong: ""
            stopIdShort: ""
            stopName: ""
            stopAddress: ""
            stopCity: ""
            stopLongitude: ""
            stopLatitude: ""
        }
    }
    Component {     // recent stops delegate
        id: recentDelegate
        Rectangle {
            width: recentList.width
            height: 70
            radius: 20
            color: config.bgColor
            opacity: 0.8
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
                        color: config.textColor
                        width: 340
                    }
                    Text{
                        text: stopIdShort
                        font.pixelSize: 35
                        color: config.textColor
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
                        color: config.textColor
                        width: 340
                    }
                    Text{
                        text: stopCity
                        font.pixelSize: 20
                        color: config.textColor
                    }
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    stopId = stopIdLong
                    getSchedule()
                    recentList.visible = false
                    list.visible = true
                    backToRecent.visible = true
                    refresh.visible = true
                    stopNameLabel.visible = true
                    stopNameLabel.text = recentModel.get(index).stopName
                    searchButton.visible = false
                    if (refreshText.text != "0") refreshTimer.start()
                }
                onPressedChanged: {
                    if (pressed == true) {
                        parent.color = config.highlightColorBg
                    } else {
                        parent.color = config.bgColor
                    }
                }
            }
        }
    }

    Item {     // grid rect
        id: infoRect
        anchors.top: searchButton.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        ListView {  // stop info list
            id: list
            visible: false
            anchors.fill: parent
            anchors.topMargin: 10
            delegate:  scheduleDelegate
            model: scheduleModel
            header: scheduleHeader
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
            currentIndex: 0
            clip: true
        }
        ListView {  // recentList
            id: recentList
            visible: true
            spacing: 10
            anchors.fill: parent
            anchors.topMargin: 10
            delegate:  recentDelegate
            model: recentModel
            currentIndex: 0
            clip: true
        }
    }


//---------------------------------------------------------------------------//
    function showError(errorText) {  // show popup splash window with error
        errorBanner.text = errorText
        errorBanner.show()
    }
    function getSchedule() {
        var scheduleHtmlReply = new XMLHttpRequest()
        scheduleHtmlReply.onreadystatechange = function() {
            if (scheduleHtmlReply.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.DONE) {
                    parseHttp(scheduleHtmlReply.responseText)
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.ERROR) {

            }
        }
        scheduleHtmlReply.open("GET","http://www.omatlahdot.fi/omatlahdot/web?command=embedded&action=view&c=" + linesCount + "&o=1&s="+stopId)
        scheduleHtmlReply.send()
    }
    function parseHttp(text_) {
        var text = new String;
        var lines = new Array;
        var times = new Array;
        var td = new Array;
        scheduleModel.clear()
        text = text_;
        lines = text.split("\n");
        for (var ii=0; ii < lines.length; ++ii) {
            if (lines[ii].search("id=\"departures\"") != -1) {
                times = lines[ii].split("<tr class='")
            }
        }
        for (var ii=1; ii<times.length; ++ii) {
            td = times[ii].split("<td class='");
            scheduleModel.append({"depTime":td[1].slice(td[1].search(">")+1,td[1].search("</td>")),
                                  "depLine":td[2].slice(td[2].search(">")+1,td[2].search("</td>")),
                                  "depDest":td[3].slice(td[3].search(">")+1,td[3].search("</td>"))})
        }
    }
    function fillModel() {      // checkout recent stops from database
             JS.__db().transaction(
                 function(tx) {
                     var rs = tx.executeSql("SELECT * FROM Stops ORDER BY stopName ASC");
                     recentModel.clear();
                     if (rs.rows.length > 0) {
                         for (var i=0; i<rs.rows.length; ++i) {
                                 recentModel.append(rs.rows.item(i))
                         }
                     }
                 }
             )
         }

}

// http://www.omatlahdot.fi/omatlahdot/web?command=embedded&action=view&c=20&o=1&s=1201229
