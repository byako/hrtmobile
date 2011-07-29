#include "hrtm_config.h"

HrtmConfig::HrtmConfig(QDeclarativeItem *parent) :
    QDeclarativeItem(parent)
{
    color_style.append("Light");
    bg_color.append(QColor(255, 255, 255, 255));
    text_color.append(QColor(0,0,0,255));
    highlight_color.append(QColor(80,150,255,255));

    color_style.append("Dark");
    bg_color.append(QColor(24, 24, 24, 255));
    text_color.append(QColor(240,240,240,255));
    highlight_color.append(QColor(200,225,255,255));

    current_style = 0;

}
