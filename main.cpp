#include <QApplication>
#include <QQmlApplicationEngine>
#include <QWebEngineSettings>
#include <QWebEngineView>
#include <QtWebEngine>

int main(int argc, char *argv[]) {

    QtWebEngine::initialize();

    QApplication app(argc, argv);


    QQmlApplicationEngine engine;


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}


