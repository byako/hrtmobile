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
                            catch (e) { console.log("StopSearch worker exception: " + e) }
                            if (rs.rows.length > 0) {
                               // REMOVE THIS AFTER DEBUG
                               for (var bb=0; bb<rs.rows.length; ++bb) {
                                   console.log("Found already in database: " + rs.rows.item(bb).stopIdLong +";"+ rs.rows.item(bb).stopName)
                               }
                               return
                            } else {
                                lonlat = a.childNodes[ii].childNodes[6].firstChild.nodeValue.split(",")
                                WorkerScript.sendMessage({"stopIdShort": a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue,
                                                          "stopIdLong" : a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue,
                                                          "stopCity" : a.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                                          "stopName" : a.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                                          "stopLongitude" : lonlat[0],
                                                          "stopLatitude" : lonlat[1],
                                                         })
                            }
                        }
                    )
                }
                WorkerScript.sendMessage({"stopIdShort": "FINISHED"});
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            showError("Request error. Is Network available?")
        }
    }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=geocode&user=byako&pass=gfccdjhl&format=xml&key=" + message.searchString)
    doc.send();
}
