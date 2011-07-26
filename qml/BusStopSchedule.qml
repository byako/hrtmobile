import QtQuick 1.1
import com.meego 1.0

Page {
    id: busStopSchedulePage
    tools: commonTools

    Label {
        id: busStopLabel
        anchors.centerIn: parent
        text: qsTr("Bus Stop Schedule")
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
/*<----------------------------------------------------------------------->*/
    function showRequestInfo(text) {
//        log.text = log.text + "\n" + text
        console.log(text)
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
                var a = doc.responseXML.documentElement;
                for (var ii = 0; ii < a.childNodes.length; ++ii) {
                    showRequestInfo(a.childNodes[ii].nodeName);
                }
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
        text: qsTr("Show Schedule")
        onClicked: {
            getXML()
            busStopLabel.text=qsTr(stopId.text + " Bus Stop Schedule")
            busStopLabel.visible=true
            focus = true
        }
    }
}
