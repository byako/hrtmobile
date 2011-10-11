import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.0

Page {
    id: lineInfoPage
    tools: commonTools
    objectName: "lineInfoPage"
    orientationLock: PageOrientation.LockPortrait
    property string loadLine: ""
    property string loadLineMap: ""
    property int scheduleLoaded : 0
    property int currentSchedule : -1
    property string searchString: ""
    property int selectedLineIndex : -1

    Config {
        id: config
    }
    InfoBanner {    // info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    Item {          // busy indicator
        id: loading
        visible: false
        anchors.fill: parent
        width: parent.width
        height: parent.height
        z: 8
        Rectangle {
            width: parent.width
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color:"#FFFFFF"
            opacity: 0.7
        }
        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            running: true
            platformStyle: BusyIndicatorStyle { size: "large" }
        }
    }
    WorkerScript {  // stopReach loader
        id: stopReachLoader
        source: "lineInfo.js"

        onMessage: {
            for (var i=0;i<stopReachModel.count;++i) {
                if (stopReachModel.get(i).stopIdLong == messageObject.stopIdLong) {
                    stopReachModel.set(i, {"stopName" : messageObject.stopName })
                }
            }
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

    ContextMenu {   // line info context menu
        id: linesContextMenu
        MenuLayout {
            MenuItem {
                text: "Delete"
                onClicked: {
                    if (JS.deleteLine(lineInfoModel.get(list.currentIndex).lineIdLong) == 0) {
                        fillModel();
                    }
                    showLineInfo()
                }
            }
            MenuItem {
                text: "Delete all"
                onClicked: {
                    loading.visible = true
                    if (JS.deleteLine("*") == 0) {
                        fillModel();
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
                    pageStack.push(Qt.resolvedUrl("stopInfo.qml"),{"searchString":stopReachModel.get(grid.currentIndex).stopIdLong});
                }
            }
            MenuItem {
                text: "Map"
                onClicked : {
//                    switchToMap()
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
    MultiSelectionDialog {   // save lines select dialog
         id: chooseLinesDialog
         acceptButtonText: "Save"
         rejectButtonText: "Not any"
         titleText: "Lines to save"
         model: searchResultLineInfoModel
         onAccepted: {
            var tempCount = lineInfoModel.count
            for (var i=0;i<selectedIndexes.length;++i) {
                saveLine(selectedIndexes[i])
            }
            if (lineInfoModel.count > tempCount) {
                list.currentIndex = tempCount
                showLineInfo()
            }
         }
         onRejected: {

         }
    }

    Component.onCompleted: { // load config and recent lines
        refreshConfig()
        checkLineLoadRequest()
        fillModel()
    }
    Rectangle{      // dark background
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
    Item{           // data rect: info labels
        id: dataRect
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top:  parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        visible: false
        height: 110
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
                        if (searchString != "") {
                            showError("Building line shape")
                            showMap()
                        }
                    }
                }
        }
        Label {
            id: lineType;
            anchors.left: parent.left;
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 5
            text: qsTr("Line type")
            color: config.textColor
            font.pixelSize: 25
        }
        Label {
            id: lineShortCodeName;
            anchors.left: lineType.right
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 5
            text: qsTr("line")
            color: config.textColor
            font.pixelSize: 25
        }
        Label {
            id: lineStart
            anchors.top: lineShortCodeName.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: qsTr("lineStart")
            color: config.textColor
            font.pixelSize: 25
        }
        Label {
            id: lineEnd
            anchors.top: lineStart.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: qsTr("lineEnd")
            color: config.textColor
            font.pixelSize: 25
        }
    }
/*    Rectangle {     // decorative horizontal line
        id: hrLineSeparator2
        anchors.left: parent.left
        anchors.top: dataRect.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }*/
    ButtonRow {     // tabs rect
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
                        focus = true
                        if (list.currentIndex != selectedLineIndex) {
                            list.currentIndex = selectedLineIndex
                        }
                    }
                }
            }
            Button {
                id: stopsButton
                text: "Stops"
                onClicked: {
                    if (grid.visible == false) {
                        list.visible = false
                        grid.visible = true
                        schedule.visible = false
                        scheduleButtons.visible = false
                        focus = true
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
                            scheduleLoader.sendMessage({"lineIdLong":searchString})
                            scheduleLoaded = 1
                        }
                        focus = true
                    }
                }
            }
    }
//--  Lists and delegates  ---------------------------------------------------//
    ListModel {     // stops reach model
        id:stopReachModel
        ListElement {
            stopIdLong: "Stop"
            stopName: "Name"
            reachTime: "Time"
        }
    }
    Component {     // stops reach delegate
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
                onPressedChanged: {
                    if (pressed == true) {
                        grid.currentIndex = index;
                    }
                }
                onPressAndHold: {
                    stopContextMenu.open()
                }
            }
        }
    }

    ListModel {     // lineInfo list model
        id:lineInfoModel
        ListElement{
            lineIdLong: "lineId"
            lineIdShort: "lineCode"
            lineName: "name"
            lineStart: "from"
            lineEnd: "dest"
            lineType: "0"
            lineTypeName: "type"
        }
    }
    ListModel {     // search result lineInfo list model
        id:searchResultLineInfoModel
        ListElement{
            name: "lineId"
        }
    }
    Component {     // lineInfo section header
        id:lineInfoSectionHeader
        Item {
            width: list.width;
            height: 35
            Text{
                anchors.horizontalCenter:  parent.horizontalCenter
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: section;
                font.pixelSize: 35;
                color: config.textColor
            }
        }
    }
    Component {     // lineInfo short delegate
        id:lineInfoShortDelegate
        Item {
            width: list.width;
            height: 45
            Text{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                text: lineStart + " -> " + lineEnd;
                font.pixelSize: 25;
                color: config.textColor
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    if (selectedLineIndex != index) {
                        searchString = lineIdLong
                        selectedLineIndex = index
                        showLineInfo()
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        list.focus = true
                        list.currentIndex = index
                    }
                }
                onPressAndHold: {
                    linesContextMenu.open()
                }
            }
        }
    }
    Component {     // lineInfo delegate
        id:lineInfoDelegate
        Item {
            width: list.width;
            height: 70
            Column {
                height: parent.height
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: lineTypeName
                    font.pixelSize: 25
                    color: config.textColor
                }
                Text{
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: lineStart + " -> " + lineEnd;
                    font.pixelSize: 25;
                    color: config.textColor
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    if (selectedLineIndex != index) {
                        searchString = lineIdLong
                        selectedLineIndex = index
                        showLineInfo()
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        list.focus = true
                        list.currentIndex = index
                    }
                }
                onPressAndHold: {
                    linesContextMenu.open()
                }
            }
        }
    }

    ListModel {     // schedule list Mon - Fri model
        id:scheduleModel
        ListElement {
            departTime: "Time"
        }
    }
    ListModel {     // schedule list Sat model
        id:scheduleModel1
        ListElement {
            departTime: "Time"
        }
    }
    ListModel {     // schedule list Sun model
        id:scheduleModel2
        ListElement {
            departTime: "Time"
        }
    }
    Component{      // schedule delegate
        id:scheduleDelegate
        Item {
            width: schedule.cellWidth
            height: schedule.cellHeight
            Text{ anchors.left: parent.left; text: departTime; font.pixelSize: 25; color: config.textColor}
        }
    }
