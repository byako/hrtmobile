// -------------------------------------- ** --------------------------------------------
// Search for a line : first offine, then online
// if save option is specified, save requested line
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {

    var doc = new XMLHttpRequest()
    var resp
    console.log("lineSearch.js: working")
    try { if (message.save) console.log("Save line requested: " + message.searchString) }
    catch(e) { console.log("lineSearch.js: exception " +e) }

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.responseXML == null) {
                WorkerScript.sendMessage({"lineIdLong":"NONE"})
                return
            } else {
                resp=doc.responseXML.documentElement
                console.log("lineSearch.js: OK, got " + doc.responseXML.documentElement.childNodes.length+ " lines")
                for (var ii = 0; ii < resp.childNodes.length; ++ii) {
//                    console.log("" + resp.childNodes[ii].childNodes[0].firstChild.nodeValue + " : " +
//                                resp.childNodes[ii].childNodes[2].firstChild.nodeValue + " : " +
//                                resp.childNodes[ii].childNodes[3].firstChild.nodeValue
//                                )
                    if (resp.childNodes[ii].childNodes[2].firstChild.nodeValue != "21" &&
                        resp.childNodes[ii].childNodes[2].firstChild.nodeValue != "23" &&
                        resp.childNodes[ii].childNodes[2].firstChild.nodeValue != "24") {
                            WorkerScript.sendMessage({"lineIdLong":resp.childNodes[ii].childNodes[0].firstChild.nodeValue,
                                                 "lineIdShort" : resp.childNodes[ii].childNodes[1].firstChild.nodeValue,
                                                 "lineName" : resp.childNodes[ii].childNodes[3].firstChild.nodeValue,
                                             })
                    } else {
                        console.log("lineSearch.js: not sending " + resp.childNodes[ii].childNodes[0].firstChild.nodeValue + " : line type " +
                                resp.childNodes[ii].childNodes[2].firstChild.nodeValue + " : " +
                                resp.childNodes[ii].childNodes[3].firstChild.nodeValue);
                    }
                }
                WorkerScript.sendMessage({"lineIdLong":"FINISH"})
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            WorkerScript.sendMessage({"lineIdLong":"ERROR"})
        }
    }

    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=lines&user=byako&pass=gfccdjhl&format=xml&epsg_out=wgs84&p=111001000&query="+message.searchString);
    doc.send();
}
