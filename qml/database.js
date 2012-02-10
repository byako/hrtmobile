.pragma library
//-------------------------------------- ** --------------------------------------------
// In this file everything concerning DB work to be used from QML pages
//
//-------------------------------------- ** --------------------------------------------
var response
function __db(){
/*    var db_ = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db_.transaction(
            function(tx) {
                tx.executeSql("DROP TABLE IF EXISTS Config");
                tx.executeSql("DROP TABLE IF EXISTS Stops");
                tx.executeSql("DROP TABLE IF EXISTS Lines");
                tx.executeSql("DROP TABLE IF EXISTS StopSchedule");
                tx.executeSql("DROP TABLE IF EXISTS LineStops");
                tx.executeSql("DROP TABLE IF EXISTS LineCoords");
                tx.executeSql('DROP TABLE IF EXISTS Current');
                tx.executeSql('DROP TABLE IF EXISTS LineTypes');
                tx.executeSql('DROP TABLE IF EXISTS StopLines');
                tx.executeSql('DROP TABLE IF EXISTS StopInfo');
                tx.executeSql('DROP TABLE IF EXISTS LineSchedule');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT UNIQUE, value TEXT, PRIMARY KEY(option) )')

                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineTypes(lineType TEXT UNIQUE, lineTypeName TEXT, PRIMARY KEY(lineType) )')
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineIdLong TEXT UNIQUE PRIMARY KEY, lineIdShort TEXT, lineName TEXT, lineType TEXT, lineStart TEXT, lineEnd TEXT, lineShape TEXT, lineSchedule TEXT, favorite TEXT, FOREIGN KEY(lineType) REFERENCES LineTypes(lineType))')
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineIdLong TEXT, stopIdLong TEXT, stopReachTime TEXT, FOREIGN KEY(lineIdLong) REFERENCES Lines(lineIdLong))')
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LineSchedule(lineIdLong TEXT, weekDay TEXT, departTime TEXT, PRIMARY KEY(lineIdLong,weekDay,departTime))')  // not used for now

                    tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT UNIQUE PRIMARY KEY, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT, favorite TEXT)')
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopLines(stopIdLong TEXT, lineIdLong TEXT, lineEnd TEXT, PRIMARY KEY(stopIdLong,lineIdLong), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong))')
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopInfo(stopIdLong TEXT, option TEXT, value TEXT, PRIMARY KEY(stopIdLong,option), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong))')
                    tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong, weekTime TEXT, departTime TEXT, lineId TEXT)')  // not used for now
            }
    ) */

    return openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
}
function resetDatabase() {
    console.log("Cleaning database")
    cleanAll()
    initDB()
}

function initDB() {
    console.log("initializing Database ")
    __db().transaction(
        function(tx) {
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT UNIQUE, value TEXT, PRIMARY KEY(option) )')

                tx.executeSql('CREATE TABLE IF NOT EXISTS LineTypes(lineType TEXT UNIQUE, lineTypeName TEXT, PRIMARY KEY(lineType) )')
                tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineIdLong TEXT UNIQUE PRIMARY KEY, lineIdShort TEXT, lineName TEXT, lineType TEXT, lineStart TEXT, lineEnd TEXT, lineShape TEXT, lineSchedule TEXT, favorite TEXT, FOREIGN KEY(lineType) REFERENCES LineTypes(lineType))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineIdLong TEXT, stopIdLong TEXT, stopReachTime TEXT, FOREIGN KEY(lineIdLong) REFERENCES Lines(lineIdLong))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineSchedule(lineIdLong TEXT, weekDay TEXT, departTime TEXT, PRIMARY KEY(lineIdLong,weekDay,departTime))')  // not used for now

                tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT UNIQUE PRIMARY KEY, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT, favorite TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopLines(stopIdLong TEXT, lineIdLong TEXT, lineEnd TEXT, PRIMARY KEY(stopIdLong,lineIdLong), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopInfo(stopIdLong TEXT, option TEXT, value TEXT, PRIMARY KEY(stopIdLong,option), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong, weekTime TEXT, departTime TEXT, lineId TEXT)')  // not used for now
            }
            catch (e) {
                console.log("DB INIT EXCEPTION" + e)
            }
	}
    )
    createDefaultConfig()
}
function cleanAll() {
    console.log("clean all initiated")
    __db().transaction(
        function(tx) {
            try {
                tx.executeSql("DROP TABLE IF EXISTS Config");
                tx.executeSql("DROP TABLE IF EXISTS Stops");
                tx.executeSql("DROP TABLE IF EXISTS Lines");
                tx.executeSql("DROP TABLE IF EXISTS StopSchedule");
                tx.executeSql("DROP TABLE IF EXISTS LineStops");
                tx.executeSql("DROP TABLE IF EXISTS LineCoords");
                tx.executeSql('DROP TABLE IF EXISTS Current');
                tx.executeSql('DROP TABLE IF EXISTS LineTypes');
                tx.executeSql('DROP TABLE IF EXISTS StopLines');
                tx.executeSql('DROP TABLE IF EXISTS StopInfo');
                tx.executeSql('DROP TABLE IF EXISTS LineSchedule');
            }
            catch(e) { console.log("cleanAll EXCEPTION: " + e) }
        }
    )
}
function createDefaultConfig() {
    console.log("Creating default Config table content")
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            try {
                tx.executeSql("INSERT INTO Config VALUES(?, ?)",["lineGroup","true"])
                tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'stopsShowAll', 'false']);
                tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'linesShowAll', 'false']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '1', 'Helsinki Bus']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '2', 'Tram']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '3', 'Espoo Bus']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '4', 'Vantaa Bus']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '5', 'Regional Bus']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '6', 'Metro']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '7', 'Ferry']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '8', 'U-Line']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '9', 'Other local traffic']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '10', 'Long-distance traffic']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '11', 'Express']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '12', 'VR local traffic']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '13', 'VR long-distance traffic']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '21', 'Helsinki service line']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '22', 'Helsinki night traffic']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '23', 'Espoo service line']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '24', 'Vantaa service line']);
                tx.executeSql('INSERT INTO LineTypes VALUES(?, ?)', [ '25', 'Regional night traffic']);
            } catch(e) {
                console.log("createDefaultConfig Exception: " + e)
            }
        }
    )
}

