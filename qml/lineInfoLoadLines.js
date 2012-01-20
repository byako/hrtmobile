// -------------------------------------- ** --------------------------------------------
// checkout recent lines from database
// and push info in lineInfoModel
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    __db.transaction(
        function(tx) {
                 try { var rs = tx.executeSql("SELECT lineIdLong, lineIdShort, lineName, lineStart, lineEnd, Lines.lineType, favorite, LineTypes.lineTypeName FROM Lines OUTER LEFT JOIN LineTypes on Lines.lineType=LineTypes.lineType ORDER BY lineIdShort ASC"); }
                 catch(e) { console.log("lineInfoLoadLines exception: " + e); }
                 for (var i=0; i<rs.rows.length; ++i) {
                    WorkerScript.sendMessage(rs.rows.item(i))
                 }
             }
    )
}
