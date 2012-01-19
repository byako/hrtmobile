// -------------------------------------- ** --------------------------------------------
// Search for a line : first offine, then online
// if save option is specified, save requested line
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {

    var doc = new XMLHttpRequest()
    var resp
    var save = 0
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);

    console.log("lineSearch.js: working")

    try { if (message.save) { console.log("Save line requested: " + message.searchString); save = 1;} }
    catch(e) { console.log("lineSearch.js: exception " +e) }

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.responseXML == null) {
                WorkerScript.sendMessage({"lineIdLong":"NONE"})
                return
            } else {
                resp=doc.responseXML.documentElement
                console.log("lineSearch.js: OK, got " + doc.responseXML.documentElement.childNodes.length+ " lines" + (save ? " : for saving" : " : for search"))
                if (save) {  // push lines to the database with all the data from server
                    for (var ii = 0; ii < resp.childNodes.length; ++ii) {
                        try {
                            rs = tx.executeSql('INSERT INTO Lines VALUES(?,?,?,?,?,?,?,?,?)',
                                       [ resp.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[3].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[7].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[6].firstChild.nodeValue ] );
                        }
                        catch (e) { console.log("lineSearch.js: save exception " + e); }

                        db.transaction(  // save line stops
                            function(tx) {
                                           console.log("Saving stop " + resp.childNodes[ii].childNodes[0].firstChild.nodeValue)
                                for (var cc = 0; cc < resp.childNodes[ii].childNodes[8].childNodes.length; ++cc) {
                                    try { tx.executeSql('INSERT INTO LineStops VALUES(?,?,?)', [resp.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[8].childNodes[cc].firstChild.firstChild.nodeValue,
                                         resp.childNodes[ii].childNodes[8].childNodes[cc].lastChild.firstChild.nodeValue]); }
                                    catch(e) { console.log("EXCEPTION: " + e) }
                                }
                            }
                        )
                    }
                    return
                } else { // save line end. here quick search starts
                    for (var ii = 0; ii < resp.childNodes.length; ++ii) {   // just push info to the page for user-review
                        if (resp.childNodes[ii].childNodes[2].firstChild.nodeValue != "21" &&
                            resp.childNodes[ii].childNodes[2].firstChild.nodeValue != "23" &&
                            resp.childNodes[ii].childNodes[2].firstChild.nodeValue != "24") {
                            var rs;
                            db.transaction( function(tx) { try { rs = tx.executeSql("SELECT lineTypeName FROM LineTypes WHERE lineType=?", [resp.childNodes[ii].childNodes[2].firstChild.nodeValue]) }
                                   catch(e) { console.log("lineSearch.js: lineType search exception: " + e) } } )

                                WorkerScript.sendMessage({"lineIdLong":resp.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                     "lineIdShort" : resp.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                                     "lineStart" : resp.childNodes[ii].childNodes[3].firstChild.nodeValue,
                                                     "lineEnd" : resp.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                                     "lineType" : resp.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                                     "lineTypeName" : (rs.rows.length ? rs.rows.item(0).lineTypeName : ""),
                                                     "favorite" : "false",
                                                     "state" : "online"
                                                 })
                        } else {
                            console.log("lineSearch.js: not sending " + resp.childNodes[ii].childNodes[0].firstChild.nodeValue + " : line type " +
                                    resp.childNodes[ii].childNodes[2].firstChild.nodeValue + " : " +
                                    resp.childNodes[ii].childNodes[5].firstChild.nodeValue);
                        }
                    }
                    WorkerScript.sendMessage({"lineIdLong":"FINISH"})
                }
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            WorkerScript.sendMessage({"lineIdLong":"ERROR"})
        }
    }

    if (! save) { // search only if no save requested
        db.transaction(  // offline search
            function(tx) {
               try { var rs = tx.executeSql("SELECT Lines.lineIdLong, Lines.lineIdshort, Lines.lineName, Lines.lineType, Lines.lineStart, Lines.lineEnd, LineTypes.lineTypeName, favorite FROM Lines LEFT OUTER JOIN LineTypes ON Lines.lineType=LineTypes.lineType WHERE lineIdLong=? OR lineIdShort=?", [message.searchString, message.searchString]) }
               catch(e) { console.log("lineSearch.js: offline search exception: " + e) }
               if (rs.rows.length > 0) {
                   console.log("lineSearch.js: offline found " + rs.rows.length)
                   for (var ii=0; ii < rs.rows.length; ++ii) {
                       WorkerScript.sendMessage({"lineIdLong" : rs.rows.item(ii).lineIdLong,
                                            "lineIdShort" : rs.rows.item(ii).lineIdShort,
                                            "lineStart" : rs.rows.item(ii).lineStart,
                                            "lineEnd" : rs.rows.item(ii).lineEnd,
                                            "lineType" : rs.rows.item(ii).lineType,
                                            "lineTypeName" : rs.rows.item(ii).lineTypeNAme,
                                            "favorite" : rs.rows.item(ii).favorite,
                                             "state" : "offline"
                                            });
                   }
               }
               console.log("lineSearch.js: offline done")
            }
        )
    }
    console.log("lineSearch.js: network search " + (save ? "with save" : "without save") )
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&epsg_out=wgs84&query="+message.searchString + (save ? "" : "&p=111111000"));
    doc.send();
}