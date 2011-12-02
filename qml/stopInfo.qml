import QtQuick 1.1
import com.nokia.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.0

Item {
    id: stopInfoPage
    objectName: "stopInfoPage"
    property string searchString: ""    // keep stopIdLong here. If stopIdShort supplied (request from lineInfo) -> remove and place stopIdLong
    property int selectedStopIndex: -1
    property bool exactSearch: false

    signal showStopMap(string stopIdLong)
    signal showStopMapLine(string stopIdLong, string lineIdLong)
    signal showLineMap(string lineIdLong)
    signal showLineInfo(string lineIdLong)
    width: 480
    height: 745

    Config { id: config }
    WorkerScript {           // quick search stops by name for non-exact search. Using geocoding.
        id: stopsLookup
        source: "stopSearch.js"
        onMessage: {
            if (messageObject.stopIdShort != "FINISHED") {
                console.log("WORKER SENT stopIdShort: " + messageObject.stopIdShort)
                showError("Got info: " + messageObject.stopIdLong + " "
                          + messageObject.stopIdShort + " "
                          + messageObject.stopName + " "
                          + messageObject.stopCity + " "
                          + messageObject.stopLongitude + " "
                          + messageObject.stopLatitude)
            } else {
                console.log("stopInfo geocode API FINISHED request " + searchString);
            }
        }
    }
    WorkerScript {           // load stop info from wev to database
        id: loadStopInfo
        source: "stopInfoLoadInfo.js"
        onMessage: {
            if (messageObject.action == "SAVED") {
                loadingMap.visible = false
                searchString = messageObject.stopIdLong
                console.log("WORKER SENT stopIdLong: setting searchString = " + messageObject.stopIdLong)
                infoModel.clear()
                linesModel.clear()
                fillModel()
                fillLinesModel()
                fillInfoModel()
                showError("Saved stop information")
            } else if (messageObject.action == "ERROR") {
                showError("Server returned ERROR");
            } else if (messageObject.action == "FAILED") {
                showError("Couldn't open information")
            }
        }
    }
    WorkerScript {           // fast schedule loader: API 1.0
        id: loadStopSchedule
        source: "stopInfoScheduleLoad.js"
        onMessage: {
            if (messageObject.departName == "STOPNAME") {
                stopName.text = messageObject.stopName
                stopAddress.text = messageObject.stopAddress
                stopCity.text = messageObject.stopCity
            } else if (messageObject.departName == "ERROR") {
                showError("Server returned ERROR")
                loading.visible = false
                loadingMap.visible = false
                dataRect.visible = false
            } else if (messageObject.departName == "FINISHED"){
                loading.visible = false
            } else {
                trafficModel.append({"departTime" : messageObject.departTime,
                                     "departLine" : messageObject.departLine,
                                     "departDest" : messageObject.departDest,
                                     "departCode" : messageObject.departCode,})
            }
        }
    }

    Component.onCompleted: { refreshConfig(); infoModel.clear(); fillModel(); setCurrent();    }

    Loading {                   // busy indicator
        id: loading
        visible: false
        anchors.fill: parent
        z: 8
    }
/*    QueryDialog {            // offline dialog
        id: offlineModeOff
        acceptButtonText: "Go online"
        rejectButtonText: "Keep offline"
        message: "Offline mode enabled.\nGo online?\n(Data charges may apply)"
        titleText: "Offline mode"
        onAccepted: {
            getInfo()
            updateSchedule()
        }
        onRejected: {
            console.log("User declined to go online")
        }
    }*/
    InfoBanner {             // info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    ContextMenu {            // recent stops context menu
        id: recentStopsContextMenu
        MenuLayout {
            MenuItem {
                text: "Delete"
                onClicked: {
                    if (JS.deleteStop(recentModel.get(stopsView.currentIndex).stopIdLong) == 0) {
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
    ContextMenu {            // depart line context menu
        id: lineContext
        MenuLayout {
            MenuItem {
                text: "Line Info"
                onClicked : stopInfoPage.showLineInfo(trafficModel.get(scheduleView.currentIndex).departCode);
            }
            MenuItem {
                text: "Line Map"
                onClicked : stopInfoPage.showStopMapLine(searchString, trafficModel.get(scheduleView.currentIndex).departCode)
            }
        }
    }
    ContextMenu {            // passing line context menu
        id: linesPassingContext
        MenuLayout {
            MenuItem {
                text: "Line Info"
                onClicked : stopInfoPage.showLineInfo(linesModel.get(linesView.currentIndex).lineNumber);
            }
            MenuItem {
                text: "Line Map"
                onClicked : stopInfoPage.showStopMapLine(searchString, linesModel.get(linesView.currentIndex).lineNumber);
            }
        }
    }
    Rectangle {              // dark background
        color: "#000000";
        anchors.fill: parent
        width: parent.width
        height:  parent.height
//        Image { source: config.bgImage ; fillMode: Image.Center; anchors.fill: parent; }
    }
    Item {                   // Data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  parent.top
        anchors.right: parent.right
        height: 120
        visible: false
        Item {          // showMapButton
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.top: parent.top
                height: 60
                width: 60
                Button { // showMapButton
                    style: ButtonStyle {
                        inverted: true
                    }
                    id: showMapButton
                    anchors.fill: parent
                    text: "M"
                    visible:  ! loadingMap.visible
                    onClicked: {
//                        if (scheduleView.visible && scheduleView.currentIndex >= 0) {
//                            stopInfoPage.showStopMapLine(searchString, trafficModel.get(scheduleView.currentIndex).departCode)
//                        } else if (linesView.visible && linesView.currentIndex >=0 ) {
//                            stopInfoPage.showStopMapLine(searchString, linesModel.get(linesView.currentIndex).lineNumber)
//                        } else {
                            stopInfoPage.showStopMap(searchString)
//                        }
                    }
                }
                BusyIndicator{// loading spinner
                    id: loadingMap
                    style: BusyIndicatorStyle { inverted: true }
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    running: true
                    visible: false
                    z: 8
                }
            }
        Item {          // favorite
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottom: parent.bottom
                height: 60
                width: 60
                Button { // favorite
                    style: ButtonStyle {
                        inverted: true
                    }
                    id: favoriteButton
                    anchors.fill: parent
                    iconSource: (recentModel.get(selectedStopIndex).favorite == "true") ? "image://theme/icon-m-toolbar-favorite-mark-white" : "image://theme/icon-m-toolbar-favorite-unmark-white"
                    onClicked: {
                        if (recentModel.get(selectedStopIndex).favorite == "true") {
                            setFavorite(searchString, "false")
                            recentModel.set(selectedStopIndex, {"favorite":"false"})
                        } else {
                            setFavorite(searchString, "true")
                            recentModel.set(selectedStopIndex, {"favorite":"true"})
                        }
                    }
                }
        }
        Column {            // data labels
            Row {
                Label {
                    id: stopNameLabel
                    text: qsTr("Name")
                    color: "#cdd9ff"
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopName;
                    text: qsTr("Name")
                    color: "#cdd9ff"
                    font.pixelSize: 30
                }
            }
            Row {
                Label {
                    id: stopAddressLabel
                    text: qsTr("Address")
                    color: "#cdd9ff"
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopAddress;
                    text: qsTr("Address")
                    color: "#cdd9ff"
                    font.pixelSize: 30
                }
            }
            Row {
                Label {
                    id: stopCityLabel;
                    text: qsTr("City")
                    color: "#cdd9ff"
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopCity;
                    text: qsTr("City")
                    color: "#cdd9ff"
                    font.pixelSize: 30
                }
            }
        }
    }
    ButtonRow {              // tabs rect
        id: tabRect
        enabled: loading.visible == true ? false : true
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        style: TabButtonStyle {
            inverted: true
        }
        Button {
            id: recentButton
            text: "Saved"
            onClicked: {
                if (stopsView.visible == false) {
                    if (stopsView.currentIndex != selectedStopIndex) {
                        stopsView.currentIndex = selectedStopIndex
                    }
                    linesView.visible = false
                    infoView.visible = false
                    scheduleView.visible = false
                    stopsView.visible = true
                }
            }
        }
        Button {
            id: stopSchedule
            text: "Schedule"
            onClicked: {
                if (scheduleView.visible == false) {
                    linesView.visible = false
                    scheduleView.visible = true
                    infoView.visible = false
                    stopsView.visible = false
                }
            }
        }
        Button {
            id: stopLines
            text: "Lines"
            onClicked: {
                if (linesView.visible == false) {
                    linesView.visible = true
                    scheduleView.visible = false
                    infoView.visible = false
                    stopsView.visible = false
                }
            }
        }
        Button {
            id: stopInfo
            text: "Info"
            onClicked: {
                if (infoView.visible == false) {
                    linesView.visible = false
                    infoView.visible = true
                    scheduleView.visible = false
                    stopsView.visible = false
                }
            }
        }
    }
/*<----------------------------------------------------------------------->*/
    ListModel {              // recent stops list
        id: recentModel
//        ListElement {
//            stopIdLong: ""
//            stopIdShort: ""
//            stopName: ""
//            stopAddress: ""
//            stopCity: ""
//            stopLongitude: ""
//            stopLatitude: ""
//        }
    }
    Component {              // recent stops delegate
        id: recentDelegate
        Item {
            width: stopsView.width
            height: 70
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
                        color: "#cdd9ff"
                        width: 340
                    }
                    Text{
                        text: stopIdShort
                        font.pixelSize: 35
                        color: "#cdd9ff"
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
                        color: "#cdd9ff"
                        width: 340
                    }
                    Text{
                        text: stopCity
                        font.pixelSize: 20
                        color: "#cdd9ff"
                    }
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    if (selectedStopIndex != index) {
                        selectedStopIndex = index
                        stopsView.currentIndex = index
                        searchString = recentModel.get(index).stopIdLong
                        showMapButton.visible = true
                        fillInfoModel()
                        fillLinesModel()
                        stopName.text = recentModel.get(stopsView.currentIndex).stopName
                        stopAddress.text = recentModel.get(stopsView.currentIndex).stopAddress
                        stopCity.text = recentModel.get(stopsView.currentIndex).stopCity
                        dataRect.visible = true
                        showMapButton.visible = true
                        updateSchedule()
                    }
                }
                onPressAndHold: {
                    stopsView.currentIndex = index
                    recentStopsContextMenu.open()
                }
            }
        }
    }
    ListModel {              // traffic Model (Time depart; Line No)
        id:trafficModel
//        ListElement {
//            departTime: "Time"
//            departLine: "Line"
//            departDest: "Destination"
//            departCode: "JORE code"
//        }
    }
    Component {              // traffic delegate
        id:trafficDelegate
        Item {
            width: scheduleView.cellWidth; height:  scheduleView.cellHeight;
            Row {
                spacing: 10;
                Text{
                    text: departTime
                    font.pixelSize: 25
                    color: trafficModel.get(scheduleView.currentIndex).departLine == departLine ? "#00ee10" : "#cdd9ff"
                }
                Text{
                    text: departLine
                    font.pixelSize: 25
                    color: trafficModel.get(scheduleView.currentIndex).departLine == departLine ? "#00ee10" : "#cdd9ff"
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    scheduleView.currentIndex = index;
                    showError("Destination :  " + departDest)
                }
                onPressAndHold: {
                    scheduleView.currentIndex = index
		    lineContext.open()
		}
                onDoubleClicked: {
                    stopInfoPage.showLineInfo(departCode)
                }
            }
        }
    }
    ListModel {              // stop info model
        id:infoModel
//        ListElement {
//            propName: ""
//            propValue: ""
//        }
    }
    Component {              // stop info delegate
        id: infoDelegate
        Item {
            width: infoView.width
            height: 50
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Text{
                    text: propName
                    font.pixelSize: 30
                    color: "#cdd9ff"
                    width: 400
                }
                Text{
                    text: propValue
                    font.pixelSize: 30
                    color: "#cdd9ff"
                }
            }
        }
    }
    ListModel {              // lines passing model
        id: linesModel
//        ListElement {
//            lineNumber: ""
//            lineDest: ""
//        }
    }
    Component {              // lines passing delegate
        id: linesDelegate
        Item {
            width: infoView.width
            height: 50
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Text{
                    text: lineNumber
                    font.pixelSize: 30
                    color: "#cdd9ff"
                    width: 140
                }
                Text{
                    text: lineDest
                    font.pixelSize: 30
                    color: "#cdd9ff"
                }
            }
            MouseArea{
                anchors.fill: parent
                onPressAndHold: { linesPassingContext.open() }
                onClicked: { linesView.currentIndex = index }
                onDoubleClicked: { stopInfoPage.showLineInfo(lineNumber) }
            }
        }
    }
    Component {              // lines passing header Header
        id: linesHeader
        Rectangle {
            width: stopsView.width
            height: 40
            color: "#222222"
            Row {
                anchors.verticalCenter : parent.verticalCenter
                anchors.left: parent.left
                spacing: 20
                Text{  // line
                    text: "Line"
                    font.pixelSize: 35
                    color: "#cdd9ff"
                    width: 140
                }
                Text{  // line
                    text: "Destination"
                    font.pixelSize: 35
                    color: "#cdd9ff"
                }
            }
        }
    }
    Item {                   // scheduleView rect
        id: infoRect
        anchors.top: tabRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        ListView {  // stopsView
            id: stopsView
            visible: true
            spacing: 10
            anchors.fill: parent
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:"#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
        GridView {  // stopSchedule grid
            id: scheduleView
            anchors.fill:  parent
            delegate: trafficDelegate
            model: trafficModel
            cellWidth: 160
            cellHeight: 30
            highlight: Rectangle { color: "#666666"; radius:  5 }
            currentIndex: 0
            clip: true
            visible: false
            flow: GridView.TopToBottom
        }
        ListView {  // lines passing
            id: linesView
            visible: false
            anchors.fill: parent
            delegate:  linesDelegate
            model: linesModel
            header: linesHeader
            highlight: Rectangle { color:"#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
        ListView {  // stop info infoView
            id: infoView
            visible: false
            anchors.fill: parent
            delegate:  infoDelegate
            model: infoModel
            highlight: Rectangle { color:"#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
    }
/*<----------------------------------------------------------------------->*/
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function getSchedule() {
        loading.visible = true
        loadStopSchedule.sendMessage({"searchString" : searchString})
        scheduleView.currentIndex = 0
        scheduleView.visible = true
        infoView.visible = false
        stopsView.visible = false
        dataRect.visible = true
    }
    function buttonClicked() {  // SearchBox action
        if (exactSearch) {
            updateSchedule()
            loadStopInfo.sendMessage({"searchString" : searchString})
            loadingMap.visible = true
        } else {
            stopsLookup.sendMessage({"searchString" : searchString})
        }
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
                    for (var i=0; i<rs.rows.length; ++i) {
                        recentModel.append(rs.rows.item(i))
                        if (rs.rows.item(i).stopIdLong == searchString) {
                             selectedStopIndex = i
                    }
                }
            }
        )
    }
    function fillInfoModel() {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql("SELECT option,value FROM StopInfo WHERE stopIdLong=?",[recentModel.get(selectedStopIndex).stopIdLong]); }
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
                try { var rs = tx.executeSql("SELECT lineIdLong, lineEnd FROM StopLines WHERE stopIdLong=?",[recentModel.get(selectedStopIndex).stopIdLong]); }
                catch(e) { console.log("FillLinesModel EXCEPTION: " + e) }
                linesModel.clear();
                for (var i=0; i<rs.rows.length; ++i) {
                    linesModel.append({"lineNumber" : rs.rows.item(i).lineIdLong,
                                      "lineDest" : rs.rows.item(i).lineEnd})
                }
            }
        )
    }
    function setFavorite(stopIdLong_,value) {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {  // TODO
                try { var rs = tx.executeSql("UPDATE Stops SET favorite=? WHERE stopIdLong=?",[value,stopIdLong_]); }
                catch(e) { console.log("stopInfo: setFavorite EXCEPTION: " + e) }
            }
        )
    }
    function setCurrent() {     // stop info request from lineInfo:stopReach
        if (searchString != "") {
             JS.__db().transaction(
                 function(tx) {
                     try { var rs = tx.executeSql("SELECT * FROM Stops WHERE stopIdLong=?", [searchString]) }
                     catch(e) { console.log("exception : "+e) }
                     if (rs.rows.length > 0) {
                         showMapButton.visible = true
                         infoModel.clear()
                         updateSchedule()
                     } else {
                         buttonClicked()
                     }
                 }
             )
        }
    }
    function refreshConfig() {
        JS.loadConfig(config)
    }
/*<----------------------------------------------------------------------->*/
}
