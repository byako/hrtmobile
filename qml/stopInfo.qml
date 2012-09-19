import QtQuick 1.1
import com.nokia.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.1

Item {
    id: stopInfoPage
    objectName: "stopInfoPage"
    property string searchString: ""    // keep stopIdLong here. If stopIdShort supplied (request from lineInfo) -> remove and place stopIdLong
    property int selectedStopIndex: -1
    signal showStopMap(string stopIdLong)
    signal showStopMapLine(string stopIdLong, string lineIdLong)
    signal showLineMap(string lineIdLong)
    signal showLineInfo(string lineIdLong)
    signal refreshFavorites()
    width: 480
    height: 745

    Timer {
        id:flickTimer
        interval: 500
        onTriggered: {
            if (scheduleView.moving && trafficModel.count > 0) {
                if (scheduleView.atXBeginning && scheduleView.dragDirection == -1 && scheduleView.contentX < -25) {
//                    console.log("updating earlier:" );
                    earlierTime.visible = true;
                    earlierTime.text = scheduleView.contentX;
                } else if (scheduleView.atXEnd &&
                           scheduleView.contentX > scheduleView.contentWidth - 480 + 25) {
                    console.log("updating later");
                    laterTime.visible = true;
                    laterTime.text = trafficModel.get(trafficModel.count-1).departTime + "+";
                } else {
                    console.log("false alarm, not moving");
                }
            }
        }
    }

    Config { id: config }
    NickNameDialog { id:nickNameDialog }
    Component.onCompleted: { refreshConfig(); fillModel(); }
    Rectangle {              // dark background
        color: "#000000";
        anchors.fill: parent
        width: parent.width
        height:  parent.height
    }

    WorkerScript {           // quick search stops by name for non-exact search. Using geocoding.
        id: stopsLookup
        source: "stopSearch.js"
        onMessage: {
            if (messageObject.stopState == "SERVER_ERROR") {
                loading.visible = false
                searchString = ""
                showError("Could not find anything")
            } else if (messageObject.stopState == "saved" ) { // response for save request
                console.log("stopInfo.qml: stopSearch saved stop " + messageObject.stopIdLong + "; checking " + stopsView.model.count)
                for (var zz=0; zz < stopsView.model.count; ++zz) {
                    console.log("stopInfo.qml: " + zz + "; " + stopsView.model.get(zz).stopIdLong + ":" + messageObject.stopIdLong)
                    if (stopsView.model.get(zz).stopIdLong == messageObject.stopIdLong) {
                        console.log("stopInfo.qml: opening stop " + zz)
                        openStop(zz, messageObject.stopName)
                    }
                }
            } else if (messageObject.stopIdLong != "FINISHED") { // add everything to searchResultStopInfoModel
                console.log("stopInfo.qml: received from stopSearch.js: " + messageObject.stopIdLong + "; stopState: " + messageObject.stopState)
                searchResultStopInfoModel.append(messageObject)
            } else {
                console.log("stopInfo geocode API FINISHED request " + searchString);
                loading.visible = false
                searchString = ""
                stopsView.model = searchResultStopInfoModel
                recentButton.text = "Found"
                if (searchResultStopInfoModel.count == 1 && searchResultStopInfoModel.get(0).stopState == "offline")  { // if only one stop has been found - show it immediately without showing a list of found stops, it should have been saved already
                    openStop(0,"")
                }
            }
        }
    }
    WorkerScript {           // lines loader
        id: linesLoader
        source: "stopInfoLoadLines.js"
        onMessage: {
            if (messageObject.departName == "ERROR") {
                showError("Server returned ERROR")
            } else {
                linesModel.append(messageObject)
            }
        }
    }
    WorkerScript {           // Omatlahdot (My Departures)
        id: myDeparturesWorker
        source: "stopInfoMyDeparturesLoad.js"
        onMessage: {
            if (messageObject.depName == "ERROR") {
                showError("Server returned ERROR")
            } else {
                trafficModel.append(messageObject)
            }
        }
    }
    WorkerScript {           // fast schedule loader: API 1.0
        id: loadStopSchedule
        source: "stopInfoScheduleLoad.js"
        onMessage: {
            if (messageObject.departName == "ERROR") {
                showError("Server returned ERROR")
                loading.visible = false
            } else if (messageObject.departName == "FINISHED"){
                loading.visible = false
            } else {
                trafficModel.append({"departTime" : messageObject.departTime,
                                     "departLine" : messageObject.departLine,
                                     "departDest" : messageObject.departDest,
                                     "departCode" : messageObject.departCode})
            }
        }
    }

    Loading {                // busy indicator
        id: loading
        visible: false
        anchors.bottom: parent.bottom
        anchors.top: dataRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        z: 8
    }
    InfoBanner {             // info banner
        id: infoBanner
        text: ""
        z: 10
        opacity: 1.0
    }

    ContextMenu {            // recent stops context menu
        id: recentStopsContextMenu
        MenuLayout {
            MenuItem {
                text: "Alias / Nickname"
                onClicked: {
                    nickNameDialog.stopCodeAndName = recentModel.get(stopsView.currentIndex).stopIdShort +
                            " : " + recentModel.get(stopsView.currentIndex).stopName + "\n" +
                            recentModel.get(stopsView.currentIndex).stopAddress
                    if (recentModel.get(stopsView.currentIndex).NickName) {
                        nickNameDialog.oldNick = "" + recentModel.get(stopsView.currentIndex).NickName
                    }
                    nickNameDialog.open();
                }
                visible: (stopsView.model == recentModel ? true : false)
            }

            MenuItem { // delete stop
                text: "Delete stop"
                onClicked: {
                    JS.deleteStop(stopsView.model.get(stopsView.currentIndex).stopIdLong) // remove from database
                    if (stopsView.model.get(stopsView.currentIndex).favorite == "true" ) stopInfoPage.refreshFavorites() // check if favorites page needs to be refreshed
                    if (selectedStopIndex >= 0) {                          // if some stop is selected to view and dataRect shows data - mess with indexes
                        if (selectedStopIndex == stopsView.currentIndex) { // if removing selected stop - clean models, hide dataRect
                            stopsView.model.remove(stopsView.currentIndex)
                            if (stopsView.model == searchResultStopInfoModel) fillModel()
                            selectedStopIndex = -1
                            stopsView.currentIndex = -1
                            dataRect.visible = false
                            trafficModel.clear()
                            linesModel.clear()
                        } else if (selectedStopIndex > stopsView.currentIndex) {
                            selectedStopIndex -= 1
                        }
                            stopsView.model.remove(stopsView.currentIndex)
                            if (stopsView.model == searchResultStopInfoModel) fillModel()
                            stopsView.currentIndex = selectedStopIndex
                    } else {
                        stopsView.model.remove(stopsView.currentIndex)
                        if (stopsView.model == searchResultStopInfoModel) {
                            fillModel()
                        }
                        stopsView.currentIndex = -1
                    }
                }
            }
            MenuItem { // delete all stops
                text: "Delete all"
                onClicked: {
                    if (stopsView.model == recentModel) { // recent stops are shown: delete all except the favourites
                        JS.deleteAllStops()
                    } else {        // Found search results are shown : delete only those
                        for (var i2=0; i2 < searchResultStopInfoModel.count; ++i2) {
                            if (searchResultStopInfoModel.get(i2).favorite != "true" && searchResultStopInfoModel.get(i2).stopState == "offline") {
                                JS.deleteStop(searchResultStopInfoModel.get(i2).stopIdLong)
                            }
                        }
                        searchResultStopInfoModel.clear()
                    }
                    fillModel()     // reload recent stops model
                    stopsView.model = recentModel
                    recentButton.text = "Recent"
                    stopsView.currentIndex = -1
                    selectedStopIndex = -1
                    trafficModel.clear()
                    linesModel.clear()
                    dataRect.visible = false
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
                onClicked : stopInfoPage.showLineInfo(linesModel.get(linesView.currentIndex).lineIdLong);
            }
            MenuItem {
                text: "Line Map"
                onClicked : stopInfoPage.showStopMapLine(searchString, linesModel.get(linesView.currentIndex).lineIdLong);
            }
        }
    }

    Item {                   // Data Rect
        id: dataRect
        anchors.left: parent.left
        anchors.top:  parent.top
        anchors.right: parent.right
        height: 120
        visible: false
        Item {               // showMapButton
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.top: parent.top
                height: 60
                width: 60
                Button {    // showMapButton
                    style: ButtonStyle {
                        inverted: true
                    }
                    id: showMapButton
                    anchors.fill: parent
                    text: "M"
                    visible:  ! loadingMap.visible
                    onClicked: {
                            stopInfoPage.showStopMap(searchString)
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
        Item {               // favorite
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
                    iconSource: (selectedStopIndex < 0) ? "" : (stopsView.model.get(selectedStopIndex).favorite == "true") ? "image://theme/icon-m-toolbar-favorite-mark-white" : "image://theme/icon-m-toolbar-favorite-unmark-white"
                    onClicked: {
                        if (stopsView.model.get(selectedStopIndex).favorite == "true") {
                            setFavorite(searchString, "false")
                            stopsView.model.set(selectedStopIndex, {"favorite":"false"})
                        } else {
                            setFavorite(searchString, "true")
                            stopsView.model.set(selectedStopIndex, {"favorite":"true"})
                        }
                        stopInfoPage.refreshFavorites()
                    }
                }
        }
        Column {             // data labels
            Row {            // stop name labels
                Label {
                    id: stopNameLabel
                    text: qsTr("Name")
                    color: "#cdd9ff"
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopNameValue;
                    text: qsTr("Name")
                    color: "#cdd9ff"
                    font.pixelSize: 30
                }
            }
            Row {            // stop address labels
                Label {
                    id: stopAddressLabel
                    text: qsTr("Address")
                    color: "#cdd9ff"
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopAddressValue;
                    text: qsTr("Address")
                    color: "#cdd9ff"
                    font.pixelSize: 30
                }
            }
            Row {            // stop city labels
                Label {
                    id: stopCityLabel;
                    text: qsTr("City")
                    color: "#cdd9ff"
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopCityValue;
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
            text: "Recent"
            onClicked: {
                if (stopsView.currentIndex != selectedStopIndex) { stopsView.currentIndex = selectedStopIndex }
                if (infoRect.state != "stopsSelected") {
                    infoRect.state = "stopsSelected"
                } else if (stopsView.model != recentModel) {
                    searchString = ""
                    fillModel()
                    stopsView.model = recentModel
                    text="Recent"
                    searchResultStopInfoModel.clear()
                    dataRect.visible = false
                } else if (searchResultStopInfoModel.count > 0){
                    stopsView.model = searchResultStopInfoModel
                    text="Found"
                } else {
                    fillModel()
                }
            }
        }
        Button {
            id: stopSchedule
            text: "Schedule"
            onClicked: {
                infoRect.state = "scheduleSelected"
            }
        }
        Button {
            id: stopLines
            text: "Lines"
            onClicked: {
                infoRect.state = "linesSelected"
            }
        }
    }
/*<----------------------------------------------------------------------->*/
    ListModel {              // search result stopInfo list model
        id:searchResultStopInfoModel
    }
    ListModel {              // recent stops list
        id: recentModel
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
                        text: (NickName == "" ? stopName : NickName )
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
                    if (stopsView.model == recentModel || stopState == "offline") {
                        console.log("stopInfo.qml: opening " + stopIdLong)
                        openStop(index,stopName)
                    } else {
                        console.log("stopInfo.qml: downloading  " + stopIdLong)
                        stopsLookup.sendMessage({"save":"true", "searchString":stopIdLong})
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
//                    scheduleView.positionViewAtIndex(index,GridView.Beginning)
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
            width: linesView.width
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
                onPressAndHold: { linesView.currentIndex = index; linesPassingContext.open() }
                onClicked: { linesView.currentIndex = index }
                onDoubleClicked: { stopInfoPage.showLineInfo(lineIdLong) }
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
        state: "stopsSelected"
        Label { // earlierUpdateTime
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            style: LabelStyle { inverted: true }
            id: earlierTime
            text: "time"
            color: "#cdd9ff"
            visible: false
            z: 10
        }
        Label { // laterUpdateTime
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            style: LabelStyle { inverted: true }
            id: laterTime
            color:"#cdd9ff"
            text: "time"
            visible: false
        }
        ListView {  // stopsView
            id: stopsView
            visible: true
            spacing: 10
            anchors.fill: parent
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:"#666666"; radius:  5 }
            highlightMoveDuration: 1200
            currentIndex: -1
            clip: true
        }
        GridView {  // stopSchedule grid
            property int dragDirection: 0
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

            onMovementStarted: {
                dragDirection = (atXBeginning ? -1 : (atXEnd ? 0 : 0 ) )// save start movement state
                                                                        // beginning: -1; end: 1; middle: 0
                // ^ no need to update laterTime label from onContentXChanged, left just in case
                flickTimer.start();
/*                console.log("Moving:" + (moving ? "true":"false") +
                            "\n atXBeginning:" + atXBeginning +
                            "\n atXEnd:" + atXEnd +
                            "\n visibleArea.xPosition:" + visibleArea.xPosition +
                            "\n contentWidth:" + contentWidth +
                            "\n contentX:" + contentX);*/
            }
            onMovementEnded: {
                dragDirection = 0; // reset direction
                if (flickTimer.running) flickTimer.stop();
                earlierTime.visible = false;
                laterTime.visible = false;
                // TODO: check for time label value and pass it to loadStopSchedule
                console.log("Movement ended");
            }
            onContentXChanged: {
                if (dragDirection == -1) {
                    if (contentX <= 0) {
                        earlierTime.text = contentX
                    } else {
                        earlierTime.text = "-0";
                    }
                } else if (dragDirection == 1) {
                    if (scheduleView.contentX >= scheduleView.contentWidth - 480) {
                        laterTime.text = scheduleView.contentX - 480
                    } else {
                        laterTime.text = "-0";
                    }
                }
            }
        }
        ListView {  // lines passing
            id: linesView
            visible: false
            anchors.fill: parent
            delegate:  linesDelegate
            model: linesModel
            header: linesHeader
            highlight: Rectangle { color:"#666666"; radius:  5 }
            highlightMoveDuration: 2
            currentIndex: -1
            clip: true
        }

    states: [
//        State {
//            name: ""
//            PropertyChanges { target: stopsView; visible: true }
//            PropertyChanges { target: scheduleView; visible: false }
//            PropertyChanges { target: linesView; visible: false }

//        },
        State {
            name: "stopsSelected"
            PropertyChanges { target: stopsView; visible: true }
            PropertyChanges { target: scheduleView; visible: false }
            PropertyChanges { target: linesView; visible: false }
        },
        State {
            name: "scheduleSelected"
            PropertyChanges { target: stopsView; visible: false }
            PropertyChanges { target: scheduleView; visible: true}
            PropertyChanges { target: linesView; visible: false }
        },
        State {
            name: "linesSelected"
            PropertyChanges { target: stopsView; visible: false }
            PropertyChanges { target: scheduleView; visible: false }
            PropertyChanges { target: linesView; visible: true }
        }
    ]

    }
/*<----------------------------------------------------------------------->*/
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function openStop(index,stopName) {
        if (selectedStopIndex != index || stopNameValue != stopName ) {
            selectedStopIndex = index
            stopsView.currentIndex = index
            searchString = "" + stopsView.model.get(index).stopIdLong
            if (stopsView.model.get(index).nickName && stopsView.model.get(index).nickName != "") {
                stopNameValue.text = stopsView.model.get(index).nickName
            } else {
                stopNameValue.text = stopsView.model.get(index).stopName
            }
            stopAddressValue.text = stopsView.model.get(index).stopAddress
            stopCityValue.text = stopsView.model.get(index).stopCity
            dataRect.visible = true
            showMapButton.visible = true
            fillLinesModel()
            fillSchedule("")
        } else if (stopsView.currentIndex != selectedStopIndex){
            stopsView.currentIndex = index
        }
        infoRect.state="scheduleSelected"
    }

    function fillModel() {      // checkout recent stops from database
        var stopReSelected = 0
        recentModel.clear();
        JS.__db().transaction(
            function(tx) {
                    try { var rs = tx.executeSql("SELECT Stops.stopIdLong, stopIdShort, stopName, stopAddress, stopCity, favorite, NickName FROM Stops LEFT OUTER JOIN StopNickNames ON Stops.stopIdLong=StopNickNames.stopIdLong " + (config.stopsShowAll == "false" ? "WHERE favorite=\"true\" " : "") + "ORDER BY stopName ASC" ); }
                    catch(e) {console.log("stopInfo.qml fill model EXCEPTION:" + e) }
                    for (var i=0; i<rs.rows.length; ++i) {
                        recentModel.append(rs.rows.item(i))
                        if (rs.rows.item(i).stopIdLong == searchString) {
                            selectedStopIndex = i
                            stopsView.currentIndex = i
                            stopReSelected = 1
                    }
                }
            }
        )
        if (searchString && !stopReSelected) {
            selectedStopIndex = -1
            stopsView.currentIndex = -1
            trafficModel.clear()
            linesModel.clear()
            dataRect.visible = false
        }

    }
    function fillLinesModel() {  // checkout stop info from database
        linesModel.clear()
        linesLoader.sendMessage({"searchString":searchString})
    }
    function fillSchedule(startTime) {
        trafficModel.clear()
        tabRect.checkedButton = stopSchedule
        loading.visible = true
        if (startTime == "") {
            loadStopSchedule.sendMessage({"searchString" : searchString})
        } else {
            loadStopSchedule.sendMessage({"searchString" : searchString, "startTime" : startTime})
        }

        scheduleView.currentIndex = 0
//        infoRect.state = "scheduleSelected"
        dataRect.visible = true
    }

    function buttonClicked() {  // SearchBox action, or transfer from lineInfo page with request to show info
        if (searchString != "") {
            for (var j=0; j<recentModel.count; ++j) {
                if (recentModel.get(j).stopIdLong == searchString) {  // this check should work only if stopIdLong supplied
                    if (selectedStopIndex != j) {
                        stopsView.model = recentModel
                        openStop(j,recentModel.get(j).stopName)
                        console.log("stopInfo: buttonClicked: found stop via stopIdLong already in recentModel: " + searchString + ": " + j);
                        return
                    }
                }
            } // if we don't have requested stop in recentModel  we go further to real search using network
            loading.visible = true
            searchResultStopInfoModel.clear()
            trafficModel.clear()
            linesModel.clear()
            selectedStopIndex = -1
            stopsView.currentIndex = -1
            dataRect.visible = false
            stopsLookup.sendMessage({"searchString" : searchString})
        } else {
            searchDialog.page = stopInfoPage;
            searchDialog.open();
            showError("Enter search criteria\nline number/line code/Key place\ni.e. 156A or Tapiola")
            return
        }
    }
    function setFavorite(stopIdLong_,value) {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {  // TODO
                try { var rs = tx.executeSql("UPDATE Stops SET favorite=? WHERE stopIdLong=?",[value,stopIdLong_]); }
                catch(e) { console.log("stopInfo: setFavorite EXCEPTION: " + e) }
            }
        )
    }
    function refreshConfig() {        // reload config from database - same function on every page
        JS.loadConfig(config)
    }
    function setNickName(newNick) {
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql("INSERT OR REPLACE INTO StopNickNames VALUES(?,?)",[recentModel.get(stopsView.currentIndex).stopIdLong, newNick]); }
                catch(e) { console.log("stopInfo: setNickName EXCEPTION: " + e) }
            }
        )
        recentModel.set(stopsView.currentIndex,{"NickName":newNick})
        if (recentModel.get(stopsView.currentIndex).favorite == "true") {
            stopInfoPage.refreshFavorites()
        }
    }

/*<----------------------------------------------------------------------->*/
}
