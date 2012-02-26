//-------------------------------------- ** --------------------------------------------
//  WorkerScript to get fast list of corresponding places/stops. Uses HSL geocoding API
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function(message) {

    var doc = new XMLHttpRequest()
    var save = 0
    var state_ = "online"

    var __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (!doc.responseXML) {
                 WorkerScript.sendMessage({"stopState": "SERVER_ERROR"})
                return
            }

            var a = doc.responseXML.documentElement
            var lonlat = new Array

            if (a.childNodes.length == 1) { // save stop: it's either a direct hit or a save request
                __db.transaction(
                    function(tx) {
                        lonlat = a.firstChild.childNodes[6].firstChild.nodeValue.split(",")
                        try { rs = tx.executeSql('INSERT OR REPLACE INTO Stops VALUES(?,?,?,?,?,?,?,?)', [a.firstChild.childNodes[7].childNodes[1].firstChild.nodeValue,
                                                                                               a.firstChild.childNodes[7].childNodes[2].firstChild.nodeValue,
                                                                                               a.firstChild.childNodes[2].firstChild.nodeValue,
                                                                                               a.firstChild.childNodes[7].childNodes[0].firstChild.nodeValue,
                                                                                               a.firstChild.childNodes[5].firstChild.nodeValue,
                                                                                             lonlat[0],
                                                                                             lonlat[1], false]) }
                        catch (e) { console.log("StopSearch worker exception 1: " + e + "\nStop can be saved already from linesInfo.qml"); }

                        // save passing lines
                        console.log("stopSearch.js: saving passing lines for" + a.firstChild.childNodes[7].childNodes[1].firstChild.nodeValue);
                        for (var g=0; g < a.firstChild.childNodes[7].childNodes[4].childNodes.length; ++g) {
                            lonlat = a.firstChild.childNodes[7].childNodes[4].childNodes[g].firstChild.nodeValue.split(":");
                            try { var rs2 = tx.executeSql("INSERT OR REPLACE INTO StopLines VALUES(?,?,?)",
                                    [a.firstChild.childNodes[7].childNodes[1].firstChild.nodeValue,lonlat[0],lonlat[1]]) }
                            catch (e) { console.log("StopSearch worker exception 2: " + e) }
                        }
                    }
                )
                if (message.save) { // if there was a request to save - specify that it's saved intentionally - stopInfo.qml will know that no need to add stop to model,only open it
                    state_ = "saved"
                } else {
                    state_ = "offline"
                }
                console.log("stopSearch.js: saved stop " + a.firstChild.childNodes[7].childNodes[1].firstChild.nodeValue)
                WorkerScript.sendMessage({"stopIdShort": a.firstChild.childNodes[7].childNodes[2].firstChild.nodeValue,
                                          "stopIdLong" : a.firstChild.childNodes[7].childNodes[1].firstChild.nodeValue,
                                          "stopAddress" : a.firstChild.childNodes[7].childNodes[0].firstChild.nodeValue,
                                          "stopCity" : a.firstChild.childNodes[5].firstChild.nodeValue,
                                          "stopName" : a.firstChild.childNodes[2].firstChild.nodeValue,
                                          "stopLongitude" : lonlat[0],
                                          "stopLatitude" : lonlat[1],
                                          "stopState" : state_
                                         })
            } else {
                for (var ii = 0; ii < a.childNodes.length; ++ii) {
                    state_ = "online"
                    __db.transaction( // check if we have this stop in DB already
                        function(tx) {
                            try { var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue]); }
                            catch (e) { console.log("StopSearch worker exception: " + e); return; }

                            if (rs.rows.length) { // if stop is already saved locally
                               state_ = "offline"
                            }
                        }
                    )
                    WorkerScript.sendMessage({"stopIdShort": a.childNodes[ii].childNodes[7].childNodes[2].firstChild.nodeValue,
                                              "stopIdLong" : a.childNodes[ii].childNodes[7].childNodes[1].firstChild.nodeValue,
                                              "stopAddress" : a.childNodes[ii].childNodes[7].childNodes[0].firstChild.nodeValue,
                                              "stopCity" : a.childNodes[ii].childNodes[5].firstChild.nodeValue,
                                              "stopName" : a.childNodes[ii].childNodes[2].firstChild.nodeValue,
                                              "stopLongitude" : lonlat[0],
                                              "stopLatitude" : lonlat[1],
                                              "stopState" : state_
                                             })
                }
            }

            console.log("stopSearch.js: finished search result processing");
            WorkerScript.sendMessage({"stopIdLong": "FINISHED"});
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            WorkerScript.sendMessage({"stopIdShort": "SERVER_ERROR"});
            showError("Request error. Is Network available? trying to do offline search")
        }
    }  // doc.onReady function end

    console.log("stopSearch.js: Online stop search initiated");

    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=geocode&user=byako&epsg_out=wgs84&loc_types=stop&pass=gfccdjhl&format=xml&key=" + message.searchString ) //+ (save == 1 ? "" : "&p=00100110" ) )
    doc.send();
}
