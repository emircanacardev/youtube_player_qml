#ifndef YOUTUBEFETCHER_H
#define YOUTUBEFETCHER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariantList>
#include <QVariantMap>

class YouTubeFetcher : public QObject
{
    Q_OBJECT
public:
    explicit YouTubeFetcher(QObject *parent = nullptr);

    QVariantList getVideoList() const;

    void fetchPlaylistVideos(const QString &playlistId, const QString &apiKey);

signals:
    void fetchCompleted();

private slots:
    void handleNetworkReply();

private:
    QNetworkAccessManager m_networkManager;
    QVariantList videoList;

};


#endif // YOUTUBEFETCHER_H
