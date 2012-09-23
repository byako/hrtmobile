//-------------------------------------- ** --------------------------------------------
//  WorkerScript to fetch and load omatlahdot-schedule of stop
//  Use Omatlahdot API - adjustable length of list and time
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {

    var scheduleHtmlReply = new XMLHttpRequest()
    scheduleHtmlReply.onreadystatechange = function() {
        if (scheduleHtmlReply.readyState == XMLHttpRequest.DONE) {
            parseHttp(scheduleHtmlReply.responseText)
        } else if (scheduleHtmlReply.readyState == XMLHttpRequest.ERROR) {
            WorkerScript.sendMessage({"depTime":"ERROR"});
        }
    }
    scheduleHtmlReply.open("GET","http://www.omatlahdot.fi/omatlahdot/web?command=embedded&action=view&o=1&s=" + message.searchString +
                           (message.linesCount ? "&c=" + message.linesCount : "" ) );
    scheduleHtmlReply.send()
}

function parseHttp(text_) {
    var text = new String;
    var lines = new Array;r
    var times = new Array;
    var td = new Array;
    text = text_;    // TODO : remove redundant text var
    lines = text.split("\n");
    for (var ii=0; ii < lines.length; ++ii) {
        if (lines[ii].search("id=\"departures\"") != -1) {
            times = lines[ii].split("<tr class='")
        }
    }
    for (var ii=1; ii<times.length; ++ii) {
        td = times[ii].split("<td class='");
        WorkerScript.sendMessage({"depTime":td[1].slice(td[1].search(">")+1,td[1].search("</td>")),
                              "depLine":td[2].slice(td[2].search(">")+1,td[2].search("</td>")),
                              "depDest":td[3].slice(td[3].search(">")+1,td[3].search("</td>")),
                                     "depCode":""
                                 })
    }
}
