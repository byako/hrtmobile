//-------------------------------------- ** --------------------------------------------
//  WorkerScript to get fast list of corresponding places/stops. Uses geocoding
//
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function(message) {
    var doc = new XMLHttpRequest()
    var search_done = 0
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
            var a = doc.responseXML.documentElement
            var lonlat = new Array
//            var coords = new String
            console.log("stopSearch.js: found " + a.childNodes.length + " stops online")
            for (var ii = 0; ii < a.childNodes.length; ++ii) { // check all entries in retrieved QML, filter out all who's not "stop"
                if (a.childNodes[ii].childNodes[0].firstChild.nodeValue == "stop") {
                    __db.transaction( // check if we have this stop in DB already
                        function(tx) {
                            /* check if found stop is already in database */
                            console.log("Checking if already saved stop " + a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue)
                            try { var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue]); }
                            catch (e) { console.log("StopSearch worker exception: " + e); return; }
                            if (rs.rows.length > 0) {
                               // REMOVE THIS AFTER DEBUG
                               for (var bb=0; bb<rs.rows.length; ++bb) {
                                   console.log("Found " + a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue + " already in database: " +
                                               rs.rows.item(bb).stopIdLong +";"+ rs.rows.item(bb).stopName)
                                   WorkerScript.sendMessage({"state":"load", "stopIdLong":rs.rows.item(bb).stopIdLong})
                               }
                               return
                            } else {  // save basic data
                                lonlat = a.childNodes[ii].childNodes[6].firstChild.nodeValue.split(",")
                                try { rs = tx.executeSql('INSERT INTO Stops VALUES(?,?,?,?,?,?,?,?)', [a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue,
                                                                                                       a.childNodes[ii].childNodes[7].childNodes[2].firstChild.nodeValue,
                                                                                                       a.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                                                                                       a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue,
                                                                                                       a.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                                                                                     lonlat[0],
                                                                                                     lonlat[1], false]) }
                                catch (e) { console.log("StopSearch worker exception 2: " + e); return}
                                for (var g=0; g < a.childNodes[ii].childNodes[7].childNodes[4].childNodes.length; ++g) {
                                    try {
                                        lonlat = a.childNodes[ii].childNodes[7].childNodes[4].childNodes[g].firstChild.nodeValue.split(":");
                                        tx.executeSql("INSERT INTO stopLines VALUES(?,?,?)", [a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue,
                                                                                              lonlat[0],lonlat[1]])
                                    } catch (e) {
                                        console.log("StopSearch worker exception 3: " + e)
                                    }
                                }
                                console.log("stopSearch.js: saved stop " + a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue)
                                WorkerScript.sendMessage({"stopIdShort": a.childNodes[ii].childNodes[7].childNodes[2].firstChild.nodeValue,
                                                          "stopIdLong" : a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue,
                                                          "stopAddress" : a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue,
                                                          "stopCity" : a.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                                          "stopName" : a.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                                          "stopLongitude" : lonlat[0],
                                                          "stopLatitude" : lonlat[1]
//                                                          "state" : "online"
                                                         })
                            }
                        }
                    )
                }
            }
            console.log("stopSearch.js: finished search result");
            WorkerScript.sendMessage({"stopIdShort": "FINISHED"});
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            WorkerScript.sendMessage({"stopIdShort": "SERVER_ERROR"});
            showError("Request error. Is Network available?")
        }
    }
    // offline search first
    console.log("stopSearch.js: Offline stop search initiated");
    __db_offline = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    __db_offline.transaction (// check if we have this stop in DB already
        function(tx) { // in case if lineIdLong was asked - check if it's already in DB
            // try to search in database
            try { var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [message.searchString]); }
            catch (e) { console.log("stopSearch worker exception: " + e) }
            if (rs.rows.length == 1) {
                // REMOVE THIS AFTER DEBUG
                console.log("Found already in database: " + rs.rows.item(bb).stopIdLong)
                WorkerScript.sendMessage(rs.rows.item(bb))
                search_done = 1
            } else {
                console.log("stopSearch.js: This shouldn't happen!")
            }
        }
    )
    if (search_done) {
        return
    }
    console.log("stopSearch.js: Online stop search initiated");

    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=geocode&user=byako&epsg_out=wgs84&loc_types=stop&pass=gfccdjhl&format=xml&key=" + message.searchString)
    doc.send();
}
