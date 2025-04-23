#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "game.h"
#include "timer.h"
#include <QtQuickControls2/QQuickStyle>
#include <QtQuickControls2/QQuickStyle>  // Chemin correct
// Chemin correct
int main(int argc, char *argv[])
{
    // Définir un style non-natif qui prend en charge la personnalisation
    QQuickStyle::setStyle("Basic");  // Décommentez cette ligne et choisissez un style

    QGuiApplication app(argc, argv);

    // Création des instances des classes principales
    Game game;
    Timer timer;

    // Initialisation forcée du jeu
    game.startNewGame();  // Ajoutez ceci pour initialiser tous les états

    // Configuration du moteur QML
    QQmlApplicationEngine engine;

    // Exposition des classes C++ au contexte QML
    engine.rootContext()->setContextProperty("game", &game);
    engine.rootContext()->setContextProperty("timer", &timer);

    // Chargement du fichier QML principal
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
