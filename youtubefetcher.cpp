#include "youtubefetcher.h"


YouTubeFetcher::YouTubeFetcher(QObject *parent)
    : QObject(parent)
{
    connect(&m_playlistNetworkManager, &QNetworkAccessManager::finished, this, &YouTubeFetcher::handlePlaylistDataReply);
    connect(&m_videoNetworkManager, &QNetworkAccessManager::finished, this, &YouTubeFetcher::handleVideoDataReply);
}

void YouTubeFetcher::fetchPlaylistData(QString playlistUrl) // Finished
{
    QUrl qUrl(playlistUrl);
    QUrlQuery urlQuery(qUrl);
    QString playlistId = urlQuery.queryItemValue("list");

    setPlaylistId(playlistId);

    QUrlQuery playlistQuery;
    QUrl playlistApiUrl("https://www.googleapis.com/youtube/v3/playlists");

    playlistQuery.addQueryItem("part", "snippet");
    playlistQuery.addQueryItem("id", playlistId);
    playlistQuery.addQueryItem("key", apiKey);

    playlistApiUrl.setQuery(playlistQuery);

    QNetworkRequest playlistReply(playlistApiUrl);
    m_playlistNetworkManager.get(playlistReply);
}

void YouTubeFetcher::handlePlaylistDataReply(QNetworkReply *playlistReply)
{

    if (playlistReply->error() == QNetworkReply::NoError)
    {
        QVariantMap playlistData;

        QByteArray response = playlistReply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();
        QJsonArray itemsArray = jsonObj["items"].toArray();

        QJsonObject firstItem = itemsArray[0].toObject();
        QJsonObject snippet = firstItem["snippet"].toObject();
        playlistData["playlistTitle"] = snippet["title"].toString();
        playlistData["playlistId"] = firstItem["id"].toString();

        foreach (const QVariant &data, m_playlistIdList)
        {
            QVariantMap map = data.toMap();
            if (map["playlistId"].toString() == playlistData["playlistId"])
            {
                return;
            }
        }

        m_playlistIdList.append(playlistData);
        emit playlistDataFetched();
    }

    playlistReply->deleteLater();
}

void YouTubeFetcher::fetchVideoData() // Finished
{
    QUrl url("https://www.googleapis.com/youtube/v3/playlistItems");
    QUrlQuery query;
    query.addQueryItem("part", "snippet");
    query.addQueryItem("playlistId", playlistId());
    query.addQueryItem("key", apiKey);
    query.addQueryItem("maxResults", "50");

    url.setQuery(query);

    QNetworkRequest request(url);
    m_videoNetworkManager.get(request);
}

void YouTubeFetcher::handleVideoDataReply(QNetworkReply *reply)
{
    m_videoList.clear();

    if (reply->error() == QNetworkReply::NoError)
    {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();
        QJsonArray itemsArray = jsonObj["items"].toArray();

        for (const QJsonValue& item : itemsArray)
        {
            QVariantMap videoData;  // Her bir videonun ayrı ayrı bilgilerini tutmak için bir map yapısı.

            QJsonObject snippet = item.toObject()["snippet"].toObject();
            videoData["title"] = snippet["title"].toString();
            videoData["videoId"] = snippet["resourceId"].toObject()["videoId"].toString();
            videoData["thumbnail"] = snippet["thumbnails"].toObject()["high"].toObject()["url"].toString();
            videoData["canPlay"] = true;

            m_videoList.append(videoData); // Dataları listeye appendledik.
        }
        reply->deleteLater();
        emit videoDataFetched();
    }
    else
    {
        qWarning() << "API Error:" << reply->errorString(); // API düzgün çalışmazsa kontrol için
        reply->deleteLater();
    }
}

QVariantList YouTubeFetcher::videoList() const
{
    return m_videoList;
}

QString YouTubeFetcher::playlistId() const
{
    return m_playlistId;
}

void YouTubeFetcher::setPlaylistId(const QString &newPlaylistId)
{
    if (m_playlistId == newPlaylistId)
    {
        return;
    }
    m_playlistId = newPlaylistId;
    emit playlistIdChanged();
}

QVariantList YouTubeFetcher::playlistIdList() const
{
    return m_playlistIdList;
}
