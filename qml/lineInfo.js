.pragma library

var doc = new XMLHttpRequest
var scheduleLoaded=0
var currentSchedule=-1

function __db(){
    return openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
}
function loadConfig() {
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    var text_ = new String
    db.transaction(
        function(tx) {
//                 createDefaultConfig();
            var rs = tx.executeSql('SELECT * FROM Config');
            var r = ""
            for(var i = 0; i < rs.rows.length; i++) {
                r += rs.rows.item(i).option + ", " + rs.rows.item(i).value + "\n"
            }

            console.log("Did something, here's da result:\n " + r)
        }
    )
}
function initDB() {
    console.log("initializing Database ")
    __db().transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopIdLong TEXT, stopIdShort TEXT, stopName TEXT, stopAddress TEXT, stopCity TEXT, stopLongitude TEXT, stopLatitude TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineId TEXT, lineType TEXT, lineName TEXT, startstopIdLong TEXT, rndStopId TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopIdLong TEXT, weekTime TEXT, departTime TEXT, lineId)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineId TEXT, stopIdLong TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS LineCoords(option TEXT, value TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS Current(option TEXT, value TEXT)')
	}
    )
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
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'bgColor', '#000000' ]);
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'textColor', '#205080' ]);
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'highlightColor', '#123456' ]);
            tx.executeSql("COMMIT")
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
