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
                WorkerScript.sendMessage({"stopIdLong" : message.stopIdLong, "stopName" : "Error"});
            } else {
                var a = doc.responseXML.documentElement
                var lonlat = new Array
                lonlat = a.childNodes[0].childNodes[6].firstChild.nodeValue.split(",")
                console.log("got coordinates: " + lonlat[0] + ":" + lonlat[1] + " for " + a.childNodes[0].childNodes[2].firstChild.nodeValue)
                WorkerScript.sendMessage({"stopIdLong" : a.childNodes[0].childNodes[7].childNodes[0].firstChild.nodeValue,
                                          "stopIdShort" : a.childNodes[0].childNodes[7].childNodes[1].firstChild.nodeValue,
                                          "stopName" : a.childNodes[0].childNodes[2].firstChild.nodeValue,
                                          "stopCity" : a.childNodes[0].childNodes[5].firstChild.nodeValue,
                                          "stopLongitude" : lonlat[0],
                                          "stopLatitude" : lonlat[1],
                                          "lineReachNumber" : message.lineReachNumber
                })
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            showError("Request error. Is Network available?")
        }
    }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=geocode&user=byako&pass=gfccdjhl&format=xml&epsg_out=wgs84&key=" + message.stopIdLong);
             http://api.reittiopas.fi/public-ytv/fi/api/?stop="+ message.stopIdLong+"&user=byako&pass=gfccdjhl");
    doc.send();
}
