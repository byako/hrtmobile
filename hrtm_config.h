#ifndef HRTM_CONFIG_H
#define HRTM_CONFIG_H

#include <QDeclarativeItem>
#include <QColor>

class HrtmConfig : public QDeclarativeItem
{
    Q_OBJECT

public:
    explicit HrtmConfig(QDeclarativeItem *parent = 0);
    QList<QColor> bg_color;
    QList<QColor> text_color;
    QList<QColor> highlight_color;
    QList<QString> color_style;
    short current_style;
signals:

public slots:

};

#endif // HRTM_CONFIG_H
