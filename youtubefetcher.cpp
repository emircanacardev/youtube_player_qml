#include "youtubefetcher.h"


YouTubeFetcher::YouTubeFetcher(QObject *parent)
    : QObject(parent)
{
    connect(&m_networkManager, &QNetworkAccessManager::finished, this, &YouTubeFetcher::handleNetworkReply);
}

void YouTubeFetcher::fetchPlaylistData() // Finished
{
    QUrl url("https://www.googleapis.com/youtube/v3/playlistItems");
    QUrlQuery query;
    query.addQueryItem("part", "snippet");
    query.addQueryItem("playlistId", "PLxA687tYuMWhkqYjvAGtW_heiEL4Hk_Lx");
    query.addQueryItem("key", "AIzaSyDyrfjylyfUDODTjeBBp1tuhZ5ptnG5v4E");
    query.addQueryItem("maxResults", "15");

    url.setQuery(query);

    QNetworkRequest request(url);
    m_networkManager.get(request);
}

void YouTubeFetcher::handleNetworkReply(QNetworkReply *reply)
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

            m_videoList.append(videoData); // Dataları listeye appendledik.
        }
        reply->deleteLater();
        emit playListDataFetched();
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


