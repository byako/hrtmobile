import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.0

Page {
    id: stopInfoPage
    tools: commonTools
    Config {
        id: config
    }
    objectName: "stopInfoPage"
    property string stopAddString: ""
    property string loadStop: ""
    property string searchString: ""    // keep stopIdLong here. If stopIdShort supplied (request from lineInfo) -> remove and place stopIdLong
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: { JS.loadConfig(config); infoModel.clear(); fillModel(); setCurrent(); }
    Item {
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
        BusyIndicator{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            platformStyle: BusyIndicatorStyle { size : "large" }
            running: true
        }
    }
    QueryDialog {
        id: offlineModeOff
        acceptButtonText: "Go online"
        rejectButtonText: "Keep offline"
        message: "Offline mode enabled.\nGo online?\n(Data charges may apply)"
        titleText: "Offline mode"
        onAccepted: {
            JS.setCurrent("networking","1")
            config.networking = "1"
            getInfo()
            updateSchedule()
        }
        onRejected: {
            console.log("User declined to go online")
        }
    }
    InfoBanner {// info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    ContextMenu {   // recent stops context menu
        id: recentStopsContextMenu
        MenuLayout {
            MenuItem {
                text: "Delete"
                onClicked: {
                    if (JS.deleteStop(recentModel.get(recentList.currentIndex).stopIdLong) == 0) {
                        fillModel();
                    }
                }
            }
            MenuItem {
                text: "Delete all"
                onClicked: {
                    if (JS.deleteStop("*") == 0) {
                        fillModel();
                    }
                }
            }
        }

    }
    ContextMenu {   // depart line context menu
        id: lineContext
        MenuLayout {
            MenuItem {
                text: "Line Info"
                onClicked : {
                    pageStack.push(Qt.resolvedUrl("lineInfo.qml"),{"loadLine":trafficModel.get(grid.currentIndex).departCode});
                }
            }
            MenuItem {
                text: "Line Map"
                onClicked : {
                    switchToMap()
                }
            }
        }
    }
    Rectangle {     // dark background
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        Image { source: config.bgImage ; fillMode: Image.Center; anchors.fill: parent; }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                focus: true
            }
        }
    }
    Item {          // Data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        height: 120
        width: parent.width
        visible: false
        Rectangle { // showMapButton
                id: showMapButton
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.topMargin: 30
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
                        pageStack.push(Qt.resolvedUrl("route.qml"),{"loadStop":searchString})
                    }
                }
                BusyIndicator{    // loading spinner
                    id: loadingMap
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    running: true
                    z: 8
                }
            }
        Label {
            id: stopNameLabel
            anchors.top: parent.top
            anchors.topMargin: 3
            anchors.left: parent.left
            text: qsTr("Name")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopName;
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.right: showMapButton.left
            anchors.rightMargin: 20
            text: qsTr("Name")
            color: config.textColor
            font.pixelSize: 25
        }
        Label {
            id: stopAddressLabel
            anchors.top: stopNameLabel.bottom
            anchors.topMargin: 2
            anchors.left: parent.left
            text: qsTr("Address")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopAddress;
            anchors.top: stopName.bottom
            anchors.topMargin: 8
            anchors.right: showMapButton.left
            anchors.rightMargin: 20
            text: qsTr("Address")
            color: config.textColor
            font.pixelSize: 25
        }
        Label {
            id: stopCityLabel;
            anchors.top: stopAddressLabel.bottom
            anchors.topMargin: 2
            anchors.left: parent.left
            text: qsTr("City")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopCity;
            anchors.top: stopAddress.bottom
            anchors.topMargin: 8
            anchors.right: showMapButton.left
            anchors.rightMargin: 20
            text: qsTr("City")
            color: config.textColor
            font.pixelSize: 25
        }
    }
    Rectangle {     // HR separator 2
        id: hrLineSeparator2
        anchors.left: parent.left
        anchors.top: dataRect.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }
    ButtonRow {     // tabs rect
        id: tabRect
        width: parent.width
        anchors.top: hrLineSeparator2.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
            Button {
                id: recentButton
                text: "Recent"
                onClicked: {
                    if (recentList.visible == false) {
                        linesList.visible = false
                        list.visible = false
                        grid.visible = false
                        recentList.visible = true
                    }
                }
            }
            Button {
                id: stopSchedule
                text: "Schedule"
                onClicked: {
                    if (grid.visible == false) {
                        linesList.visible = false
                        grid.visible = true
                        list.visible = false
                        recentList.visible = false
                    }
                }
            }
            Button {
                id: stopLines
                text: "Lines"
                onClicked: {
                    if (linesList.visible == false) {
                        linesList.visible = true
                        grid.visible = false
                        list.visible = false
                        recentList.visible = false
                    }
                }
            }
            Button {
                id: stopInfo
                text: "Info"
                onClicked: {
                    if (list.visible == false) {
                        linesList.visible = false
                        list.visible = true
                        grid.visible = false
                        recentList.visible = false
                    }
                }
            }
    }
