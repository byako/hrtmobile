//-------------------------------------- ** --------------------------------------------
//  WorkerScript to fetch and load info about stop
//  Use Api v2.0 slower, but will give more data: stops, line shape, link for schedule
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function(message) {
    var doc = new XMLHttpRequest()
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
//---------------------------------------------------------------------------------------
            __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
            var a = doc.responseXML.documentElement
            var lonlat = new Array
            var coords = new String
            for (var ii = 0; ii < a.childNodes.length; ++ii) {
                coords = a.childNodes[ii].childNodes[8].firstChild.nodeValue
                lonlat = coords.split(",")
                __db.transaction(  // stop lines, stop info
                    function(tx) {
                        /* check if found stop is already in database */
                        var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [a.childNodes[ii].childNodes[0].firstChild.nodeValue]);
                        if (rs.rows.length > 0) {
                           for (var bb=0; bb<rs.rows.length; ++bb) {
                               console.log("Found already in database: " + rs.rows.item(bb).stopIdLong +";"+ rs.rows.item(bb).stopName)
                           }
                           return
                        } else {
                            returnVal = 1
                            // first only push basic info into DB's Stops table
                            try { rs = tx.executeSql('INSERT INTO Stops VALUES(?,?,?,?,?,?,?)', [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                                                                 a.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                                                                                 a.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                                                                                 a.childNodes[ii].childNodes[13].firstChild.nodeValue,
                                                                                                 a.childNodes[ii].childNodes[4].firstChild.nodeValue,
                                                                                                 lonlat[0],
                                                                                                 lonlat[1]]) }
                            catch(e) { WorkerScript.sendMessage({"action" : "FAILED"}); console.log("EXCEPTION: " + e); return }
                            // for every passing line put a record to stopLines table of DB
                            for (var cc=0;cc<a.childNodes[ii].childNodes[6].childNodes.length;++cc) {
                               try {
                                   lonlat = a.childNodes[ii].childNodes[6].childNodes[cc].firstChild.nodeValue.split(":");
                                   tx.executeSql("INSERT INTO stopLines VALUES(?,?,?)", [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                                                         lonlat[0],lonlat[1]])
//                                   WorkerScrip.sendMessage({"lineNumber":lonlat[0],"lineDest":lonlat[1]})
                                }
                                catch(e) {
                                    // if we got an exception while trying to put info in stopLines table, clean all put data from stopLines and basic info from Stops tables
                                    try {
                                        tx.executeSql('DELETE from StopLines WHERE stopIdLong=?',[a.childNodes[ii].childNodes[0].firstChild.nodeValue]);
                                        tx.executeSql('DELETE from Stops WHERE stopIdLong=?', [a.childNodes[ii].childNodes[0].firstChild.nodeValue]);
                                    }
                                    catch(ee) {
                                        console.log("Exception: stopInfoLoadInfo.js : " + ee)
                                    }
                                    console.log("stopInfoLoadInfo.js : Exception during pushing stopLines: CC = " + cc)
                                    WorkerScript.sendMessage({"action" : "FAILED"})
                                    return
                                }
                            }
                            // put all accesibility info in stopInfo table
                            for (var oo=0;oo<a.childNodes[ii].childNodes[9].childNodes.length;++oo) {
                                try{
/*                                    WorkerScrip.sendMessage({"propName" : a.childNodes[ii].childNodes[9].childNodes[oo].nodeName,
                                                 "propValue" : a.childNodes[ii].childNodes[9].childNodes[oo].firstChild.nodeValue})*/
                                    tx.executeSql("INSERT INTO stopInfo VALUES(?,?,?)", [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                                                         a.childNodes[ii].childNodes[9].childNodes[oo].nodeName,
                                                                                         a.childNodes[ii].childNodes[9].childNodes[oo].firstChild.nodeValue])
                                }
                                // if we got an exception while putting info to stopInfo -> clean data from stopLines and Stops tables
                                catch(e) {
                                    if (oo != a.childNodes[ii].childNodes[9].childNodes.length -1) {
                                        try{
                                            tx.executeSql('DELETE from StopLines WHERE stopIdLong=?',[a.childNodes[ii].childNodes[0].firstChild.nodeValue]);
                                            tx.executeSql('DELETE from Stops WHERE stopIdLong=?', [a.childNodes[ii].childNodes[0].firstChild.nodeValue]);
                                            tx.executeSql('DELETE from StopInfo WHERE stopIdLong=?',[a.childNodes[ii].childNodes[0].firstChild.nodeValue]);
                                        }
                                        catch(ee) {
                                            console.log("EXCEPTION: stopInfoLoadInfo.js: " + ee);
                                        }
                                        console.log("stopInfo: parsing stop info : " + e)
                                        WorkerScript.sendMessage({"action" : "FAILED"})
                                        return
                                    }
                                }
                            }
                        }
                    }
                )
                WorkerScript.sendMessage({"stopIdLong" : a.childNodes[ii].childNodes[0].firstChild.nodeValue, "action" : "SAVED"})
            }
//---------------------------------------------------------------------------------------
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            WorkerScript.sendMessage({"action" : "ERROR"})
            showError("Request error. Is Network available?")
        }
    }

    doc.open("GET", "http://api.reittiopas.fi/hsl/1_1_3/?request=stop&user=byako&pass=gfccdjhl&format=xml&code=" + message.searchString)
    doc.send();
}
