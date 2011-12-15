import QtQuick 1.1
import com.nokia.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.1

Item {
    objectName: "lineInfoPage"
    id: lineInfoPageItem
    property string loadLine: ""
    property int scheduleLoaded : 0
    property int currentSchedule : -1
    property string searchString: ""
    property int selectedLineIndex : -1
    property bool offlineResult : false

    signal showLineMap(string lineIdLong)
    signal showLineMapStop(string lineIdLong, string stopIdLong)
    signal showStopMap(string stopIdLong)
    signal showStopInfo(string stopIdLong)
    signal pushStopToMap(string stopIdLong_, string stopIdShort_, string stopName_, string stopLongitude_, string stopLatitude_)
    signal refreshFavorites()
    signal cleanMapAndPushStops()
    width: 480
    height: 745

    Component.onCompleted: { // load config and recent lines
        refreshConfig()
        checkLineLoadRequest()
        lineInfoLoadLines.sendMessage("")
    }

    Config { id: config }
    InfoBanner {    // info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    Loading {          // busy indicator
        id: loading
        visible: false
        anchors.fill: parent
        z: 8
    }
    WorkerScript {  // stop name loader
        id: stopReachLoader
        source: "lineInfo.js"

        onMessage: {
            stopReachModel.set(messageObject.lineReachNumber, {"stopName" : messageObject.stopName,
                                   "stopIdShort" : messageObject.stopIdShort,
                                   "stopCity" : messageObject.stopCity,
                                   "stopLongitude" : messageObject.stopLongitude,
                                   "stopLatitude" : messageObject.stopLatitude,
                               })
        }
    }
    WorkerScript {  // schedule loader
        id: scheduleLoader
        source: "lineInfoSchedule.js"

        onMessage: {
            switch(messageObject.departDay) {
                case 0: scheduleModel.append({"departTime" : messageObject.departTime}); break;
                case 1: scheduleModel1.append({"departTime" : messageObject.departTime}); break;
                case 2: scheduleModel2.append({"departTime" : messageObject.departTime}); break;
                default : console.log("What the F&&&???!! - " + messageObject.departDay);
            }
        }
    }
    WorkerScript {  // lineInfoLoadLines
        id: lineInfoLoadLines
        source: "lineInfoLoadLines.js"

        onMessage: {
            lineInfoModel.append({"lineIdLong" : messageObject.lineIdLong, "lineIdShort" : messageObject.lineIdShort,
                                     "lineStart" : messageObject.lineStart, "lineEnd" : messageObject.lineEnd,
                                     "lineName" : messageObject.lineName, "lineType" : messageObject.lineType,
                                     "lineTypeName" : JS.getLineType(messageObject.lineType) + " " + messageObject.lineIdShort,
                                     "favorite" : messageObject.favorite
                                 })
        }
    }
    MultiSelectionDialog {   // save lines select dialog
         id: chooseLinesDialog
         acceptButtonText: "Save"
         rejectButtonText: "Cancel"
         titleText: "Lines to save"
         model: searchResultLineInfoModel
         onAccepted: {
            var tempCount = lineInfoModel.count
            for (var i=0;i<selectedIndexes.length;++i) {
                saveLine(selectedIndexes[i])
            }
            if (lineInfoModel.count > tempCount) {
                linesView.currentIndex = tempCount
                showLineInfo()
            }
         }
         onRejected: {

         }
    }
    ContextMenu {   // line info context menu
        id: linesContextMenu
        MenuLayout {
            MenuItem {
                text: "Delete line"
                onClicked: {
                    if (JS.deleteLine(lineInfoModel.get(linesView.currentIndex).lineIdLong) == 0) {
                        lineInfoModel.clear()
                        lineInfoLoadLines.sendMessage("")
                    }
                    showLineInfo()
                }
            }
            MenuItem {
                text: "Delete all"
                onClicked: {
                    loading.visible = true
                    if (JS.deleteLine("*") == 0) {
                        lineInfoModel.clear()
                        lineInfoLoadLines.sendMessage("")
                    }
                    loading.visible = false
                    showLineInfo()
                }
            }
        }
    }
    ContextMenu {   // stop reach context menu
        id: stopContextMenu
        MenuLayout {
            MenuItem {
                text: "Stop Info"
                onClicked : {
                    showStopInfo(stopReachModel.get(stopsView.currentIndex).stopIdLong)
                }
            }
            MenuItem {
                text: "Map"
                onClicked : {
                    // send stopIdLong and lineIdLong to map page to show both
                    lineInfoPageItem.cleanMapAndPushStops()
                    showLineMapStop(searchString, stopReachModel.get(stopsView.currentIndex).stopIdLong)
                }
            }
        }
    }
    QueryDialog {   // many lines save/select dialog
        id: saveSelectDialog
        acceptButtonText: "Save all"
        rejectButtonText: "Select"
        message: "Found a lot of lines. Saving all can take a while. Still save all or select which lines to save?"
        titleText: "Save / Select"
        onAccepted: {
            saveAllLines()
        }
        onRejected: {
            fillSearchResultInfoModel()
        }
    }
    Rectangle{      // dark background
        color: "#000000"
        anchors.fill: parent
        width: parent.width
        height:  parent.height
    }
    Item{           // data rect: info labels
        id: dataRect
        anchors.left: parent.left
        anchors.top:  parent.top
        anchors.right: parent.right
        visible: false
        height: 120
        Button {    // showMapButton
            id: showMapButtonButton
            style: TabButtonStyle {
                inverted: true
            }
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 20
            height: 60
            width: 60
            text: "M"
            visible: false
            onClicked: {
                if (searchString != "") {
                    showError("Building line shape")
                    showMap()
                }
            }
        }
        Item {          // favorite
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            height: 60
            width: 60
            Button { // favorite
                style: TabButtonStyle {
                    inverted: true
                }
                id: favoriteButton
                anchors.fill: parent
                iconSource: (lineInfoModel.get(selectedLineIndex).favorite == "true") ? "image://theme/icon-m-toolbar-favorite-mark-white" : "image://theme/icon-m-toolbar-favorite-unmark-white"
                onClicked: {
                    if (lineInfoModel.get(selectedLineIndex).favorite == "true") {
                        setFavorite(searchString, "false")
                        lineInfoModel.set(selectedLineIndex, {"favorite":"false"})
                    } else {
                        setFavorite(searchString, "true")
                        lineInfoModel.set(selectedLineIndex, {"favorite":"true"})
                    }
                    lineInfoPageItem.refreshFavorites()
                }
            }
        }
        Column {
            Row {
                Label {
                    id: lineType;
                    text: qsTr("Line type")
                    color: "#cdd9ff"
                    font.pixelSize: 30
                }
                Label {
                    id: lineShortCodeName;
                    text: qsTr("line")
                    color: "#cdd9ff"
                    font.pixelSize: 30
                }
            }
            Label {
                id: lineStart
                text: qsTr("lineStart")
                color: "#cdd9ff"
                font.pixelSize: 30
            }
            Label {
                id: lineEnd
                text: qsTr("lineEnd")
                color: "#cdd9ff"
                font.pixelSize: 30
            }
        } // column
    }

    ButtonRow {     // tabs rect
        id: tabRect
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        style: TabButtonStyle {
            inverted: true
        }
            Button {  // recent lines
                id: linesButton
                text: "Saved lines"
                onClicked: {
                    infoRect.state = "linesSelected"
                    if (linesView.currentIndex != selectedLineIndex) {
                        linesView.currentIndex = selectedLineIndex
                    } else if (offlineResult == true) {
                        lineInfoModel.clear()
                        lineInfoLoadLines.sendMessage("")
                        offlineResult = false
                    }
                }
            }
            Button {  // line stops
                id: stopsButton
                text: "Line Stops"
                onClicked: {
                    infoRect.state = "stopsSelected"
                }
            }
            Button {  // line schedule
                id: scheduleButton
                text: "Schedule"
                onClicked: {
                    infoRect.state = "scheduleSelected"
                    if (scheduleLoaded == 0 && selectedLineIndex != -1) {
                        scheduleLoader.sendMessage({"lineIdLong":searchString})
                        scheduleLoaded = 1
                    }
                }
            }
    }
//--  Lists and delegates  ---------------------------------------------------//
    ListModel {     // stops reach model
        id:stopReachModel
    }
    Component {     // stop reach header
        id: stopReachHeader
        Rectangle {
            width: stopsView.width
            height: 40
            color: "#222222"
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: 20
                Text{  // stop Name
                    text: "Stop name"
                    font.pixelSize: 35
                    color: "#cdd9ff"
                    width: 310
                }
                Text{  // reach time
                    text: "Reach(m)"
                    font.pixelSize: 35
                    color: "#cdd9ff"
                }
            }
        }
    }
    Component {     // stops reach delegate
        id:stopReachDelegate
        Item {
            width: stopsView.width;
            height: 50;
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                height: parent.height
                spacing: 15
                Text{ text: stopName == "" ? stopIdLong:stopName; font.pixelSize: 30; color: "#cdd9ff"; anchors.verticalCenter : parent.verticalCenter; width: 400;}
                Text{ text: reachTime; font.pixelSize: 30; color: "#cdd9ff"; anchors.verticalCenter : parent.verticalCenter}
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    stopsView.currentIndex = index;
                }
                onDoubleClicked: {
                    stopsView.currentIndex = index;
                    showStopInfo(stopIdLong)
                }
                onPressAndHold: {
                    stopsView.currentIndex = index;
                    stopContextMenu.open()
                }
            }
        }
    }

    ListModel {     // lineInfo list model
        id:lineInfoModel
    }
    ListModel {     // search result lineInfo list model
        id:searchResultLineInfoModel
    }
    Component {     // lineInfo section header
        id:lineInfoSectionHeader
        Item {
            width: linesView.width;
            height: 35
            Text{
                anchors.left:  parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: section;
                font.pixelSize: 35;
                color: "#cdd9ff"
            }
        }
    }
    Component {     // lineInfo short delegate
        id:lineInfoShortDelegate
        Item {
            width: linesView.width;
            height: 35
            Text{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 50
                wrapMode: Text.WordWrap
                text: lineStart + " -> " + lineEnd;
                font.pixelSize: 25;
                color: "#cdd9ff"
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    if (selectedLineIndex != index) {
                        searchString = lineIdLong
                        selectedLineIndex = index
                        linesView.currentIndex = index
                        tabRect.checkedButton = stopsButton
                        showLineInfo()
                    }
                }
                onPressAndHold: {
                    linesView.currentIndex = index
                    linesContextMenu.open()
                }
            }
        }
    }
    ListModel {     // schedule list Mon - Fri model
        id:scheduleModel
    }
    ListModel {     // schedule list Sat model
        id:scheduleModel1
    }
    ListModel {     // schedule list Sun model
        id:scheduleModel2
    }
    Component{      // schedule delegate
        id:scheduleDelegate
        Item {
            width: scheduleView.cellWidth
            height: scheduleView.cellHeight
            Text{ anchors.left: parent.left; text: departTime; font.pixelSize: 25; color: "#cdd9ff"}
        }
    }