/*<----------------------------------------------------------------------->*/
    ListModel {     // recent stops list
        id: recentModel
        ListElement {
            stopIdLong: ""
            stopIdShort: ""
            stopName: ""
            stopAddress: ""
            stopCity: ""
            stopLongitude: ""
            stopLatitude: ""
        }
    }
    Component {     // recent stops delegate
        id: recentDelegate
        Rectangle {
            width: recentList.width
            height: 70
            radius: 20
            color: config.highlightColorBg
            opacity: 0.8
            Column {
                height: parent.height
                width: parent.width
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 20
                    Text{
                        text: stopName
                        font.pixelSize: 35
                        color: config.textColor
                        width: 340
                    }
                    Text{
                        text: stopIdShort
                        font.pixelSize: 35
                        color: config.textColor
                    }
                }
                Row {
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.left: parent.left
                    spacing: 20
                    Text{
                        text: stopAddress
                        font.pixelSize: 20
                        color: config.textColor
                        width: 340
                    }
                    Text{
                        text: stopCity
                        font.pixelSize: 20
                        color: config.textColor
                    }
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    recentList.focus = true
                    recentList.currentIndex = index
                    searchString = recentModel.get(index).stopIdShort
                    showMapButtonButton.visible = true
                    fillInfoModel()
                    fillLinesModel()
                    if (config.networking < 1) {
                        showError("Offline networking mode enabled. Change networking mode in settings.")
                        console.log("stop: " + recentModel.get(recentList.currentIndex).stopName+ "; id:" + recentList.currentIndex)
                        stopName.text = recentModel.get(recentList.currentIndex).stopName
                        stopAddress.text = recentModel.get(recentList.currentIndex).stopAddress
                        stopCity.text = recentModel.get(recentList.currentIndex).stopCity
                        dataRect.visible = true
                        loadingMap.visible = false
                        showMapButtonButton.visible = true
                    } else {
                        updateSchedule()
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        recentList.focus = true
                        recentList.currentIndex = index
                    }
                }
                onPressAndHold: {
                    recentStopsContextMenu.open()
                }
            }
        }
    }
    ListModel {     // traffic Model (Time depart; Line No)
        id:trafficModel
        ListElement {
            departTime: "Time"
            departLine: "Line"
            departDest: "Destination"
            departCode: "JORE code"
        }
    }
    Component {     // traffic delegate
        id:trafficDelegate
        Item {
            width: grid.cellWidth; height:  grid.cellHeight;
            Row {
                spacing: 10;
                anchors.fill: parent;
                Text{
                    text: departTime
                    font.pixelSize: 25
                    color: trafficModel.get(grid.currentIndex).departLine == departLine ? (grid.currentIndex == index ? config.highlightColor : config.highlightColor) : config.textColor
                }
                Text{
                    text: departLine
                    font.pixelSize: 25
                    color: trafficModel.get(grid.currentIndex).departLine == departLine ? (grid.currentIndex == index ? config.highlightColor : config.highlightColor) : config.textColor
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    grid.currentIndex = index;
                    grid.focus = true;
                    showError("Destination :  " + departDest)
                }
                onPressAndHold: {
		    grid.currentIndex = index
		    lineContext.open()
		}
            }
        }
    }
    ListModel {     // stop info model
        id:infoModel
        ListElement {
            propName: ""
            propValue: ""
        }
    }
    Component {     // stop info delegate
        id: infoDelegate
        Item {
            width: list.width
            height: 50
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Text{
                    text: propName
                    font.pixelSize: 30
                    color: config.textColor
                    width: 400
                }
                Text{
                    text: propValue
                    font.pixelSize: 30
                    color: config.textColor
                }
            }
        }
    }
    ListModel {     // lines passing model
        id: linesModel
        ListElement {
            lineNumber: ""
            lineDest: ""
        }
    }
    Component {     // lines passing delegate
        id: linesDelegate
        Item {
            width: list.width
            height: 50
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Text{
                    text: lineNumber
                    font.pixelSize: 30
                    color: config.textColor
                    width: 140
                }
                Text{
                    text: lineDest
                    font.pixelSize: 30
                    color: config.textColor
                }
            }
        }
    }
    Component {     // lines passing header Header
        id: linesHeader
        Item {
            width: recentList.width
            height: 40
            Row {
                anchors.left: parent.left
                spacing: 20
                Text{  // line
                    text: "Line"
                    font.pixelSize: 35
                    color: config.textColor
                    width: 140
                }
                Text{  // line
                    text: "Destination"
                    font.pixelSize: 35
                    color: config.textColor
                }
            }
        }
    }
    Item {     // grid rect
        id: infoRect
        anchors.top: tabRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        GridView {  // stopSchedule grid
            id: grid
            anchors.fill:  parent
            anchors.topMargin: 10
            delegate: trafficDelegate
            model: trafficModel
            focus: true
            cellWidth: 160
            cellHeight: 30
            width: parent.width
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
            currentIndex: 0
            clip: true
            visible: false
            flow: GridView.TopToBottom
        }
        ListView {  // stop info list
            id: list
            visible: false
            anchors.fill: parent
            anchors.topMargin: 10
            delegate:  infoDelegate
            model: infoModel
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
            currentIndex: -1
            clip: true
        }
        ListView {  // recentList
            id: recentList
            visible: true
            spacing: 10
            anchors.fill: parent
            anchors.topMargin: 10
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
            currentIndex: -1
            clip: true
        }
        ListView {  // lines passing
            id: linesList
            visible: false
            anchors.fill: parent
            anchors.topMargin: 10
            delegate:  linesDelegate
            model: linesModel
            header: linesHeader
            highlight: Rectangle { color:config.highlightColorBg; radius:  5 }
            currentIndex: -1
            clip: true
        }
    }
