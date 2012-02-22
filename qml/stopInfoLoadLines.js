//-------------------------------------- ** --------------------------------------------
//   this workerscript checks in db if lines are loaded for the required stop
//   and loads them from the network in case if there aren't any
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    db_ = openDatabaseSync('hrtmobile', '1.0', 'hrtmobile config database', 1000000)
    db_.transaction(
        function(tx) {
            try { var rs = tx.executeSql("SELECT StopLines.lineIdLong, StopLines.lineEnd, Lines.lineType FROM StopLines LEFT OUTER JOIN Lines ON StopLines.lineIdLong=Lines.lineIdLong WHERE stopIdLong=?",[message.searchString]); }
            catch(e) { console.log("FillLinesModel EXCEPTION: " + e) }
            if (rs.rows.length) {
                for (var i=0; i<rs.rows.length; ++i) {
                    WorkerScript.sendMessage({"lineNumber" : rs.rows.item(i).lineIdLong.substr(1,5),
                                      "lineDest" : rs.rows.item(i).lineEnd})
                }
            } else { // load and save passing lines

                var doc = new XMLHttpRequest()

                doc.onreadystatechange = function() {
                    if (doc.readyState == XMLHttpRequest.DONE) {
                        var a = doc.responseXML.documentElement
                        var lonlat = new Array

                        for (var g=0; g < a.firstChild.childNodes[1].childNodes.length; ++g) {
                            try {
                                lonlat = a.firstChild.childNodes[1].childNodes[g].firstChild.nodeValue.split(":");
                                tx.executeSql("INSERT OR REPLACE INTO StopLines VALUES(?,?,?)", [a.firstChild.childNodes[0].firstChild.nodeValue,
                                    lonlat[0],lonlat[1]])
                                WorkerScript.sendMessage({"lineNumber" : lonlat[0].substr(1,5),
                                                             "lineDest" : lonlat[1]})
                            } catch (e) { console.log("StopSearch worker exception 2: " + e) }
                        }

                        console.log("stopSearch.js: finished search result processing");
                    } else if (doc.readyState == XMLHttpRequest.ERROR) {
                        WorkerScript.sendMessage({"stopIdShort": "SERVER"});
                        showError("Request error. Is Network available? trying to do offline search")
                    }
                }  // doc.onReady function end

                doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=stop&user=byako&pass=gfccdjhl&format=xml&p=1000001000000&code=" + message.searchString);
                doc.send();
            }
        }
    )
}
