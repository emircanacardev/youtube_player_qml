#include "youtubefetcher.h"
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>

YouTubeFetcher::YouTubeFetcher(QObject *parent)
    : QObject(parent) {
}


void YouTubeFetcher::fetchPlaylistVideos(const QString &playlistId, const QString &apiKey) {
    QUrl url("https://www.googleapis.com/youtube/v3/playlistItems");
    QUrlQuery query;
    query.addQueryItem("part", "snippet");
    query.addQueryItem("playlistId", playlistId);
    query.addQueryItem("key", apiKey);
    url.setQuery(query);

    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &YouTubeFetcher::handleNetworkReply);
}

void YouTubeFetcher::handleNetworkReply()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    if (reply->error() == QNetworkReply::NoError)
    {

        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();
        QJsonArray itemsArray = jsonObj["items"].toArray();

        m_videoInfoList.clear();

        for (const QJsonValue& item : itemsArray) {
            QJsonObject snippet = item.toObject()["snippet"].toObject();
            QString videoId = snippet["resourceId"].toObject()["videoId"].toString();
            QString thumbnail = snippet["thumbnails"].toObject()["high"].toObject()["url"].toString();
            QString title = snippet["title"].toString();

            m_videoInfoList.append({title, videoId, thumbnail});
        }


        for (const VideoInfo& videoInfo : qAsConst(m_videoInfoList)) {
            qDebug() << "trackName:" << videoInfo.title;
            qDebug() << "trackUrl:" << videoInfo.videoId;
            qDebug() << "trackThumbnail:" << videoInfo.thumbnail;
            qDebug() << "--------------------------";
        }
    } else {
        qWarning() << "API Error:" << reply->errorString();
    }

    reply->deleteLater();
}


