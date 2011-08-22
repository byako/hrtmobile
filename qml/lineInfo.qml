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

    Rectangle{      // data rect: info labels
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
        color: config.bgColor
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


    Rectangle {     // decorative horizontal line
        id: hrLineSeparator2
        anchors.left: parent.left
        anchors.top: dataRect.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }

    ButtonRow {  // tabs rect
        id: tabRect
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.right: parent.right
        width: (parent.width-10)
            Button {
                id: linesButton
                text: "Lines"
                onClicked: {
                    if (list.visible == false) {
                        list.visible = true
                        grid.visible = false
                        schedule.visible = false
                        scheduleButtons.visible = false
                    }
                }
            }
            Button {
                id: stopsButton
                text: "Info"
                onClicked: {
                    if (grid.visible == false) {
                        list.visible = false
                        grid.visible = true
                        schedule.visible = false
                        scheduleButtons.visible = false
                    }
                }
            }
            Button {
                id: scheduleButton
                text: "Schedule"
                onClicked: {
                    if (schedule.visible == false) {
                        list.visible = false
                        grid.visible = false
                        schedule.visible = true
                        if (JS.scheduleLoaded == 0) {
                            getSchedule(list.currentIndex)
                        }
                        scheduleButtons.visible = true
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
        Item {
            width: grid.cellWidth;
            height: grid.cellHeight;
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
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
            radius: 20
            color: "#333333"
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
                        parent.color = config.highlightColor
                    } else {
                        parent.color = "#333333"
                    }
                }
                onClicked: {
                    list.visible = false
                    grid.visible = true
                    dataRect.visible = true
                    if (list.currentIndex != index) {
                        list.currentIndex = index
                        JS.scheduleLoaded = 0
                        scheduleClear()
                        stopReachModel.clear()
                        getStops(list.currentIndex)
                        lineShortCodeName.text = lineInfoModel.get(list.currentIndex).lineShortCode
                        lineDirection.text = lineInfoModel.get(list.currentIndex).direction
                        lineType.text = lineInfoModel.get(list.currentIndex).type
                    }
                }
            }
        }
    }

    ListModel{      // schedule list model direction 1 Mon-Fri
        id:scheduleModelDir1MonFri
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{      // schedule list model direction 1 Sat
        id:scheduleModelDir1Sat
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{      // schedule list model direction 1 Sun
        id:scheduleModelDir1Sun
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{      // schedule list model direction 2 Mon-Fri
        id:scheduleModelDir2MonFri
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{      // schedule list model direction 2 Sat
        id:scheduleModelDir2Sat
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{      // schedule list model direction 2 Sun
        id:scheduleModelDir2Sun
        ListElement {
            departTime: "Time"
        }
    }

    Component{  // schedule delegate
        id:scheduleDelegate
        Item {
            width: schedule.cellWidth
            height: schedule.cellHeight
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Text{ text: departTime; font.pixelSize: 25; color: config.textColor}
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    schedule.focus = true
                    if (schedule.currentIndex != index) {
                        schedule.currentIndex = index
                    }
                }
            }
        }
    }

    Rectangle{    // grid rect
        id: infoRect
        anchors.top: tabRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: config.bgColor
        radius: 5
        ListView {  // list
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
                    tabRect.checkedButton = linesButton;
                }
            }
        }
        GridView {  // stops reach model show
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
                    tabRect.checkedButton = stopsButton;
                }
            }
        }

        ButtonRow {  // scheduleButtons week period choose
            id: scheduleButtons
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            visible: false
            height: 35
            Button {
                id: scheduleButton0
                text: "Mon-Fri"
                onClicked: {
                    JS.currentSchedule = 0
                    scheduleShow();
                }
            }
            Button {
                id: scheduleButton1
                text: "Sat"
                onClicked: {
                    JS.currentSchedule = 1
                    scheduleShow();
                }
            }
            Button {
                id: scheduleButton2
                text: "Sun"
                onClicked: {
                    JS.currentSchedule = 2
                    scheduleShow();
                }
            }
        }

        GridView {  // scheduleModel* show
            id: schedule
            anchors.left: parent.left
            anchors.leftMargin:10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 70
            anchors.bottom: parent.bottom
            delegate: scheduleDelegate
            model: scheduleModelDir1MonFri
            cellWidth: 115
            cellHeight: 30
            highlight: Rectangle { color: config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false;
            onVisibleChanged: {
                if (visible == true) {
                    tabRect.checkedButton = scheduleButton;
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

    function parseHttp(text_) {
        scheduleClear();
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
            if (lines[ii].search("line_dirtitle") != -1) {
                tables.push(ii);
                console.log("line " + ii + " : " + lines[ii]);
            }
        }
        text.slice
        for (var ii=0; ii<tables.length; ++ii) {
            cur = tables[ii];
            while (lines[cur-1].search("</table>") == -1) {
                if (lines[cur].search("time") != -1) {
                    times = lines[cur].split("<");
//                    console.log("time: " + times[1].slice(times[1].length-5));
                    one.push(times[1].slice(times[1].length-5));
//                    console.log("time: " + times[2].slice(times[2].length-5));
                    two.push(times[2].slice(times[2].length-5));
//                    console.log("time: " + times[3].slice(times[3].length-5));
                    if (times[3].slice(times[3].length-1) != ";") {
                        three.push(times[3].slice(times[3].length-5));
                    }
                }
                cur++;
            }
            switch (ii) {
            case 0: // Dir 1 MonFri
                while (one.length > 0) {
                    scheduleModelDir1MonFri.append({"departTime" : one.shift()});
                };
                while (two.length > 0) {
                    scheduleModelDir1MonFri.append({"departTime" : two.shift()});
                }
                while (three.length > 0) {
                    scheduleModelDir1MonFri.append({"departTime" : three.shift()});
                }
                break;
            case 1: // Dir 2 MonFri
                while (one.length > 0) {
                    scheduleModelDir2MonFri.append({"departTime" : one.shift()});
                };
                while (two.length > 0) {
                    scheduleModelDir2MonFri.append({"departTime" : two.shift()});
                }
                while (three.length > 0) {
                    scheduleModelDir2MonFri.append({"departTime" : three.shift()});
                }
                break;
            case 2: // Dir 2 MonFri
                while (one.length > 0) {
                    scheduleModelDir1Sat.append({"departTime" : one.shift()});
                };
                while (two.length > 0) {
                    scheduleModelDir1Sat.append({"departTime" : two.shift()});
                }
                while (three.length > 0) {
                    scheduleModelDir1Sat.append({"departTime" : three.shift()});
                }
                break;
            case 3: // Dir 2 MonFri
                while (one.length > 0) {
                    scheduleModelDir2Sat.append({"departTime" : one.shift()});
                };
                while (two.length > 0) {
                    scheduleModelDir2Sat.append({"departTime" : two.shift()});
                }
                while (three.length > 0) {
                    scheduleModelDir2Sat.append({"departTime" : three.shift()});
                }
                break;
            case 4: // Dir 2 MonFri
                while (one.length > 0) {
                    scheduleModelDir1Sun.append({"departTime" : one.shift()});
                };
                while (two.length > 0) {
                    scheduleModelDir1Sun.append({"departTime" : two.shift()});
                }
                while (three.length > 0) {
                    scheduleModelDir1Sun.append({"departTime" : three.shift()});
                }
                break;
            case 5: // Dir 2 MonFri
                while (one.length > 0) {
                    scheduleModelDir2Sun.append({"departTime" : one.shift()});
                };
                while (two.length > 0) {
                    scheduleModelDir2Sun.append({"departTime" : two.shift()});
                }
                while (three.length > 0) {
                    scheduleModelDir2Sun.append({"departTime" : three.shift()});
                }
                break;
            default:
                break;
            }
        }
        JS.scheduleLoaded = 1;
        JS.currentSchedule = 0;
    }

    function getSchedule(a) {
        var scheduleHtmlReply = new XMLHttpRequest()
        if (a==-1) {
            a=1
            if (list.count==0) {
                return;
            }
        }
        scheduleHtmlReply.onreadystatechange = function() {
            if (scheduleHtmlReply.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.DONE) {
                    parseHttp(scheduleHtmlReply.responseText)
                    schedule.visible = true
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.ERROR) {
                showRequestInfo("ERROR")
                errorLabel.visible = true
                errorLabel.text = "ERROR"
                list.visible=false
                grid.visible=false
                schedule.visible=false
            }
        }
        scheduleHtmlReply.open("GET",JS.doc.responseXML.documentElement.childNodes[a].childNodes[6].firstChild.nodeValue)
        scheduleHtmlReply.send()
    }

    function scheduleClear() {
        scheduleModelDir1MonFri.clear();
        scheduleModelDir1Sat.clear();
        scheduleModelDir1Sun.clear();
        scheduleModelDir2MonFri.clear();
        scheduleModelDir2Sat.clear();
        scheduleModelDir2Sun.clear();
    }

    function scheduleShow() {
        grid.visible = false;
        list.visible = false;
        switch(JS.currentSchedule) {
            case 0:
                schedule.model = scheduleModelDir1MonFri;
                schedule.visible = true;
                break;
            case 1:
                schedule.model = scheduleModelDir1Sat;
                schedule.visible = true;
                break;
            case 2:
                schedule.model = scheduleModelDir1Sun;
                schedule.visible = true;
                break;
            case 3:
                schedule.model = scheduleModelDir2MonFri;
                schedule.visible = true;
                break;
            case 4:
                schedule.model = scheduleModelDir2Sat;
                schedule.visible = true;
                break;
            case 5:
                schedule.model = scheduleModelDir2Sun;
                schedule.visible = true;
                break;
            case -1:
                schedule.visible = false;
            default:
                console.log("ERROR. Unknows switch code in scheduleShow\n")
        }
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
