import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
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
    }
    objectName: "stopInfoPage"
    property string stopId: ""
    property string linesCount: "20"
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: { JS.loadConfig(config); fillModel(); }

    InfoBanner {
        id: errorBanner
        text: "Error description here"
        timerShowTime: 5000
        z: 10
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

    Button{
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
/*
    ListModel {     // stopSchedule
        id: scheduleModel
        ListElement {
            time: ""
            line: ""
            dest: ""
        }
    }
    Component {     // recent stops delegate
        id: scheduleDelegate
        Item {
            width: recentList.width
            height: 70
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                spacing: 20
                Text{
                    text: time
                    font.pixelSize: 35
                    color: config.textColor
                }
                Text{
                    text: line
                    font.pixelSize: 35
                    color: config.textColor
                }
                Text{
                    text: dest
                    font.pixelSize: 35
                    color: config.textColor
                }
            }
        }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    recentList.focus = true
                    recentList.currentIndex = index
                    scheduleModel.clear()
                    updateSchedule()
                }
                onPressedChanged: {
                    if (pressed == true) {
                        parent.color = "#205080"
                    } else {
                        parent.color = "#333333"
                    }
                }
            }
    }
*/
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
            color: "#006610"
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
                        text: stopCity
                        font.pixelSize: 20
                        color: config.textColor
                    }
                    Text{
                        text: stopAddress
                        font.pixelSize: 20
                        color: config.textColor
                    }
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    recentList.focus = true
                    recentList.currentIndex = index
//                    scheduleModel.clear()
                    stopId = stopIdLong
                    getSchedule()
                }
                onPressedChanged: {
                    if (pressed == true) {
                        parent.color = "#205080"
                    } else {
                        parent.color = "#006610"
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
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
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
        var tables = new Array;
        var lines = new Array;
        var text = new String;
        var times = new Array;
        var one = new Array;
        var two = new Array;
        var three = new Array;
        var cur=0;
        text = text_;
        lines = text.split("\n");
        for (var ii=0; ii < lines.length; ++ii) {
            if (lines[ii].search("class=\"title\"") != -1 || lines[ii].search("id=\"departures\"") != -1) {
                console.log("line " + ii + " : " + lines[ii]);
            }
        }

/*        for (var ii=0; ii<tables.length; ++ii) {
            cur = tables[ii];
            while (lines[cur-1].search("</table>") == -1) {
                if (lines[cur].search("time") != -1) {
                    times = lines[cur].split("<");
                    one.push(times[1].slice(times[1].length-5));
                    two.push(times[2].slice(times[2].length-5));
                    if (times[3].slice(times[3].length-1) != ";") {
                        three.push(times[3].slice(times[3].length-5));
                    }
                }
                cur++;
            }
        }*/
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
