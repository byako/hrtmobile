WorkerScript.onMessage = function (message) {
        __db = openDatabaseSync("hrtmobile", "1.0", "hrtmobile config database", 1000000);
        __db.transaction(
            function(tx) {
                try { var rs = tx.executeSql("SELECT lineShape FROM Lines WHERE lineIdLong=?", [message.lineIdLong]) }
                catch(e) {  }
                if (rs.rows.length > 0) {
                    var coords = new Array
                    var lonlat = new Array
                    coords = rs.rows.item(0).lineShape.split("|")
                    for (var ii=0;ii<coords.length;++ii) {
                        lonlat = coords[ii].split(",")
                        WorkerScript.sendMessage({"longitude" : lonlat[0], "latitude" : lonlat[1]})
                    }
/*                    lonlat = coords[0].split(",")
                    map.center.longitude = lonlat[0]
                    map.center.latitude = lonlat[1]
                    circle.center.longitude = lonlat[0]
                    circle.center.latitude = lonlat[1]*/
                }
            }
        )
}

