//-------------------------------------- ** --------------------------------------------
//  WorkerScript to build line shape on map
//
//-------------------------------------- ** --------------------------------------------
WorkerScript.onMessage = function (message) {
        __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
        __db.transaction(
            function(tx) {
                try { var rs = tx.executeSql("SELECT lineShape,lineIdShort,lineEnd FROM Lines WHERE lineIdLong=?", [message.lineIdLong]) }
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
                    WorkerScript.sendMessage({"longitude" : "finish", "latitude" : message.lineIdLong, "longit" : lonlat[0], "latit" : lonlat[1], "lineIdShort" : rs.rows.item(0).lineIdShort, "lineEnd" : rs.rows.item(0).lineEnd})
                } else { // load line staight from network
                    console.log("Requesting line shape " + message.lineIdLong + " from network")
                    var lonlat;
                    var doc = new XMLHttpRequest()
                        doc.onreadystatechange = function() {
                            if (doc.readyState == XMLHttpRequest.DONE) {
                                if (doc.responseXML == null) {
                                    return
                                } else {
                                    var coords = doc.responseXML.documentElement.firstChild.childNodes[2].firstChild.nodeValue.split("|")
                                    for (var ii=0;ii<coords.length;++ii) {
                                        lonlat = coords[ii].split(",")
                                        WorkerScript.sendMessage({"longitude" : lonlat[0], "latitude" : lonlat[1]})
                                    }
                                    WorkerScript.sendMessage({"longitude" : "finish", "latitude" : message.lineIdLong, "lineIdShort" : doc.responseXML.documentElement.firstChild.childNodes[0].firstChild.nodeValue, "lineEnd" : doc.responseXML.documentElement.firstChild.childNodes[1].firstChild.nodeValue})
                                }
                            } else if (doc.readyState == XMLHttpRequest.ERROR) {
                            }
                        }
                    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&epsg_out=wgs84&p=010010010&query="+message.lineIdLong); // for line info request
                    doc.send();
                }
            }
        )
}

