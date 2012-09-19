.pragma library
function __db(){
    return openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
}

function updateNeeded() { // here  database is checked to contain up-to-date info
    var result=0
    console.log("updateDatabase.js: checking if update needed")
    __db().transaction(
        function(tx) {
            try {
                var rs = tx.executeSql('SELECT * FROM Config WHERE option=?', ["dbTimeStampTo"]);
            }
            catch (e) {
                console.log('updateDatabase.js: timestamp check exception: ' + e)
                result = -1
                return;
            }
            if (!rs.rows.length) { // put a timestamp
                console.log("updateDatabase.js: no timestamp in the database. Need to get one.")
                getTimestamps();
                console.log("updateDatebase.js: leaving not waiting for the timestamp");
                return;
            } else {
                var dateTime = Qt.formatDateTime(new Date(), "yyyyMMdd")
                console.log("updateDatabase: found timeStamp:" + rs.rows.item(0).option + ":" + rs.rows.item(0).value +
                            "date: " + dateTime)
                if (dateTime > rs.rows.item(0).value) {
                    console.log("database timestamp: " + dateTime + "; network timestamp is " + rs.rows.item(0).value + "; UPDATE IS NEEDED")
                    result++;
                }
            }
            return result;
        }
    )
    return result;
}

function resetNeeded() {
    console.log("updateDatabase.js: checking if reset needed")
    var result=0;
    var rs;
    __db().transaction(
        function(tx) {
            try {
                rs = tx.executeSql('SELECT * FROM Reset');
            }
            catch (e) {
                // this means table was not created yet => no reset needed
                console.log('updateDatabase.js: database doesn\'t contain reset table:' + e)
                result = -1;
                return ;
            }
            if (rs.rows.length > 0) {
                console.log("updateDatabse.js: found a reset database with data : " + rs.rows.item(0).value)
                if (rs.rows.item(0).value == "true") {
                    console.log("updateDatabse.js: reset is needed, value in Reset is true")
                    result = 1;
                }
            } else {
                result = -2;
            }
        }
    )
    return result;
}

function resetDatabase() {
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
//                    tx.executeSql('DELETE FROM StopNickNames;');
                    tx.executeSql('DELETE FROM StopInfo;');
                    tx.executeSql('DELETE FROM LineSchedule;');
                    tx.executeSql('DELETE FROM Reset;');
                    err=1
                    tx.executeSql('DROP TABLE IF EXISTS Config;');
                    tx.executeSql('DROP TABLE IF EXISTS Lines;');
                    tx.executeSql('DROP TABLE IF EXISTS Stops;');
                    tx.executeSql('DROP TABLE IF EXISTS StopSchedule;');
                    tx.executeSql('DROP TABLE IF EXISTS LineStops;');
                    tx.executeSql('DROP TABLE IF EXISTS LineTypes;');
                    tx.executeSql('DROP TABLE IF EXISTS StopLines;');
                    tx.executeSql('DROP TABLE IF EXISTS StopNickNames;');
                    tx.executeSql('DROP TABLE IF EXISTS StopInfo;');
                    tx.executeSql('DROP TABLE IF EXISTS LineSchedule;');
                    tx.executeSql('DROP TABLE IF EXISTS Reset;');
                    err=2
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Reset(option TEXT, value TEXT, PRIMARY KEY(option) );');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT, PRIMARY KEY(option) );');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineTypes(lineType TEXT, lineTypeName TEXT, PRIMARY KEY(lineType) );');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineIdLong TEXT PRIMARY KEY, lineIdShort TEXT, lineName TEXT, lineType TEXT, lineStart TEXT, lineEnd TEXT, lineShape TEXT, lineSchedule TEXT, favorite TEXT, FOREIGN KEY(lineType) REFERENCES LineTypes(lineType));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineIdLong TEXT, stopIdLong TEXT, stopReachTime TEXT, FOREIGN KEY(lineIdLong) REFERENCES Lines(lineIdLong));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineSchedule(lineIdLong TEXT, weekDay TEXT, departTime TEXT, PRIMARY KEY(lineIdLong,weekDay,departTime));');  // not used for now
                    err=3
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT PRIMARY KEY, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT, favorite TEXT);');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopLines(stopIdLong TEXT, lineIdLong TEXT, lineEnd TEXT, PRIMARY KEY(stopIdLong,lineIdLong), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopNickNames(stopIdLong TEXT, NickName TEXT, PRIMARY KEY(stopIdLong), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopInfo(stopIdLong TEXT, option TEXT, value TEXT, PRIMARY KEY(stopIdLong,option), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong));');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong, weekTime TEXT, departTime TEXT, lineId TEXT);');  // not used for now
                    err=4
                    tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?, ?)', [ "lineGroup","true"]);
                    tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?, ?)', [ 'stopsShowAll', 'false']);
                    tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?, ?)', [ 'linesShowAll', 'false']);
                    tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?, ?)', [ 'dbTimeStampFrom', Qt.formatDateTime(new Date(), "yyyyMMdd")]);
                    err=5
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
                    err=0
                } catch (e) { console.log ( "updateDatabase.js: reset exception " + e); if (err=0) err=-1;}
                if (err) {
                    try { tx.executeSql('CREATE TABLE IF NOT EXISTS Reset(option TEXT, value TEXT, PRIMARY KEY(option) );');
                    tx.executeSql('INSERT OR REPLACE INTO Reset VALUES(?, ?)',["reset","true"]); }
                    catch (e) { console.log ("updateDatabase.js: reset exception 2 " + e); }
                    return
                }
            }
        )
    return err;
}

// template function update_XXYYZZ_N() { }

function getTimestamps() {

    var doc = new XMLHttpRequest()
    var resp
    var stamps = ""
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.responseXML == null) {
                return;
            } else {
                resp=doc.responseXML.documentElement
                try { stamps = resp.childNodes[0].firstChild.nodeValue + ":" + resp.childNodes[1].firstChild.nodeValue }
                catch(e) { console.log("You stupid! fix parsing!"); stamps = ""; }
                pushDBTimeStamp(stamps);
                return;
            }
        }
    }

    doc.open("GET", "http://api.reittiopas.fi/hsl/prod/?request=validity&user=byako&pass=gfccdjhl&format=xml");
    doc.send();
}


function pushDBTimeStamp(timeStamp) {
    var stamps = timeStamp.split(":")
    if (stamps[0].length != 8 || stamps[1].length!=8) {
        return // be safe if parsing went wrong, don't put crap in DB, at least attempt
    }
    console.log("DBTimeStamp from:" + stamps[0] + "; to " + stamps[1])
    __db().transaction(
        function(tx) {
            try {
                tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?,?)', ["dbTimeStampFrom",stamps[0]]);
                tx.executeSql('INSERT OR REPLACE INTO Config VALUES(?,?)', ["dbTimeStampTo",stamps[1]]);
            }
            catch (e) {
                console.log('updateDatabase.js: pushDBTimeStamp exception: ' + e)
            }
        }
    )
}


function initialUpdate() {
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
