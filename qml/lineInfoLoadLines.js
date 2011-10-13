// -------------------------------------- ** --------------------------------------------
// checkout recent lines from database
// and push info in lineInfoModel
// -------------------------------------- ** --------------------------------------------

WorkerScript.onMessage = function (message) {
    __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
    __db.transaction(
        function(tx) {
                 try { var rs = tx.executeSql("SELECT lineIdLong, lineIdShort, lineName, lineStart, lineEnd, lineType FROM Lines ORDER BY lineIdShort ASC"); }
                 catch(e) { console.log("lineInfoLoadLines exception: " + e); }

                 for (var i=0; i<rs.rows.length; ++i) {
                     WorkerScript.sendMessage({"lineIdLong":rs.rows.item(i).lineIdLong, "lineIdShort":rs.rows.item(i).lineIdShort, "lineName":rs.rows.item(i).lineName,
                                          "lineStart":rs.rows.item(i).lineStart, "lineEnd":rs.rows.item(i).lineEnd, "lineType":rs.rows.item(i).lineType})
                 }
             }
    )
}
