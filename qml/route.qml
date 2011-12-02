import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "database.js" as JS
import com.nokia.extras 1.0

Item {
    id: routePage
    property bool firstRun: true
    property bool findStops: false
    property string loadStop: ""
    property string loadLine: ""
    property int loadedLine: -1
    property int loadedStop: -1
    signal stopInfo(string stopIdLong_)
    width: 480
    height: 745
//    Component.onCompleted: { checkLoadStop(); checkLoadLine(); }

    InfoBanner {             // info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    WorkerScript {  // line shape loader
        id: loader
        source: "route.js"

        onMessage: {
            if (messageObject.longitude == "finish") {
                if (loadedStop == -1) {
                    map.center.longitude = messageObject.longit
                    map.center.latitude = messageObject.latit
                    positionCircle.center.longitude = messageObject.longit
                    positionCircle.center.latitude = messageObject.latit
                }
            } else if (messageObject.longitude == "error"){
                lines.get(ii).lineShape.destroy()
                lines.remove(lines.count-1)
            } else {
                temp.longitude = messageObject.longitude
                temp.latitude = messageObject.latitude
                lines.get(lines.count-1).lineShape.addCoordinate(temp)
            }
        }
    }
    WorkerScript {  // nearby stops loader
        id: stopsSearch
        source: "mapStopsSearch.js"
        onMessage: {                  // check if stop is already on the map before adding; leave if found
            for (var ii=0; ii < stopsLoaded.count; ++ii) {
                if (stopsLoaded.get(ii).stopIdLong == "" + messageObject.stopIdLong) {
                    console.log("Stop " + messageObject.stopIdLong + " is already on map. Skipping")
                    return
                }
            }
            stopsLoaded.append({"stopIdLong" : messageObject.stopIdLong,
                                "longitude" : messageObject.longitude,
                                "latitude" : messageObject.latitude,
                                "status" : 0 })
            console.log("MAP: CREATING STOP " + messageObject.stopIdLong + "; Coords: " + messageObject.longitude + ":" + messageObject.latitude + " ; Distance: " + messageObject.distance);
            stopInfoLoad.sendMessage({"stopIdLong" : messageObject.stopIdLong})
            map.addMapObject(Qt.createQmlObject('import Qt 4.7; import QtMobility.location 1.2;' +
                                                'MapCircle{ id: mapStop' + messageObject.stopIdLong +
                                                '; center : Coordinate { longitude : ' + messageObject.longitude +
                                                '; latitude : ' + messageObject.latitude +
                                                '} color : "#80FF0000"; radius: 30.0' +
                                                '; signal pupUp()' +
                                                '; property string stopIdLong : "" +' + messageObject.stopIdLong +
                                                '; property string distance : "" + ' + messageObject.distance +
                                                '; MapMouseArea { anchors.fill: parent; onClicked: { routePage.pupUp(stopIdLong) } }' +
                                                '}', map))

        }
    }
    WorkerScript {  // nearby stops info load
        id: stopInfoLoad
        source: "lineInfo.js"
        onMessage: {
            for (var ii=0; ii < stopsLoaded.count; ++ii) {
                if (stopsLoaded.get(ii).stopIdLong == "" + messageObject.stopIdLong) {
                    console.log("received info about " + messageObject.stopIdLong)
                    if (messageObject.stopName == "Error") { // in case if server returned an error, don't repeat queries
                        stopsLoaded.set(ii, {"status" : "-1"})
                        return
                    }
                    stopsLoaded.set(ii,{"stopAddress" : messageObject.stopAddress, "stopName" : messageObject.stopName})
                    if (stopsLoaded.get(ii).status == "2") {
                        stopsLoaded.set(ii, {"status" : "1"})
                        infoBanner.text = "Name: " + messageObject.stopName + " Address: " + messageObject.stopAddress
                        infoBanner.show()
                    }
                    break
                }
            }
        }
    }

    ListModel { id: stops }
    ListModel { id: lines }

    PositionSource {// gps data receiver
        id: positionSource
        updateInterval: 10000
        active: false //(loadStop == loadLine) ? true : false
        onPositionChanged: {
            console.log("position chhanged. distance from previous: " + position.coordinate.distanceTo(positionCircle.center) );
            if (position.coordinate.distanceTo(positionCircle.prev) > 100 || firstRun == true) {
                firstRun = false
                console.log("New position: lon: " + position.coordinate.longitude + "; lan: " + position.coordinate.latitude)
                if (findStops) {
                    stopsSearch.sendMessage({"longitude" : position.coordinate.longitude, "latitude" : position.coordinate.latitude})
                }
                positionCircle.center = position.coordinate
                map.center = position.coordinate
            }

        }
    }

    MapPolyline {
        id: lineShape
        border { color: "#ff0000"; width: 4; }
    }
    Coordinate { id: temp }

    Map {        
        id: map
        z : 1
        plugin : Plugin {
            name : "nokia"
//            parameters: PluginParameter {
//                name: "mapping.app_id"
//                value: WrBja0-QSlb_Ei59BA6s
//                mapping.token: kAwbj6b1hMhgcPfFR148lQ%3D%3D
//                mapping.secret: MosYa80xjv5tZQmoAN6N
//            }
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
            MapMouseArea {
                onClicked: {
                    console.log("Me touched!");
                }
/*                onPositionChanged: {
                    positionCircle.center = mouse.coordinate
                }*/
            }
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

        ButtonColumn {
            id: mapButtons
            z: 5
            width: 60
            height: 120
            opacity: 0.7
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            style: ButtonStyle {
                inverted: true
            }
            Button {
                id: zoomIn
                checkable: false
                text: "+"
                onClicked: {
                    map.zoomLevel += 1
                }
            }
            Button {
                id: zoomOut
                checkable: false
                text: "-"
                onClicked: {
                    map.zoomLevel -= 1
                }
            }
        }
        Button {
            id: statesChangeButton
            width: 100
            anchors.horizontalCenter: map.horizontalCenter
            anchors.top: map.top
            checkable: false
            text: "Info"
            opacity: 0.7
            style: ButtonStyle {
                inverted: true
            }
            onClicked: {
                routePage.state = (map.height == routePage.height) ? "showStops" : "hideStops"
            }
        }
        Button {
            id: showCurrentLocation
            anchors.right: map.right
            anchors.top: map.top
            width: 60
            height: 60
            checkable: true
            iconSource:  "image://theme/icon-s-location-picker"
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
    function pupUp(stopIdLong_) {
        for (var ii=0; ii < stopsLoaded.count; ++ii) {
            if (stopsLoaded.get(ii).stopIdLong == "" + stopIdLong_) {
                if (stopsLoaded.get(ii).status == 0 || stopsLoaded.get(ii).status == 2) { // [2] : waiting status: if still in waiting status - repeat request
                    stopsLoaded.set(ii,{"status" : 2})
                    console.log("STATUS WAS 2")
                    stopInfoLoad.sendMessage({"stopIdLong" : stopIdLong_})
                } else if (stopsLoaded.get(ii).status == -1) {  // [-1] : invalid stop ID, no info on server, got an error from it
                    infoBanner.text = "Error: no info on server"
                    infoBanner.show()
                } else  { // print current ifo
                    infoBanner.text = "Name: " + stopsLoaded.get(ii).stopName + " Address: " + stopsLoaded.get(ii).stopAddress
                    infoBanner.show()
                }
            }
        }
    }
    function showError(stringToShow) {
        infoBanner.text = stringToShow
        infoBanner.show()
    }
    function setCurrentStop(stopIdLong_) {                  // sets normal color to highlighted stop and sets loadedStop to newly highlighted index from stopsModel
        if (loadedStop != -1) {
            stops.get(loadedStop).mapCircle.color = "#80ff0000"
        }
            for (var ii=0; ii < stops.count; ++ii) {
                if (stops.get(ii).stopIdLong == stopIdLong_) {       // search in model for a loaded stop
                            loadedStop = ii
                }
            }
    }

    function checkAddStop(stopIdLong_, stopIdShort_, stopName_, stopLongitude_, stopLatitude_) {
        for (var ii=0; ii < stops.count; ++ii) {            // check if stop is already loaded in stopsModel before adding
            if (stops.get(ii).stopIdLong == stopIdLong_) {
                stops.get(ii).mapCircle.color = "#500f0f000"
                map.center = stops.get(ii).mapCircle.center
                setCurrentStop(stopIdLong_)
                loadStop = ""
                return
            }
        }
        addStop(stopIdLong_, stopIdShort_, stopName_, stopLongitude_, stopLatitude_);

    }

    function checkLoadStop() {
        if (loadStop != "") {                               // got request to show stop
            if (loadedStop == -1 || loadStop != stops.get(loadedStop).stopIdLong) {                   // it's not current stop
                for (var ii=0; ii < stops.count; ++ii) {    // check if stop is already loaded in stopsModel
                    if (stops.get(ii).stopIdLong == loadStop) {
                        stops.get(ii).mapCircle.color = "#500f0f000"
                        map.center = stops.get(ii).mapCircle.center
                        setCurrentStop(loadStop)
                        loadStop = ""
                        return
                    }
                }
                JS.__db().transaction(                      // if need to show not loaded into model stop - look in DB first
                    function(tx) {
                        try {var rs = tx.executeSql("SELECT * FROM Stops WHERE stopIdLong=?", [loadStop]) }
                        catch (e) { console.log("route: checkLoadStop EXCEPTION: "+ e) }
                        if (rs.rows.length > 0) {
                            console.log("route: found " + rs.rows.count + "stops for load stop request: " + loadStop)
                            addStop(rs.rows.item(0).stopIdLong, rs.rows.item(0).stopIdShort, rs.rows.item(0).stopName, rs.rows.item(0).stopLongitude, rs.rows.item(0).stopLatitude)
                            map.center = stops.get(stops.count-1).mapCircle.center
                            stops.get(stops.count-1).mapCircle.color = "#500f0f000"
                            setCurrentStop(loadStop)
                            loadedStop = stops.count-1
                        } else {
                            console.log("didn't find in DB")
                // TODO: here in case we didn't find stop in DB - load data from geocode API - fast and with coords.
                        }
                    }
                )
                loadStop = ""
            } else {
                loadStop = ""
            }
        }  // do nothing if loadStop empty
    }

    function checkLoadLine() {
        if (loadLine != "") {
            if (loadedLine != -1) {       // some line shape is loaded
                if (loadLine == lines.get(loadedLine).lineIdLong) {     // requested line already loaded
                    return
                }
                else {
                    map.removeMapObject(lines.get(loadedLine).lineShape)
                    loadedLine = -1
                }
            }
//            while (lineShape.path.length > 1) lineShape.removeCoordinate(lineShape.path[0])

//            lineShape.removeCoordinate(lineShape.path[0])
//            while (stops.count) {
//                map.removeMapObject(stops.get(stops.count-1).mapCircle)
//            }
            for (var ii=0; ii < lines.count; ++ii) {              // check if line is already in lines model
                if (lines.get(ii).lineIdLong == loadLine) {
                    map.addMapObject(lines.get(ii).lineShape)
                    loadLine = ""
                    loadedLine = ii
                    return
                }
            }
            try { lines.append({ "lineIdLong": loadLine, "lineShape" : Qt.createQmlObject('import Qt 4.7; import QtMobility.location 1.2;' +
                                                            'MapPolyline { id: "lineShape' + lines.count +
                                                            '"; border { color: "#ff0000"; width: 4 }' +
                                                            '}', map)
                             }) }
            catch (e) {
                console.log("route.qml: checkLoadLine exception " + e)
                loadLine = ""
                return
            }
            console.log("added one more line: " + lines.count)
            loader.sendMessage({"lineIdLong" : loadLine});
            loadedLine = lines.count-1
            loadLine = ""
            map.addMapObject(lines.get(lines.count-1).lineShape)
        }
    }
    function addStop(stopIdLong_, stopIdShort_, stopName_, stopLongitude_, stopLatitude_) {
//        console.log("route: adding stop to map: " + stopName_)
        try { stops.append({ "stopIdLong": stopIdLong_, "mapCircle" : Qt.createQmlObject('import Qt 4.7; import QtMobility.location 1.2;' +
                                                        'MapCircle{ id: "lineStop' + stopIdLong_ +
                                                        '"; center : Coordinate { longitude : ' + stopLongitude_ +
                                                        '; latitude : ' + stopLatitude_ +
                                                        '} color : "#80FF0000"; radius: 30.0' +
                                                        '; signal pupUp()' +
                                                        '; property string stopIdShort : "' + stopIdShort_ +
                                                        '"; property string stopIdLong : "' + stopIdLong_ +
                                                        '"; property string stopName : "' + stopName_ +
                                                        '"; MapMouseArea { anchors.fill: parent; onClicked: {' +
                                                          ' if (loadedStop == -1 || stops.get(loadedStop).stopIdLong != stopIdLong) {' +
                                                          ' routePage.setCurrentStop(stopIdLong); color="#500F0F000"; }'+
                                                        ' routePage.showError("" + stopIdShort + ": " + stopName) }' +
                                                        'onDoubleClicked: { routePage.stopInfo(stopIdLong) } ' +
                                                        '} }', map)
                         }) }
        catch (e) {
            console.log("route.qml: addStop exception " + e)
        }

        map.addMapObject(stops.get(stops.count-1).mapCircle)
    }
}
