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
    property int linesToSave : 0

    signal showLineMap(string lineIdLong)
    signal showLineMapStop(string lineIdLong, string stopIdLong)
    signal showStopMap(string stopIdLong)
    signal showStopInfo(string stopIdLong)
    signal pushStopToMap(string stopIdLong_, string stopIdShort_, string stopName_, string stopLongitude_, string stopLatitude_)
    signal refreshFavorites()
    signal cleanMapAndPushStops()
    width: 480
    height: 745

    Component.onCompleted: { // load and recent lines
        checkLineLoadRequest()
        lineInfoLoadLines.sendMessage("")
    }

    InfoBanner {    // info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    Loading {          // busy indicator
        id: loading
        visible: false
        anchors.top: dataRect.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        z: 8
    }
    WorkerScript {  // lineSearch
        id: lineSearchWorker
        source: "lineSearch.js"

        onMessage: {
            if (messageObject.lineIdLong == "FINISH") {
                console.log("lineInfo.qml: worker finished")
                if (searchResultLineInfoModel.count > 2) {
                    linesView.model = searchResultLineInfoModel
                    console.log("lineInfo.qml: RECENTBUTTON: FILTERED SIGN")
                    recentText.text = "Filtered"
                    recentButtonAnimation.running = "true"
                    loading.visible = false
                } else {
                    linesToSave = searchResultLineInfoModel.count
                    for (var ii=0; ii<searchResultLineInfoModel.count; ++ii) {
                        console.log("lineInfo.qml: sending save request " + searchResultLineInfoModel.get(ii).lineIdLong)
                        lineSearchWorker.sendMessage({"searchString":searchResultLineInfoModel.get(ii).lineIdLong,"save":"true"})
                    }
/*                    infoRect.visible = true;
                    infoRect.state = "stopsSelected"
                    dataRect.visible = true
                    linesView.currentIndex = 0
                    showLineInfo()*/
                }
            } else if (messageObject.lineIdLong == "NONE") {
                loading.visible = true
                showError("No lines found")
            } else if (messageObject.lineIdLong == "ERROR") {
                loading.visible = true
                showError("Server returned ERROR")
            } else {
                if (messageObject.state != "saved") {  // offline || online
                    for (var bb=0; bb < searchResultLineInfoModel.count; ++bb) {
                        if (searchResultLineInfoModel.get(bb).lineIdLong == messageObject.lineIdLong){
                            return;
                        }
                    }
                    searchResultLineInfoModel.append(messageObject);
                } else {
                    --linesToSave;
                    if (!linesToSave) loading.visible = false
                    for (var bb=0; bb < searchResultLineInfoModel.count; ++bb) {
                        if (searchResultLineInfoModel.get(bb).lineIdLong == messageObject.lineIdLong){
                            searchResultLineInfoModel.set(bb,{"state":"offline"})
                            lineInfoModel.append(searchResultLineInfoModel.get(bb));
                        }
                    }
                    showLineInfo()
                }
            }
        }
    }
    WorkerScript {  // stop name loader
        id: stopReachLoader
        source: "stopName.js"

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
            if (messageObject.lineIdLong != "FINISH") {
                lineInfoModel.append(messageObject)
            } else {
                linesView.currentIndex = selectedLineIndex
            }
        }
    }
    ContextMenu {   // line info context menu
        id: linesContextMenu
        MenuLayout {
            MenuItem {
                text: "Delete line"
                onClicked: {
                    if (JS.deleteLine(lineInfoModel.get(linesView.currentIndex).lineIdLong) == 0) {
                        if (lineInfoModel.get(linesView.currentIndex).favorite == "true") {
                            lineInfoPageItem.refreshFavorites()
                        }
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
                    for (var i=0; i< lineInfoModel.count; ++i) {
                        if (lineInfoModel.get(i).favorite == "false") {
                            JS.deleteLine(lineInfoModel.get(i).lineIdLong)
                        }
                    }
                    lineInfoModel.clear()
                    lineInfoLoadLines.sendMessage("")
                    loading.visible = false
                    scheduleClear()
                    stopReachModel.clear()
                    linesView.currentIndex = -1
                    selectedLineIndex = -1
                    dataRect.visible = false
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
                iconSource: (linesView.model.get(selectedLineIndex).favorite == "true") ? "image://theme/icon-m-toolbar-favorite-mark-white" : "image://theme/icon-m-toolbar-favorite-unmark-white"
                onClicked: {
                    if (linesView.model.get(selectedLineIndex).favorite == "true") {
                        setFavorite(searchString, "false")
                        linesView.model.set(selectedLineIndex, {"favorite":"false"})
                        for (var ii=0; ii < lineInfoModel.count; ii++) {
                            if (lineInfoModel.get(ii).lineIdLong == searchString)
                                lineInfoModel.set(ii, {"favorite":"false"})
                        }
                    } else {
                        setFavorite(searchString, "true")
                        lineInfoModel.set(selectedLineIndex, {"favorite":"true"})
                        for (var ii=0; ii < lineInfoModel.count; ii++) {
                            if (lineInfoModel.get(ii).lineIdLong == searchString)
                                lineInfoModel.set(ii, {"favorite":"true"})
                        }
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
                Text {
                    id: recentText
                    anchors.centerIn: parent
                    SequentialAnimation on color {
                        running: false
                        id: recentButtonAnimation
                        loops: Animation.Infinite;
                        ColorAnimation { from: "white"; to: "black"; duration: 800; }
                        ColorAnimation { from: "black"; to: "white"; duration: 800; }
                    }
                    text: "Recent"
                    font.pixelSize: 25
                    color: "#eeeeee"
                }
                onClicked: {
                    if (linesView.currentIndex != selectedLineIndex) { linesView.currentIndex = selectedLineIndex }
                    if ( infoRect.state != "linesSelected" ) {
                         infoRect.state = "linesSelected";
                    } else if (linesView.model != lineInfoModel) {
                        linesView.model = lineInfoModel
                        searchResultLineInfoModel.clear()
                        recentText.text = "Recent"
                        recentText.color = "white"
                        recentButtonAnimation.running = "false"
                        for (var ii=0; ii < lineInfoModel.count; ++ii) {
                            if (lineInfoModel.get(ii).lineIdLong == searchString) {
                                selectedLineIndex = ii
                                linesView.currentIndex = ii
                            }
                        }
                    } else {
                        lineInfoModel.clear()
                        lineInfoLoadLines.sendMessage("")
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
    Component {     // lineInfo delegate
        id:lineInfoShortDelegate
        Item {
            width: linesView.width;
            height: 40
            Text{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
//                anchors.leftMargin: 50
                wrapMode: Text.WordWrap
                text: "" + lineIdShort + "  " + lineStart + " -> " + lineEnd;
                font.pixelSize: 28;
                color: "#cdd9ff"
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    if (linesView.model != lineInfoModel && index != selectedLineIndex) {
                        console.log("lineInfo.qml: open line from search result:" + lineIdLong + ": saving")
                        searchString = lineIdLong
                        stopReachModel.clear()
                        scheduleClear()
                        console.log("lineInfo: selected line " + lineIdLong + " : " + linesView.model.get(index).state)
                        if (linesView.model.get(index).state == "online") {
                            lineSearchWorker.sendMessage({"searchString": "" + lineIdLong, "save":"true"})
                        } else {
                            showLineInfo()
                        }
                        selectedLineIndex = index
                        linesView.currentIndex = index
                        showLineInfo()
                    } else if (selectedLineIndex != index) {
                        searchString = lineIdLong
                        selectedLineIndex = index
                        linesView.currentIndex = index
                        showLineInfo()
                    }
                }
                onPressAndHold: {
                    if (linesView.model == lineInfoModel) {
                        linesView.currentIndex = index
                        linesContextMenu.open()
                    }
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
        state: "linesSelected";
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
        searchResultLineInfoModel.clear()
        loading.visible = true
        lineSearchWorker.sendMessage({"searchString":searchString})
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
            console.log("ShowLineInfo:  current index is " + selectedLineIndex)
            infoRect.state = "stopsSelected"
            tabRect.checkedButton = stopsButton
            dataRect.visible = true
            showMapButtonButton.visible = true
            scheduleLoaded = 0
            scheduleClear()
            stopReachModel.clear()
            getStops()
            lineShortCodeName.text = linesView.model.get(selectedLineIndex).lineIdShort
            lineStart.text = "From : " + linesView.model.get(selectedLineIndex).lineStart
            lineEnd.text = "To : " + linesView.model.get(selectedLineIndex).lineEnd
            lineType.text = linesView.model.get(selectedLineIndex).lineTypeName
            searchString = linesView.model.get(selectedLineIndex).lineIdLong
        } else {
            dataRect.visible = false
            stopReachModel.clear()
            scheduleClear()
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
/*<----------------------------------------------------------------------->*/
}