//--                        --------------------------------------------------//
    Item{           // stopsView rect
        id: infoRect
        anchors.top: tabRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: true;
        ListView {  // Lines list
            id: linesView
            anchors.fill:  parent
            delegate: lineInfoShortDelegate
            section.property: "lineTypeName"
            section.delegate: lineInfoSectionHeader
            model: lineInfoModel
            spacing: 5
            highlight: Rectangle { color: "#666666"; radius:  5 }
            currentIndex: -1
            clip: true
            visible: true
//            onVisibleChanged: {
//                if (visible == true) {
//                    tabRect.checkedButton = linesButton;
//                }
//            }
        }
        ListView {  // stops reach model show
            id: stopsView
            anchors.fill:  parent
            delegate: stopReachDelegate
            model: stopReachModel
            highlight: Rectangle { color: "#666666"; radius:  5 }
            currentIndex: -1
            header: stopReachHeader
            clip: true
            visible: false;
//            onVisibleChanged: {
//                if (visible == true) {
//                    tabRect.checkedButton = stopsButton;
//                }
//            }
        }
        ButtonRow { // scheduleButtons week period choose
            id: scheduleButtons
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 350
            visible: false
            style: TabButtonStyle {
                inverted: true
            }

            Button {
                id: scheduleButton0
                text: "Mon-Fri"
                onClicked: {
                    scheduleView.model = scheduleModel
                }
            }
            Button {
                id: scheduleButton1
                text: "Sat"
                onClicked: {
                    scheduleView.model = scheduleModel1
                }
            }
            Button {
                id: scheduleButton2
                text: "Sun"
                onClicked: {
                    scheduleView.model = scheduleModel2
                }
            }
        }
        GridView {  // scheduleView list
            id: scheduleView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: scheduleButtons.bottom
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            delegate: scheduleDelegate
            model: scheduleModel
            cellWidth: 115
            cellHeight: 30
            highlight: Rectangle { color: "#666666"; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false;
//            onVisibleChanged: {
//                if (visible == true) {
//                    tabRect.checkedButton = scheduleButton;
//                }
//            }
        }
        states: [
            State {
                name: "linesSelected"
                PropertyChanges { target: linesView; visible: true }
                PropertyChanges { target: stopsView; visible: false }
                PropertyChanges { target: scheduleView; visible: false }
                PropertyChanges { target: scheduleButtons; visible: false }
            },
            State {
                name: "stopsSelected"
                PropertyChanges { target: linesView; visible: false }
                PropertyChanges { target: stopsView; visible: true }
                PropertyChanges { target: scheduleView; visible: false }
                PropertyChanges { target: scheduleButtons; visible: false }
            },
            State {
                name: "scheduleSelected"
                PropertyChanges { target: linesView; visible: false }
                PropertyChanges { target: stopsView; visible: false }
                PropertyChanges { target: scheduleView; visible: true }
                PropertyChanges { target: scheduleButtons; visible: true }
            }
        ]
    }
/*<-------------------------------------------------------------------------->*/
    function showError(errorText) {   // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function fillSearchResultInfoModel() {
        var lineInfo;
        loading.visible = true;
        searchResultLineInfoModel.clear()
        for (var ii = 0; ii < JS.response.childNodes.length; ++ii) {
            lineInfo = "" + JS.response.childNodes[ii].childNodes[1].firstChild.nodeValue + " : " + JS.response.childNodes[ii].childNodes[3].firstChild.nodeValue + " -> " + JS.response.childNodes[ii].childNodes[4].firstChild.nodeValue
            searchResultLineInfoModel.append({"name" : lineInfo });
        }
        loading.visible = false
        chooseLinesDialog.open()
    }
    function saveAllLines() {
        loading.visible = true
        var tempCount = lineInfoModel.count
        for (var ii = 0; ii < JS.response.childNodes.length; ++ii) {
            saveLine(ii)
        }
        if (lineInfoModel.count > tempCount) {
            if (tempCount >= 0) {
                linesView.currentIndex = tempCount
                selectedLineIndex = tempCount
            } else {
                linesView.currentIndex = 0
                selectedLineIndex = 0
            }
            searchString = lineInfoModel.get(tempCount).lineIdLong
            showLineInfo()
        }
        loading.visible = false
        gotLinesInfo()
    }
    function saveLine(ii) {           // parse lines description, map
            lineInfoModel.append({"lineIdLong" : "" + JS.response.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                 "lineIdShort" : ""+ JS.response.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                 "lineName" : "" + JS.response.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                 "lineStart" : "" + JS.response.childNodes[ii].childNodes[3].firstChild.nodeValue,
                                 "lineEnd" : "" + JS.response.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                 "lineType" : "" + JS.response.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                 "lineTypeName" : "" + JS.getLineType(JS.response.childNodes[ii].childNodes[2].firstChild.nodeValue) + " " + JS.response.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                 "favorite" : "false"
                                 });
            if ( JS.addLine(""+ JS.response.childNodes[ii].childNodes[0].firstChild.nodeValue +
                            ";"+ JS.response.childNodes[ii].childNodes[1].firstChild.nodeValue +
                            ";"+ JS.response.childNodes[ii].childNodes[5].firstChild.nodeValue +
                            ";" + JS.response.childNodes[ii].childNodes[2].firstChild.nodeValue +
                            ";" + JS.response.childNodes[ii].childNodes[3].firstChild.nodeValue +
                            ";" + JS.response.childNodes[ii].childNodes[4].firstChild.nodeValue +
                            ";" + JS.response.childNodes[ii].childNodes[8].firstChild.firstChild.firstChild.nodeValue +
                            ";" + JS.response.childNodes[ii].childNodes[8].lastChild.firstChild.firstChild.nodeValue +
                            ";" + JS.response.childNodes[ii].childNodes[7].firstChild.nodeValue +
                            ";" + JS.response.childNodes[ii].childNodes[6].firstChild.nodeValue +
                            ";" + "false" ) == 0 ) {
                showError("Saved new line: " + JS.response.childNodes[ii].childNodes[1].firstChild.nodeValue)
            }
            JS.__db().transaction(
                function(tx) {
                    for (var cc = 0; cc < JS.response.childNodes[ii].childNodes[8].childNodes.length; ++cc) {
                        try { tx.executeSql('INSERT INTO LineStops VALUES(?,?,?)', [JS.response.childNodes[ii].childNodes[0].firstChild.nodeValue,
                             JS.response.childNodes[ii].childNodes[8].childNodes[cc].firstChild.firstChild.nodeValue,
                             JS.response.childNodes[ii].childNodes[8].childNodes[cc].lastChild.firstChild.nodeValue]); }
                        catch(e) { console.log("EXCEPTION: " + e) }
                    }
                }
            )
    }
    function getXML() {               // xml http request                 : TODO : switch to use local var instead of JS.doc
      var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (doc.readyState == XMLHttpRequest.DONE) {
                if (doc.responseXML == null) {
                    showError("No lines found")
                    loading.visible = false
                    return
                } else {
                    JS.response = doc.responseXML.documentElement
                    console.log("OK, got " + doc.responseXML.documentElement.childNodes.length+ " lines")
                    loading.visible = false
                    if (doc.responseXML.documentElement.childNodes.length > 4) {
                        saveSelectDialog.open()
                    } else {
                        saveAllLines()
                    }
                }
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showError("ERROR returned from server")
                loading.visible = false
            }
        }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&epsg_out=wgs84&query="+searchString); // for line info request
//             http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");
    loading.visible = true
    doc.send();
    }
    function scheduleClear() {
        scheduleModel.clear()
        scheduleModel1.clear()
        scheduleModel2.clear()
    }
    function buttonClicked() {        // entry point after search dialog: searchString is set now to what user has entered to search
        console.log("Button clicked: " + searchString)
        if (searchString == "Enter LineID" || searchString == "") {
            showError("Enter search criteria\nline number/line code/Key place\ni.e. 156A or Tapiola")
            return
        }
        if (checkOffline() != 0) {
            getXML()
        } else {
            gotLinesInfo()
        }
    }
    function sendStopsToMap() {
        for (var ii=0; ii < stopReachModel.count; ++ii) {
            if (stopReachModel.get(ii).stopName != "") {
                pushStopToMap(stopReachModel.get(ii).stopIdLong,
                              stopReachModel.get(ii).stopIdShort,
                              stopReachModel.get(ii).stopName,
                              stopReachModel.get(ii).stopLongitude,
                              stopReachModel.get(ii).stopLatitude)
            }
        }
    }
    function showMap() {            // push lineIdLong and stops to map page
        lineInfoPageItem.cleanMapAndPushStops()
        if (stopsView.currentIndex >= 0) {
            showLineMapStop(searchString, stopReachModel.get(stopsView.currentIndex).stopIdLong)
        } else {
            showLineMap(searchString)
        }
    }
    function checkLineLoadRequest() {
        if (loadLine != "") {
            searchString = loadLine
            buttonClicked()
        }
    }
    function checkOffline() {        // check if requested line is already in DB
        var retVal = 0
        JS.__db().transaction(
            function(tx) {
               try { var rs = tx.executeSql("SELECT lineIdLong, lineIdshort, lineName, lineType, lineStart, lineEnd FROM Lines WHERE lineIdLong=? OR lineIdShort=?", [searchString, searchString]) }
               catch(e) { console.log("EXCEPTION in checkOffline: " + e) }
               if (rs.rows.length > 0) {
                   lineInfoModel.clear()
                   stopReachModel.clear()
                   offlineResult = true
                   for (var ii=0; ii < rs.rows.length; ++ii) {
                       lineInfoModel.append({"lineIdLong" : rs.rows.item(ii).lineIdLong,
                                            "lineIdShort" : rs.rows.item(ii).lineIdShort,
                                            "lineName" : rs.rows.item(ii).lineName,
                                            "lineStart" : rs.rows.item(ii).lineStart,
                                            "lineEnd" : rs.rows.item(ii).lineEnd,
                                            "lineType" : rs.rows.item(ii).lineType,
                                            "lineTypeName" : JS.getLineType(rs.rows.item(ii).lineType) + " " + rs.rows.item(ii).lineIdShort,
                                            "favorite" : rs.rows.item(ii).favorite
                                            });
                   }
               } else {
                   retVal = -1
               }
            }
        )
        return retVal
    }
    function getStops() {             // load stops from LineStops database table
        var temp_name
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql('SELECT * FROM LineStops WHERE lineIdLong=?', [searchString]); }
                catch (e) { console.log ("lineInfo.qml: getStops exception 1: " + e) }
                for (var ii=0; ii<rs.rows.length; ++ii) {
                    try {
                        var rs2 = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [rs.rows.item(ii).stopIdLong]);
                    }
                    catch (e) { console.log ("lineInfo.qml: getStops exception 2: " + e) }
