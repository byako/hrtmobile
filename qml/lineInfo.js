.pragma library

var doc = new XMLHttpRequest
var scheduleLoaded=0
var currentSchedule=-1

function __db(){
    return openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
}
function setTheme(themeName) {
    var currentTheme = getCurrent("currentTheme")
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
    config2.bgColor = getCurrent("bgColor")
    config2.bgImage = getCurrent("bgImage")
    config2.highlightColor = getCurrent("highlightColor")
    config2.textColor = getCurrent("textColor")
    config2.highlightColorBg = getCurrent("highlightColorBg")
}
function initDB() {
    console.log("initializing Database ")
    __db().transaction(
        function(tx) {
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT, theme TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineIdLong TEXT, lineIdShort TEXT, lineName TEXT, lineType TEXT, lineStart TEXT, lineEnd TEXT, startStopIdLong TEXT, endStopIdLong TEXT, lineShape TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong TEXT, weekTime TEXT, departTime TEXT, lineId TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineId TEXT, stopIdLong TEXT, stopReachTime TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS Current(option TEXT, value TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS LineTypes(lineType TEXT, lineTypeName TEXT)')
                tx.executeSql('CREATE TABLE IF NOT EXISTS StopLines(stopIdLong TEXT, lineIdLong TEXT)')
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
        }
    )
}
function createDefaultConfig() {
    console.log("Creating default Config table content")
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            try {
                tx.executeSql("INSERT INTO Current VALUES(?, ?)",["currentTheme","black"])
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
function showDB() {
    console.log("DEBUG: showDatabase invoked: ");
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            var rs, ii;
            if (tx.executeSql("SELECT * FROM CONFIG")) {
                rs = tx.executeSql("SELECT * FROM CONFIG");
                for (ii=0; ii < rs.rows.length; ++ii ) {
                    console.log("" + rs.rows.item(ii).option + " : " + rs.rows.item(ii).value)
                }
            }
/*	    if (rs.length > 0) {
		console.log("found " + ts.length + " tables\n");
	    } else {
                console.log("no tables found\n");
		return;
            }
	    for (var ii=0; ii < rs.length; ++ii) {
		console.log("table: " + rs[ii]);
            }*/
	}
    )
}
function addLine(string) {
    var returnVal = 0
    var fields = new Array
    fields = string.split(";")
    if (fields.length < 9) {
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
                    rs = tx.executeSql('INSERT INTO Lines VALUES(?,?,?,?,?,?,?,?,?)', [fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], fields[6], fields[7], fields[8]])
                }
            }
        )
    }
    return returnVal
}
function addStop(string) {
    var returnVal = 0
    var fields = new Array
    fields = string.split(";")
    if (fields.length < 7) {
        returnVal = -1
        return returnVal
    }

    __db().transaction(
        function(tx) {
            console.log ("checking if there is already a stop info in DB [" + fields[0] + "]: ")
            var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [fields[0]]);
            if (rs.rows.length > 0) {
                for (var ii=0; ii<rs.rows.length; ++ii) {
                    console.log("" + rs.rows.item(ii).stopIdLong +";"+ rs.rows.item(ii).stopName)
                }
            } else {
                returnVal = 1
                rs = tx.executeSql('INSERT INTO Stops VALUES(?,?,?,?,?,?,?)', [fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], fields[6]])
            }
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
                    tx.executeSql('DELETE from Stops');
                } else {
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
            }
        }
    )
    return return_v
}
function getStopName(stopIdLong) {
    var return_v = ""
    __db().transaction(
        function(tx) {
           try {
                var rs = tx.executeSql("SELECT * FROM Stops WHERE stopIdLong=?", [stopIdLong])
           } catch(e) {
                console.log("EXCEPTION: " + e)
           }
           if (rs.rows.length > 0) {
               return_v = rs.rows.item(0).stopName
           }
        }
    )
    return return_v
}