/*<----------------------------------------------------------------------->*/
    function checkFavorites() { // database API use here TODO
        removeFavoriteTool.visible = true;
    }
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function parseResponse(a) { // parsing plaintext table | fetching schedule
        var schedText = new String;
        schedText = a;
        var schedule = new Array;
        var lines = new Array;
        var time_ = Array

        grid.currentIndex = 0
        schedule = schedText.split("\n")
        lines = schedule[0].split("|")
        stopName.text = lines[1]
        stopAddress.text = lines[2]
        stopCity.text = lines[3]
        for (var ii = 1; ii < schedule.length-1; ii++) {
            lines = schedule[ii].split("|")
            time_[0] = lines[0].slice(0,lines[0].length -2)
            time_[1] = lines[0].slice(lines[0].length-2,lines[0].length)
            if (time_[0] > 23) time_[0]-=24
            trafficModel.append({ "departTime" : ""+time_[0]+":"+time_[1], "departLine" : "" + lines[1], "departDest" : lines[2], "departCode" : lines[3] })
        }
        loading.visible = false
        grid.focus = true
        grid.visible = true
        list.visible = false
        recentList.visible = false
        dataRect.visible = true
    }
    function getSchedule() {    // Use Api v1.0 to get just schedule - less data traffic, more departures in one reply
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                if (doc.responseText.slice(0,5) == "Error") {
                    showError("Schedule ERROR. Server returned error for Stop ID:"+searchString)
                    return
                } else {
                    parseResponse(doc.responseText)
                }
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showError("Request error. Is Network available?")
            }
        }
        //              API 1.0 (plaintext) : faster, more informative
        doc.open("GET", "http://api.reittiopas.fi/public-ytv/fi/api/?stop="+ searchString+"&user=byako&pass=gfccdjhl");
        loading.visible = true
        doc.send();
    }
    function parseInfo(a) {     // Stop info parsing
        var lonlat = Array
        var coords = String
        infoModel.clear()
        for (var ii = 0; ii < a.childNodes.length; ++ii) {
            stopAddString += a.childNodes[ii].childNodes[0].firstChild.nodeValue
            stopAddString += ";"
            stopAddString += a.childNodes[ii].childNodes[1].firstChild.nodeValue
            stopAddString += ";"
            stopAddString += a.childNodes[ii].childNodes[2].firstChild.nodeValue
            stopAddString += ";"
            stopAddString += stopAddress.text
            stopAddString += ";"
            stopAddString += a.childNodes[ii].childNodes[4].firstChild.nodeValue
            stopAddString += ";"
            coords = a.childNodes[ii].childNodes[8].firstChild.nodeValue
            lonlat = coords.split(",")
            stopAddString += lonlat[0]
            stopAddString += ";"
            stopAddString += lonlat[1]
            stopAddString += ";"
            linesModel.clear()
            JS.__db().transaction(  // stop lines
                function(tx) {
                    for (var cc=0;cc<a.childNodes[ii].childNodes[6].childNodes.length;++cc) {
                       try {
                           lonlat = a.childNodes[ii].childNodes[6].childNodes[cc].firstChild.nodeValue.split(":");
                           tx.executeSql("INSERT INTO stopLines VALUES(?,?,?)", [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                                                 lonlat[0],lonlat[1]])
                           linesModel.append({"lineNumber":lonlat[0],"lineDest":lonlat[1]})
                        }
                        catch(e) {
                            console.log("stopInfo: Exception during pushing stopLines: CC = " + cc)
                        }
                    }
                }
            )
            JS.__db().transaction(  // stop info
                function(tx) {
                    for (var oo=0;oo<a.childNodes[ii].childNodes[9].childNodes.length;++oo) {
                        try{
                            infoModel.append({"propName" : a.childNodes[ii].childNodes[9].childNodes[oo].nodeName,
                                         "propValue" : a.childNodes[ii].childNodes[9].childNodes[oo].firstChild.nodeValue})
                            tx.executeSql("INSERT INTO stopInfo VALUES(?,?,?)", [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                                                 a.childNodes[ii].childNodes[9].childNodes[oo].nodeName,
                                                                                 a.childNodes[ii].childNodes[9].childNodes[oo].firstChild.nodeValue])
                        }
                        catch(e) { console.log("stopInfo: parsing stop info : " + e) }
                    }
                 }
            )
            searchString = a.childNodes[ii].childNodes[0].firstChild.nodeValue
            showMapButtonButton.visible = true
            coords = JS.addStop(stopAddString)
            stopAddString = ""
            if (coords == 1) {
                showError("Saved stop info: " + stopName.text)
                fillModel()
            } else if (coords == -1) {
                showError("ERROR. Stop is not added. Sorry")
            }
        }
        loadingMap.visible = false
    }
    function getInfo() {        // Use Api v2.0 - more informative about the stop itself, conditions, coordinates
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                parseInfo(doc.responseXML.documentElement)
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showError("Request error. Is Network available?")
            }
        }
