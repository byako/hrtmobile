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
// here we manually parse clean http, searching for a "special" places in body
    var midpoints = new Array;
    var tables = new Array;
    var lines = new Array;
    var times = new Array;
    var one = new Array;
    var two = new Array;
    var three = new Array;
    var cur=0;
    var day = 0;
    var midpoint = 0;
    var temp = ""

// get last symbol from lineIdLong - get the direction
//      - will save only 1 direction for now. other one will be saved when user will check it
    var direction = lineTemplate.slice(-1)

    // mess here TODO: clean up this hack
    if (direction == 2) {
        direction = 0
    }

    lines = text_.split("\n");

//  fetching tables start lines and type of table:
//      - two-column with midpoints
//      - three column regular
    for (var ii=0; ii < lines.length; ++ii) {  // looking for a table header
        if (lines[ii].search("line_dirtitle") != -1) {
            tables.push(ii);
            if (lines[ii+1].search("midpoint_title") != -1) {
                midpoint = 1
            }
        }
    }

// seek and parse all six tables
    for (var ii=0; ii<tables.length; ++ii) {
        if (ii%2 != direction) {
            if (ii < 2) {         // 1st and 2nd tables are Mon-Fri
                day = 0
            } else if (ii < 4) {  // 3rd and 4th - Sat
                day = 1
            } else {              // 5th and 6th - Sun
                day = 2
            }
            // cur = start line of nex table to parse
            cur = tables[ii]

            if (midpoint == 1) {
                times = lines[cur+1].replace(/\&nbsp\;/g, "").replace(/\<br \/\>/g, "").match(/\<td.*?\<\/td/g)
                for (var bb=0;bb<times.length;++bb) {
                    midpoints.push( times[bb].replace(/\<td.*\>/,"").replace("</td",""))
                }
                while (lines[cur].search("</table") == -1) {
                    if (lines[cur].search("mid_bus") != -1) {
                        times = lines[cur].replace(/\&nbsp\;/g,"").replace(/\ /g,"").split("<td")
                        for (var bb=0;bb<times.length;++bb) {
                            if (times[bb] != "") {
                                WorkerScript.sendMessage({"departTime" : times[bb].replace(/.*\>/,"").replace(/\&nbsp\;/g,"").replace(/\ /g,""),
                                                      "departDay" : day,
                                                      "departMidpoint" : midpoints[bb]})
                            }
                        }
                    }
                    cur++
                }
            } else {
                while (lines[cur-1].search("</table>") == -1) {
                    if (lines[cur].search("time") != -1) {
                        times = lines[cur].replace(/\ /g,"").replace(/\&nbsp\;/g,"").replace(/\<\/*?sup\>/g,"").split("<td")
                        one.push(times[1].replace(/.*?>/g,""))
                        two.push(times[2].replace(/.*?>/g,""))
                        temp = times[3].replace(/<.*?>/g,"").replace(/.*?>/g,"")
                        if (temp != "") {
                            three.push(temp)
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
}

