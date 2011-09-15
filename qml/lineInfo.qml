import QtQuick 1.1
import com.meego 1.0
import "lineInfo.js" as JS
import com.nokia.extras 1.0

Page {
    id: lineInfoPage
    tools: commonTools
    Item {      // config object
        id: config
        property string bgColor: ""
        property string textColor: ""
        property string highlightColor: ""
        property string bgImage: ""
        property string highlightColorBg: ""
    }
    InfoBanner {// info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }

    objectName: "lineInfoPage"
    orientationLock: PageOrientation.LockPortrait
    property string loadLine: ""
    property string loadLineMap: ""
    property string lineAddString : ""
    property int scheduleLoaded : 0
    property int currentSchedule : -1

    Component.onCompleted: { // load configand recent lines
        JS.loadConfig(config)
        checkLineLoadRequest()
    }
    Rectangle{  // dark background
        color: config.bgColor
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        Image { source: config.bgImage; fillMode: Image.Center; anchors.fill: parent; }
        MouseArea {
            anchors.fill: parent
            onClicked: focus = true
        }
    }
    Item {      // search box
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
            color: config.highlightColorBg
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
                buttonClicked()
            }
       }
    }
    Rectangle { // decorative horizontal line
        id: hrLineSeparator
        anchors.left: parent.left
        anchors.top: searchBox.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }
    Item{       // data rect: info labels
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
        Rectangle { // showMapButton
                id: showMapButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20
                color: "#777777"
                height: 60
                width: 60
                radius: 10
                Button {
                    id: showMapButtonButton
                    anchors.fill: parent
                    text: "M"
                    visible: false
                    onClicked: {
                        showMap()
                    }
                }
        }
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
    }
    Rectangle { // decorative horizontal line
        id: hrLineSeparator2
        anchors.left: parent.left
        anchors.top: dataRect.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }
    ButtonRow { // tabs rect
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
                        fucus = true
                    }
                }
            }
            Button {
                id: stopsButton
                text: "Stops"
                onClicked: {
                    if (grid.visible == false) {
                        list.visible = false
                        updateStopReachModel()
                        grid.visible = true
                        schedule.visible = false
                        scheduleButtons.visible = false
                        fucus = true
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
                        scheduleButtons.visible = true
                        if (scheduleLoaded == 0 && list.currentIndex != -1) {
                            getSchedule()
                        }
                        fucus = true
                    }
                }
            }
    }
