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
                lonlat = a.firstChild.childNodes[4].firstChild.nodeValue.split(",")
                WorkerScript.sendMessage({"stopIdLong" : a.firstChild.childNodes[0].firstChild.nodeValue,
                                          "stopIdShort" : a.firstChild.childNodes[1].firstChild.nodeValue,
                                          "stopName" : a.firstChild.childNodes[2].firstChild.nodeValue,
                                          "stopCity" : a.firstChild.childNodes[3].firstChild.nodeValue,
                                          "stopLongitude" : lonlat[0],
                                          "stopLatitude" : lonlat[1]
//                                          "lineReachNumber" : message.lineReachNumber
                })
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            showError("Request error. Is Network available?")
        }
    }
    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=stop&user=byako&pass=gfccdjhl&format=xml&p=1110100010000&code=" + message.stopIdLong);
    doc.send();
}
