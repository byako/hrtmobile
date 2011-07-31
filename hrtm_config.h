#ifndef HRTM_CONFIG_H
#define HRTM_CONFIG_H

#include <QDeclarativeItem>
#include <QColor>

class HrtmConfig : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(QColor bgColor READ bgColor WRITE bgColorSet NOTIFY bgColorChanged)
    Q_PROPERTY(QColor textColor READ textColor WRITE textColorSet NOTIFY textColorChanged)
    Q_PROPERTY(QColor highlightColor READ highlightColor WRITE highlightColorSet NOTIFY highlightColorChanged)
    Q_PROPERTY(QString colorStyleName READ colorStyleName WRITE colorStyleNameSet NOTIFY colorStyleNameChanged)
    Q_PROPERTY(int currentStyle READ currentStyle WRITE currentStyleSet NOTIFY currentStyleChanged)

    QColor bgColor_;
    QColor textColor_;
    QColor highlightColor_;
    QString colorStyleName_;
    int currentStyle_;

public:
    explicit HrtmConfig(QDeclarativeItem *parent = 0);

    QColor bgColor() const;
    void bgColorSet(const QColor &);
    QColor textColor() const;
    void textColorSet(const QColor &);
    QColor highlightColor() const;
    void highlightColorSet(const QColor &);
    QString colorStyleName() const;
    void colorStyleNameSet(const QString &);
    int currentStyle() const;
    void currentStyleSet(int);

signals:
    void bgColorChanged();
    void textColorChanged();
    void highlightColorChanged();
    void colorStyleNameChanged();
    void currentStyleChanged();
public slots:

};

#endif // HRTM_CONFIG_H
