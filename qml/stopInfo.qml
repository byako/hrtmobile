import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
import "lineInfo.js" as JS
import com.nokia.extras 1.0

Page {
    id: stopInfoPage
    tools: commonTools
    MyQueryDialog {
        id: offlineModeOff
    }
    Item {
        id: config
        property string bgColor: ""
        property string textColor: ""
        property string highlightColor: ""
        property string bgImage: ""
        property string highlightColorBg: ""
    }
    objectName: "stopInfoPage"
    property string longit: ""
    property string latit: ""
    property string stopAddString: ""
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: { JS.loadConfig(config); infoModel.clear(); trafficModel.clear(); fillModel(); setCurrent(); }

    InfoBanner {
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
    Label {         // error label
        Rectangle{
            color: "#606060"
            radius: 10
            anchors.fill: parent
            width: parent.width
            height:  parent.height
        }
        id: errorLabel;
        text: qsTr("Error. Wrong stop ID ?")
        anchors.bottomMargin: 100
        anchors.centerIn: parent
        visible : false
        font.pixelSize: 30
        color: config.textColor
    }
    Item {          // Search box
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
            color: config.highlightColorBg
            radius: 15
            TextInput{
                id: stopId
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
                text: "Enter StopID"
            }
        }
       Button{
            id: searchButton
            anchors.right: parent.right
            anchors.top: parent.top
            text: qsTr("Show info")
            width: 200
            height: parent.height
            onClicked: buttonClicked()
        }
    }
    Rectangle {     // HR separator
        id: hrLineSeparator
        anchors.left: parent.left
        anchors.top: searchBox.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }
    Item {          // Data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  searchBox.bottom
        anchors.topMargin: 10
        anchors.right: parent.right
        height: 120
        width: parent.width
//        color: config.bgColor
//        radius: 10
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
                        console.log("Here comes da map:")
                        console.log("long: " + longit + "; lat: " + latit)
                        pushCoordinates()
                        pageStack.push(Qt.resolvedUrl("route.qml"))
                    }
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
            visible: false
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
            visible: false
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
            visible: false
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
        anchors.top: hrLineSeparator2.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
            Button {
                id: recentButton
                text: "Recent"
                onClicked: {
                    if (recentList.visible == false) {
                        list.visible = false
                        grid.visible = false
                        recentList.visible = true
                    }
                }
            }
            Button {
                id: stopInfo
                text: "Info"
                onClicked: {
                    if (list.visible == false) {
                        list.visible = true
                        grid.visible = false
                        recentList.visible = false
                    }
                }
            }
            Button {
                id: stopSchedule
                text: "Schedule"
                onClicked: {
                    if (grid.visible == false) {
                        grid.visible = true
                        list.visible = false
                        recentList.visible = false
                    }
                }
            }
    }
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
            color: "#333333"
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
                    stopId.text = recentModel.get(recentList.currentIndex).stopIdShort
                    latit = stopLatitude
                    longit = stopLongitude
                    showMapButtonButton.visible = true
                    infoModel.clear()
                    updateSchedule()
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
                    color: trafficModel.get(grid.currentIndex).departLine == departLine ? config.highlightColor : config.textColor
                }
                Text{ text: departLine; font.pixelSize: 25; color: config.textColor}
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    grid.currentIndex = index;
                    grid.focus = true;
                }
                onPressAndHold: { lineContext.open() }
                onPressedChanged: {
                    if (pressed == true) {
                        grid.currentIndex = index;
                    }
                }
            }
        }
    }
    ListModel {     // stopInfo
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
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Text{
                    text: propName
                    font.pixelSize: 30
                    color: config.textColor
                }
                Text{
                    text: propValue
                    font.pixelSize: 30
                    color: config.textColor
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    list.focus = true
                    list.currentIndex = index
                }
            }
        }
    }
    ContextMenu {
        id: lineContext
        MenuLayout {
            MenuItem {
                text: "Info"
                onClicked : {
                    pageStack.push(Qt.resolvedUrl("lineInfo.qml"),{"loadLine":trafficModel.get(grid.currentIndex).departLine});
                }
            }
            MenuItem {
                text: "Map"
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
            cellWidth: 155
            cellHeight: 30
            width: 420
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
            currentIndex: 0
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
            currentIndex: 0
            clip: true
        }
    }

/*<----------------------------------------------------------------------->*/
    function checkFavorites() { // database API use here TODO
        removeFavoriteTool.visible = true;
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
        stopName.visible = true
        stopAddress.text = lines[2]
        stopAddress.visible = true
        stopCity.text = lines[3]
        stopCity.visible = true
        for (var ii = 1; ii < schedule.length-1; ii++) {
            lines = schedule[ii].split("|")
            time_[0] = lines[0].slice(0,lines[0].length -2)
            time_[1] = lines[0].slice(lines[0].length-2,lines[0].length)
            if (time_[0] > 23) time_[0]-=24
            trafficModel.append({ "departTime" : ""+time_[0]+":"+time_[1], "departLine" : "" + lines[1] })
        }
        grid.focus = true
        grid.visible = true
        list.visible = false
        recentList.visible = false
        dataRect.visible = true
        addFavoriteTool.visible = true
    }
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function getSchedule() {    // Use Api v1.0 to get just schedule - less data traffic, more departures in one reply
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                if (doc.responseText.slice(0,5) == "Error") {
                    showError("Schedule ERROR. Server returned error for Stop ID:"+stopId.text)
                    return
                } else {
                    parseResponse(doc.responseText)
                }
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showError("Request error. Is Network available?")
            }
        }
        //              API 1.0 (plaintext) : faster, more informative
        doc.open("GET", "http://api.reittiopas.fi/public-ytv/fi/api/?stop="+ stopId.text +"&user=byako&pass=gfccdjhl");
        doc.send();
    }
    function parseInfo(a) {     //
        var lonlat = Array;
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
            infoModel.append({"propName" : "longitude" , "propValue" : lonlat[0]})
            stopAddString += lonlat[0]
            stopAddString += ";"
            infoModel.append({"propName" : "latitude" , "propValue" : lonlat[0]})
            for (var oo=0;oo<a.childNodes[ii].childNodes[9].childNodes.length;++oo) {
                try{
                    infoModel.append({"propName" : a.childNodes[ii].childNodes[9].childNodes[oo].nodeName,
                                     "propValue" : a.childNodes[ii].childNodes[9].childNodes[oo].firstChild.nodeValue})
                }
                catch(e) {
                    console.log("stopInfo: infoModel.append exception happened")
                }
            }

            stopAddString += lonlat[1]
            stopAddString += ";"
            longit = lonlat[0]
            latit = lonlat[1]
            showMapButtonButton.visible = true
            coords = JS.addStop(stopAddString)
            stopAddString = ""
            if (coords == 1) {
                infoBanner.text = "Added stop " + stopName.text
                infoBanner.show()
            } else if (coords == -1) {
                infoBanner.text = "ERROR. Stop is not added. Sorry"
                infoBanner.show()
            }

            fillModel()
        }
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
        if (JS.getCurrent("offline") == "true") {
            offlineModeOff.open();
            console.log("some shit happened")
            return
        }
        doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=stop&code=" + stopId.text + "&user=byako&pass=gfccdjhl&format=xml")
        doc.send();
    }
    function buttonClicked() {  // SearchBox actioncommander keen
        if (stopId.text == "" || stopId.text.length > 7 || stopId.text.length < 4) {
            showError("Wrong stop ID:"+stopId.text+".\nStop ID is 4 digit or 1 letter & 4 digits. Example: E3127")
            return;
        }
        infoModel.clear()
        getInfo()
        updateSchedule()
        fillModel()
        showMapButtonButton.visible = false
    }
    function updateSchedule() { // update only schedule
        trafficModel.clear()
        searchButton.focus = true
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
    function pushCoordinates() {
        JS.__db().transaction(
            function(tx) {
                tx.executeSql("INSERT INTO Current VALUES(?,?)",["setCurrentPosition","true"])
                tx.executeSql("INSERT INTO Current VALUES(?,?)",["longitude",longit])
                tx.executeSql("INSERT INTO Current VALUES(?,?)",["latitude",latit])
            }
        )
    }
    function setCurrent() {
             JS.__db().transaction(
                 function(tx) {
                    try {
                        var rs = tx.executeSql("SELECT option,value FROM Current WHERE option=?", ["setCurrentStop"])
                    } catch(e) {
                         console.log("EXCEPTION: " + e)
                    }
                    if (rs.rows.length > 0) {
                        rs = tx.executeSql("SELECT option,value FROM Current WHERE option=?", ["stopIdLong"])
                        var option = rs.rows.item(0).value  // this stopId we need to show
                        try {
                            rs = tx.executeSql("SELECT * FROM Stops WHERE stopIdLong=?", [option])
                        } catch(e) {
                            console.log("exception : "+e)
                        }
                        if (rs.rows.length > 0) {
                            stopId.text = rs.rows.item(0).stopIdShort
                            latit = rs.rows.item(0).stopLatitude
                            longit = rs.rows.item(0).stopLongitude
                            showMapButtonButton.visible = true
                            infoModel.clear()
                            updateSchedule()
                        } else {
                            stopId.text = option
                            searchButton.focus = true
                            buttonClicked()
                        }
                        tx.executeSql("DELETE FROM Current WHERE option=?", ["setCurrentStop"])
                        tx.executeSql("DELETE FROM Current WHERE option=?", ["stopIdLong"])
                    } else {
                        console.log("Didn't find setCurrentStop in DB")
                    }
                 }
             )
    }
/*<----------------------------------------------------------------------->*/
}
