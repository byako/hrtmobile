import QtQuick 1.0
import com.meego 1.0
import HRTMConfig 1.0
import QtMobility.location 1.2
Page {
    id: routePage
    HrtmConfig { id: config }
    anchors.fill: parent
    tools: commonTools
    orientationLock: PageOrientation.LockPortrait

    Rectangle {
        id: background
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        color: config.bgColor
    }

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
                 color : "#80FF0000"
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
                     lastX = -1
                     lastY = -1
                 }
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
}