//--  Lists and delegates  ---------------------------------------------------//
    ListModel{  // stops list model
        id:stopReachModel
        ListElement {
            stopIdLong: "Stop"
            stopName: "Name"
            reachTime: "Time"
        }
    }
    Component{  // stops reach delegate
        id:stopReachDelegate
        Item {
            width: grid.width;
            height: 50;
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                spacing: 15
                Text{ text: stopName == "" ? stopIdLong:stopName; font.pixelSize: 30; color: config.textColor; anchors.verticalCenter : parent.verticalCenter}
                Text{ text: reachTime; font.pixelSize: 30; color: config.textColor; anchors.verticalCenter : parent.verticalCenter}
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    grid.focus = true;
                    grid.currentIndex = index;
                }
                onPressAndHold: {
                    pageStack.push(Qt.resolvedUrl("stopInfo.qml"),{"loadStop":stopIdLong});
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
            color: config.highlightColorBg
            opacity: 0.8
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
                onClicked: {
                    list.visible = false
                    grid.visible = true
                    dataRect.visible = true
                    if (list.currentIndex != index) {
                        list.currentIndex = index
                        showLineInfo()
                    }
                }
            }
        }
    }
    ListModel{  // schedule list model direction 1 Mon-Fri
        id:scheduleModelDir1MonFri
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{  // schedule list model direction 1 Sat
        id:scheduleModelDir1Sat
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{  // schedule list model direction 1 Sun
        id:scheduleModelDir1Sun
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{  // schedule list model direction 2 Mon-Fri
        id:scheduleModelDir2MonFri
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{  // schedule list model direction 2 Sat
        id:scheduleModelDir2Sat
        ListElement {
            departTime: "Time"
        }
    }
    ListModel{  // schedule list model direction 2 Sun
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
//--                        --------------------------------------------------//
    Item{  // grid rect
        id: infoRect
        anchors.top: tabRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false;
        ListView {  // Lines list
            id: list
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            anchors.rightMargin: 10
            delegate: lineInfoDelegate
            model: lineInfoModel
            spacing: 10
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
            currentIndex: -1
            clip: true
            visible: true
            onVisibleChanged: {
                if (visible == true) {
                    tabRect.checkedButton = linesButton;
                }
            }
        }
        ListView {  // stops reach model show
            id: grid
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            delegate: stopReachDelegate
            model: stopReachModel
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false;
            onVisibleChanged: {
                if (visible == true) {
                    tabRect.checkedButton = stopsButton;
                }
            }
        }
        ButtonRow { // scheduleButtons week period choose
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
                    currentSchedule = 0
                    scheduleShow();
                }
            }
            Button {
                id: scheduleButton1
                text: "Sat"
                onClicked: {
                    currentSchedule = 1
                    scheduleShow();
                }
            }
            Button {
                id: scheduleButton2
                text: "Sun"
                onClicked: {
                    currentSchedule = 2
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
            highlight: Rectangle { color: config.highlightColorBg; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false;
            onVisibleChanged: {
                if (visible == true) {
                    tabRect.checkedButton = scheduleButton;
                }
            }
        }
    }
/*<-------------------------------------------------------------------------->*/
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function getStops(){             // parse stops from dox.responseXML
        JS.__db().transaction(
            function(tx) {
                var rs = tx.executeSql('SELECT * FROM LineStops WHERE lineIdLong=?', [lineInfoModel.get(list.currentIndex).lineLongCode]);
                for (var ii=0; ii<rs.rows.length; ++ii) {
                    stopReachModel.append({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                                  "stopName" : JS.getStopName(rs.rows.item(ii).stopIdLong),
                                  "reachTime" : rs.rows.item(ii).stopReachTime });
                }
            }
        )
    }
    function parseXML(a){            // parse lines description, map
        lineInfoModel.clear()
        stopReachModel.clear()
        for (var ii = 0; ii < a.childNodes.length; ++ii) {
            lineAddString = ""
            lineInfoModel.append({"lineLongCode" : "" + a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                 "lineShortCode" : ""+a.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                 "direction" : "" + a.childNodes[ii].childNodes[3].firstChild.nodeValue + " -> " + a.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                 "type" : "" + JS.getLineType(a.childNodes[ii].childNodes[2].firstChild.nodeValue),
                                 "typeCode" : "" + a.childNodes[ii].childNodes[2].firstChild.nodeValue
                                 });
            if ( JS.addLine(""+ a.childNodes[ii].childNodes[0].firstChild.nodeValue +
                            ";"+ a.childNodes[ii].childNodes[1].firstChild.nodeValue +
                            ";"+ a.childNodes[ii].childNodes[5].firstChild.nodeValue +
                            ";" + a.childNodes[ii].childNodes[2].firstChild.nodeValue +
                            ";" + a.childNodes[ii].childNodes[3].firstChild.nodeValue +
                            ";" + a.childNodes[ii].childNodes[4].firstChild.nodeValue +
                            ";" + a.childNodes[ii].childNodes[8].firstChild.firstChild.firstChild.nodeValue +
                            ";" + a.childNodes[ii].childNodes[8].lastChild.firstChild.firstChild.nodeValue +
                            ";" + a.childNodes[ii].childNodes[7].firstChild.nodeValue +
                            ";" + a.childNodes[ii].childNodes[6].firstChild.nodeValue) == 0 ) {
                showError("Saved new line: " + a.childNodes[ii].childNodes[1].firstChild.nodeValue)
            }
            JS.__db().transaction(
                function(tx) {
                    for (var cc = 0; cc < a.childNodes[ii].childNodes[8].childNodes.length; ++cc) {
                        try { tx.executeSql('INSERT INTO LineStops VALUES(?,?,?)', [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                             a.childNodes[ii].childNodes[8].childNodes[cc].firstChild.firstChild.nodeValue,
                             a.childNodes[ii].childNodes[8].childNodes[cc].lastChild.firstChild.nodeValue]); }
                        catch(e) { console.log("EXCEPTION: " + e) }
                    }
                }
            )
        }
        gotLinesInfo()
    }
    function getXML() {              // xml http request                 : TODO : switch to use local var instead of JS.doc
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (doc.readyState == XMLHttpRequest.DONE) {
                if (doc.responseXML == null) {
                    showError("No lines found")
                    return
                } else {
                    console.log("OK, got " + doc.responseXML.documentElement.childNodes.length+ " lines")
                    parseXML(doc.responseXML.documentElement);
                }
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showError("ERROR returned from server")
            }
        }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&epsg_out=wgs84&query="+lineId.text); // for line info request
//             http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");
    doc.send();
    }
    function parseHttp(text_) {      // parse schedule reittiopas http page  : TODO: switch to use local vars
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

        for (var ii=0; ii<tables.length; ++ii) {
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
        scheduleLoaded = 1;
        currentSchedule = 0;
    }
    function getSchedule() {         // xml http request : schedule reittiopas page
        var scheduleURL = ""
        var scheduleHtmlReply = new XMLHttpRequest()
        scheduleHtmlReply.onreadystatechange = function() {
            if (scheduleHtmlReply.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.DONE) {
                    parseHttp(scheduleHtmlReply.responseText)
                    schedule.visible = true
            } else if (scheduleHtmlReply.readyState == XMLHttpRequest.ERROR) {
                console.log("ERROR")
                showError("ERROR")
            }
        }
        JS.__db().transaction(
            function(tx) {
                        try { var rs = tx.executeSql("SELECT lineSchedule FROM Lines WHERE lineIdLong=?", [lineInfoModel.get(list.currentIndex).lineLongCode]) }
                catch(e) { console.log("EXCEPTION: " + e) }
                if (rs.rows.length > 0) {
                    scheduleURL = rs.rows.item(0).lineSchedule
                }
            }
        )
        if (scheduleURL == "") {
            return
        }
        scheduleHtmlReply.open("GET",scheduleURL)
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
        switch(currentSchedule) {
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
        if (lineId.text == "Enter LineID") {
            showError("Enter search criteria\nline number/line code/Key place\ni.e. 156A or Tapiola or 2132  2")
            return
        }
//        stopReachModel.clear()
//        lineInfoModel.clear()
        searchButton.focus = true
        if (checkOffline() != 0) {
            getXML()
        } else {
            gotLinesInfo()
        }
    }
    function updateStopReachModel() {
        for (var ii=0;ii<stopReachModel.count;++ii) {
            stopReachModel.set(ii,{"stopName" : JS.getStopName(stopReachModel.get(ii).stopIdLong)});
        }
    }
    function showMap() {
        var ok=0
        if (list.currentIndex >= 0) {
            JS.__db().transaction(
                function(tx) {
                    try {
                        console.log("pushing line ID: " + lineInfoModel.get(list.currentIndex).lineLongCode)
                        tx.executeSql("INSERT INTO Current VALUES(?,?)",["setLineShape", lineInfoModel.get(list.currentIndex).lineLongCode])
                    }
                    catch(e) {
                        console.log("lineInfo: Exception: couldn't load map from responseXML")
                        ok=1
                    }
                }
            )
            if (ok ==0) {
                if (loadLineMap != "") {
                    pageStack.replace(Qt.resolvedUrl("route.qml"))
                } else {
                    pageStack.push(Qt.resolvedUrl("route.qml"))
                }
            }
        }
    }
    function checkLineLoadRequest() {
        if (loadLine != "") {
            lineId.text = loadLine
            buttonClicked()
        }
    }
    function checkOffline() {
        var retVal = 0
        JS.__db().transaction(
            function(tx) {
               try { var rs = tx.executeSql("SELECT * FROM Lines WHERE lineIdLong=? OR lineIdShort=?", [lineId.text, lineId.text]) }
               catch(e) { console.log("EXCEPTION in checkOffline: " + e) }
               if (rs.rows.length > 0) {
                   lineInfoModel.clear()
                   stopReachModel.clear()
                   for (var ii=0; ii < rs.rows.length; ++ii) {
                       lineInfoModel.append({"lineLongCode" : rs.rows.item(ii).lineIdLong,
                                            "lineShortCode" : rs.rows.item(ii).lineIdShort,
                                            "direction" : rs.rows.item(ii).lineStart + " -> " + rs.rows.item(ii).lineEnd,
                                            "type" : JS.getLineType(rs.rows.item(ii).lineType),
                                            "typeCode" : rs.rows.item(ii).lineType
                                            });
                   }
               } else {
                   retVal = -1
               }
            }
        )
        return retVal
    }
    function showLineInfo() {
        showMapButtonButton.visible = true
        scheduleLoaded = 0
        scheduleClear()
        stopReachModel.clear()
        getStops()
        lineShortCodeName.text = lineInfoModel.get(list.currentIndex).lineShortCode
        lineDirection.text = lineInfoModel.get(list.currentIndex).direction
        lineType.text = lineInfoModel.get(list.currentIndex).type
    }
    function gotLinesInfo() {
        infoRect.visible = true;
        if (loadLineMap != "") {
            list.currentIndex = 0
            showMap()
        }
        if (lineInfoModel.count == 1) {
            list.visible = false
            grid.visible = true
            dataRect.visible = true
            list.currentIndex = 0
            showLineInfo()
        }
    }

/*<----------------------------------------------------------------------->*/
}
