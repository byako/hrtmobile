.pragma library

var doc = new XMLHttpRequest
var scheduleLoaded=0
var currentSchedule=-1

function loadConfig() {
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    var text_ = new String
    db.transaction(
        function(tx) {
            tx.executeSql("DROP TABLE Config");
            
            var rs = tx.executeSql("SELECT * FROM Config")
	    if (rs.rows == 0) {
                 initDB();
            }

            rs = tx.executeSql('SELECT * FROM Config');
            var r = ""
            for(var i = 0; i < rs.rows.length; i++) {
                r += rs.rows.item(i).option + ", " + rs.rows.item(i).value + "\n"
            }

            console.log("Did something, here's da result: " + r)
        }
    )
}

function initDB() {
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
	    tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT)');
	    tx.executeSql('CREATE TABLE IF NOT EXISTS Stops(stopId TEXT, stopName TEXT, address TEXT, city TEXT, longitude TEXT, latitude TEXT)');
	    tx.executeSql('CREATE TABLE IF NOT EXISTS Lines(lineId TEXT, lineType TEXT, lineName TEXT, startStopId TEXT, rndStopId TEXT)');
	    tx.executeSql('CREATE TABLE IF NOT EXISTS StopSchedule(stopId TEXT, weekTime TEXT, departTime TEXT, lineId)');
	    tx.executeSql('CREATE TABLE IF NOT EXISTS LineStops(lineId TEXT, stopId TEXT)');
	    tx.executeSql('CREATE TABLE IF NOT EXISTS LineCoords(option TEXT, value TEXT)');
	}
    )
}

function createDefaultConfig() {
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'bgColor', '#000000' ]);
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'textColor', '#205080' ]);
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'highlightColor', '#123456' ]);
        }
    )
}

function addStop(string) {
    var fields = new Array;
    fields = string.split(";");
    if (fields.length < 6) {
        return;
    }
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM Stops WHERE stopId is "' + fields[0]  + '" ');
	    console.log ("checking if there is already a stop info in DB: " + rs )

		// TODO: add stop info here
	}
    );
}
