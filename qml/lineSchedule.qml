import QtQuick 1.0
import com.meego 1.0
import HRTMConfig 1.0
Page {
    id: lineSchedulePage
    HrtmConfig { id: config }
    anchors.fill: parent
    tools: commonTools
    property int curPage: 0

    function setPage(page) {
        console.debug("pageView::setPage " + page);
        curPage = page;
    }

    signal menuShow

    Rectangle {
        id: background
        anchors.fill: parent
        width: parent.width
        height:  parent.height
        color: config.bgColor
    }
}
