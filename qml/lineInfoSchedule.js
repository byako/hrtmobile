// -------------------------------------- ** --------------------------------------------
// Here we recieve message with stopIdLong field, to get the schedule URL from database.
// Retrieve the schedule HTML page from server and parse it. save all in database
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    var scheduleURL = ""
    var lineTemplate = ""
    var scheduleHtmlReply = new XMLHttpRequest()
    scheduleHtmlReply.onreadystatechange = function() {
        if (scheduleHtmlReply.readyState == XMLHttpRequest.DONE) {
            parseHttp(scheduleHtmlReply.responseText, message.lineIdLong)
        } else if (scheduleHtmlReply.readyState == XMLHttpRequest.ERROR) {
            console.log("Request error. Is Network available?")
            WorkerScript.sendMessage({"result": "error"})
        }
    }
    __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    __db.transaction(
        function(tx) {
                    try { var rs = tx.executeSql("SELECT lineSchedule FROM Lines WHERE lineIdLong=?", [message.lineIdLong]) }
            catch(e) { console.log("EXCEPTION: " + e) }
            if (rs.rows.length > 0) {
                scheduleURL = rs.rows.item(0).lineSchedule
                lineTemplate = message.lineIdLong.slice(0,-1)
            }
        }
    )
    if (scheduleURL == "") {
        console.log("didn't find URL in database");
        WorkerScript.sendMessage({"result": "error"})
        return
    }
    scheduleHtmlReply.open("GET",scheduleURL)
    scheduleHtmlReply.send()
}

function parseHttp(text_, lineTemplate) {      // parse schedule reittiopas http page  : TODO: switch to use local vars

    // get last symbol from lineIdLong - get the direction. save only 1 direction for now. other will be saved when user will check it
    var tables = new Array;
    var lines = new Array;
//    var text = new String;
    var times = new Array;
    var one = new Array;
    var two = new Array;
    var three = new Array;
    var cur=0;
    var day = 0
    var direction = lineTemplate.slice(-1)

    if (direction == 2) {
        console.log ("direction was 2, decreasing by 2")
        direction = 0
    }

//    text = text_;
    lines = text_.split("\n");

    console.log("lineTemplate is : " + lineTemplate)

    for (var ii=0; ii < lines.length; ++ii) {  // looking for a table header
        if (lines[ii].search("line_dirtitle") != -1) {
            tables.push(ii);
            console.log("line " + ii + " : " + lines[ii]);
        }
    }

    for (var ii=0; ii<tables.length; ++ii) {
        if (ii%2 != direction) {
            if (ii < 2) {         // 1st and 2nd tables are Mon-Fri
                day = 0
            } else if (ii < 4) {  // 3rd and 4th - Sat
                day = 1
            } else {              // 5th and 6th - Sun
                day = 2
            }

            cur = tables[ii]
            while (lines[cur-1].search("</table>") == -1) {
                if (lines[cur].search("time") != -1) {
                    times = lines[cur].split("<")
                    one.push(times[1].slice(times[1].length-5))
                    two.push(times[2].slice(times[2].length-5))
                    if (times[3].slice(times[3].length-1) != ";") {
                        three.push(times[3].slice(times[3].length-5))
                    }
                }
                cur++
            }

            while (one.length > 0) {
                WorkerScript.sendMessage({"departTime" : one.shift(), "departDay":day})
            }
            while (two.length > 0) {
                WorkerScript.sendMessage({"departTime" : two.shift(), "departDay":day})
            }
            while (three.length > 0) {
                WorkerScript.sendMessage({"departTime" : three.shift(), "departDay":day})
            }
        }
    }
}

