// -------------------------------------- ** --------------------------------------------
// send saved stops
//
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {

    var db_ = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db_.transaction(
        function(tx) {
            try { var rs = tx.executeSql('SELECT * FROM LineStops WHERE lineIdLong=?', [message.searchString]); }
            catch (e) { console.log ("lineInfo.qml: getStops exception 1: " + e) }
            for (var ii=0; ii<rs.rows.length; ++ii) {
                try {
                    var rs2 = tx.executeSql('SELECT stopIdLong, stopIdShort, stopName, stopAddress, stopLatitude, stopLongitude FROM Stops WHERE stopIdLong=?', [rs.rows.item(ii).stopIdLong]);
                }
                catch (e) { console.log ("lineInfoLoadStops.js: getStops exception 2: " + e) }

                if (rs2.rows.length == 0) {
                    WorkerScript.sendMessage({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                                              "stopName" : "",
                                              "reachTime" : rs.rows.item(ii).stopReachTime,
                                              "stopState":"online"});
                } else {
                    WorkerScript.sendMessage({"stopIdLong" : rs.rows.item(ii).stopIdLong,
                              "stopIdShort" : rs2.rows.item(0).stopIdShort,
                              "stopName" : rs2.rows.item(0).stopName,
                              "stopAddress" : rs2.rows.item(0).stopAddress,
                              "stopLatitude" : rs2.rows.item(0).stopLatitude,
                              "stopLongitude" : rs2.rows.item(0).stopLongitude,
                              "reachTime" : rs.rows.item(ii).stopReachTime,
                              "stopState" : "offline"});
                }
            }
            WorkerScript.sendMessage({"stopIdLong" : "finish"});
        }
    )
}
