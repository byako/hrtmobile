#include "hrtm_config.h"

HrtmConfig::HrtmConfig(QDeclarativeItem *parent) :
    QDeclarativeItem(parent)
{
    bgColor_.setRgb(0,0,0,255);
    textColor_.setRgb(205, 217, 255, 255);
    highlightColor_.setRgb(70, 70, 180, 255);
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
