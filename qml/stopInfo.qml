import QtQuick 1.1
import com.meego 1.0
import HRTMConfig 1.0

Page {
    id: stopInfoPage
    tools: commonTools
    HrtmConfig {id: config}
    objectName: "stopInfoPage"

    Rectangle{       // dark background
        color: config.bgColor;
        anchors.fill: parent
        width: parent.width
        height:  parent.height
    }

    Label{     // error label
        Rectangle{
            color: "#606060"
            radius: 10
            anchors.fill: parent
            width: parent.width
            height:  parent.height
        }
        id: errorLabel;
        text: qsTr("Error. Wrong stop ID ?")
        anchors.bottomMargin: 100
        anchors.centerIn: parent
        visible : false
        font.pixelSize: 30
        color: config.textColor
    } // error label end

    Item {          // search box
        id: searchBox
        width: 240
        height: 35
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        Rectangle{
            anchors.top: parent.top
            anchors.left: parent.left
            width: 240
            height: parent.height
            color: "#7090AA"
            radius: 15
            TextInput{
                id: stopId
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                width: parent.width
                height: parent.height
                maximumLength: 16
                onFocusChanged: {
                    focus == true ? openSoftwareInputPanel() : closeSoftwareInputPanel()
                    focus == true ? text = qsTr("") : null
                }
                onAccepted: buttonClicked()
                font.pixelSize: 30
                color: config.textColor
                text: "Enter StopID"
            }
        }
       Button{
            id: searchButton
            anchors.right: parent.right
            anchors.top: parent.top
            text: qsTr("Show info")
            width: 200
            height: parent.height
            onClicked: buttonClicked()
        }
    } // searchBox end

    Rectangle {     // HR separator
        id: hrLineSeparator
        anchors.left: parent.left
        anchors.top: searchBox.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }

    Rectangle{      // data
        id: dataRect
        anchors.left: parent.left
        anchors.top:  searchBox.bottom
        anchors.topMargin: 10
        anchors.right: parent.right
        height: 120
        width: parent.width
        color: config.bgColor
        radius: 10
        visible: false
        Label {
            id: stopNameLabel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 5
            text: qsTr("Name")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopName;
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 10
            text: qsTr("Name")
            color: config.textColor
            font.pixelSize: 25
            visible: false
        }
        Label {
            id: stopAddressLabel
            anchors.top: stopNameLabel.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            text: qsTr("Address")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopAddress;
            anchors.top: stopName.bottom
            anchors.topMargin: 13
            anchors.right: parent.right
            text: qsTr("Address")
            color: config.textColor
            font.pixelSize: 25
            visible: false
        }
        Label {
            id: stopCityLabel;
            anchors.top: stopAddressLabel.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            text: qsTr("City")
            color: config.textColor
            font.pixelSize: 30
        }
        Label {
            id: stopCity;
            anchors.right: parent.right;
            anchors.top: stopAddress.bottom
            anchors.topMargin: 13
            text: qsTr("City")
            color: config.textColor
            font.pixelSize: 25
            visible: false
        }
    } // data end

    Rectangle {     // HR separator 2
        id: hrLineSeparator2
        anchors.left: parent.left
        anchors.top: dataRect.bottom
        anchors.topMargin: 5
        width: parent.width
        height:  2
        color: config.textColor
    }

    ListModel{      // Traffic Model (Time depart; Line No)
        id:trafficModel
        ListElement {
            departTime: "Time"
            departLine: "Line"
        }
    }

    Component{
        id:trafficDelegate
        Item {
            width: grid.cellWidth; height:  grid.cellHeight;
            Row {
                spacing: 10;
                anchors.fill: parent;                
                Text{
                    text: departTime
                    font.pixelSize: 25
                    color: trafficModel.get(grid.currentIndex).departLine == departLine ? "#00FF00" : config.textColor
                }
                Text{ text: departLine; font.pixelSize: 25; color: config.textColor}
            }
            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    grid.focus = true;
                    grid.currentIndex = index;
                }
            }
        }
    }

    Rectangle{    // grid rect
        id: infoRect
        anchors.top: dataRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: config.bgColor
        GridView {
            id: grid
            anchors.fill:  parent
            anchors.leftMargin:10
            anchors.topMargin: 10
            delegate: trafficDelegate
            model: trafficModel
            focus: true
            cellWidth: 155
            cellHeight: 30
            width: 420
            highlight: Rectangle { color:config.highlightColor; radius:  5 }
            currentIndex: -1
            clip: true
            visible: false
        }
    } // grid rect end

/*<----------------------------------------------------------------------->*/
    function checkFavorites(){
        removeFavoriteTool.visible = true;
    }

    function parseResponse(a){
        var schedText = new String;
        schedText = a;
        var schedule = new Array;
        var lines = new Array;
        var time_ = Array
        if (schedText.slice(0,5) == "Error") {
            trafficModel.clear();
            errorLabel.visible = true;
            return;
        }
        schedule = schedText.split("\n");
        lines = schedule[0].split("|");
        stopName.text = lines[1];
        stopName.visible = true;
        stopAddress.text = lines[2];
        stopAddress.visible = true;
        stopCity.text = lines[3];
        stopCity.visible = true;
        for (var ii = 1; ii < schedule.length-1; ii++) {
            lines = schedule[ii].split("|");
            time_[0] = lines[0].slice(0,lines[0].length -2)
            time_[1] = lines[0].slice(lines[0].length-2,lines[0].length)
            if (time_[0] > 23) time_[0]-=24
            trafficModel.append({ "departTime" : ""+time_[0]+":"+time_[1], "departLine" : "" + lines[1] })
        }
        grid.focus = true
        grid.visible = true
        grid.currentIndex = 0
        dataRect.visible = true
        addFavoriteTool.visible = true
    }

    function getInfo() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                errorLabel.text = qsTr("Error. Wrong stop ID ?")
                errorLabel.visible = false
                parseResponse(doc.responseText)
            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                trafficModel.clear()
                dataRect.visible = false
                errorLabel.text = qsTr("Request error. Is Network available?")
                errorLabel.visible = True
            }
        }
//              API 1.0 (plaintext) : faster, more informative
        if (stopId.text == "" || stopId.text.length > 7 || stopId.text.length < 4) {
            errorLabel.text = qsTr("Wrong stop ID format")
            errorLabel.visible = true
            return;
        }

        doc.open("GET", "http://api.reittiopas.fi/public-ytv/fi/api/?stop="+ stopId.text +"&user=byako&pass=gfccdjhl");
//              API 2.0 (XML) : slower
//              http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&query="+stopId.text); // for line info request
//              http://api.reittiopas.fi/public-ytv/fi/api/?key="+stopId.text+"&user=byako&pass=gfccdjhl");

        doc.send();
    }

    function buttonClicked() {
        trafficModel.clear()
        errorLabel.visible = false
        searchButton.focus = true
        getInfo()
    }

/*<----------------------------------------------------------------------->*/

}
