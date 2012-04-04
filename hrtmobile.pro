# Add more folders to ship with the application, here

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT+= declarative
symbian:TARGET.UID3 = 0xE6AD570E

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp


OTHER_FILES += \
    qml/MainPage.qml \
    qml/main.qml \
    hrtmobile.desktop \
    hrtmobile.svg \
    hrtmobile.png \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/stopInfo.qml \
    qml/lineInfo.qml \
    qml/route.qml \
    qml/settings.qml \
    qml/realtimeSchedule.qml \
    qml/Spinner.qml \
    qml/database.js \
    qml/Config.qml \
    qml/route.js \
    qml/lineInfoSchedule.js \
    qml/lineInfoLoadLines.js \
    qml/mapStopsSearch.js \
    qml/stopInfoScheduleLoad.js \
    qml/SearchDialog.qml \
    qml/stopSearch.js \
    qml/Loading.qml \
    qml/Favorites.qml \
    qml/lineSearch.js \
    qml/stopName.js \
    qml/About.qml \
    qml/resetDatabase.js \
    qml/lineInfoLoadStops.js \
    qml/stopInfoLoadLines.js \
    qml/updateDatabase.js \
    qml/UpdatePage.qml \
    qml/UpdateQueryDialog.qml

RESOURCES += \
    res.qrc

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

# enable booster
CONFIG += qdeclarative-boostable
QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic

HEADERS +=

contains(MEEGO_EDITION,harmattan) {
    icon.files = hrtmobile.png
    icon.path = /usr/share/icons/hicolor/80x80/apps
    INSTALLS += icon
}

contains(MEEGO_EDITION,harmattan) {
    target.path = /opt/hrtmobile/bin
    INSTALLS += target
}





















