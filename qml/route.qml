import QtQuick 1.1
import com.meego 1.0
import QtMobility.location 1.2
import "database.js" as JS
import com.nokia.extras 1.0

Page {
    id: routePage
    anchors.fill: parent
    tools: commonTools
    orientationLock: PageOrientation.LockPortrait
    InfoBanner {             // info banner
        id: infoBanner
        text: "info description here"
        z: 10
        opacity: 1.0
    }
    WorkerScript {
        id: loader
        source: "route.js"

        onMessage: {
            temp.longitude = messageObject.longitude
            temp.latitude = messageObject.latitude
            lineShape.addCoordinate(temp)
        }
    }

    WorkerScript {
        id: stopsSearch
        source: "mapStopsSearch.js"

        onMessage: {
            console.log("route.qml: stop: " + messageObject.stopIdLong + "; distance: " + messageObject.distance);
            map.addMapObject(Qt.createQmlObject('import Qt 4.7; import QtMobility.location 1.2;' +
                                                'MapCircle{ id: stop' + messageObject.stopIdLong +
                                                '; center : Coordinate { longitude : ' + messageObject.longitude +
                                                '; latitude : ' + messageObject.latitude +
                                                '} color : "#80FF0000"; radius: 30.0; property string stopIdLong : "" +' + messageObject.stopIdLong +
                                                '; MouseArea { anchors.fill: parent; onClicked: { infoBanner.text = stopIdLong; infoBanner.show() } }' +
                                                '}', map) )
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 10000
        active: true
        onPositionChanged: {
            console.log("position chhanged. distance from previous: " + position.coordinate.distanceTo(circle.center) );
            if (position.coordinate.distanceTo(circle.center) > 100) {
                console.log("New position: lon: " + position.coordinate.longitude + "; lan: " + position.coordinate.latitude)
                stopsSearch.sendMessage({"longitude" : position.coordinate.longitude, "latitude" : position.coordinate.latitude})
                circle.center = position.coordinate
                map.center = position.coordinate
            }

        }
    }

    Component.onCompleted: { loader.sendMessage({"lineIdLong" : loadLine}); setCurrent(); }
    Coordinate {
        id: temp
    }
    property string loadStop: ""
    property string loadLine: ""

/*    Rectangle {
        id: background
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        color: config.bgColor
    }*/
    Map {
        id: map
        z : 1
        plugin : Plugin {
            name : "nokia"
        }
        size.width: parent.width
        size.height: parent.height
        zoomLevel: 14
        center: Coordinate {
            latitude: 60.1636
            longitude: 24.9167
        }
        MapCircle {
            id : circle
            center : Coordinate {
                latitude : 60.1636
                longitude : 24.9167
            }
            color : "#80FF00"
            radius : 30.0
            MapMouseArea {
                onPositionChanged: {
                    if (mouse.button == Qt.LeftButton)
                        circle.center = mouse.coordinate
                    if (mouse.button == Qt.RightButton)
                        circle.radius = circle.center.distanceTo(mouse.coordinate)
                }
            }
        }
        Landmark {
            id: busStop
            name: "Bus Stop 1"
            description: "Bus Stop 2"
            coordinate: Coordinate {
                latitude: 60.1636
                longitude: 24.9167
            }
        }

/*        MouseArea {
            id: mousearea
            property bool __isPanning: false
            property int __lastX: -1
            property int __lastY: -1

            anchors.fill : parent

            onPressed: {
                __isPanning = true
                __lastX = mouse.x
                __lastY = mouse.y
            }

            onReleased: {
                __isPanning = false
            }

            onPositionChanged: {
                if (__isPanning) {
                    var dx = mouse.x - __lastX
                    var dy = mouse.y - __lastY
                    map.pan(-dx, -dy)
                    __lastX = mouse.x
                    __lastY = mouse.y
                }
            }

            onCanceled: {
                __isPanning = false;
            }
        } */
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
                map.center = mouse.coordinate
                map.zoomLevel += 1
                console.log("MAP: zoom level : " + map.zoomLevel)
                lastX = -1
                lastY = -1
            }
        }
/*        PinchArea {
           id: pincharea
           property double __oldZoom
           anchors.fill: parent

           function calcZoomDelta(zoom, percent) {
              return zoom + Math.log(percent)/Math.log(2)
           }
           onPinchStarted: {
              __oldZoom = map.zoomLevel
           }
           onPinchUpdated: {
              map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
           }
           onPinchFinished: {
              map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
           }
        }*/

        MapPolyline {
            id: lineShape
            border { color: "#ff0000"; width: 4; }
        }
    }
    Keys.onPressed: {
        if (event.key == Qt.Key_Plus) {
            map.zoomLevel += 1
        } else if (event.key == Qt.Key_Minus) {
            map.zoomLevel -= 1
        } else if (event.key == Qt.Key_T) {
            if (map.mapType == Map.StreetMap) {
                map.mapType = Map.SatelliteMapDay
            } else if (map.mapType == Map.SatelliteMapDay) {
                map.mapType = Map.StreetMap
            }
        }
    }
//----------------------------------------------------------------------------//
    function setCurrent() {
        if (loadStop != "") {
            console.log("loading stop #" + loadStop)
            JS.__db().transaction(
                function(tx) {
                    try {var rs = tx.executeSql("SELECT stopLongitude,stopLatitude FROM Stops WHERE stopIdLong=?", [loadStop]) }
                    catch (e) { console.log("route: setCurrent EXCEPTION: "+ e) }
                    if (rs.rows.length > 0) {
                        map.center.longitude = rs.rows.item(0).stopLongitude
                        circle.center.longitude = rs.rows.item(0).stopLongitude
                        map.center.latitude = rs.rows.item(0).stopLatitude
                        circle.center.latitude = rs.rows.item(0).stopLatitude
                    }
                }
            )
        }
    }
}
