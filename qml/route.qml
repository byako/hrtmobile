import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "database.js" as JS
import com.nokia.extras 1.1

Item {
    id: routePage
    property bool firstRun: true
    property bool searchNearbyStops: false
    property bool findStops: false
    property string loadStopIdLong: ""
    property string loadLineIdLong: ""
    property int loadedLine: -1
    property int loadedStop: -1

    property string passiveBusStopColor: "#806060BB"
    property string activeBusStopColor: "#80f1ff15"
    property string passiveTramStopColor: "#806060BB"
    property string activeTramStopColor: "#80f1ff15"
    property string passiveMetroStopColor: "#806060BB"
    property string activeMetroStopColor: "#80f1ff15"


    property string busLineColor: "#BB093a81"
    property string tramLineColor: "#BB3e8a00"
    property string metroLineColor: "#BBFF6600"

    signal stopInfo(string stopIdLong_)

    state: "hideStops"
    width: 480
    height: 745

    InfoBanner {             // info banner
        id: infoBanner
        text: ""
        z: 10
        opacity: 1.0
    }
    WorkerScript {  // stop name loader
        id: stopNameLoader
        source: "stopName.js"

        onMessage: {
            if (messageObject.stopName != "Error") {
                console.log("route.qml: " + messageObject.stopIdLong + " : " + messageObject.stopIdShort)
                for (var ii=0; ii < stops.count; ++ii) {
                    if (stops.get(ii).stopIdLong == messageObject.stopIdLong) {
                        stops.get(ii).mapCircle.stopName = messageObject.stopName
                        stops.get(ii).mapCircle.stopAddress = messageObject.stopAddress
                        stops.get(ii).mapCircle.stopIdShort = messageObject.stopIdShort
                        stops.set(ii, { "stopIdShortName" : messageObject.stopIdShort + " - " + messageObject.stopName})
                    }
                }
            } else {
                console.log("route: got Error for stop: " + messageObject.stopIdLong + "; removing from map")
                for (var ii=0; ii < stops.count; ++ii) {
                    if (stops.get(ii).stopIdLong == messageObject.stopIdLong) {
                        map.removeMapObject(stops.get(ii).mapCircle)
                    }
                }
            }
        }
    }
    WorkerScript {  // load line stops, send a request to find the name if needed
        id: lineStopsLoader
        source: "lineInfoLoadStops.js"
        onMessage: {
            if (messageObject.stopIdLong == "finish") {
                if (loadStopIdLong != "") { // center map on the line's last stop
                    loadStop();
                }
                return
            }
            if (messageObject.stopState != "offline") {
                console.log("route.qml: RECEIVED ONLINE STOP!")
//                stopNameLoader.sendMessage({"searchString":messageObject.stopIdLong})
            } else {
                for (var aa=0;aa<stops.count;++aa) {
                    if (stops.get(aa).stopIdLong == messageObject.stopIdLong) {
                        stops.set(aa,{"stopObjectType":"line"})
                        return
                    }
                }
                addStop(messageObject.stopIdLong,
                        messageObject.stopIdShort,
                        messageObject.stopName,
                        messageObject.stopLongitude,
                        messageObject.stopLatitude,
                        messageObject.stopAddress,
                        "line")
            }
        }
    }
    WorkerScript {  // line shape loader
        id: lineLoader
        source: "route.js"

        onMessage: {
            if (messageObject.longitude == "finish") {
                if (loadStopIdLong == "") {
                    map.center.longitude = messageObject.longit
                    map.center.latitude = messageObject.latit
                }
                lineStopsLoader.sendMessage({"searchString":lines.get(loadedLine).lineIdLong})
                lineLabel.text = messageObject.lineIdShort + " -> " + messageObject.lineEnd
                lines.set(loadedLine,{"lineIdShort":messageObject.lineIdShort,"lineEnd":messageObject.lineEnd,"lineType":messageObject.lineType})
                switch (messageObject.lineType) {
                    case "1"||"3"||"4"||"5"||"10" : lines.get(loadedLine).lineShape.border.color=busLineColor; console.debug("busLineColor"); break;
                    case "2" : lines.get(loadedLine).lineShape.border.color=tramLineColor; console.debug("tramLineColor"); break;
                    case "6"||"8" : lines.get(loadedLine).lineShape.border.color=metroLineColor; console.debug("metroLineColor"); break;
                    default: lines.get(loadedLine).lineShape.border.color=busLineColor ; console.debug("busLineColor"); break;
                }
            } else if (messageObject.longitude == "error"){
                map.removeMapObject(lines.get(loadedLine).lineShape)
                lines.get(loadedLine).lineShape.destroy()
                lines.remove(loadedLine)
                lineLabel.text = ""
            } else {
                temp.longitude = messageObject.longitude
                temp.latitude = messageObject.latitude
                lines.get(loadedLine).lineShape.addCoordinate(temp)
            }
        }
    }
    WorkerScript {  // nearby stops loader
        id: stopsNearbySearch
        source: "mapStopsSearch.js"
        onMessage: {                  // check if stop is already on the map before adding; leave if found
            if (messageObject.stopIdLong == "FINISH") {
                searchStopsButton.iconSource = "image://theme/icon-m-toolbar-search-white"
                return
            }

            for (var ii=0; ii < stops.count; ++ii) {
                if (stops.get(ii).stopIdLong == "" + messageObject.stopIdLong) {
                    console.log("Stop " + messageObject.stopIdLong + " is already on map. Skipping")
                    return
                }
            }
            console.log("MAP: NEARBY STOP " + messageObject.stopIdLong + "; Coords: " + messageObject.longitude + ":" + messageObject.latitude + " ; Distance: " + messageObject.distance);
            addStop(messageObject.stopIdLong, "", "", messageObject.longitude, messageObject.latitude, "","nearby")
            stopNameLoader.sendMessage({"searchString":messageObject.stopIdLong})
        }
    }

    ListModel { id: stops }
    Component {
        id:stopsDelegate
        Item {
            width: stopsView.width;
            height: 40
            Text{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                text: stopIdShortName;
                font.pixelSize: 28;
                color: "#cdd9ff"
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    mapCircle.color=activeBusStopColor
                    if (loadedStop >= 0) {
                        stops.get(loadedStop).mapCircle.color=passiveBusStopColor
                    }
                    loadedStop = index
                    stopsView.currentIndex = index
                    map.center = mapCircle.center
                }
                onDoubleClicked: {
                     routePage.stopInfo(stopIdLong)
                }
            }
        }
    }

    ListModel { id: lines }

    PositionSource {// gps data receiver
        id: positionSource
        updateInterval: 10000
        active: false
        onPositionChanged: {
            console.log("route.qml: position chhanged. distance from previous: " + position.coordinate.distanceTo(positionCircle.center) );
            if (position.coordinate.distanceTo(positionCircle.prev) > 100 || firstRun == true) {
                firstRun = false
                console.log("route.qml: new position: lon: " + position.coordinate.longitude + "; lat: " + position.coordinate.latitude)
                if (findStops) {
                    stopsNearbySearch.sendMessage({"longitude" : position.coordinate.longitude, "latitude" : position.coordinate.latitude})
                }
                positionCircle.center = position.coordinate
                map.center = position.coordinate
            }

        }
    }

    MapPolyline {
        id: lineShape
        border { color: "#00FF00"; width: 4; }
    }
    Coordinate { id: temp }

    Label {
        anchors.top: parent.top
        anchors.left: parent.left
        id: lineLabel
        text: "Line"
        color: "#cdd9ff"
        font.pixelSize: 35
    }
    Item {
        anchors.top : lineLabel.bottom
        anchors.topMargin: 10
        width: parent.width
        height: 160
        ListView {
            id: stopsView
            anchors.fill: parent
            model: stops
            delegate: stopsDelegate
            spacing: 5
            highlight: Rectangle { color: "#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
    }

    Map {
        id: map
        z : 1
        plugin : Plugin {
            name : "nokia"
            parameters: [
                PluginParameter { name: "mapping.app_id";  value: "WrBja0-QSlb_Ei59BA6s"},
                PluginParameter { name: "mapping.token"; value: "kAwbj6b1hMhgcPfFR148lQ"}
            ]
        }
//        anchors.fill: routePage
        width: routePage.width
        height: routePage.height
        anchors.bottom: parent.bottom
        zoomLevel: 14
        center: Coordinate {
            latitude: 60.1636
            longitude: 24.9167
        }
        MapCircle {
            id : positionCircle
            property Coordinate prev: Coordinate // for stops search steps
            {
                latitude : 60.1636
                longitude : 24.9167
            }
            center : Coordinate {
                latitude : 60.1636
                longitude : 24.9167
            }
            color : "#80FF00"
            radius : 30.0
            visible: false
        }
        MapMouseArea {
            property int lastX : -1
            property int lastY : -1
            onPressed : {
                lastX = mouse.x
                lastY = mouse.y
            }
            onReleased : {
                lastX = -1
                lastY = -1
            }
            onPositionChanged: {
                if (mouse.button == Qt.LeftButton) {
                    if ((lastX != -1) && (lastY != -1)) {
                        var dx = mouse.x - lastX
                        var dy = mouse.y - lastY
                            map.pan(-dx, -dy)
                    }
                    lastX = mouse.x
                    lastY = mouse.y
                }
            }
            onDoubleClicked: {
                console.log("MAP: doubleclicked!");
                map.center = mouse.coordinate
                lastX = -1
                lastY = -1
            }
        }

        Column {
            id: mapButtons
            z: 5
            width: 60
            height: 120
            opacity: 0.7
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            Button {
                id: zoomIn
                style: ButtonStyle {
                    inverted: true
                }
                width: parent.width
                checkable: false
                text: "+"
                onClicked: {
                    map.zoomLevel += 1
                    scaleStops()
                }
            }
            Button {
                id: zoomOut
                style: ButtonStyle {
                    inverted: true
                }
                width: parent.width
                checkable: false
                text: "-"
                onClicked: {
                    map.zoomLevel -= 1
                    scaleStops()
                }
            }
        }
        Button {  // info button
            id: statesChangeButton
            width: 100
            anchors.horizontalCenter: map.horizontalCenter
            anchors.top: map.top
            checkable: true
            text: "Info \u2195"
            opacity: 0.7
            style: ButtonStyle {
                inverted: true
            }
            onClicked: {
                routePage.state = (map.height == routePage.height) ? "showStops" : "hideStops"
            }
        }
        Button {  // showCurrentLocation button
            id: showCurrentLocation
            anchors.right: map.right
            anchors.top: map.top
            width: 60
            height: 60
            checkable: true
            iconSource:  "image://theme/icon-s-location-picker-inverse"
            opacity: 0.7
            style: ButtonStyle {
                inverted: true
            }
            onClicked: {
                if (checked) {
                    map.center = positionCircle.center
                    positionCircle.visible = true
                    positionSource.active = true
                    showError("Position tracking enabled")
                } else {
//                    positionCircle.visible = false
                    positionSource.active = false
                    if (loadedStop != -1)
                        map.center = stops.get(loadedStop).mapCircle.center
                        // TODO: keep tracking GPS position
                    showError("Position tracking disabled")
                }
            }
        }
        Button {  // showCurrentLocation button
            id: searchStopsButton
            anchors.left: map.left
            anchors.top: map.top
            width: 60
            height: 60
            checkable: true
            iconSource: "image://theme/icon-m-toolbar-search-white" //":/images/radar.png"
            opacity: 0.7
            style: ButtonStyle {
                inverted: true
            }
            onClicked: {
                if (!checked) { // remove found stops from map
                    var aa=0;
                    if (loadedStop != -1 && stops.get(loadedStop).stopObjectType == "nearby") {
                        loadedStop = -1;
                        stopsView.currentIndex = -1;
                    }
                    while (aa<stops.count) {
                        if (stops.get(aa).stopObjectType=="nearby") {
                            map.removeMapObject(stops.get(aa).mapCircle)
                            stops.remove(aa)
                        } else {
                            aa++
                        }
                    }
                } else {
                    showError("Searching for stops nearby")
                    iconSource=":/images/radar.png"
                    stopsNearbySearch.sendMessage({"longitude":map.center.longitude,"latitude":map.center.latitude})
                }
            }
        }
    }

    states: [
        State {
            name: "showStops"
            PropertyChanges { target: map; height: 500; y:  244}
        },
        State {
            name: "hideStops"
            PropertyChanges { target: map; height: routePage.height; y: 0 }
        }
    ]

//----------------------------------------------------------------------------//
    function showError(stringToShow) {
        infoBanner.text = stringToShow
        infoBanner.show()
    }

    function cleanStops() {
        var i=0;
        var temp = "";
        if (loadedStop != -1 && stops.get(loadedStop).stopObjectType != "nearby") {
            loadedStop = -1;
        } else {
            temp = stops.get(loadedStop).stopIdLong
        }

        while (i<stops.count) {
            if(stops.get(i).stopObjectType != "nearby") {
                map.removeMapObject(stops.get(i).mapCircle);
                stops.remove(i);
            } else {
                i++;
            }
        }
        if (temp != "") {
            for (i=0;i<stops.count;++i) {
                if (temp == stops.get(i).stopIdLong) {
                    loadedStop = i
                    stopsView.currentIndex = i
                }
            }
        }
    }

    function loadStop(loadStopIdLong_) {                        // this is called to load/highlight stop on map from outside of route page

        var stopIdLong_

        if (loadStopIdLong_) {
            stopIdLong_ = loadStopIdLong_
        } else {
            stopIdLong_ = loadStopIdLong
            loadStopIdLong = ""
        }

        if (stopIdLong_ != "") {                                // got request to show stop
            if (loadedStop != -1) {                             // unhighlight current stop
                stops.get(loadedStop).mapCircle.color=passiveBusStopColor
            }
            for (var ii=0; ii < stops.count; ++ii) {    // check if stop is already loaded in stopsModel
                if (stops.get(ii).stopIdLong == stopIdLong_) {  // if it's loaded - just highlight it and center map on it
                    if (loadedStop != ii) {
                        stops.get(ii).mapCircle.color=activeBusStopColor
                        map.center = stops.get(ii).mapCircle.center
                        loadedStop = ii
                        stopsView.currentIndex = ii
                        return
                    }
                }
            }
            JS.__db().transaction(
                function(tx) {
                    try {var rs = tx.executeSql("SELECT stopIdLong, stopName, stopIdShort, stopLongitude, stopLatitude, stopAddress FROM Stops WHERE stopIdLong=?", [stopIdLong_]) }
                    catch (e) { console.log("route: loadStop EXCEPTION: "+ e) }
                    if (rs.rows.length > 0) {
                        console.log("route.qml: adding stop to the map")
                        addStop(rs.rows.item(0).stopIdLong, rs.rows.item(0).stopIdShort, rs.rows.item(0).stopName, rs.rows.item(0).stopLongitude, rs.rows.item(0).stopLatitude, rs.rows.item(0).stopAddress,"line")
                        map.center = stops.get(stops.count-1).mapCircle.center
                        stops.get(stops.count-1).mapCircle.color=activeBusStopColor
                        stopsView.currentIndex = stops.count-1
                        loadedStop = stops.count-1
                    } else {
                        addStop(stopIdLong_, rs.rows.item(0).stopIdShort, rs.rows.item(0).stopName, rs.rows.item(0).stopLongitude, rs.rows.item(0).stopLatitude, rs.rows.item(0).stopAddress,"line")
                        stopReachLoader.sendMessage({"searchString":stopIdLong_})
                    }
                }
            )
        }
    }

    function loadLine(loadLineIdLong_) {

        var lineIdLong_

        if (loadLineIdLong_) { // check if argument is supplied
            lineIdLong_ = loadLineIdLong_;
        } else {               // if no argument - use page property value
            lineIdLong_ = loadLineIdLong
            loadLineIdLong = ""
        }

        if (lineIdLong_ != "") {
            if (loadedLine != -1) {                                             // some line shape is loaded
                if (lineIdLong_ == lines.get(loadedLine).lineIdLong) {          // requested line already loaded
                    return
                } else {
                    map.removeMapObject(lines.get(loadedLine).lineShape)
                }
            }

            if (loadedLine != -1 || loadedStop != -1) {
                cleanStops()
                loadedLine = -1
            }

            for (var ii=0; ii < lines.count; ++ii) {              // check if line is already in lines model
                if (lines.get(ii).lineIdLong == lineIdLong_) {
                    map.addMapObject(lines.get(ii).lineShape)
                    loadedLine = ii
                    lineStopsLoader.sendMessage({"searchString":lineIdLong_})
                    lineLabel.text = lines.get(ii).lineIdShort + " -> " + lines.get(ii).lineEnd
                    return
                }
            }
            try { lines.append({ "lineIdLong": lineIdLong_, "lineShape" : Qt.createQmlObject('import Qt 4.7; import QtMobility.location 1.2;' +
                                                            'MapPolyline { id: "lineShape' + lines.count +
                                                            '"; border { color: "'+busLineColor+'"; width: 6 }' +
                                                            '}', map)
                             }) }
            catch (e) {
                console.log("route.qml: loadLine exception " + e)
                lineIdLong_ = ""
                return
            }
            console.log("route.qml: loadLine: added one more line: " + lines.count)
            lineLoader.sendMessage({"lineIdLong" : lineIdLong_});
            loadedLine = lines.count - 1
            map.addMapObject(lines.get(lines.count-1).lineShape)
        }
    }
    function addStop(stopIdLong_, stopIdShort_, stopName_, stopLongitude_, stopLatitude_, stopAddress_, stopObjectType_) {
        try { stops.append({ "stopIdLong": stopIdLong_, "mapCircle" : Qt.createQmlObject('import Qt 4.7; import QtMobility.location 1.2;' +
                                                        'MapCircle{ id: "lineStop' + stopIdLong_ +
                                                        '"; center : Coordinate { longitude : ' + stopLongitude_ +
                                                        '; latitude : ' + stopLatitude_ +
                                                        '} color : "'+ passiveBusStopColor + '"; radius: 32.0' +
                                                        '; property string stopIdShort : "' + stopIdShort_ +
                                                        '"; property string stopIdLong : "' + stopIdLong_ +
                                                        '"; property string stopName : "' + stopName_ +
                                                        '"; property string stopAddress : "' + stopAddress_ +
                                                        '"; MapMouseArea { anchors.fill: parent; onClicked: {' +
                                                        ' if (loadedStop == -1 || stops.get(loadedStop).stopIdLong != stopIdLong) {' +
                                                        ' routePage.loadStop(stopIdLong); color="'+activeBusStopColor+'"; }'+
                                                        ' if (routePage.state == "hideStops") routePage.showError("" + stopIdShort + ": " + stopName) }' +
                                                        'onDoubleClicked: { routePage.stopInfo(stopIdLong) }' +
                                                        '} }', map),
                               "stopIdShortName" : "" + stopIdShort_ + "-" + stopName_,
                               "stopObjectType" : stopObjectType_
                         }) }
        catch (e) {
            console.log("route.qml: addStop exception " + e)
        }
        map.addMapObject(stops.get(stops.count-1).mapCircle)
    }

    function scaleStops() {
        var radius_ = 30;
        switch(map.zoomLevel) {
            case 20 : radius_ = 4; break;
            case 19 : radius_ = 8; break;
            case 18 : radius_ = 16; break;
            case 17 : radius_ = 24; break;
            case 15 || 16 : radius_ = 32; break;
            case 14 : radius_ = 64; break;
            case 13 : radius_ = 96; break;
            case 12 : radius_ = 128; break;
            default: radius_ = 32;
        }
        for (var ii=0; ii < stops.count; ++ii) {
            stops.get(ii).mapCircle.radius = radius_
        };
        positionCircle.radius = radius_
    }
}
