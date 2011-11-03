import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS
import com.nokia.extras 1.0

Item {
    id: stopInfoPage
    objectName: "stopInfoPage"
    property string stopAddString: ""
    property string searchString: ""    // keep stopIdLong here. If stopIdShort supplied (request from lineInfo) -> remove and place stopIdLong
    property int selectedStopIndex: -1
    anchors.fill: parent

    Config { id: config }
    WorkerScript {           // load stop info in database
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
    WorkerScript {           // fast schedule loader
        id: loadStopSchedule
        source: "stopInfoScheduleLoad.js"
        onMessage: {
            if (messageObject.departName == "STOPNAME") {
                stopName.text = messageObject.stopName
                stopAddress.text = messageObject.stopAddress
                if (selectedStopIndex == -1 || recentModel.get(selectedStopIndex).stopIdLong != searchString) {
                    loadStopInfo.sendMessage({"searchString" : searchString,"stopAddress" : messageObject.stopAddress})
                    loadingMap.visible = true
                } else {
                    loadingMap.visible = false
                }
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
    Item {                   // busy indicator
        id: loading
        visible: false
        anchors.fill: parent
        z: 8
        Rectangle {
            anchors.fill: parent
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
    QueryDialog {            // offline dialog
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
    ContextMenu {            // depart line context menu
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
                    pageStack.push(Qt.resolvedUrl("route.qml"),{"loadLine":trafficModel.get(grid.currentIndex).departCode, "loadStop":searchString});
                }
            }
        }
    }
    ContextMenu {            // passing line context menu
        id: linesPassingContext
        MenuLayout {
            MenuItem {
                text: "Line Info"
                onClicked : {
                    pageStack.push(Qt.resolvedUrl("lineInfo.qml"),{"loadLine":linesModel.get(linesList.currentIndex).lineNumber});
                }
            }
            MenuItem {
                text: "Line Map"
                onClicked : {
                    pageStack.push(Qt.resolvedUrl("route.qml"),{"loadLine":linesModel.get(linesList.currentIndex).lineNumber, "loadStop":searchString});
                }
            }
        }
    }
    Rectangle {              // dark background
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
    Item {                   // Data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  parent.top
        anchors.right: parent.right
        height: 110
        visible: false
        Rectangle {          // showMapButton
                id: showMapButton
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "#777777"
                height: 60
                width: 60
                radius: 10
                Button {
                    id: showMapButtonButton
                    anchors.fill: parent
                    text: "M"
                    visible: (loadingMap.visible) ? false : true
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("route.qml"),{"loadStop":searchString})
                    }
                }
                BusyIndicator{// loading spinner
                    id: loadingMap
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    running: true
                    visible: false
                    z: 8
                }
            }
        Column {
//            spacing: 5
            Row {
                Label {
                    id: stopNameLabel
                    text: qsTr("Name")
                    color: config.textColor
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopName;
                    text: qsTr("Name")
                    color: config.textColor
                    font.pixelSize: 30
                }
            }
            Row {
                Label {
                    id: stopAddressLabel
                    text: qsTr("Address")
                    color: config.textColor
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopAddress;
                    text: qsTr("Address")
                    color: config.textColor
                    font.pixelSize: 30
                }
            }
            Row {
                Label {
                    id: stopCityLabel;
                    text: qsTr("City")
                    color: config.textColor
                    font.pixelSize: 25
                    width: 100
                }
                Label {
                    id: stopCity;
                    text: qsTr("City")
                    color: config.textColor
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
        anchors.right: parent.right
        anchors.left: parent.left
            Button {
                id: recentButton
                text: "Recent"
                onClicked: {
                    if (recentList.visible == false) {
                        if (recentList.currentIndex != selectedStopIndex) {
                            recentList.currentIndex = selectedStopIndex
                        }
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
            width: recentList.width
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
                    if (selectedStopIndex != index) {
                        selectedStopIndex = index
//                        recentList.focus = true
                        recentList.currentIndex = index
                        searchString = recentModel.get(index).stopIdLong
                        showMapButtonButton.visible = true
                        fillInfoModel()
                        fillLinesModel()
//                        if (config.networking < 1) {
//                            showError("Offline networking mode enabled. Change networking mode in settings.")
//                            console.log("stop: " + recentModel.get(recentList.currentIndex).stopName+ "; id:" + recentList.currentIndex)
                        stopName.text = recentModel.get(recentList.currentIndex).stopName
                        stopAddress.text = recentModel.get(recentList.currentIndex).stopAddress
                        stopCity.text = recentModel.get(recentList.currentIndex).stopCity
                        dataRect.visible = true
                        showMapButtonButton.visible = true
//                        } else {
                            updateSchedule()
//                        }
                    }
                }
                onPressedChanged: {
                    if (pressed == true) {
                        recentList.focus = true
                        recentList.currentIndex = index
                    }
                }
                onPressAndHold: {
                    console.log("Press and holded!!!")
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
            MouseArea{
                anchors.fill: parent
                onPressAndHold: { linesPassingContext.open() }
                onClicked: { linesList.currentIndex = index }
            }
        }
    }
    Component {              // lines passing header Header
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
    Item {                   // grid rect
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
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function getSchedule() {
        loading.visible = true
        loadStopSchedule.sendMessage({"searchString" : searchString})
        grid.currentIndex = 0
        grid.focus = true
        grid.visible = true
        list.visible = false
        recentList.visible = false
        dataRect.visible = true
    }
    function buttonClicked() {  // SearchBox action
        console.log("Button clicked: " + searchString)
        if (searchString == "" || searchString.length > 7 || searchString.length < 4) {
            showError("Wrong stop ID:"+searchString+".\nStop ID is 4 digit or 1 letter & 4 digits. Example: E3127")
        }
        if (config.networking < 1) {
            offlineModeOff.open();
            return
        }
        updateSchedule()
    }
    function updateSchedule() { // update only schedule
        trafficModel.clear()
        getSchedule()
        tabRect.checkedButton = stopSchedule
    }
    function fillModel() {      // checkout recent stops from database
        console.log("Fill model started")
        recentModel.clear();
        JS.__db().transaction(
            function(tx) {
                     var rs = tx.executeSql("SELECT * FROM Stops ORDER BY stopName ASC");
                         for (var i=0; i<rs.rows.length; ++i) {
                            recentModel.append(rs.rows.item(i))
                             console.log("recentModel: add "  + rs.rows.item(i).stopIdLong)
                             if (rs.rows.item(i).stopIdLong == searchString) {
                                 console.log("fillModel: found index:" + i + " : " + rs.rows.item(i).stopIdLong)
                                 selectedStopIndex = i
                             }
                         }
                 }
        )
    }
    function fillInfoModel() {  // checkout stop info from database
        console.log("Fill info model started")
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
    function setCurrent() {     // stop info request from lineInfo:stopReach
        if (searchString != "") {
             JS.__db().transaction(
                 function(tx) {
                        try { var rs = tx.executeSql("SELECT * FROM Stops WHERE stopIdLong=?", [searchString]) }
                        catch(e) { console.log("exception : "+e) }
                        if (rs.rows.length > 0) {
                            showMapButtonButton.visible = true
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