//              API 2.0 (XML) : slower
        doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=stop&code=" + searchString + "&user=byako&pass=gfccdjhl&format=xml")
        doc.send();
    }
    function buttonClicked() {  // SearchBox actioncommander keen
        if (searchString == "" || searchString.length > 7 || searchString.length < 4) {
            showError("Wrong stop ID:"+searchString+".\nStop ID is 4 digit or 1 letter & 4 digits. Example: E3127")
            return;
        }
        if (config.networking < 1) {
            offlineModeOff.open();
            return
        }
        infoModel.clear()
        getInfo()
        updateSchedule()
        fillModel()
        showMapButtonButton.visible = false
    }
    function updateSchedule() { // update only schedule
        trafficModel.clear()
        getSchedule()
        tabRect.checkedButton = stopSchedule
    }
    function fillModel() {      // checkout recent stops from database
        recentModel.clear();
        JS.__db().transaction(
            function(tx) {
                     var rs = tx.executeSql("SELECT * FROM Stops ORDER BY stopName ASC");
                     recentModel.clear();
                     if (rs.rows.length > 0) {
                         for (var i=0; i<rs.rows.length; ++i) {
                                 recentModel.append(rs.rows.item(i))
                         }
                     }
                 }
        )
    }
    function fillInfoModel() {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql("SELECT option,value FROM StopInfo WHERE stopIdLong=?",[recentModel.get(recentList.currentIndex).stopIdLong]); }
                catch(e) { console.log("FillInfoModel EXCEPTION: " + e) }
                infoModel.clear();
                for (var i=0; i<rs.rows.length; ++i) {
                    infoModel.append({"propName" : rs.rows.item(i).option,
                                      "propValue" : rs.rows.item(i).value})
                }
            }
        )
    }
    function fillLinesModel() {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {  // TODO
                try { var rs = tx.executeSql("SELECT lineIdLong, lineEnd FROM StopLines WHERE stopIdLong=?",[recentModel.get(recentList.currentIndex).stopIdLong]); }
                catch(e) { console.log("FillInfoModel EXCEPTION: " + e) }
                linesModel.clear();
                for (var i=0; i<rs.rows.length; ++i) {
                    linesModel.append({"lineNumber" : rs.rows.item(i).lineIdLong,
                                      "lineDest" : rs.rows.item(i).lineEnd})
                }
            }
        )
    }
    function setCurrent() {     // stop info request from lineInfo:stopReach
        if (loadStop != "") {
             JS.__db().transaction(
                 function(tx) {
                        try { var rs = tx.executeSql("SELECT * FROM Stops WHERE stopIdLong=?", [loadStop]) }
                        catch(e) { console.log("exception : "+e) }
                        if (rs.rows.length > 0) {
                            searchString = rs.rows.item(0).stopIdShort
                            showMapButtonButton.visible = true
                            infoModel.clear()
                            updateSchedule()
                        } else {
                            searchString = loadStop
                            buttonClicked()
                        }
                 }
             )
        }
    }
    function switchToMap() {    // ContextMenu map item action
        var retVal = 0
        JS.__db().transaction(
            function(tx) {
                try {
                    var rs = tx.executeSql("SELECT lineIdLong FROM Lines where lineIdLong=?",[trafficModel.get(grid.currentIndex).departCode])
                    if (rs.rows.length > 0) {
                        showError("Loading line info...")
                    } else {
                        retVal = 1
                    }
                }
                catch(e) {
                    console.log("stopInfo: " + e)
                }
            }
        )
        if (retVal != 0) { // get new line info
            pageStack.push(Qt.resolvedUrl("lineInfo.qml"),{"loadLineMap":trafficModel.get(grid.currentIndex).departCode});
        } else { // just open map
            pageStack.push(Qt.resolvedUrl("route.qml"),{"loadLine":trafficModel.get(grid.currentIndex).departCode});
        }
    }

/*<----------------------------------------------------------------------->*/
}
