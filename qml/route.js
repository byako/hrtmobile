//-------------------------------------- ** --------------------------------------------
//  WorkerScript to build line shape on map
//
//-------------------------------------- ** --------------------------------------------
WorkerScript.onMessage = function (message) {
        __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
        __db.transaction(
            function(tx) {
                try { var rs = tx.executeSql("SELECT lineShape FROM Lines WHERE lineIdLong=?", [message.lineIdLong]) }
                catch(e) {  }
                if (rs.rows.length > 0) {  // found offline line shape
                    var coords = new Array
                    var lonlat = new Array
                    coords = rs.rows.item(0).lineShape.split("|")
                    for (var ii=0;ii<coords.length;++ii) {
                        lonlat = coords[ii].split(",")
                        WorkerScript.sendMessage({"longitude" : lonlat[0], "latitude" : lonlat[1]})
                    }
                    lonlat = coords[0].split(",")
                    WorkerScript.sendMessage({"longitude" : "finish", "latitude" : message.lineIdLong, "longit" : lonlat[0], "latit" : lonlat[1]})
                } else { // load line staight from network
                    console.log("Loading line shape " + message.lineIdLong + "from Network")
                    var lonlat
                    var doc = new XMLHttpRequest()
                        doc.onreadystatechange = function() {
                            if (doc.readyState == XMLHttpRequest.DONE) {
                                if (doc.responseXML == null) {
                                    return
                                } else {
                                    var coords = doc.responseXML.documentElement.firstChild.childNodes[7].firstChild.nodeValue.split("|")
                                    for (var ii=0;ii<coords.length;++ii) {
                                        lonlat = coords[ii].split(",")
                                        WorkerScript.sendMessage({"longitude" : lonlat[0], "latitude" : lonlat[1]})
                                    }
                                    WorkerScript.sendMessage({"longitude" : "finish", "latitude" : message.lineIdLong})
                                }
                            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                            }
                        }
                    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&epsg_out=wgs84&query="+message.lineIdLong); // for line info request
                    doc.send();
                }
            }
        )
}

