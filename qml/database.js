.pragma library
//-------------------------------------- ** --------------------------------------------
// In this file everything concerning DB work to be used from QML pages
//
//-------------------------------------- ** --------------------------------------------
var response
function __db(){
    return openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
}
function setTheme(themeName) {
    var currentTheme = getCurrent("theme")
    __db().transaction(
        function(tx) {
            if (themeName != currentTheme && themeName != "") {
                try{
                    tx.executeSql("DELETE FROM Current WHERE option=?", ["theme"])
                    tx.executeSql("INSERT INTO Current VALUES(?, ?)",["theme",themeName])
                }
                catch (e) {
                    console.log("exception: "+e)
                }
                currentTheme = themeName
            }
            try {
                var rs = tx.executeSql('SELECT * FROM Config WHERE theme=?',[currentTheme]);
            } catch (e) {
                console.log("exception: "+e)
            }
            for(var i = 0; i < rs.rows.length; i++) {
                tx.executeSql("DELETE FROM Current WHERE option=?", [rs.rows.item(i).option])
                tx.executeSql("INSERT INTO Current VALUES(?, ?)",[rs.rows.item(i).option,rs.rows.item(i).value])
            }
        }
    )
}
function loadConfig(config2) {
    __db().transaction(
        function(tx) {
            try { var rs = tx.executeSql("SELECT * FROM CONFIG WHERE option=?", ["theme"]) }
            catch(e) { console.log("DB is not initialized. Creating all data from scratch.");cleanAll(); initDB(); }
        }
    )
    config2.bgColor = getCurrent("bgColor")
    config2.bgImage = getCurrent("bgImage")
    config2.highlightColor = getCurrent("highlightColor")
    config2.textColor = getCurrent("textColor")
    config2.highlightColorBg = getCurrent("highlightColorBg")
    config2.lineGroup = getCurrent("lineGroup")
}
function initDB() {
    console.log("initializing Database ")
    __db().transaction(
        function(tx) {
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT, theme TEXT, PRIMARY KEY(option, theme))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS Current(option TEXT PRIMARY KEY, value TEXT)')

                tx.executeSql('CREATE TABLE IF NOT EXISTS LineTypes(lineType TEXT, lineTypeName TEXT, PRIMARY KEY(lineType,lineTypeName))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineIdLong TEXT PRIMARY KEY, lineIdShort TEXT, lineName TEXT, lineType TEXT, lineStart TEXT, lineEnd TEXT, startStopIdLong TEXT, endStopIdLong TEXT, lineShape TEXT, lineSchedule TEXT, favorite TEXT, FOREIGN KEY(lineType) REFERENCES LineTypes(lineType))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineIdLong TEXT, stopIdLong TEXT, stopReachTime TEXT, FOREIGN KEY(lineIdLong) REFERENCES Lines(lineIdLong))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineSchedule(lineIdLong TEXT, weekDay TEXT, departTime TEXT, PRIMARY KEY(lineIdLong,weekDay,departTime))')  // not used for now

                tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT PRIMARY KEY, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT, favorite TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopLines(stopIdLong TEXT, lineIdLong TEXT, lineEnd TEXT, PRIMARY KEY(stopIdLong,lineIdLong), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopInfo(stopIdLong TEXT, option TEXT, value TEXT, PRIMARY KEY(stopIdLong,option), FOREIGN KEY(stopIdLong) REFERENCES Stops(stopIdLong))')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong, weekTime TEXT, departTime TEXT, lineId TEXT)')  // not used for now
            }
            catch (e) {
                console.log("EXCEPTION" + e)
            }
	}
    )
    createDefaultConfig()
    setTheme("")
}
function cleanAll() {
    __db().transaction(
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
        }
    )
}
function createDefaultConfig() {
    console.log("Creating default Config table content")
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            try {
                tx.executeSql("INSERT INTO Current VALUES(?, ?)",["theme","black"])
                tx.executeSql("INSERT INTO Current VALUES(?, ?)",["lineGroup","true"])
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'bgColor', '#000000' , "black"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'textColor', '#cdd9ff', "black"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'highlightColor', '#00ee10', "black"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'highlightColorBg', '#666666', "black"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'bgImage', '', "black"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'bgColor', '#000000' , "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'textColor', '#00aa10', "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'highlightColor', '#ffff50', "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'highlightColorBg', '#000000', "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'bgImage', ':/images/background4.jpg', "fallout"]);
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
                console.log("Exception: " + e)
            }
        }
    )
}

function addLine(string) {
    var returnVal = 0
    var fields = new Array
    fields = string.split(";")
    if (fields.length < 11) {
        returnVal = -1
    } else {
        __db().transaction(
            function(tx) {
                try {
                    var rs = tx.executeSql('SELECT * FROM Lines WHERE lineIdLong=?', [fields[0]]);
                }
                catch(e) {
                    console.log("addLine: Exception while selecting line from DB")
                    returnVal = -1
                    return
                }
                if (rs.rows.length > 0) {
                    for (var ii=0; ii<rs.rows.length; ++ii) {
                        console.log("Add line: found: " + rs.rows.item(ii).lineIdLong +" : "+ rs.rows.item(ii).lineName)
                        returnVal = 1
                    }
                } else {
                    rs = tx.executeSql('INSERT INTO Lines VALUES(?,?,?,?,?,?,?,?,?,?,?)', [fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], fields[6], fields[7], fields[8], fields[9], fields[10]])
                }
            }
        )
    }
    return returnVal
}
function addLineStop(string) {
    var returnVal = 0
    var fields = new Array
    fields = string.split(";")
    if (fields.length < 3) {
        returnVal = -1
        return returnVal
    }
    __db().transaction(
        function(tx) {
                try { var rs = tx.executeSql('INSERT INTO LineStops VALUES(?,?,?)', [fields[0], fields[1], fields[2]]); }
                catch(e) { console.log("EXCEPTION: " + e); returnVal = 1 }
        }
    )
    return returnVal
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
function getCurrent(string) {
    var return_v=""
    __db().transaction(
        function(tx) {
            try {
                var rs = tx.executeSql("SELECT option,value FROM Current WHERE option=?", [string])
            } catch(e) {
                console.log("EXCEPTION: " + e)
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
                tx.executeSql("INSERT INTO Current VALUES(?, ?)",[option_, value_])
            } catch(e) {
                console.log("EXCEPTION: " + e)
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
                console.log("EXCEPTION: " + e)
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
