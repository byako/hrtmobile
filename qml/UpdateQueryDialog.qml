import QtQuick 1.1
import com.nokia.meego 1.0

QueryDialog {
    acceptButtonText: "Update"
    rejectButtonText: "Later"
    message: "Some of the routes or timetables have been changed. Database needs to be updated to prevent showing the wrong information"
    titleText: "Database update needed"
}
