// -------------------------------------- ** --------------------------------------------
// Search for a line : first offine, then online
// if save option is specified, save requested line
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {

    var db_ = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    console.log("lineInfoLoadStops.js: started request for " + message.searchString)
    db_.transaction(
        function(tx) {
            try { var rs = tx.executeSql('SELECT * FROM LineStops WHERE lineIdLong=?', [message.searchString]); }
            catch (e) { console.log ("lineInfo.qml: getStops exception 1: " + e) }
            console.log("lineInfoLoadStops.js: found " + rs.rows.length + "stops")
            for (var ii=0; ii<rs.rows.length; ++ii) {
                try {
                    var rs2 = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [rs.rows.item(ii).stopIdLong]);
                }
                catch (e) { console.log ("lineInfoLoadStops.js: getStops exception 2: " + e) }

                if (rs2.rows.length == 0) {
                    console.log("lineInfo.qml: some stops need to be loaded still: " + rs.rows.item(ii).stopIdLong)
//                    WorkerScript.sendMessage({"stopIdLong":rs.rows.item(ii).stopIdLong, "state" : "load"})
//                    stopReachModel.append(
                    WorkerScript.sendMessage({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                                              "stopName" : "",
                                              "stopIdShort" : "UNKNOWN",
                                              "stopLongitude" : "UNKNOWN",
                                              "stopLatitude" : "UNKNOWN",
                                              "stopCity" : "UNKNOWN",
                                              "reachTime" : rs.rows.item(ii).stopReachTime,
                                              "state":"online",
                                              "lineReachNumber" : ii});
                } else {
//                    stopReachModel.append(
                    WorkerScript.sendMessage({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                              "stopName" : rs2.rows.item(0).stopName,
                              "stopIdShort" : rs2.rows.item(0).stopIdShort,
                              "stopLongitude" : rs2.rows.item(0).stopLongitude,
                              "stopLatitude" : rs2.rows.item(0).stopLatitude,
                              "stopCity" : rs2.rows.item(0).stopCity,
                              "reachTime" : rs.rows.item(ii).stopReachTime,
                              "state" : "offline"});
                }
            }
        }
    )
}
