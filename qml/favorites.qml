import QtQuick 1.0

Item {
    // -================================ STOPS ==================================-
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
                    // TODO
                }
            }
        }
    }

    // -================================ LINES ==================================-

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
                anchors.horizontalCenter:  parent.horizontalCenter
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: section;
                font.pixelSize: 35;
                color: "#cdd9ff"
            }
        }
    }
    Component {     // lineInfo short delegate
        id:lineInfoShortDelegate
        Item {
            width: linesView.width;
            height: 45
            Text{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                text: lineStart + " -> " + lineEnd;
                font.pixelSize: 25;
                color: "#cdd9ff"
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    if (selectedLineIndex != index) {
                        searchString = lineIdLong
                        selectedLineIndex = index
                        linesView.currentIndex = index
                        tabRect.checkedButton = stopsButton
                        showLineInfo()
                    }
                }
                onPressAndHold: {
                    linesView.currentIndex = index
                    linesContextMenu.open()
                }
            }
        }
    }
    Component {     // lineInfo delegate
        id:lineInfoDelegate
        Item {
            width: linesView.width;
            height: 70
            Column {
                height: parent.height
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: lineTypeName
                    font.pixelSize: 25
                    color: "#cdd9ff"
                }
                Text{
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: lineStart + " -> " + lineEnd;
                    font.pixelSize: 25;
                    color: "#cdd9ff"
                }
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    if (selectedLineIndex != index) {
                        searchString = lineIdLong
                        selectedLineIndex = index
                        showLineInfo()
                    }
                }
                onPressAndHold: {
                    linesView.currentIndex = index
                    linesContextMenu.open()
                }
            }
        }
    }

    //-==========================================================================-
    Item {                   // scheduleView rect
        id: infoRect
        anchors.fill: parent
        ListView {  // stopsView
            id: stopsView
            spacing: 10
            anchors.fill: parent
            delegate:  recentDelegate
            model: recentModel
            highlight: Rectangle { color:"#666666"; radius:  5 }
            currentIndex: -1
            clip: true
        }
        ListView {  // linesView
            id: linesView
            anchors.fill:  parent
            delegate: config.lineGroup == "true" ? lineInfoShortDelegate : lineInfoDelegate
            section.property: config.lineGroup == "true" ? "lineTypeName": ""
            section.delegate: config.lineGroup == "true" ? lineInfoSectionHeader : {} ;
            model: lineInfoModel
            spacing: 5
            highlight: Rectangle { color: "#666666"; radius:  5 }
            currentIndex: -1
            clip: true
            visible: true
        }
    }
}
