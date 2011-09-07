.pragma library

var doc = new XMLHttpRequest
var scheduleLoaded=0
var currentSchedule=-1

function __db(){
    return openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
}
function setTheme(themeName) {
    var currentTheme = getCurrent("currentTheme")
    console.log("got current theme: " + currentTheme)
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
                console.log("changing theme to new: " + themeName)
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
            tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT, theme TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineId TEXT, lineType TEXT, lineName TEXT, startstopIdLong TEXT, rndStopId TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong TEXT, weekTime TEXT, departTime TEXT, lineId)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineId TEXT, stopIdLong TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS LineCoords(option TEXT, value TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS Current(option TEXT, value TEXT)')
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
//                tx.executeSql("INSERT INTO Current VALUES(?, ?)",["currentTheme","fallout"])
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'bgColor', '#000000' , "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'textColor', '#00ee10', "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'highlightColor', '#00ff50', "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'highlightColorBg', '#66aa66', "fallout"]);
                tx.executeSql('INSERT INTO Config VALUES(?, ?, ?)', [ 'bgImage', ':/images/background3.jpg', "fallout"]);
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
// TODO : this function
}
function addStop(string) {
    console.log("Add stop: " + string)
    var fields = new Array;
    fields = string.split(";");
    if (fields.length < 7) {
        console.log("Wrong stopAddString format");
        return;
    }
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            console.log ("checking if there is already a stop info in DB [" + fields[0] + "]: ")
            var rs = tx.executeSql('SELECT * FROM Stops WHERE stopIdLong=?', [fields[0]]);
            if (rs.rows.length > 0) {
                console.log("found :")
                for (var ii=0; ii<rs.rows.length; ++ii) {
                    console.log("" + rs.rows.item(ii).stopIdLong +";"+ rs.rows.item(ii).stopName)
                }
            } else {
                console.log("not found. adding")
                rs = tx.executeSql('INSERT INTO Stops VALUES(?,?,?,?,?,?,?)', [fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], fields[6]])
            }
	}
    );
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