//--                        --------------------------------------------------//
    Item{           // grid rect
        id: infoRect
        anchors.top: tabRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: true;
        ListView {  // Lines list
            id: list
            anchors.fill:  parent
            delegate: config.lineGroup == "true" ? lineInfoShortDelegate : lineInfoDelegate
            section.property: config.lineGroup == "true" ? "lineTypeName": ""
            section.delegate: config.lineGroup == "true" ? lineInfoSectionHeader : {} ;
            model: lineInfoModel
            spacing: 5
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
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            visible: false
            Button {
                id: scheduleButton0
                text: "Mon-Fri"
                onClicked: {
                    schedule.model = scheduleModel
                }
            }
            Button {
                id: scheduleButton1
                text: "Sat"
                onClicked: {
                    schedule.model = scheduleModel1
                }
            }
            Button {
                id: scheduleButton2
                text: "Sun"
                onClicked: {
                    schedule.model = scheduleModel2
                }
            }
        }
        GridView {  // schedule list
            id: schedule
            anchors.left: parent.left
            anchors.leftMargin:10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: scheduleButtons.bottom
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            delegate: scheduleDelegate
            model: scheduleModel
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
    function getStops() {             // parse stops from dox.responseXML
        var temp_name
        JS.__db().transaction(
            function(tx) {
                var rs = tx.executeSql('SELECT * FROM LineStops WHERE lineIdLong=?', [lineInfoModel.get(list.currentIndex).lineIdLong]);
                for (var ii=0; ii<rs.rows.length; ++ii) {
                    temp_name = JS.getStopName(rs.rows.item(ii).stopIdLong)
                    if (temp_name == "") {
                        stopReachLoader.sendMessage({"stopIdLong":rs.rows.item(ii).stopIdLong})
                    }
                    stopReachModel.append({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                                  "stopName" : temp_name,
                                  "reachTime" : rs.rows.item(ii).stopReachTime });
                }
            }
        )
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
        console.log ("spinner visible")
        loading.visible = true
        var tempCount = lineInfoModel.count
        for (var ii = 0; ii < JS.response.childNodes.length; ++ii) {
            saveLine(ii)
        }
        if (lineInfoModel.count > tempCount) {
            list.currentIndex = tempCount
            showLineInfo()
        }
        console.log ("spinner invisible")
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
                                 "lineTypeName" : "" + JS.getLineType(JS.response.childNodes[ii].childNodes[2].firstChild.nodeValue) + " " + JS.response.childNodes[ii].childNodes[1].firstChild.nodeValue
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
                            ";" + JS.response.childNodes[ii].childNodes[6].firstChild.nodeValue) == 0 ) {
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
    function getXML() {              // xml http request                 : TODO : switch to use local var instead of JS.doc
      var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            } else if (doc.readyState == XMLHttpRequest.DONE) {
                if (doc.responseXML == null) {
                    showError("No lines found")
                    return
                } else {
                    JS.response = doc.responseXML.documentElement
                    console.log("OK, got " + doc.responseXML.documentElement.childNodes.length+ " lines")
                    if (doc.responseXML.documentElement.childNodes.length > 4) {
                        saveSelectDialog.open()
                    } else {
                        saveAllLines()
                    }
                }
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showError("ERROR returned from server")
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
    function buttonClicked() {  // entry point after search dialog: searchString is set now to what user has entered to search
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
    function updateStopReachModel() {
        for (var ii=0;ii<stopReachModel.count;++ii) {
            stopReachModel.set(ii,{"stopName" : JS.getStopName(stopReachModel.get(ii).stopIdLong)});
            if (stopReachModel.get(ii).stopName == "") {
                stopReachLoader.sendMessage({"stopIdLong":stopReachModel.get(ii).stopIdLong})
            }
        }
    }
    function showMap() {        // push Map page or replace current with Map page
        if (list.currentIndex >= 0) {
            if (loadLineMap != "") {
                pageStack.replace(Qt.resolvedUrl("route.qml"),{"loadLine":lineInfoModel.get(list.currentIndex).lineIdLong})
            } else {
                pageStack.push(Qt.resolvedUrl("route.qml"),{"loadLine":lineInfoModel.get(list.currentIndex).lineIdLong})
            }
        }
    }
    function checkLineLoadRequest() {
        if (loadLine != "") {
            searchString = loadLine
            buttonClicked()
        } else if (loadLineMap != "") {
            searchString = loadLineMap
            buttonClicked()
        }
    }
    function checkOffline() {
        var retVal = 0
        JS.__db().transaction(
            function(tx) {
               try { var rs = tx.executeSql("SELECT lineIdLong, lineIdshort, lineName, lineType, lineStart, lineEnd FROM Lines WHERE lineIdLong=? OR lineIdShort=?", [searchString, searchString]) }
               catch(e) { console.log("EXCEPTION in checkOffline: " + e) }
               if (rs.rows.length > 0) {
                   lineInfoModel.clear()
                   stopReachModel.clear()
                   for (var ii=0; ii < rs.rows.length; ++ii) {
                       lineInfoModel.append({"lineIdLong" : rs.rows.item(ii).lineIdLong,
                                            "lineIdShort" : rs.rows.item(ii).lineIdShort,
                                            "lineName" : rs.rows.item(ii).lineName,
                                            "lineStart" : rs.rows.item(ii).lineStart,
                                            "lineEnd" : rs.rows.item(ii).lineEnd,
                                            "lineType" : rs.rows.item(ii).lineType,
                                            "lineTypeName" : JS.getLineType(rs.rows.item(ii).lineType) + " " + rs.rows.item(ii).lineIdShort
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
        if (list.currentIndex >= 0) {
            list.visible = false
            grid.visible = true
            dataRect.visible = true
            showMapButtonButton.visible = true
            scheduleLoaded = 0
            scheduleClear()
            stopReachModel.clear()
            getStops()
            lineShortCodeName.text = lineInfoModel.get(list.currentIndex).lineIdShort
            lineStart.text = "From : " + lineInfoModel.get(list.currentIndex).lineStart
            lineEnd.text = "To : " + lineInfoModel.get(list.currentIndex).lineEnd
            lineType.text = JS.getLineType(lineInfoModel.get(list.currentIndex).lineType)
        } else {
            dataRect.visible = false
            stopReachModel.clear()
            scheduleClear()
        }
    }
    function gotLinesInfo() {  // after offline search is succeded
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
    function fillModel() {      // checkout recent stops from database
        lineInfoModel.clear();
        JS.__db().transaction(
            function(tx) {
                     var rs = tx.executeSql("SELECT lineIdLong, lineIdShort, lineName, lineStart, lineEnd, lineType FROM Lines ORDER BY lineIdShort ASC");
                     for (var i=0; i<rs.rows.length; ++i) {
                         lineInfoModel.append({"lineIdLong":rs.rows.item(i).lineIdLong, "lineIdShort":rs.rows.item(i).lineIdShort, "lineName":rs.rows.item(i).lineName,
                                              "lineStart":rs.rows.item(i).lineStart, "lineEnd":rs.rows.item(i).lineEnd, "lineType":rs.rows.item(i).lineType,
                                                  "lineTypeName" : JS.getLineType(rs.rows.item(i).lineType) + " " + rs.rows.item(i).lineIdShort})
                     }
                 }
        )
    }
    function refreshConfig() {
        JS.loadConfig(config)
    }
/*<----------------------------------------------------------------------->*/
}
