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
    Q_PROPERTY(QString playlistId READ playlistId WRITE setPlaylistId NOTIFY playlistIdChanged FINAL)
    Q_PROPERTY(QVariantList playlistIdList READ playlistIdList NOTIFY playlistIdListChanged FINAL)

public:
    explicit YouTubeFetcher(QObject *parent = nullptr);

    Q_INVOKABLE void fetchVideoData();

    Q_INVOKABLE void fetchPlaylistData(QString playlistUrl);

    QVariantList videoList() const;

    void fetchVideoEmbedInfo(const QString &videoId, QVariantMap &videoData);

    QString playlistId() const;

    Q_INVOKABLE void setPlaylistId(const QString &newPlaylistId);

    QVariantList playlistIdList() const;

    QString apiKey = "AIzaSyDyrfjylyfUDODTjeBBp1tuhZ5ptnG5v4E";

signals:

    void videoDataFetched();

    void playlistDataFetched();

    void videoListChanged();

    void playlistIdChanged();

    void playlistIdListChanged();

private slots:
    void handleVideoDataReply(QNetworkReply *reply);

    void handlePlaylistDataReply(QNetworkReply *playlistReply);

private:
    QNetworkAccessManager m_videoNetworkManager;
    QNetworkAccessManager m_playlistNetworkManager;
    QVariantList m_videoList;
    QString m_playlistId;
    QVariantList m_playlistIdList;
};

#endif // YOUTUBEFETCHER_H
