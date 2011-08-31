.pragma library

var doc = new XMLHttpRequest
var scheduleLoaded=0
var currentSchedule=-1

function loadConfig() {
             var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
             var text_ = new String
             db.transaction(
                 function(tx) {
                     tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT)');

                    var rs = tx.executeSql("DELETE * FROM Config")
                    console.log("result of delete: " + rs)
                    rs = tx.executeSql('SELECT * FROM Config');

                     var r = ""
                     for(var i = 0; i < rs.rows.length; i++) {
                         r += rs.rows.item(i).option + ", " + rs.rows.item(i).value + "\n"
                     }
                     text_ = r
                     console.log("Did something, here's da result: " + text_)
                 }
             )
         }

function createDefaultConfig() {
    var db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS Config(option TEXT, value TEXT)');
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'bgColor', '#000000' ]);
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'textColor', '#205080' ]);
            tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'HighlightColor', '#123456' ]);
            console.log("Did something, here's da result: " + text_)
        }
    )
}
