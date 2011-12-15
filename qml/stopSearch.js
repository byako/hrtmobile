//-------------------------------------- ** --------------------------------------------
//  WorkerScript to get fast list of corresponding places/stops. Uses geocoding
//
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function(message) {
    var doc = new XMLHttpRequest()
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
            var a = doc.responseXML.documentElement
            var lonlat = new Array
//            var coords = new String
            for (var ii = 0; ii < a.childNodes.length; ++ii) { // check all entries in retrieved QML, filter out all who's not "stop"
                if (a.childNodes[ii].childNodes[0].firstChild.nodeValue == "stop") {
                    __db.transaction( // check if we have this stop in DB already
                        function(tx) {
                            /* check if found stop is already in database */
                            try { var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue]); }
                            catch (e) { console.log("StopSearch worker exception: " + e); return; }
                            if (rs.rows.length > 0) {
                               // REMOVE THIS AFTER DEBUG
                               for (var bb=0; bb<rs.rows.length; ++bb) {
                                   console.log("Found" + a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue + " already in database: " +
                                               rs.rows.item(bb).stopIdLong +";"+ rs.rows.item(bb).stopName)
                                   WorkerScript.sendMessage({"state":"load", "stopIdLong":rs.rows.item(bb).stopIdLong})
                               }
                               return
                            } else {  // save basic data
                                lonlat = a.childNodes[ii].childNodes[6].firstChild.nodeValue.split(",")
                                try { rs = tx.executeSql('INSERT INTO Stops VALUES(?,?,?,?,?,?,?,?)', [a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue,
                                                                                                       a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue,
                                                                                                       a.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                                                                                       "",
                                                                                                       a.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                                                                                     lonlat[0],
                                                                                                     lonlat[1], false]) }
                                catch (e) { console.log("StopSearch worker exception 2: " + e); return; }
                                for (var g=0; g < a.childNodes[ii].childNodes[7].childNodes[3].childNodes.length; ++g) {
                                    try {
                                        lonlat = a.childNodes[ii].childNodes[7].childNodes[3].childNodes[g].firstChild.nodeValue.split(":");
                                        tx.executeSql("INSERT INTO stopLines VALUES(?,?,?)", [a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue,
                                                                                              lonlat[0],lonlat[1]])
                                    } catch (e) {
                                        console.log("StopSearch worker exception 3: " + e)
                                    }
                                }
                                console.log("StopSearch: saved stop " + a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue)
                                WorkerScript.sendMessage({"stopIdShort": a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue,
                                                          "stopIdLong" : a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue,
                                                          "stopAddress" : "",
                                                          "stopCity" : a.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                                          "stopName" : a.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                                          "stopLongitude" : lonlat[0],
                                                          "stopLatitude" : lonlat[1],
                                                          "state" : "online"
                                                         })
                            }
                        }
                    )
                }
            }
            WorkerScript.sendMessage({"stopIdShort": "FINISHED"});
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            showError("Request error. Is Network available?")
        }
    }
    // offline search first
    console.log("stopSearch.js: Offline stop search initiated");
    __db_offline = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    __db_offline.transaction (// check if we have this stop in DB already
        function(tx) {
            /* check if requested stop is already in database */
            try { var rs = tx.executeSql('SELECT stopIdLong FROM Stops WHERE stopIdLong=? OR stopIdShort=? or stopName=? OR stopAddress=?', [message.searchString,message.searchString,message.searchString,message.searchString]); }
            catch (e) { console.log("stopSearch worker exception: " + e) }
            if (rs.rows.length > 0) {
               for (var bb=0; bb<rs.rows.length; ++bb) {
                   // REMOVE THIS AFTER DEBUG
                   console.log("Found already in database: " + rs.rows.item(bb).stopIdLong)
                   WorkerScript.sendMessage({"state":"load", "stopIdLong":rs.rows.item(bb).stopIdLong})
               }
               return
            }
        }
    )
    console.log("stopSearch.js: Online stop search initiated");

    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=geocode&user=byako&epsg_out=wgs84&pass=gfccdjhl&format=xml&key=" + message.searchString)
    doc.send();
}
