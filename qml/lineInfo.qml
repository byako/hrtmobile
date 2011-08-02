import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0

Page {
    id: lineInfoPage
    tools: commonTools
    HrtmConfig {id: config}
    objectName: "lineInfoPage"

    Rectangle{       // dark background
        color: config.bgColor
        anchors.fill: parent
        width: parent.width
        height:  parent.height
    }

    Label{     // error label
        Rectangle{
            color: "#606060"
            radius: 10
            anchors.fill: parent
            width: parent.width
            height:  parent.height
        }
        id: errorLabel;
        text: qsTr("Error. Wrong line ID ?")
        anchors.bottomMargin: 100
        anchors.centerIn: parent
        visible : false
        font.pixelSize: 30
        color: config.textColor
    } // error label end

    Item {          // search box
        width: 240
        height: 35
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        Rectangle{
            anchors.top: parent.top
            anchors.left: parent.left
            width: 240
            height: parent.height
            color: "#7090AA"
            radius: 15
            TextInput{
                id: lineId
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                width: parent.width
                height: parent.height
                maximumLength: 16
                onFocusChanged: {
                    focus == true ? openSoftwareInputPanel() : closeSoftwareInputPanel()
                    focus == true ? text = qsTr("") : null
                }
                font.pixelSize: 30
                color: config.textColor
                text: "Enter LineID"
            }
        }
       Button{
            anchors.right: parent.right
            anchors.top: parent.top
            text: qsTr("Show info")
            width: 200
            height: parent.height
            onClicked: {
                console.log("i got " + lineId.acceptableInput.toString())
                lineInfoModel.clear();
                errorLabel.visible = false;
                getXML()
                focus = true

                busStopLabel.text=qsTr(lineId.text + " line info here")
                busStopLabel.visible=true

            }
        }
    } // searchBox end

    Rectangle{      // data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  parent.top
        anchors.topMargin: 65
        anchors.right: parent.right
        height: 120
        width: parent.width
        color: "#303030"
        radius: 10
        Label {
            id: stopNameLabel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 5
            text: qsTr("Name")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopName;
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 10
            text: qsTr("Name")
            color: config.textColor
            font.pixelSize: 25
            visible: false
        }
        Label {
            id: stopAddressLabel
            anchors.top: stopNameLabel.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            text: qsTr("Address")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopAddress;
            anchors.top: stopName.bottom
            anchors.topMargin: 13
            anchors.right: parent.right
            text: qsTr("Address")
            color: config.textColor
            font.pixelSize: 25
            visible: false
        }
        Label {
            id: stopCityLabel;
            anchors.top: stopAddressLabel.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            text: qsTr("City")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopCity;
            anchors.right: parent.right;
            anchors.top: stopAddress.bottom
            anchors.topMargin: 13
            text: qsTr("City")
            color: config.textColor
            font.pixelSize: 25
            visible: false
        }
    } // data end

    ListModel{
        id:lineInfoModel

        ListElement {
            stopId: "Stop"
            reachTime: "Time"
        }
    }
    ListModel{
        id:responseModel

        ListElement{
            shortCode: "Name"
            direction: "Direction"
            type: "type"
            id: "id"
            ListElement {
                stopId: "Stop"
                reachTime: "Time"
            }
        }
    }

    Component{
        id:lineInfoDelegate
        Item {
            width: grid.cellWidth; height:  grid.cellHeight;
            Row {
                spacing: 10;
                anchors.fill: parent;
                Text{ text: lineId; font.pixelSize: 25; color: config.textColor}
                Text{ text: reachTime; font.pixelSize: 25; color: config.textColor}
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    grid.focus = true;
                    grid.currentIndex = index;
                }
            }
        }
    }

    Rectangle{    // grid rect
        id: infoRect
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#303030"
        GridView {
            id: grid
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            delegate: lineInfoDelegate
            model: lineInfoModel
            focus: true
            cellWidth: 200
            cellHeight: 30
            width: 420
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
        }
    } // grid rect end
/*<----------------------------------------------------------------------->*/
    function showRequestInfo(text) {
        console.log(text)
    }

    function parseXML(a){
        console.log("here starts XML parsing:");
        var stops;
        for (var ii = 0; ii < a.childNodes.length; ++ii) {
            showRequestInfo("we're in : "+ a.childNodes[ii].nodeName);
            showRequestInfo("line No:"+a.childNodes[ii].childNodes[1].firstChild.nodeValue);
            showRequestInfo("line Type: " + a.childNodes[ii].childNodes[2].firstChild.nodeValue);
            showRequestInfo("line Direction:"+a.childNodes[ii].childNodes[3].firstChild.nodeValue + " -> " + a.childNodes[ii].childNodes[4].firstChild.nodeValue);
            showRequestInfo("line Name:"+a.childNodes[ii].childNodes[5].firstChild.nodeValue);
            showRequestInfo("Transport Stops:");
            stops = a.childNodes[ii].childNodes[8];
            for (var aa = 0; aa < stops.childNodes.length; ++aa) {
                showRequestInfo(stops.childNodes[aa].childNodes[0].firstChild.nodeValue + " : " + stops.childNodes[aa].childNodes[1].firstChild.nodeValue);
            }
/*            for (var bb = 0; bb < a.childNodes[ii].childNodes.length; ++bb) {
                if (a.childNodes[ii].childNodes[bb].childNodes.length == 1)
                    showRequestInfo("    "+a.childNodes[ii].childNodes[bb].nodeName+" : "+a.childNodes[ii].childNodes[bb].firstChild.nodeValue);
                else {
                    for (var cc = 0; cc < a.childNodes[ii].childNodes[bb].childNodes.length; ++cc) {
                        showRequestInfo("        "+a.childNodes[ii].childNodes[bb].childNodes[cc].nodeName+" : "+a.childNodes[ii].childNodes[bb].childNodes[cc].firstChild.nodeValue);
                    }
                }
            }*/
        }
    }

    function getXML() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));
            } else if (doc.readyState == XMLHttpRequest.DONE) {
                parseXML(doc.responseXML.documentElement);
                showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showRequestInfo("ERROR")
            }
        }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&query="+lineId.text); // for line info request
//             http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");
    console.log("url: " + doc.url);
    doc.send();

    }
/*<----------------------------------------------------------------------->*/
}
