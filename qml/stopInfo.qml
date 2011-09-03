import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0
import "lineInfo.js" as JS

Page {
    id: stopInfoPage
    tools: commonTools
    HrtmConfig {id: config}
    objectName: "stopInfoPage"
    property string longit: ""
    property string latit: ""
    property string stopAddString: ""
    orientationLock: PageOrientation.LockPortrait
    Component.onCompleted: { infoModel.clear(); trafficModel.clear(); fillModel(); }
    Rectangle{      // dark background
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
    }
    Label{          // error label
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
            color: "#7090AA"
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
    Rectangle{      // Data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  searchBox.bottom
        anchors.topMargin: 10
        anchors.right: parent.right
        height: 120
        width: parent.width
        color: config.bgColor
        radius: 10
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

    ListModel{      // recent stops list
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
    Component{      // recent stops delegate
        id: recentDelegate
        Rectangle {
            width: recentList.width
            height: 70
            radius: 20
            color: "#333333"
            Column {
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                height: parent.height
                width: parent.width
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 20
                    Text{
                        text: stopName
                        font.pixelSize: 30
                        color: config.textColor
                    }
                    Text{
                        text: stopIdShort
                        font.pixelSize: 30
                        color: config.textColor
                    }
                }
                Row {
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.right: parent.right
                    spacing: 20
                    Text{
                        text: stopAddress
                        font.pixelSize: 30
                        color: config.textColor
                    }
                    Text{
                        text: stopCity
                        font.pixelSize: 30
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
                    buttonClicked()
                }
            }
        }
    }
    ListModel{      // traffic Model (Time depart; Line No)
        id:trafficModel
        ListElement {
            departTime: "Time"
            departLine: "Line"
        }
    }
    Component{      // traffic delegate
        id:trafficDelegate
        Item {
            width: grid.cellWidth; height:  grid.cellHeight;
            Row {
                spacing: 10;
                anchors.fill: parent;
                Text{
                    text: departTime
                    font.pixelSize: 25
                    color: trafficModel.get(grid.currentIndex).departLine == departLine ? "#00FF00" : config.textColor
                }
                Text{ text: departLine; font.pixelSize: 25; color: config.textColor}
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
    ListModel{      // stopInfo
        id:infoModel
        ListElement {
            propName: ""
            propValue: ""
        }
    }
    Component{      // stop info delegate
        id: infoDelegate
        Rectangle {
            width: list.width
            height: 50
            radius: 10
            color: config.bgColor
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


    Rectangle{      // grid rect
        id: infoRect
        anchors.top: tabRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: config.bgColor
        radius: 10
        GridView {  // stopSchedule grid
            id: grid
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            delegate: trafficDelegate
            model: trafficModel
            focus: true
            cellWidth: 155
            cellHeight: 30
            width: 420
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: 0
            clip: true
            visible: false
        }
        ListView {  // stop info list
            id: list
            visible: false
            anchors.fill: parent
            anchors.topMargin: 10
            delegate:  infoDelegate
            model: infoModel
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: 0
            clip: true
        }
        ListView {  // recentList
            id: recentList
            visible: true
            spacing: 10
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: 0
            clip: true
        }
    } // grid rect end

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
    function showError(text) {  // show popup splash window with error
        //here comes da error show windows with da text
    }
    function getSchedule() {    // Use Api v1.0 to get just schedule - less data traffic, more departures in one reply
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                if (doc.responseText.slice(0,5) == "Error") {
                    showError("Error. Wrong stop ID ?")
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
        console.log("parseInfo invoked")
        console.log(""+a)
        infoModel.clear()
        for (var ii = 0; ii < a.childNodes.length; ++ii) {
//            switch(a.childNodes[ii].childNodes[2].firstChild.nodeValue) {
/*            lineInfoModel.append({"" : "" + a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                "lineShortCode" : ""+a.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                 "direction" : "" + a.childNodes[ii].childNodes[3].firstChild.nodeValue + " -> " + a.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                 "type" : ""+lineType,
                                 "typeCode" : "" + a.childNodes[ii].childNodes[2].firstChild.nodeValue
                                 });*/
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
            stopAddString += lonlat[1]
            stopAddString += ";"
            longit = lonlat[0]
            latit = lonlat[1]
            console.log("longit: "+lonlat[0]+"; atitit: "+lonlat[1])
            showMapButtonButton.visible = true
            JS.addStop(stopAddString)
            stopAddString = ""
        }
    }
    function getInfo() {        // Use Api v2.0 - more informative about the stop itself, conditions, coordinates
        console.log("getInfo invoked")
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                parseInfo(doc.responseXML.documentElement)
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                showError("Request error. Is Network available?")
            }
        }
//              API 2.0 (XML) : slower
        doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=stop&code=" + stopId.text + "&user=byako&pass=gfccdjhl&format=xml")
        doc.send();
    }
    function buttonClicked() {  // SearchBox action
        if (stopId.text == "" || stopId.text.length > 7 || stopId.text.length < 4) {
            showError("Wrong stop ID format")
            return;
        }
        trafficModel.clear()
        infoModel.clear()
        errorLabel.visible = false
        searchButton.focus = true
        getInfo()
        getSchedule()
        tabRect.checkedButton = stopSchedule
        fillModel()
    }
    function fillModel() {
             JS.__db().transaction(
                 function(tx) {
//                     __ensureTables(tx);
                     var rs = tx.executeSql("SELECT * FROM Stops ORDER BY stopName ASC");
                     recentModel.clear();
                     if (rs.rows.length > 0) {
                         for (var i=0; i<rs.rows.length; ++i) {
                                 recentModel.append(rs.rows.item(i))
                             console.log("model-append: " + rs.rows.item(i).stopIdShort + ";" + rs.rows.item(i).stopCity)
                         }
                     }
                 }
             )
         }
/*<----------------------------------------------------------------------->*/
}