function loadConfig(config2) {
    console.log("loading config within request")
    __db().transaction(
        function(tx) {
            try { var rs = tx.executeSql("SELECT * FROM CONFIG") }
            catch(e) { console.log("DB is not initialized. Creating all data from scratch."); cleanAll(); initDB(); }
        }
    )
    config2.lineGroup = getConfigValue("lineGroup")
    config2.linesShowAll = getConfigValue("linesShowAll")
    config2.stopsShowAll = getConfigValue("stopsShowAll")
}

function deleteStop(string) {
    var retVal = 0;
    __db().transaction(
        function(tx) {
            try {
                if (string == "*") {
                    tx.executeSql('DELETE from StopSchedule');
                    tx.executeSql('DELETE from StopInfo');
                    tx.executeSql('DELETE from StopLines');
                    tx.executeSql('DELETE from Stops');
                } else {
                    tx.executeSql('DELETE from StopSchedule WHERE stopIdLong=?',[string]);
                    tx.executeSql('DELETE from StopInfo WHERE stopIdLong=?',[string]);
                    tx.executeSql('DELETE from StopLines WHERE stopIdLong=?',[string]);
                    tx.executeSql('DELETE from Stops WHERE stopIdLong=?', [string]);
                }
            }
            catch(e) {
                console.log("delete stop from table exception occured. string = "+ string)
                retVal = 1
            }
        }
    )
    return retVal
}

function deleteLine(string) {
    var retVal = 0;
    __db().transaction(
        function(tx) {
            try {
                if (string == "*") {
                    tx.executeSql('DELETE from LineSchedule');
                    tx.executeSql('DELETE from LineStops');
                    tx.executeSql('DELETE from Lines');
                } else {
                    tx.executeSql('DELETE from LineSchedule WHERE lineIdLong=?',[string]);
                    tx.executeSql('DELETE from LineStops WHERE lineIdLong=?',[string]);
                    tx.executeSql('DELETE from Lines WHERE lineIdLong=?', [string]);
                }
            }
            catch(e) {
                console.log("delete line from table exception occured. string = "+ string)
                retVal = 1
            }
        }
    )
    return retVal
}

function getConfigValue(string) {
    var return_v=""
    __db().transaction(
        function(tx) {
            try {
                var rs = tx.executeSql("SELECT option,value FROM Current WHERE option=?", [string])
            } catch(e) {
                console.log("getConfigValue EXCEPTION: " + e)
            }
            if (rs.rows.length > 0) {
                return_v = rs.rows.item(0).value
            }
        }
    )
    return return_v
}

function setCurrent(option_,value_) {
    var return_v = 0
    __db().transaction(
        function(tx) {
            try {
                tx.executeSql("DELETE FROM Current WHERE option=?", [option_])
                tx.executeSql("INSERT OR REPLACE INTO Current VALUES(?, ?)",[option_, value_])
            } catch(e) {
                console.log("setCurrent EXCEPTION: " + e)
                return_v = 1
            }
        }
    )
    return return_v
}
function getLineType(string) {
    var return_v="unknown"
    __db().transaction(
        function(tx) {
            try {
                var rs = tx.executeSql("SELECT * FROM LineTypes WHERE lineType=?",[string])
            } catch(e) {
                console.log("getLineType EXCEPTION: " + e)
            }
            if (rs.rows.length > 0) {
                return_v = rs.rows.item(0).lineTypeName
            } else {
                console.log("Oops, didn't find line type: " + string)
            }
        }
    )
    return return_v
}
