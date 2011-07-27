import QtQuick 1.1
import com.meego 1.0

Page {

    id: stopInfoPage
    tools: commonTools

    Label {
        id: busStopLabel
        anchors.centerIn: parent
        text: qsTr("Stop Info")
        visible: false
    }

    TextInput{
        id: stopId
        width: 140
        maximumLength: 16
        color: "#000000"
        onFocusChanged: {
            focus == true ? openSoftwareInputPanel() : closeSoftwareInputPanel()
        }
        selectionColor: "green"
        font.pixelSize: 32
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: "Stop ID"
    }

    Button{
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 20
        text: qsTr("Show info")
        onClicked: {
            getInfo()
            busStopLabel.text=qsTr(stopId.text + " stop info here")
            busStopLabel.visible=true
            focus = true
        }
    }

    Label {
        id: stopName;
        anchors.left: parent.left;
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 80
        text: qsTr("Name")
        font.pixelSize: 25
    }
    Label {
        id: stopAddress;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: parent.top
        anchors.topMargin: 80
        text: qsTr("Address")
        font.pixelSize: 25
    }
    Label {
        id: stopCity;
        anchors.right: parent.right;
        anchors.top: parent.top
        anchors.rightMargin: 20
        anchors.topMargin: 80
        text: qsTr("City")
        font.pixelSize: 25
    }

    ListModel{
        id:trafficList
        ListElement { time: "Time"; line: "Line"; }
    }

    Component{
        id:trafficDelegate

        Item{
            width: 100; height:60;
            Text{
                id:departureTime;
                anchors.left:parent.left;
                text: time;
            }
            Text{
                anchors.left:departureTime.right;
                text: line;
            }
        }
    }

    GridView {
        id: grid
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
        cellWidth: 100; cellHeight: 60
        delegate: trafficDelegate
        focus: true

//        model: ContactModel {}
//        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
    }

/*<----------------------------------------------------------------------->*/
    function showRequestInfo(text) {
        console.log(text)
    }

    function parseResponse(a){
        var schedText = new String;
        schedText = a;
        var schedule = new Array;
        var lines = new Array;
        var time_ = Array
        schedule = schedText.split("\n");
        lines = schedule[0].split("|");
        stopName.text = lines[1];
        stopAddress.text = lines[2];
        stopCity.text = lines[3];
        console.log("Stop name: " + lines[1] + "; Address: " + lines[2] + "; City: " + lines[3]);
        for (var ii = 1; ii < schedule.length-1; ii++) {
            lines = schedule[ii].split("|");
            time_[0] = lines[0].slice(0,2)
            time_[1] = lines[0].slice(2,4)
//            showRequestInfo(time_[0] + ":" + time_[1] + " -> " + lines[1]);
            trafficList.append({"time": "" + time_[0] + ":" + time_[1], "line":""+lines[1]})
        }
    }

    function getInfo() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
/*            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));
            } else*/ if (doc.readyState == XMLHttpRequest.DONE) {
                parseResponse(doc.responseText);
/*                showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));*/
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showRequestInfo("ERROR")
            }
        }

// API 1.0 (plaintext) : faster, more informative
    doc.open("GET", "http://api.reittiopas.fi/public-ytv/fi/api/?stop="+ stopId.text +"&user=byako&pass=gfccdjhl");
// API 2.0 (XML) : slower
//             http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&query="+stopId.text); // for line info request
//             http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");

    doc.send();

    }
/*<----------------------------------------------------------------------->*/

}
