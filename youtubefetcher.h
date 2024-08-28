#ifndef YOUTUBEFETCHER_H
#define YOUTUBEFETCHER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include <QUrlQuery>

class YouTubeFetcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList videoList READ videoList NOTIFY videoListChanged FINAL)

public:
    explicit YouTubeFetcher(QObject *parent = nullptr);

    Q_INVOKABLE void fetchPlaylistData();

    QVariantList videoList() const;

    void fetchVideoEmbedInfo(const QString &videoId, QVariantMap &videoData);

signals:
    void playListDataFetched();
    void videoListChanged();

private slots:
    void handleNetworkReply(QNetworkReply *reply);

private:
    QNetworkAccessManager m_networkManager;
    QVariantList m_videoList;
};


#endif // YOUTUBEFETCHER_H
