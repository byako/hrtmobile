//-------------------------------------- ** --------------------------------------------
//  WorkerScript to fetch and load info about stop
//  Use Api v2.0 slower, but will give more data: stops, line shape, link for schedule
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function(message)
    var doc = new XMLHttpRequest()
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
//---------------------------------------------------------------------------------------
            __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
            var a = doc.responseXML.documentElement
            var lonlat = Array
            var coords = String
            for (var ii = 0; ii < a.childNodes.length; ++ii) {
                stopAddString += a.childNodes[ii].childNodes[0].firstChild.nodeValue
                stopAddString += ";"
                stopAddString += a.childNodes[ii].childNodes[1].firstChild.nodeValue
                stopAddString += ";"
                stopAddString += a.childNodes[ii].childNodes[2].firstChild.nodeValue
                stopAddString += ";"
                stopAddString += stopAddress.text
                stopAddString += ";"
                stopAddString += a.childNodes[ii].childNodes[4].firstChild.nodeValue
                stopAddString += ";"
                coords = a.childNodes[ii].childNodes[8].firstChild.nodeValue
                lonlat = coords.split(",")
                stopAddString += lonlat[0]
                stopAddString += ";"
                stopAddString += lonlat[1]
                stopAddString += ";"
                __db.transaction(  // stop lines, stop info
                    function(tx) {
                        var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [fields[0]]);
                        if (rs.rows.length > 0) {
                           for (var ii=0; ii<rs.rows.length; ++ii) {
                               console.log("" + rs.rows.item(ii).stopIdLong +";"+ rs.rows.item(ii).stopName)
                           }
                        } else {
                           returnVal = 1
                           try { rs = tx.executeSql('INSERT INTO Stops VALUES(?,?,?,?,?,?,?)', [fields[0],
                                                                                                fields[1],
                                                                                                fields[2],
                                                                                                fields[3],
                                                                                                fields[4],
                                                                                                fields[5],
                                                                                                fields[6]]) }
                           catch(e) { console.log("EXCEPTION: " + e) }
                        }
                        for (var cc=0;cc<a.childNodes[ii].childNodes[6].childNodes.length;++cc) {
                           try {
                               lonlat = a.childNodes[ii].childNodes[6].childNodes[cc].firstChild.nodeValue.split(":");
                               tx.executeSql("INSERT INTO stopLines VALUES(?,?,?)", [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                                                     lonlat[0],lonlat[1]])
                               WorkerScrip.sendMessage({"lineNumber":lonlat[0],"lineDest":lonlat[1]})
                            }
                            catch(e) {
                                console.log("stopInfoLoadInfo.js : Exception during pushing stopLines: CC = " + cc)
                            }
                        }
                        for (var oo=0;oo<a.childNodes[ii].childNodes[9].childNodes.length;++oo) {
                            try{
                                WorkerScrip.sendMessage({"propName" : a.childNodes[ii].childNodes[9].childNodes[oo].nodeName,
                                             "propValue" : a.childNodes[ii].childNodes[9].childNodes[oo].firstChild.nodeValue})
                                tx.executeSql("INSERT INTO stopInfo VALUES(?,?,?)", [a.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                                                     a.childNodes[ii].childNodes[9].childNodes[oo].nodeName,
                                                                                     a.childNodes[ii].childNodes[9].childNodes[oo].firstChild.nodeValue])
                            }
                            catch(e) { console.log("stopInfo: parsing stop info : " + e) }
                        }
                     }
                )
                coords = JS.addStop(stopAddString)
                stopAddString = ""
                if (coords == 1) {
                    showError("Saved stop info: " + stopName.text)
                    fillModel()
                } else if (coords == -1) {
                    showError("ERROR. Stop is not added. Sorry")
                }
            }
//---------------------------------------------------------------------------------------
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            showError("Request error. Is Network available?")
        }
    }

    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=stop&code=" + message.searchString + "&user=byako&pass=gfccdjhl&format=xml")
    doc.send();
}

            infoModel.clear()
            linesModel.clear()
            linesModel.append(
            loadingMap.visible = false
            infoModel.append(
            searchString = a.childNodes[ii].childNodes[0].firstChild.nodeValue
                loadingMap.visible = false
                showMapButtonButton.visible = true
