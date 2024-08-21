#include "youtubefetcher.h"
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>

YouTubeFetcher::YouTubeFetcher(QObject *parent)
    : QObject(parent)
{
    connect(this, &YouTubeFetcher::fetchCompleted, this, [this]()
    {
        QVariantList videos = this->getVideoList();
        qDebug() << "Fetched videos:" << videos;
        // Burada videoList ile yapılacak işlemleri gerçekleştirebilirsin.
    });
}

QVariantList YouTubeFetcher::getVideoList() const
{

    return videoList;
}

void YouTubeFetcher::fetchPlaylistVideos(const QString &playlistId, const QString &apiKey) {
    QUrl url("https://www.googleapis.com/youtube/v3/playlistItems");
    QUrlQuery query;
    query.addQueryItem("part", "snippet");
    query.addQueryItem("playlistId", playlistId);
    query.addQueryItem("key", apiKey);
    query.addQueryItem("maxResults", "5");

    url.setQuery(query);

    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &YouTubeFetcher::handleNetworkReply);
}



void YouTubeFetcher::handleNetworkReply()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    videoList.clear();

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

            videoList.append(videoData); // Dataları listeye appendledik.
        }

        emit fetchCompleted();
    }



    else
    {
        qWarning() << "API Error:" << reply->errorString(); // API düzgün çalışmazsa kontrol için
    }

    reply->deleteLater();
}
