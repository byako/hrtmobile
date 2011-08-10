import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
import "lineInfo.js" as JS

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
        height: 40
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        Rectangle{
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.left: parent.left
            width: 240
            height: 35
            color: "#205080"
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
                onAccepted: buttonClicked()
                font.pixelSize: 30
                color: config.textColor
                text: "Enter LineID"
            }
        }
       Button{
            id: searchButton
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: qsTr("Show info")
            width: 200
            height: parent.height
            onClicked: buttonClicked()
        }
    } // searchBox end

    Rectangle {     // decorative horizontal line
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
        anchors.leftMargin: 10
        anchors.top:  searchBox.bottom
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        visible: false
        height: 90
        width: parent.width
        color: "#205080"
        radius: 10
        Label {
            id: lineType;
            anchors.left: parent.left;
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
            text: qsTr("Line type")
            color: config.textColor
            font.pixelSize: 25
        }
        Label {
            id: lineShortCodeName;
            anchors.left: lineType.right
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
            text: qsTr("line")
            color: config.textColor
            font.pixelSize: 25
        }
        Label {
            id: lineDirection;
            anchors.top: lineShortCodeName.bottom
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: qsTr("Direction")
            color: config.textColor
            font.pixelSize: 25
        }
    } // data end

    Rectangle {
        id: tabRect
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: parent.width
        height: 45
        color: "#000000"
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width-80
            height: parent.height
            Button {
                Rectangle {
                    id: linesRect
                    anchors.fill: parent
                    color: "#505050"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Lines"
                    color: "#FFFFFF"
                    font.pixelSize: 25
                }
                width: parent.width/2-20
                onClicked: {
                    if (grid.visible == true) {
                        grid.visible = false
                        linesRect.color = "#707070"
                        list.visible = true
                        gridRect.color = "#505050"
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        linesRect.color = "#909090"
                    } else {
                        linesRect.color = list.visible ? "#707070" : "#505050"
                    }
                }
            }
            Button {
                Rectangle {
                    id: gridRect
                    anchors.fill: parent
                    color: "#505050"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Info"
                    color: "#FFFFFF"
                    font.pixelSize: 25
                }
                width: parent.width/2-20
                onClicked: {
                    if (list.visible == true) {
                        grid.visible = true
                        gridRect.color = "#707070"
                        list.visible = false
                        linesRect.color = "#505050"
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        gridRect.color = "#909090"
                    } else {
                        gridRect.color = grid.visible ? "#707070" : "#505050"
                    }
                }

            }
        }
    }

    ListModel{      // stops
        id:stopReachModel
        ListElement {
            stopIdLong: "Stop"
            reachTime: "Time"
        }
    }

    Component{
        id:stopReachDelegate
        Rectangle {
            width: grid.cellWidth;
            height: grid.cellHeight;
            radius: 5
            color: "#000000"
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 30
                Text{ text: stopIdLong; font.pixelSize: 25; color: config.textColor}
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

    ListModel{
        id:lineInfoModel

        ListElement{
            lineLongCode: "lineId"
            lineShortCode: "Name"
            direction: "Direction"
            typeCode: "0"
            type: "type"
        }
    }

    Component{
        id:lineInfoDelegate
        Rectangle {
            width: list.width;
            height: 70
            radius: 10
            color: "#205080"
            Column {
                spacing: 5
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.leftMargin: 10
                anchors.rightMargin: 10
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
                onPressedChanged: {
                    if (pressed == true) {
                        parent.color = "#BBBBAA"
                    } else {
                        parent.color = "#205080"
                    }
                }
                onClicked: {
                    list.focus = true
                    list.currentIndex = index
//                    console.log("picked: line " + lineInfoModel.get(list.currentIndex).lineLongCode)
                    stopReachModel.clear()
                    getStops(list.currentIndex)
                    list.visible = false
                    grid.visible = true
                    dataRect.visible = true
                    lineShortCodeName.text = lineInfoModel.get(list.currentIndex).lineShortCode
                    lineDirection.text = lineInfoModel.get(list.currentIndex).direction
                    lineType.text = lineInfoModel.get(list.currentIndex).type
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
        anchors.top: tabRect.bottom
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
            delegate: stopReachDelegate
            model: stopReachModel
            focus: true
            cellWidth: 230
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
            model: lineInfoModel
            spacing: 10
            focus: true
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false
        }
    } // grid rect end
/*<----------------------------------------------------------------------->*/
    function showRequestInfo(text) {
        console.log(text)
    }

    function getStops(a){
        var stops;
        stops = JS.doc.responseXML.documentElement.childNodes[a].childNodes[8];
        for (var aa = 0; aa < stops.childNodes.length; ++aa) {
            stopReachModel.append({"stopIdLong" : stops.childNodes[aa].childNodes[0].firstChild.nodeValue,
                                  "reachTime" : stops.childNodes[aa].childNodes[1].firstChild.nodeValue });
        }
    }

    function parseXML(a){
        var lineType;
        for (var ii = 0; ii < a.childNodes.length; ++ii) {
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
            lineInfoModel.append({"lineLongCode" : "" + a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                 "lineShortCode" : ""+a.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                 "direction" : "" + a.childNodes[ii].childNodes[3].firstChild.nodeValue + " -> " + a.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                 "type" : ""+lineType,
                                 "typeCode" : "" + a.childNodes[ii].childNodes[2].firstChild.nodeValue
                                 });
        }
    }

    function getXML() {
        JS.doc.onreadystatechange = function() {
            if (JS.doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (JS.doc.readyState == XMLHttpRequest.DONE) {
                if (JS.doc.responseXML == null) {
                    errorLabel.visible = true
                    errorLabel.text = "No lines found"
                    list.visible=false
                    grid.visible=false
                    return
                } else {
                    showRequestInfo("OK, got " + JS.doc.responseXML.documentElement.childNodes.length+ " lines")
                    parseXML(JS.doc.responseXML.documentElement);
                    list.visible = true
                }
            } else if (JS.doc.readyState == XMLHttpRequest.ERROR) {
                showRequestInfo("ERROR")
                errorLabel.visible = true
                errorLabel.text = "ERROR"
                list.visible=false
                grid.visible=false
            }
        }
    JS.doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&query="+lineId.text); // for line info request
//             http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");
    JS.doc.send();
    }

    function buttonClicked() {
        stopReachModel.clear()
        lineInfoModel.clear()
        errorLabel.visible = false
        searchButton.focus = true
        getXML()
    }
/*<----------------------------------------------------------------------->*/
}
