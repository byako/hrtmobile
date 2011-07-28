import QtQuick 1.1
import com.meego 1.0

Page {
    id: lineInfoPage
    tools: commonTools

    Label {
        id: busStopLabel
        anchors.centerIn: parent
        text: qsTr("Line Info here")
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
        text: "Line ID"
    }
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
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&query="+stopId.text); // for line info request
//             http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");
    console.log("url: " + doc.url);
    doc.send();

    }
/*<----------------------------------------------------------------------->*/

    Button{
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 20
        text: qsTr("Show info")
        onClicked: {
            getXML()
            busStopLabel.text=qsTr(stopId.text + " line info here")
            busStopLabel.visible=true
            focus = true
        }
    }
}
