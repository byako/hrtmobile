// -------------------------------------- ** --------------------------------------------
// In this file we search for a nearby stops. Receiving coords from qml file
// and sending back filtered stops data to add to map
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    console.log("mapStopsSearch : WORKING {" + message.longitude + ":" + message.latitude + "}");
    var doc = new XMLHttpRequest()
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseXML.documentElement;
            for (var ii = 0; ii < xml.childNodes[1].childNodes.length; ++ii) {
                if (xml.childNodes[1].childNodes[ii].nodeName == "LOC") {
                    WorkerScript.sendMessage({"stopIdLong" : xml.childNodes[1].childNodes[ii].attributes[0].nodeValue, "distance" : xml.childNodes[1].childNodes[ii].attributes[3].nodeValue,
                                                 "longitude" : xml.childNodes[1].childNodes[ii].attributes[1].nodeValue, "latitude" : xml.childNodes[1].childNodes[ii].attributes[2].nodeValue});
                }
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            console.log("mapStopsSearch: server returned ERROR")
        }
    }
//              API 1.0 (XML)
    doc.open("GET", "http://api.reittiopas.fi/public-ytv/fi/api/?closest_stops=1&lon=" + message.longitude + "&lat=" + message.latitude + "&user=byako&pass=gfccdjhl&radius=" + (message.distance ? message.distance : "250"))
    doc.send();
}
