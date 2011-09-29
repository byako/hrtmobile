// -------------------------------------- ** --------------------------------------------
// Here we recieve message with stopIdLong field, to get the schedule URL from database.
// Retrieve the schedule HTML page from server and parse it. save all in database
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    var scheduleURL = ""
    var scheduleHtmlReply = new XMLHttpRequest()
    scheduleHtmlReply.onreadystatechange = function() {
        if (scheduleHtmlReply.readyState == XMLHttpRequest.DONE) {
            parseHttp(scheduleHtmlReply.responseText)
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
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

function parseHttp(text_) {      // parse schedule reittiopas http page  : TODO: switch to use local vars

    // get last symbol from lineIdLong - get the direction. save only 1 direction for now. other will be saved when user will check it
    scheduleClear();
    var tables = new Array;
    var lines = new Array;
    var text = new String;
    var times = new Array;
    var one = new Array;
    var two = new Array;
    var three = new Array;
    var cur=0;
    text = text_;
    lines = text.split("\n");
    for (var ii=0; ii < lines.length; ++ii) {
        if (lines[ii].search("line_dirtitle") != -1) {
            tables.push(ii);
            console.log("line " + ii + " : " + lines[ii]);
        }
    }

    for (var ii=0; ii<tables.length; ++ii) {
        cur = tables[ii];
        while (lines[cur-1].search("</table>") == -1) {
            if (lines[cur].search("time") != -1) {
                times = lines[cur].split("<");
                one.push(times[1].slice(times[1].length-5));
                two.push(times[2].slice(times[2].length-5));
                if (times[3].slice(times[3].length-1) != ";") {
                    three.push(times[3].slice(times[3].length-5));
                }
            }
            cur++;
        }
        switch (ii) {
        case 0: // Dir 1 MonFri
            while (one.length > 0) {
                scheduleModelDir1MonFri.append({"departTime" : one.shift()});
            };
            while (two.length > 0) {
                scheduleModelDir1MonFri.append({"departTime" : two.shift()});
            }
            while (three.length > 0) {
                scheduleModelDir1MonFri.append({"departTime" : three.shift()});
            }
            break;
        case 1: // Dir 2 MonFri
            while (one.length > 0) {
                scheduleModelDir2MonFri.append({"departTime" : one.shift()});
            };
            while (two.length > 0) {
                scheduleModelDir2MonFri.append({"departTime" : two.shift()});
            }
            while (three.length > 0) {
                scheduleModelDir2MonFri.append({"departTime" : three.shift()});
            }
            break;
        case 2: // Dir 2 MonFri
            while (one.length > 0) {
                scheduleModelDir1Sat.append({"departTime" : one.shift()});
            };
            while (two.length > 0) {
                scheduleModelDir1Sat.append({"departTime" : two.shift()});
            }
            while (three.length > 0) {
                scheduleModelDir1Sat.append({"departTime" : three.shift()});
            }
            break;
        case 3: // Dir 2 MonFri
            while (one.length > 0) {
                scheduleModelDir2Sat.append({"departTime" : one.shift()});
            };
            while (two.length > 0) {
                scheduleModelDir2Sat.append({"departTime" : two.shift()});
            }
            while (three.length > 0) {
                scheduleModelDir2Sat.append({"departTime" : three.shift()});
            }
            break;
        case 4: // Dir 2 MonFri
            while (one.length > 0) {
                scheduleModelDir1Sun.append({"departTime" : one.shift()});
            };
            while (two.length > 0) {
                scheduleModelDir1Sun.append({"departTime" : two.shift()});
            }
            while (three.length > 0) {
                scheduleModelDir1Sun.append({"departTime" : three.shift()});
            }
            break;
        case 5: // Dir 2 MonFri
            while (one.length > 0) {
                scheduleModelDir2Sun.append({"departTime" : one.shift()});
            };
            while (two.length > 0) {
                scheduleModelDir2Sun.append({"departTime" : two.shift()});
            }
            while (three.length > 0) {
                scheduleModelDir2Sun.append({"departTime" : three.shift()});
            }
            break;
        default:
            break;
        }
    }
}

