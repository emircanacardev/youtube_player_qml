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

    QString playlistId = "PL7DA3D097D6FDBC02";
    QString apiKey = "AIzaSyDyrfjylyfUDODTjeBBp1tuhZ5ptnG5v4E";

    youtubeFetcher.fetchPlaylistData(playlistId, apiKey);

    engine.rootContext()->setContextProperty("youtubeFetcher", &youtubeFetcher);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}


