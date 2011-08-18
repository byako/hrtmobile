import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
import "lineInfo.js" as JS

Page {
    id: lineInfoPage
    tools: commonTools
    HrtmConfig{ id:config }
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
            onClicked: {
                config.loadConfig()
                buttonClicked()
            }
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

    Rectangle{      // labels
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
        color: "#000000"
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

    Rectangle {  // tabs rect
        id: tabRect
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.right: parent.right
        width: (parent.width-80)
        height: 45
        color: "#000000"
        Row {
            anchors.right: parent.right
            width: parent.width
            height: parent.height
            Button {
                width: parent.width/3
                Rectangle {
                    id: linesTab
                    anchors.fill: parent
                    color: "#505050"
                    radius: 5
                }
                Text {
                    id: linesTabText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Lines"
                    color: "#FFFFFF"
                    font.pixelSize: 25
                }
                onClicked: {
                    if (list.visible == false) {
                        list.visible = true
                        grid.visible = false
                        schedule.visible = false
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        linesTab.color = "#909090"
                    } else {
                        linesTab.color = list.visible ? "#205080" : "#505050"
                    }
                }
            }
            Button {
                width: parent.width/3
                Rectangle {
                    id: stopsTab
                    anchors.fill: parent
                    color: "#505050"
                    radius: 5
                }
                Text {
                    id: stopsTabText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Info"
                    color: "#FFFFFF"
                    font.pixelSize: 25
                }
                onClicked: {
                    if (grid.visible == false) {
                        list.visible = false
                        grid.visible = true
                        schedule.visible = false
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        stopsTab.color = "#909090"
                    } else {
                        stopsTab.color = grid.visible ? "#205080" : "#505050"
                    }
                }

            }
            Button {
                width: parent.width/3
                Rectangle {
                    id: scheduleTab
                    anchors.fill: parent
                    color: "#505050"
                    radius: 5
                }
                Text {
                    id: scheduleTabText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Schedule"
                    color: "#FFFFFF"
                    font.pixelSize: 25
                }
                onClicked: {
                    if (schedule.visible == false) {
                        list.visible = false
                        grid.visible = false
                        schedule.visible = true
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        scheduleTab.color = "#909090"
                    } else {
                        scheduleTab.color = schedule.visible ? "#205080" : "#505050"
                    }
                }
            }
        }
    }

    ListModel{      // stops list model
        id:stopReachModel
        ListElement {
            stopIdLong: "Stop"
            reachTime: "Time"
        }
    }

    Component{  // stops reach delegate
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
                Text{ text: stopIdLong; font.pixelSize: 25; color: "#ffffff"}
                Text{ text: reachTime; font.pixelSize: 25; color: "#ffffff"}
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

    ListModel{  // lineInfo list model
        id:lineInfoModel

        ListElement{
            lineLongCode: "lineId"
            lineShortCode: "Name"
            direction: "Direction"
            typeCode: "0"
            type: "type"
        }
    }

    Component{  // lineInfo delegate
        id:lineInfoDelegate
        Rectangle {
            width: list.width;
            height: 70
            radius: 10
            color: "#000000"
            Column {
                spacing: 5
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Row {
                    height: 30
                    spacing: 20
                    Text{ text: type; font.pixelSize: 25; color: "#ffffff"}
                    Text{ text: lineShortCode; font.pixelSize: 25; color: "#ffffff"}
                }
                Row {
                    height: 30
                    Text{ text: direction; font.pixelSize: 25; color: "#ffffff"}
                }
            }
            MouseArea {
                anchors.fill:  parent
                onPressedChanged: {
                    if (pressed == true) {
                        parent.color = "#205080"
                    } else {
                        parent.color = "#000000"
                    }
                }
                onClicked: {
                    list.focus = true
                    list.currentIndex = index
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

    ListModel{      // schedule list model
        id:scheduleModel
        ListElement {
            stopIdLong: "Stop"
            reachTime: "Time"
        }
    }

    Component{  // schedule delegate
        id:scheduleDelegate
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
                Text{ text: stopIdLong; font.pixelSize: 25; color: "#ffffff"}
                Text{ text: reachTime; font.pixelSize: 25; color: "#ffffff"}
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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#205080"
        radius: 5
        ListView {
            id: list
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            anchors.rightMargin: 10
            delegate: lineInfoDelegate
            model: lineInfoModel
            spacing: 10
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false
            onVisibleChanged: {
                if (visible == true) {
                    linesTab.color = "#205080"
                    stopsTab.color = "#505050"
                    scheduleTab.color = "#505050"
                }
            }
        }
        GridView {
            id: grid
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            delegate: stopReachDelegate
            model: stopReachModel
            cellWidth: 230
            cellHeight: 30
            width: 420
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false;
            onVisibleChanged: {
                if (visible == true) {
                    stopsTab.color = "#205070"
                    linesTab.color = "#505050"
                    scheduleTab.color = "#505050"
                }
            }
        }
        GridView {
            id: schedule
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            delegate: scheduleDelegate
            model: scheduleModel
            cellWidth: 150
            cellHeight: 30
            width: 420
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false;
            onVisibleChanged: {
                if (visible == true) {
                    stopsTab.color = "#505050"
                    linesTab.color = "#505050"
                    scheduleTab.color = "#205080"
                }
            }
        }
        visible: false;
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
        infoRect.visible = true;
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

    function getSchedule(url) {
        var scheduleHtmlReply = new XMLHttpRequest();
        scheduleHtmlReply.onreadystatechanged = function() {
            if (scheduleHtmlReply.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.DONE) {
                if (scheduleHtmlReply.responseXML == null) {
                    errorLabel.visible = true
                    errorLabel.text = "No lines found"
                    list.visible=false
                    grid.visible=false
                    return
                } else {
                    showRequestInfo("OK, got " + scheduleHtmlReply.responseXML.documentElement.childNodes.length+ " lines")
                    parseXML(scheduleHtmlReply.responseXML.documentElement);
                    list.visible = true
                }
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.ERROR) {
                showRequestInfo("ERROR")
                errorLabel.visible = true
                errorLabel.text = "ERROR"
                list.visible=false
                grid.visible=false
            }
    }
        scheduleHtmlReply.open("GET",url);
        scheduleHtmlReply.send();
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
