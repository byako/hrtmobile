import QtQuick 1.1
import com.meego 1.0

Page {

    id: stopInfoPage
    tools: commonTools
    Label{
        id: errorLabel;
        text: qsTr("Error. Wrong stop ID ?");
        anchors.bottomMargin: 100;
        anchors.centerIn: parent;
        visible : false;
        font.pixelSize: 30
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
            errorLabel.visible = false;
            getInfo()
            focus = true
        }
    }

    Label {
        id: stopNameLabel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 80
        text: qsTr("Name")
        font.pixelSize: 30
    }
    Label {
        id: stopName;
        anchors.left: parent.left;
        anchors.top: stopNameLabel.top
        anchors.leftMargin: 20
        anchors.topMargin: 30
        text: qsTr("Name")
        font.pixelSize: 25
        visible: false
    }
    Label {
        id: stopAddressLabel;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: parent.top
        anchors.topMargin: 80
        text: qsTr("Address")
        font.pixelSize: 30
    }
    Label {
        id: stopAddress;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: stopAddressLabel.top
        anchors.topMargin: 30
        text: qsTr("Address")
        font.pixelSize: 25
        visible: false
    }
    Label {
        id: stopCityLabel;
        anchors.right: parent.right;
        anchors.top: parent.top
        anchors.rightMargin: 20
        anchors.topMargin: 80
        text: qsTr("City")
        font.pixelSize: 30
    }
    Label {
        id: stopCity;
        anchors.right: parent.right;
        anchors.top: stopCityLabel.top
        anchors.topMargin: 30
        anchors.rightMargin: 20
        text: qsTr("City")
        font.pixelSize: 25
        visible: false
    }
    ListModel{
        id:trafficModel

        ListElement {
            departTime: "Time"
            departLine: "Line"
        }
    }

    Component{
        id:trafficDelegate
        Row{
            spacing: 10
            Text{ text: departTime; font.pixelSize: 25 }
            Text{ text: departLine; font.pixelSize: 25 }
        }
    }

    ListView {
        id: grid
        anchors.fill:  parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 250
        delegate: trafficDelegate
        model: trafficModel
        focus: true

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
        showRequestInfo("length = "+schedText.length);
        showRequestInfo(schedText);
        if (schedText.slice(0,5) == "Error") {
            errorLabel.visible = true;
            return;
        }
        schedule = schedText.split("\n");
        lines = schedule[0].split("|");
        stopName.text = lines[1];
        stopName.visible = true;
        stopAddress.text = lines[2];
        stopAddress.visible = true;
        stopCity.text = lines[3];
        stopCity.visible = true;
        console.log("Stop name: " + lines[1] + "; Address: " + lines[2] + "; City: " + lines[3]);
        for (var ii = 1; ii < schedule.length-1; ii++) {
            lines = schedule[ii].split("|");
            time_[0] = lines[0].slice(0,2)
            time_[1] = lines[0].slice(2,4)
            trafficModel.append({ "departTime" : ""+time_[0]+":"+time_[1], "departLine" : "" + lines[1] })
        }
        grid.focus = true
    }

    function getInfo() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                parseResponse(doc.responseText);
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
