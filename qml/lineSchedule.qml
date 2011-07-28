import QtQuick 1.0
import com.meego 1.0

Page {
    id: lineSchedulePage

Item {
    id: pageView
    anchors.fill: parent

    property int curPage: 0

    function setPage(page) {
        console.debug("pageView::setPage " + page);
        curPage = page;
    }

    signal menuShow

    // *** Background image ***
    Image {
        id: backgroundImage
        source: "images/z_951244fd.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        anchors.fill: parent
        // Make the background "parallax scrolling"
//        x: -gameView.width/8.0 - boardFlickable.contentX/4.0
//        y: -gameView.height/8.0 - boardFlickable.contentY/4.0
    }


 /*   Rectangle {
        id: background
        anchors.fill: parent
        color: "#363534"
    }
*/

    PagePanel {
        id: pagePanel
        currentPage: curPage

        onToLeft:  { curPage-- }
        onToRight: { curPage++ }
        onMenuClicked: { pageView.menuShow() }
    }

    Page1 { currentPage: curPage }
    Page2 { currentPage: curPage }
    Page3 { currentPage: curPage }
    Page4 { currentPage: curPage }
    Page5 { currentPage: curPage }
    Page6 { currentPage: curPage }
    Page7 { currentPage: curPage }
    Page8 { currentPage: curPage }
}

}
