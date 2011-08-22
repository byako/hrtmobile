import QtQuick 1.0
import com.meego 1.0
import HRTMConfig 1.0
Page {
    id: routePage
    HrtmConfig { id: config }
    anchors.fill: parent
    tools: commonTools

    Rectangle {
        id: background
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        color: config.bgColor
    }


}
