// -------------------------------------- ** --------------------------------------------
// this needs to be separated to notify settings page that cleanup is finished
//
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
        var db_ = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
        var err = 0;
        db_.transaction(
            function(tx) {
                try {
                    tx.executeSql('DELETE FROM Config;');
                    tx.executeSql('DELETE FROM Lines;');
                    tx.executeSql('DELETE FROM Stops;');
                    tx.executeSql('DELETE FROM StopSchedule;');
                    tx.executeSql('DELETE FROM LineStops;');
                    tx.executeSql('DELETE FROM LineTypes;');
                    tx.executeSql('DELETE FROM StopLines;');
                    tx.executeSql('DELETE FROM StopInfo;');
                    tx.executeSql('DELETE FROM LineSchedule;');

                    tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT, PRIMARY KEY(option) );');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineTypes(lineType TEXT, lineTypeName TEXT, PRIMARY KEY(lineType) );');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineIdLong TEXT PRIMARY KEY, lineIdShort TEXT, lineName TEXT, lineType TEXT, lineStart TEXT, lineEnd TEXT, lineShape TEXT, lineSchedule TEXT, favorite TEXT, FOREIGN KEY(lineType) REFERENCES LineTypes(lineType));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineIdLong TEXT, stopIdLong TEXT, stopReachTime TEXT, FOREIGN KEY(lineIdLong) REFERENCES Lines(lineIdLong));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineSchedule(lineIdLong TEXT, weekDay TEXT, departTime TEXT, PRIMARY KEY(lineIdLong,weekDay,departTime));');  // not used for now

                    tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT PRIMARY KEY, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT, favorite TEXT);');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopLines(stopIdLong TEXT, lineIdLong TEXT, lineEnd TEXT, PRIMARY KEY(stopIdLong,lineIdLong), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopInfo(stopIdLong TEXT, option TEXT, value TEXT, PRIMARY KEY(stopIdLong,option), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong, weekTime TEXT, departTime TEXT, lineId TEXT);');  // not used for now

                    tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?, ?)',["lineGroup","true"]);
                    tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?, ?)', [ 'stopsShowAll', 'false']);
                    tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?, ?)', [ 'linesShowAll', 'false']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '1', 'Helsinki Bus']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '2', 'Tram']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '3', 'Espoo Bus']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '4', 'Vantaa Bus']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '5', 'Regional Bus']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '6', 'Metro']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '7', 'Ferry']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '8', 'U-Line']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '9', 'Other local traffic']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '10', 'Long-distance traffic']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '11', 'Express']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '12', 'VR local traffic']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '13', 'VR long-distance traffic']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '21', 'Helsinki service line']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '22', 'Helsinki night traffic']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '23', 'Espoo service line']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '24', 'Vantaa service line']);
                    tx.executeSql('INSERT OR REPLACE INTO LineTypes VALUES(?, ?)', [ '25', 'Regional night traffic']);
                } catch (e) { console.log ( "resetDatabase.js: exception " + e); err=1;}
                if (err) {
                    try { tx.executeSql('CREATE TABLE IF NOT EXISTS Reset(option TEXT, value TEXT, PRIMARY KEY(option) );');
                    tx.executeSql('INSERT OR REPLACE INTO Reset VALUES(?, ?)',["reset","true"]); }
                    catch (e) { console.log ("resetDatabase.js: exception " + e);}
                    WorkerScript.sendMessage({"clean":"error"})
                    return
                }
                WorkerScript.sendMessage({"clean":"done"})
            }
        )
}