//                    temp_name = JS.getStopName(rs.rows.item(ii).stopIdLong)
                    if (rs2.rows.length == 0) {
                        stopReachLoader.sendMessage({"stopIdLong":rs.rows.item(ii).stopIdLong, "lineReachNumber" : ii})
                        stopReachModel.append({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                                                  "stopName" : "",
                                                  "stopIdShort" : "",
                                                  "stopLongitude" : "",
                                                  "stopLatitude" : "",
                                                  "stopCity" : "",
                                                  "reachTime" : rs.rows.item(ii).stopReachTime });
                    } else {
                        stopReachModel.append({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                                  "stopName" : rs2.rows.item(0).stopName,
                                  "stopIdShort" : rs2.rows.item(0).stopIdShort,
                                  "stopLongitude" : rs2.rows.item(0).stopLongitude,
                                  "stopLatitude" : rs2.rows.item(0).stopLatitude,
                                  "stopCity" : rs2.rows.item(0).stopCity,
                                  "reachTime" : rs.rows.item(ii).stopReachTime });
                    }
                }
            }
        )
    }
    function showLineInfo() {        // triggered when one of saved line selected by user
        if (linesView.currentIndex >= 0) {
            console.log("ShowLineInfo:  current index is " + linesView.currentIndex)
            infoRect.state = "stopsSelected"
            tabRect.checkedButton = stopsButton
            dataRect.visible = true
            showMapButtonButton.visible = true
            scheduleLoaded = 0
            scheduleClear()
            stopReachModel.clear()
            getStops()
            lineShortCodeName.text = lineInfoModel.get(linesView.currentIndex).lineIdShort
            lineStart.text = "From : " + lineInfoModel.get(linesView.currentIndex).lineStart
            lineEnd.text = "To : " + lineInfoModel.get(linesView.currentIndex).lineEnd
            lineType.text = JS.getLineType(lineInfoModel.get(linesView.currentIndex).lineType)
            searchString = lineInfoModel.get(linesView.currentIndex).lineIdLong
        } else {
            dataRect.visible = false
            stopReachModel.clear()
            scheduleClear()
        }
    }
    function gotLinesInfo() {         // after offline search is succeded
        console.log("DEBUG ME HERE! I DON'T KNOW WHY IS THIS HAPPENING TO ME!!!!! HELP!!")
        infoRect.visible = true;
        if (lineInfoModel.count == 1) {
            infoRect.state = "stopsSelected"
            dataRect.visible = true
            linesView.currentIndex = 0
            showLineInfo()
        }
    }
    function setFavorite(lineIdLong_,value) {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {  // TODO
                try { var rs = tx.executeSql("UPDATE Lines SET favorite=? WHERE lineIdLong=?",[value,lineIdLong_]); }
                catch(e) { console.log("lineInfo: setFavorite EXCEPTION: " + e) }
            }
        )
    }
    function refreshConfig() {        // reload config from database - same function on every page
        JS.loadConfig(config)
    }
/*<----------------------------------------------------------------------->*/
}
