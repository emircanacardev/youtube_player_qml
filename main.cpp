#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QWebEngineSettings>
#include <QWebEngineView>
#include <QtWebEngine>
#include <QQmlContext>
#include <youtubefetcher.h>

int main(int argc, char *argv[]) {

    QtWebEngine::initialize();

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    YouTubeFetcher youtubeFetcher;

    QString playlistUrl1 = "https://www.youtube.com/playlist?list=PL7DA3D097D6FDBC02";
    QString playlistUrl2 = "https://www.youtube.com/playlist?list=PLiCkTNneBHcYPOUnWF-zM1niD58MI4VF3";

    youtubeFetcher.fetchPlaylistData(playlistUrl1);
    youtubeFetcher.fetchPlaylistData(playlistUrl2);
    youtubeFetcher.fetchVideoData();

    engine.rootContext()->setContextProperty("youtubeFetcher", &youtubeFetcher);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}


