function __db(){
    return openDatabaseSync('hrtmobile', '1.0', 'hrtmobile config database', 1000000);
}

function check_if_update_needed(dbTimeStamp) {
    __db().transaction(
        function(tx) {
            var ok=1;
            try {
                var rs = tx.executeSql('SELECT * FROM Config WHERE option=?', ["dbTimeStamp"]);
            }
            catch (e) {
                console.log('updateDatabase.js: database doesn\'t contain timestamp' + e)
                ok=0
                return
            }
            if (!ok || !rs.rows.count) { // put a timestamp
                try { tx.executeSql('INSERT INTO OR REPLACE Config VALUES(?, ?)', ['dbTimeStamp',dbTimeStamp]) }
                catch(e) {
                    console.log("updateDatabase.js: exception setting dbTimeStamp: " + e)
                    return
                }
            }
            console.log("updateDatabase.js: current timeStamp is " + rs.rows.item(0).value)
        }
    )
}

// template function update_XXYYZZ_N() { }

function update () {
    console.log('initializing Database ')
        __db().transaction(
            function(tx) {
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT UNIQUE, value TEXT, PRIMARY KEY(option) );')

                tx.executeSql('CREATE TABLE IF NOT EXISTS LineTypes(lineType TEXT UNIQUE, lineTypeName TEXT, PRIMARY KEY(lineType) );')
                tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineIdLong TEXT UNIQUE PRIMARY KEY, lineIdShort TEXT, lineName TEXT, lineType TEXT, lineStart TEXT, lineEnd TEXT, lineShape TEXT, lineSchedule TEXT, favorite TEXT, FOREIGN KEY(lineType) REFERENCES LineTypes(lineType));')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineIdLong TEXT, stopIdLong TEXT, stopReachTime TEXT, FOREIGN KEY(lineIdLong) REFERENCES Lines(lineIdLong));')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineSchedule(lineIdLong TEXT, weekDay TEXT, departTime TEXT, PRIMARY KEY(lineIdLong,weekDay,departTime));')  // not used for now

                tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT UNIQUE PRIMARY KEY, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT, favorite TEXT);')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopLines(stopIdLong TEXT, lineIdLong TEXT, lineEnd TEXT, PRIMARY KEY(stopIdLong,lineIdLong), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong));')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopInfo(stopIdLong TEXT, option TEXT, value TEXT, PRIMARY KEY(stopIdLong,option), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong));')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong, weekTime TEXT, departTime TEXT, lineId TEXT);')  // not used for now
            }
            catch (e) {
                console.log('DB INIT EXCEPTION' + e)
            }
        }
    )
    createDefaultConfig()
}
