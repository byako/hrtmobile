WorkerScript.onMessage = function (message) {
    var doc = new XMLHttpRequest()
    var schedule = new Array;
    var lines = new Array;
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.responseText.slice(0,5) == "Error") {
            } else {
                schedule = doc.responseText.split("\n")
                lines = schedule[0].split("|")
                WorkerScript.sendMessage({"stopIdLong" : message.stopIdLong,
                "stopName" : lines[1],
                "stopAddress" : lines[2],
                "stopCity" : lines[3]})
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            showError("Request error. Is Network available?")
        }
    }
    doc.open("GET", "http://api.reittiopas.fi/public-ytv/fi/api/?stop="+ message.stopIdLong+"&user=byako&pass=gfccdjhl");
    doc.send();
}
