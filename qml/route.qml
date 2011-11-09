import QtQuick 1.1
import com.meego 1.0
import QtMobility.location 1.2
import "database.js" as JS
import com.nokia.extras 1.0

Item {
    id: routePage
    property bool firstRun: true
    property string loadStop: ""
    property string loadLine: ""
    property string loadedLine: ""
    property string loadedStop: ""
    anchors.fill: parent

    Component.onCompleted: { checkLoadStop(); checkLoadLine(); }

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
                loadedLine = messageObject.latitude
                if (loadedStop == "") {
                    map.center.longitude = messageObject.longit
                    map.center.latitude = messageObject.latit
                    positionCircle.center.longitude = messageObject.longit
                    positionCircle.center.latitude = messageObject.latit
                }
            } else {
                temp.longitude = messageObject.longitude
                temp.latitude = messageObject.latitude
                lineShape.addCoordinate(temp)
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

    ListModel { id: stopsLoaded }
    ListModel { id: lineStops }
    PositionSource {// gps data receiver
        id: positionSource
        updateInterval: 10000
        active: false //(loadStop == loadLine) ? true : false
        onPositionChanged: {
            console.log("position chhanged. distance from previous: " + position.coordinate.distanceTo(positionCircle.center) );
            if (position.coordinate.distanceTo(positionCircle.center) > 100 || firstRun == true) {
                firstRun = false
                console.log("New position: lon: " + position.coordinate.longitude + "; lan: " + position.coordinate.latitude)
                stopsSearch.sendMessage({"longitude" : position.coordinate.longitude, "latitude" : position.coordinate.latitude})
                positionCircle.center = position.coordinate
                map.center = position.coordinate
            }

        }
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
        size.width: parent.width
        size.height: 500
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        zoomLevel: 14
        center: Coordinate {
            latitude: 60.1636
            longitude: 24.9167
        }
        MapCircle {
            id : positionCircle
            center : Coordinate {
                latitude : 60.1636
                longitude : 24.9167
            }
            color : "#80FF00"
            radius : 30.0
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

        MapPolyline {
            id: lineShape
            border { color: "#ff0000"; width: 4; }
        }

        ButtonRow {
            z: 5
            opacity: 0.8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.left: parent.left
            width: 200
            height: 45
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
            Button {
                id: findMe
                checkable: false
                text: "Me"
                onClicked: {
                    map.center = positionCircle.center
                }
            }
        }
    }

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
    function newCurrentStop(stopIdLong_) {
        for (var ii=0; ii < lineStops.count; ++ii) {
            if (lineStops.get(ii).stopIdLong == loadedStop) {
                console.log("setting old color for " + lineStops.get(ii).stopName)
                lineStops.get(ii).mapCircle.color = "#80ff0000"
                loadedStop = stopIdLong_
                return 0
            }
        }
        loadedStop = stopIdLong_
        return 1
    }

    function checkLoadStop() {
        if (loadStop != "" && loadStop != loadedStop) {
            if (! newCurrentStop(loadStop)) {
                loadedStop = loadStop
                loadStop = ""
                return
            }
            JS.__db().transaction(
                function(tx) {
                    try {var rs = tx.executeSql("SELECT stopLongitude,stopLatitude FROM Stops WHERE stopIdLong=?", [loadStop]) }
                    catch (e) { console.log("route: setCurrent EXCEPTION: "+ e) }
                    if (rs.rows.length > 0) {
                        map.center.longitude = rs.rows.item(0).stopLongitude
                        positionCircle.center.longitude = rs.rows.item(0).stopLongitude
                        map.center.latitude = rs.rows.item(0).stopLatitude
                        positionCircle.center.latitude = rs.rows.item(0).stopLatitude
                        loadedStop = loadStop
                    } else {

                    }
                }
            )
            loadStop= ""
        } else if (!newCurrentStop(loadStop)) {

        }
    }

    function checkLoadLine() {
        if (loadLine != "" && loadLine != loadedLine) {
            while (lineShape.path.length) lineShape.removeCoordinate(lineShape.path[0])
            console.log("Map Cleaned line")
            loader.sendMessage({"lineIdLong" : loadLine});
            loadLine = ""
        }
    }
    function addStop(stopIdLong_, stopIdShort_, stopName_, stopLongitude_, stopLatitude_) {
        try { lineStops.append({ "stopIdLong": stopIdLong_, "mapCircle" : Qt.createQmlObject('import Qt 4.7; import QtMobility.location 1.2;' +
                                                        'MapCircle{ id: "lineStop' + stopIdLong_ +
                                                        '"; center : Coordinate { longitude : ' + stopLongitude_ +
                                                        '; latitude : ' + stopLatitude_ +
                                                        '} color : "#80FF0000"; radius: 30.0' +
                                                        '; signal pupUp()' +
                                                        '; property string stopIdShort : "' + stopIdShort_ +
                                                        '"; property string stopIdLong : "' + stopIdLong_ +
                                                        '"; property string stopName : "' + stopName_ +
                                                        '"; MapMouseArea { anchors.fill: parent; onClicked: { if (routePage.loadedStop != stopIdLong) { routePage.newCurrentStop(stopIdLong); color="#500F0F000"; } routePage.showError("" + stopIdShort + ": " + stopName) } }' +
                                                        '}', map)
                         }) }
//                                                        '} color : ("lineStop" + routePage.currentStop == id ) ? "#80FF0000" : color="#20bb2000" ; radius: 30.0' +
        catch (e) {
            console.log("route.qml: addStop exception " + e)
        }

        map.addMapObject(lineStops.get(lineStops.count-1).mapCircle)
    }
}
