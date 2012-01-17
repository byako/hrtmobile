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

    Component.onCompleted: { refreshConfig(); infoModel.clear(); fillModel(); }
    Config { id: config }
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
            if (messageObject.stopIdShort != "FINISHED") {
//                console.log("WORKER SENT stopIdLong: " + messageObject.stopIdLong + "; stopIdShort: " + messageObject.stopIdShort + "; state: " + messageObject.state)
                if (messageObject.state == "load") { // load stop short info from recentModel to searchResultStopInfoModel
                    for (var i=0;i<searchResultStopInfoModel.count;++i) {
                        if (searchResultStopInfoModel.get(i).stopIdLong == messageObject.stopIdLong)
                            return
                    }
                    for (var i=0;i<recentModel.count;++i) { // just put saved already stop from recent model to searchResultStopInfoModel
                        if (recentModel.get(i).stopIdLong == messageObject.stopIdLong) {
                            searchResultStopInfoModel.append(recentModel.get(i))
                            break
                        }
                    }
                } else if (messageObject.state == "online") {
                    searchResultStopInfoModel.append(messageObject)
                    recentModel.append(messageObject)
                }
            } else {
                loading.visible = false
                console.log("stopInfo geocode API FINISHED request " + searchString);
                searchString = ""
                if (searchResultStopInfoModel.count > 1) {
                    stopsView.model = searchResultStopInfoModel
                    recentButton.text = "Filtered"
                } else { // if only one stop has been found - show it immediately without showing a list of found stops
                    searchString = searchResultStopInfoModel.get(0).stopIdLong
                    searchResultStopInfoModel.clear()
                    buttonClicked()
                }
            }
        }
    }
    WorkerScript {           // load stop info from web or database
        id: loadStopInfo
        source: "stopInfoLoadInfo.js"
        onMessage: {
            if (messageObject.action == "SAVED") {  // stop has been saved from server reply
                loadingMap.visible = false
                searchString = messageObject.stopIdLong
                console.log("WORKER SENT stopIdLong: setting searchString = " + messageObject.stopIdLong)
                infoModel.clear()
                linesModel.clear()
                fillModel()
                fillLinesModel()
                fillInfoModel()
                showError("Saved stop information")
            } else if (messageObject.action == "LOAD") { // stop has been found in database
                // TODO load stop from offline DATABASE
            } else if (messageObject.action == "ERROR") {
                showError("Server returned ERROR");
            } else if (messageObject.action == "FAILED") {
                showError("Couldn't open information")
            } else {
                console.log("stopInfo: loadStopInfo worker: unknown action: " + messageBoject.action)
            }
        }
    }
    WorkerScript {           // fast schedule loader: API 1.0
        id: loadStopSchedule
        source: "stopInfoScheduleLoad.js"
        onMessage: {
            if (messageObject.departName == "STOPNAME") {
                stopNameValue.text = messageObject.stopName
                stopAddressValue.text = messageObject.stopAddress
                stopCityValue.text = messageObject.stopCity
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

    Loading {                // busy indicator
        id: loading
        visible: false
        anchors.fill: parent
        z: 8
    }
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
                text: "Delete stop"
                onClicked: {
                    JS.deleteStop(stopsView.model.get(stopsView.currentIndex).stopIdLong) // remove from database
                    if (stopsView.model.get(stopsView.currentIndex).favorite == "true" ) stopInfoPage.refreshFavorites() // check if favorites page needs to be refreshed
                    if (selectedStopIndex >= 0) { // if some stop is selected to view and dataRect shows data - mess with indexes
                        if (selectedStopIndex == stopsView.currentIndex) { // if removing selected stop - clean models, hide dataRect
                            stopsView.model.remove(stopsView.currentIndex)
                            if (stopsView.model == searchResultStopInfoModel) fillModel()
                            selectedStopIndex = -1
                            stopsView.currentIndex = -1
                            dataRect.visible = false
                            trafficModel.clear()
                            linesModel.clear()
                            infoModel.clear()
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
            MenuItem {
                text: "Delete all"
                onClicked: {
                    if (stopsView.model == recentModel) { // recent stops are shown: delete all except the favourites
                        for (var i1=0; i1 < recentModel.count; ++i1) {
                            if (recentModel.get(i1).favorite != "true") {
                                JS.deleteStop(recentModel.get(i1).stopIdLong)
                            }
                        }
                    } else { // filtered search results are shown : delete only those
                        for (var i2=0; i2 < searchResultStopInfoModel.count; ++i2) {
                            if (searchResultStopInfoModel.get(i2).favorite != "true") {
                                JS.deleteStop(searchResultStopInfoModel.get(i2).stopIdLong)
                            }
                        }
                        searchResultStopInfoModel.clear()
                    }
                    fillModel()  // reload recent stops model
                    stopsView.model = recentModel
                    recentButton.text = "Recent"
                    stopsView.currentIndex = -1
                    selectedStopIndex = -1
                    trafficModel.clear()
                    linesModel.clear()
                    infoModel.clear()
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
                onClicked : stopInfoPage.showLineInfo(linesModel.get(linesView.currentIndex).lineNumber);
            }
            MenuItem {
                text: "Line Map"
                onClicked : stopInfoPage.showStopMapLine(searchString, linesModel.get(linesView.currentIndex).lineNumber);
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
                Button { // showMapButton
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
                    text="Filtered"
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
        Button {
            id: stopInfo
            text: "Info"
            onClicked: {
                infoRect.state = "infoSelected"
            }
        }
    }
/*<----------------------------------------------------------------------->*/
    ListModel {              // search result stopInfo list model
        id:searchResultStopInfoModel
    }
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
                    if (selectedStopIndex != index || stopNameValue != stopName ) {
                        selectedStopIndex = index
                        stopsView.currentIndex = index
                        searchString = "" + stopsView.model.get(index).stopIdLong
                        showMapButton.visible = true
                        fillInfoModel()
                        fillLinesModel()
                        stopNameValue.text = stopName
                        stopAddressValue.text = stopAddress
                        stopCityValue.text = stopCity
                        dataRect.visible = true
                        showMapButton.visible = true
                        fillSchedule()
                    } else if (stopsView.currentIndex != selectedStopIndex){
                        stopsView.currentIndex = index
                    }
                    infoRect.state="scheduleSelected"
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
                onPressAndHold: { linesView.currentIndex = index; linesPassingContext.open() }
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
        state: "stopsSelected"
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

    states: [
        State {
            name: "stopsSelected"
            PropertyChanges { target: stopsView; visible: true }
            PropertyChanges { target: scheduleView; visible: false }
//            PropertyChanges { target: scheduleButtons; visible: false }
            PropertyChanges { target: linesView; visible: false }
            PropertyChanges { target: infoView; visible: false }
        },
        State {
            name: "scheduleSelected"
            PropertyChanges { target: stopsView; visible: false }
            PropertyChanges { target: scheduleView; visible: true}
//            PropertyChanges { target: scheduleButtons; visible: true }
            PropertyChanges { target: linesView; visible: false }
            PropertyChanges { target: infoView; visible: false }
        },
        State {
            name: "linesSelected"
            PropertyChanges { target: stopsView; visible: false }
            PropertyChanges { target: scheduleView; visible: false }
//            PropertyChanges { target: scheduleButtons; visible: false }
            PropertyChanges { target: linesView; visible: true }
            PropertyChanges { target: infoView; visible: false }
        },
        State {
            name: "infoSelected"
            PropertyChanges { target: stopsView; visible: false }
            PropertyChanges { target: scheduleView; visible: false }
//            PropertyChanges { target: scheduleButtons; visible: false }
            PropertyChanges { target: linesView; visible: false }
            PropertyChanges { target: infoView; visible: true }
        }
    ]

    }
/*<----------------------------------------------------------------------->*/
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
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
                            stopsView.currentIndex = i
                    }
                }
            }
        )

    }
    function fillInfoModel() {  // checkout stop info from database
        JS.__db().transaction(
            function(tx) {
                try { var rs = tx.executeSql("SELECT option,value FROM StopInfo WHERE stopIdLong=?",[searchString]); }
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
                try { var rs = tx.executeSql("SELECT StopLines.lineIdLong, StopLines.lineEnd, Lines.lineType FROM StopLines LEFT OUTER JOIN Lines ON StopLines.lineIdLong=Lines.lineIdLong WHERE stopIdLong=?",[searchString]); }
                catch(e) { console.log("FillLinesModel EXCEPTION: " + e); return }
                linesModel.clear();
                for (var i=0; i<rs.rows.length; ++i) {
                    linesModel.append({"lineNumber" : rs.rows.item(i).lineIdLong,
                                      "lineDest" : rs.rows.item(i).lineEnd})
                    if (rs.rows.item(i).lineType) {
                        console.log("Adding lineType for the stop:"+rs.rows.item(i).lineType)
                    }
                }
            }
        )
    }
    function fillSchedule() {
        trafficModel.clear()
        tabRect.checkedButton = stopSchedule
        loading.visible = true
        loadStopSchedule.sendMessage({"searchString" : searchString})
        scheduleView.currentIndex = 0
//        infoRect.state = "scheduleSelected"
        dataRect.visible = true
    }

    function buttonClicked() {  // SearchBox action, or transfer from lineInfo page with request to show info
        if (searchString != "") {
            for (var j=0; j<recentModel.count; ++j) {
                if (stopsView.model.get(j).stopIdLong == searchString) {  // this check should work only if stopIdLong supplied
                    if (selectedStopIndex != j) {
                        infoRect.state = "scheduleSelected"
                        stopsView.model = recentModel
                        selectedStopIndex = j
                        stopsView.currentIndex = j
                        searchString = "" + recentModel.get(j).stopIdLong
                        showMapButton.visible = true
                        fillInfoModel()
                        fillLinesModel()
                        stopNameValue.text = recentModel.get(selectedStopIndex).stopName
                        stopAddressValue.text = recentModel.get(selectedStopIndex).stopAddress
                        stopCityValue.text = recentModel.get(selectedStopIndex).stopCity
                        dataRect.visible = true
                        showMapButton.visible = true
                        fillSchedule()
                        console.log("stopInfo: buttonClicked: found stop via stopIdLong already in model: " + searchString + ": " + j);
                        return
                    }
                }
            }
            loading.visible = true
            searchResultStopInfoModel.clear()
            selectedStopIndex = -1
            stopsView.currentIndex = -1
            dataRect.visible = false
            trafficModel.clear()
            infoModel.clear()
            linesModel.clear()
            stopsLookup.sendMessage({"searchString" : searchString})
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
    function refreshConfig() {
        JS.loadConfig(config)
    }
/*<----------------------------------------------------------------------->*/
}
