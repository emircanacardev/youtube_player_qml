#ifndef YOUTUBEFETCHER_H
#define YOUTUBEFETCHER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

struct VideoInfo {
    QString title;
    QString videoId;
    QString thumbnail;
};

class YouTubeFetcher : public QObject
{
    Q_OBJECT

public:
    explicit YouTubeFetcher(QObject *parent = nullptr);
    void fetchPlaylistVideos(const QString &playlistId, const QString &apiKey);

private slots:
    void handleNetworkReply();

private:
    QNetworkAccessManager m_networkManager;
    QList<VideoInfo> m_videoInfoList;

};


#endif // YOUTUBEFETCHER_H
