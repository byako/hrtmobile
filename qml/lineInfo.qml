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
        id: searchBox
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
                responseModel.clear();
                lineInfoModel.clear();
                errorLabel.visible = false;
                getXML()
                focus = true

                errorLabel.text=qsTr(lineId.text + " line info here")
                errorLabel.visible=true

            }
        }
    } // searchBox end

    Rectangle {
        id: hrLineSeparator
        anchors.left: parent.left
        anchors.top: searchBox.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }

    Rectangle{      // data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  searchBox.bottom
        anchors.topMargin: 10
        anchors.right: parent.right
        height: 120
        width: parent.width
        color: config.bgColor
        radius: 10
        Label {
            id: stopNameLabel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 5
            text: qsTr("Line")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopName;
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 10
            text: qsTr("Direction")
            color: config.textColor
            font.pixelSize: 25
            visible: false
        }
        Label {
            id: stopAddressLabel
            anchors.top: stopNameLabel.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            text: qsTr("Direction")
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
            visible: false
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
            stopIdLong: "Stop"
            reachTime: "Time"
        }
    }
    ListModel{
        id:responseModel

        ListElement{
            lineLongCode: "lineId"
            lineShortCode: "Name"
            direction: "Direction"
            typeCode: "0"
            type: "type"
/*            ListElement {
                stopIdLong: "Stop"
                reachTime: "Time"
            }*/
        }
    }

    Component{
        id:lineInfoDelegate
        Rectangle {
            width: list.width;
            height: 70;
            radius: 5
            color: "#7090AA"
            Column {
                spacing: 5
                anchors.fill: parent
                Row {
                    height: 30
                    spacing: 20
                    Text{ text: type; font.pixelSize: 25; color: config.textColor}
                    Text{ text: lineShortCode; font.pixelSize: 25; color: config.textColor}
                }
                Row {
                    height: 30
                    Text{ text: direction; font.pixelSize: 25; color: config.textColor}
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    list.focus = true;
                    list.currentIndex = index;
                    console.log("picked: line " + responseModel.get(list.currentIndex).lineLongCode)
//                    console.log("picked: line " + list.currentIndex)
                }
            }
        }
    }

    Rectangle {
        id: hrLineSeparator2
        anchors.left: parent.left
        anchors.top: dataRect.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }

    Rectangle{    // grid rect
        id: infoRect
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: config.bgColor
        GridView {
            id: grid
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            delegate: lineInfoDelegate
            model: responseModel
            focus: true
            cellWidth: 200
            cellHeight: 30
            width: 420
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false;
        }
        ListView {
            id: list
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            anchors.rightMargin: 10
            delegate: lineInfoDelegate
            model: responseModel
            spacing: 10
            focus: true
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: true;
        }
    } // grid rect end
/*<----------------------------------------------------------------------->*/
    function showRequestInfo(text) {
        console.log(text)
    }

    function parseXML(a){
        console.log("here starts XML parsing:");
        var stops;
        var lineType;
        for (var ii = 0; ii < a.childNodes.length; ++ii) {
            showRequestInfo("we're in : "+ a.childNodes[ii].nodeName);
            showRequestInfo("line No:"+a.childNodes[ii].childNodes[1].firstChild.nodeValue);
            showRequestInfo("line Type: " + a.childNodes[ii].childNodes[2].firstChild.nodeValue);
            showRequestInfo("line Direction:"+a.childNodes[ii].childNodes[3].firstChild.nodeValue + " -> " + a.childNodes[ii].childNodes[4].firstChild.nodeValue);
            showRequestInfo("line Name:"+a.childNodes[ii].childNodes[5].firstChild.nodeValue);
            switch(a.childNodes[ii].childNodes[2].firstChild.nodeValue) {
                case "1": { lineType = "Helsinki bus"; break; }
                case "2": { lineType = "Tram"; break; }
                case "3": { lineType = "Espoo bus"; break; }
                case "4": { lineType = "Vantaa bus"; break; }
                case "5": { lineType = "Regional bus"; break; }
                case "6": { lineType = "Metro"; break; }
                case "7": { lineType = "Ferry"; break; }
                case "8": { lineType = "U-line"; break; }
                default: { lineType = "unknown"; break; }
            }
            responseModel.append({"lineLongCode" : "" + a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                 "lineShortCode" : ""+a.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                 "direction" : "" + a.childNodes[ii].childNodes[3].firstChild.nodeValue + " -> " + a.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                 "type" : ""+lineType,
                                 "typeCode" : "" + a.childNodes[ii].childNodes[2].firstChild.nodeValue
                                 });
            showRequestInfo("Transport Stops:");
            stops = a.childNodes[ii].childNodes[8];

            for (var aa = 0; aa < stops.childNodes.length; ++aa) {
//                ex = lineInfoModel.get(ii)
//                ex.append({"stopIdLong" : ""+stops.childNodes[aa].childNodes[0].firstChild.nodeValue, "reachTime" : ""+stops.childNodes[aa].childNodes[1].firstChild.nodeValue});
                showRequestInfo(stops.childNodes[aa].childNodes[0].firstChild.nodeValue + " : " + stops.childNodes[aa].childNodes[1].firstChild.nodeValue);
            }
        }
    }

    function getXML() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (doc.readyState == XMLHttpRequest.DONE) {
                parseXML(doc.responseXML.documentElement);
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showRequestInfo("ERROR")
                list.visible=false
                grid.visible=false
                errorLabel.visible = true
            }
        }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&query="+lineId.text); // for line info request
//             http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");
    console.log("url: " + doc.url);
    doc.send();

    }
/*<----------------------------------------------------------------------->*/
}
