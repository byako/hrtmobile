#include "hrtm_config.h"
#include <QFile>

HrtmConfig::HrtmConfig(QDeclarativeItem *parent) :
    QDeclarativeItem(parent)
{
    bgColor_.setRgb(0,0,0,255);
//    textColor_.setRgba(205, 217, 255, 255);
    textColor_.setRgb(0,150,20);
    highlightColor_.setRgb(36, 90, 140, 255);
    colorStyleName_ = "Dark";
/*
    color_style.append("Dark");
    bg_color.append(QColor(24, 24, 24, 255));
    text_color.append(QColor(240,240,240,255));
    highlight_color.append(QColor(200,225,255,255));
*/
    currentStyle_ = 0;

}

QColor HrtmConfig::bgColor() const {
    return bgColor_;
}
void HrtmConfig::bgColorSet(const QColor &newColor) {
    bgColor_ = newColor;
}

QColor HrtmConfig::textColor() const {
    return textColor_;
}
void HrtmConfig::textColorSet(const QColor &newColor) {
    textColor_ = newColor;
}

QColor HrtmConfig::highlightColor() const {
    return highlightColor_;
}
void HrtmConfig::highlightColorSet(const QColor &newColor) {
    highlightColor_ = newColor;
}

QString HrtmConfig::colorStyleName() const {
    return colorStyleName_;
}
void HrtmConfig::colorStyleNameSet(const QString &newColor) {
    colorStyleName_ = newColor;
}

int HrtmConfig::currentStyle() const {
    return currentStyle_;
}
void HrtmConfig::currentStyleSet(int newStyle) {
    currentStyle_ = newStyle;
}

void HrtmConfig::loadConfig() {
    QFile configFile("~/.hrtmobile/config");
    fprintf(stderr,"Loading config from file\n");
    if(!configFile.open(QIODevice::ReadOnly)) {
        fprintf(stderr,"Some shit happend. File dissapeared. Error\n");
        fprintf(stderr,"Creating file and saving default config\n");
        if (!configFile.open(QIODevice::ReadWrite)) {
            fprintf(stderr,"This is bad, can't save file. Error\n");
            return;
        } else {
            configFile.close();
            if(!configFile.open(QIODevice::ReadOnly)) {
                fprintf(stderr,"Can't open saved file.. Damn it. Error\n");
            } else {
                configFile.close();
                fprintf(stderr, "Nice job!");
            }
        }
    } else {
        configFile.close();
        fprintf(stderr,"OK\n");
    }
//    QTextStream stream(&configFile);
}

void HrtmConfig::saveConfig() {

}
