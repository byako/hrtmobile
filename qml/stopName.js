//-------------------------------------- ** --------------------------------------------
//   this workerscript fetches the stop basic info from geocode API
//   used to substitute stop IDs with the real stop names on stops section of lineInfo
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    var doc = new XMLHttpRequest()
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.responseText.slice(0,5) == "Error") {
                // check what happens if return stopname equal to "Error" aroung lineInfo.qml
                console.log("Request error. Server returned error for " + message.searchString)
                WorkerScript.sendMessage({"stopIdLong" : message.searchString, "stopName" : "Error"});
            } else {
                var a = doc.responseXML.documentElement
                var lonlat = new Array
                var lines = new String
                lonlat = a.firstChild.childNodes[4].firstChild.nodeValue.split(",")

                    db_ = openDatabaseSync('hrtmobile', '1.0', 'hrtmobile config database', 1000000)
                    db_.transaction(
                        function(tx) {
                            try {
                                tx.executeSql('INSERT INTO Stops VALUES(?,?,?,?,?,?,?,?)', [
                                    a.firstChild.childNodes[0].firstChild.nodeValue,
                                    a.firstChild.childNodes[1].firstChild.nodeValue,
                                    a.firstChild.childNodes[2].firstChild.nodeValue,
                                    a.firstChild.childNodes[5].firstChild.nodeValue,
                                    a.firstChild.childNodes[3].firstChild.nodeValue,
                                    lonlat[0], lonlat[1], "false" ]);
                            }
                            catch(e) { console.log("stopName.js: failed to save basic stop info: " + e) }
                        }
                    )

                WorkerScript.sendMessage({"stopIdLong" : a.firstChild.childNodes[0].firstChild.nodeValue,
                                          "stopName" : a.firstChild.childNodes[2].firstChild.nodeValue,
                                          "stopIdShort" : a.firstChild.childNodes[1].firstChild.nodeValue,
                                          "stopAddress" : a.firstChild.childNodes[5].firstChild.nodeValue
//                                          "stopLongitude" : lonlat[0],
//                                          "stopLatitude" : lonlat[1]

                })
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            console.log("Request error. Is Network available?")
            WorkerScript.sendMessage({"stopIdLong" : message.searchString, "stopName" : "Error"});
        }
    }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=stop&user=byako&pass=gfccdjhl&format=xml&p=1110100010010&code=" + message.searchString);
    doc.send();
}
