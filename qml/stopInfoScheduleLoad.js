//-------------------------------------- ** --------------------------------------------
//  WorkerScript to fetch and load schedule of stop
//  Use Api v1.0 to get just schedule - less data traffic, more departures in one reply
//-------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    var doc = new XMLHttpRequest()
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.responseText.slice(0,5) == "Error") {
                WorkerScript.sendMessage({"departName" : "ERROR"})
                console.log("stopInfoScheduleLoad.js : ERROR received from server for: " + message.searchString)
                return
            } else {
                var schedText = doc.responseText
                var schedule = new Array;
                var lines = new Array;
                var time_ = Array
                var stopName, stopAddress, stopCity

                schedule = schedText.split("\n")
                lines = schedule[0].split("|")
                WorkerScript.sendMessage({"departName" : "STOPNAME", "stopName" : lines[1], "stopAddress" : lines[2], "stopCity" : lines[3]})
                for (var ii = 1; ii < schedule.length-1; ii++) {
                    lines = schedule[ii].split("|")
                    time_[0] = lines[0].slice(0,lines[0].length -2)
                    time_[1] = lines[0].slice(lines[0].length-2,lines[0].length)
                    if (time_[0] > 23) time_[0]-=24
                    WorkerScript.sendMessage({ "departTime" : ""+time_[0]+":"+time_[1], "departLine" : "" + lines[1], "departDest" : lines[2], "departCode" : lines[3] })
                }
                WorkerScript.sendMessage({"departName" : "FINISHED"})
            }
        } else if (doc.readyState == XMLHttpRequest.ERROR) {
            WorkerScript.sendMessage({"departName" : "ERROR"})
            console.log("Request error. Is Network available?")
        }
    }
    doc.open("GET", "http://api.reittiopas.fi/public-ytv/fi/api/?stop="+ message.searchString+"&user=byako&pass=gfccdjhl");
    doc.send();
}
