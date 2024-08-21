#include <QApplication>
#include <QQmlApplicationEngine>
#include <QWebEngineSettings>
#include <QWebEngineView>
#include <QtWebEngine>
#include <QQmlContext>
#include <youtubefetcher.h>

int main(int argc, char *argv[]) {

    QtWebEngine::initialize();

    QApplication app(argc, argv);


    QString playlistId = "PLovRZbEwYy6g_7u3YLtGy2o42OylAlS0M";
    QString apiKey = "AIzaSyDyrfjylyfUDODTjeBBp1tuhZ5ptnG5v4E";

    YouTubeFetcher youtubeFetcher;

    youtubeFetcher.fetchPlaylistVideos(playlistId, apiKey);
    QObject::connect(&youtubeFetcher, &YouTubeFetcher::fetchCompleted, [&youtubeFetcher]() {
        qDebug() << "fetchCompleted sinyali alındı!";

        // videoList'i kontrol et
        QVariantList videos = youtubeFetcher.getVideoList();
        qDebug() << "Fetched videos:" << videos;
    });

    QQmlApplicationEngine engine;

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}


