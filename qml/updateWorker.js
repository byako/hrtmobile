.pragma library

WorkerScript.onMessage = function (message) {
    var lines;
    var stops;
    var nickNames;
    var err = 0;
    var db__ = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    // first - get all IdLong's for fastest updateDatebaseInfo
    db__.transaction(
        function(tx) {
            try {
                lines = tx.executeSql('SELECT lineIdLong, favorite FROM Lines;');
                console.log("updateDatabase.js: updateDatabaseInfo: found " + lines.rows.length + " lines")
                err++;
                stops = tx.executeSql('SELECT stopIdLong, favorite FROM Stops;');
                console.log("updateDatabase.js: updateDatabaseInfo: found " + stops.rows.length + " stops")
                err++;
                nickNames = tx.executeSql('SELECT stopIdLong, nickName FROM StopNickNames;');
                console.log("updateDatabase.js: updateDatabaseInfo: found " + nickNames.rows.length + " nicks")
                err=0;
            }
            catch(e) { console.log("UpdateDatabase: updateDatabaseInfo: SELECT exception: " + e + "; err = " + err); }
        }
    )
            if (err != 0 && err != 2) { return };
            for (var ii=0; ii<lines.rows.length; ++ii) {
                WorkerScript.sendMessage({"message":"line","lineIdLong":lines.rows.item(ii).lineIdLong, "favorite":lines.rows.item(ii).favorite});
            }
            for (var ii=0; ii<stops.rows.length; ++ii) {
                WorkerScript.sendMessage({"message":"stop","stopIdLong":stops.rows.item(ii).stopIdLong, "favorite":stops.rows.item(ii).favorite});
            }
            if (nickNames) {
                for (var ii=0; ii<nickNames.rows.length; ++ii) {
                    WorkerScript.sendMessage({"stopIdLong":nickNames.rows.item(ii).stopIdLong, "message":"nickName","nickName":nickNames.rows.item(ii).stopIdLong});
                }
            }
    err = 0; // can be reset: we already reported on the console if we got an exception
    // now let's clean all info fetched from Reittiopas servers
    db__.transaction(
        function(tx) {
            console.log("updateWorker: cleaning database")
            try {
                tx.executeSql('DELETE FROM Lines;');
                err++;
                tx.executeSql('DELETE FROM Stops;');
                err++;
                tx.executeSql('DELETE FROM StopSchedule;');
                err++;
                tx.executeSql('DELETE FROM LineStops;');
                err++;
                tx.executeSql('DELETE FROM StopLines;');
                err++;
                tx.executeSql('DELETE FROM StopNickNames;');
                err++;
                tx.executeSql('DELETE FROM StopInfo;');
                err++;
                tx.executeSql('DELETE FROM LineSchedule;');
                err=0;
            }
            catch(e) { console.log("UpdateDatabase: updateDatabaseInfo: DELETE exception: " + e + "; err = " + err) }
        }
    )
            // TODO: ERROR MANAGEMENT
            WorkerScript.sendMessage({"message":"finish"})
}
