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

    // QString playlistId = "PL4BS1o6D9qZL8gODpYZ40D_1_HNQp1Q0a";
    // QString playlistId = "ADxL1aqCkQ8";
    // QString apiKey = "AIzaSyDyrfjylyfUDODTjeBBp1tuhZ5ptnG5v4E";

    youtubeFetcher.fetchPlaylistData();

    engine.rootContext()->setContextProperty("youtubeFetcher", &youtubeFetcher);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}


