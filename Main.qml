import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Window {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: qsTr("Motus")

    // Gestionnaire d'écrans
    property string currentScreen: "home"

    // Écran d'accueil
    Item {
        id: homeScreen
        anchors.fill: parent
        visible: currentScreen === "home"

        Rectangle {
            anchors.fill: parent
            color: "#f0f0f0"
        }

        Column {
            anchors.centerIn: parent
            spacing: 20
            width: parent.width * 0.5

            Text {
                text: "MOTUS"
                font.pixelSize: 48
                font.bold: true
                color: "#e74c3c"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            // Bouton Nouvelle Partie
            Rectangle {
                width: parent.width
                height: 60
                color: mouseArea1.pressed ? "#2980b9" : "#3498db"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Nouvelle Partie")
                    font.pixelSize: 20
                    color: "white"
                }

                MouseArea {
                    id: mouseArea1
                    anchors.fill: parent
                    onClicked: {
                        timer.reset();
                        game.startNewGame();
                        timer.start();
                        currentScreen = "game";
                    }
                }
            }

            // Bouton Règles du Jeu
            Rectangle {
                width: parent.width
                height: 60
                color: mouseArea2.pressed ? "#27ae60" : "#2ecc71"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Règles du Jeu")
                    font.pixelSize: 20
                    color: "white"
                }

                MouseArea {
                    id: mouseArea2
                    anchors.fill: parent
                    onClicked: {
                        currentScreen = "rules";
                    }
                }
            }

            // Bouton Quitter
            Rectangle {
                width: parent.width
                height: 60
                color: mouseArea3.pressed ? "#c0392b" : "#e74c3c"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Quitter")
                    font.pixelSize: 20
                    color: "white"
                }

                MouseArea {
                    id: mouseArea3
                    anchors.fill: parent
                    onClicked: {
                        Qt.quit();
                    }
                }
            }
        }
    }

    // Écran de règles
    Item {
        id: rulesScreen
        anchors.fill: parent
        visible: currentScreen === "rules"

        Rectangle {
            anchors.fill: parent
            color: "#4b86f0"
        }

        // En-tête
        Rectangle {
            id: rulesHeader
            width: parent.width
            height: 60
            color: "#f0a044"

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Rectangle {
                    width: 40
                    height: 40
                    color: "#4b86f0"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        color: "white"
                        font.pixelSize: 24
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentScreen = "home";
                        }
                    }
                }

                Text {
                    text: "Règles du jeu"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#4b86f0"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Contenu des règles
        Rectangle {
            anchors.top: rulesHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            color: "white"
            radius: 8

            Flickable {
                anchors.fill: parent
                anchors.margins: 20
                contentHeight: rulesContent.height
                clip: true

                Column {
                    id: rulesContent
                    width: parent.width
                    spacing: 15

                    Text {
                        width: parent.width
                        text: "Comment jouer au Motus"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        text: "1. La première lettre du mot est donnée."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 16
                    }

                    Text {
                        width: parent.width
                        text: "2. Essayez de deviner le mot en 6 tentatives maximum."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 16
                    }

                    Text {
                        width: parent.width
                        text: "3. Après chaque tentative, les lettres sont colorées :"
                        wrapMode: Text.WordWrap
                        font.pixelSize: 16
                    }

                    Row {
                        spacing: 10

                        Rectangle {
                            width: 30
                            height: 30
                            color: "#42a642" // Vert
                        }

                        Text {
                            text: "La lettre est correcte et bien placée"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 10

                        Rectangle {
                            width: 30
                            height: 30
                            color: "#f0a044" // Orange
                        }

                        Text {
                            text: "La lettre est dans le mot mais mal placée"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 10

                        Rectangle {
                            width: 30
                            height: 30
                            color: "#7f8c8d" // Gris
                        }

                        Text {
                            text: "La lettre n'est pas dans le mot"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        width: parent.width
                        text: "4. Les mots peuvent contenir des lettres qui se répètent."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 16
                    }

                    Text {
                        width: parent.width
                        text: "5. Les accents ne sont pas pris en compte."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 16
                    }
                }
            }
        }
    }

    // Écran de jeu
    GameScreen {
        id: gameScreenItem
        anchors.fill: parent
        visible: currentScreen === "game"

        onBackToHomeClicked: {
            timer.stop();
            game.abandonGame();
            currentScreen = "home";
        }
    }

    // Transitions entre les écrans
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    // Connexions au jeu
    Connections {
        target: game
    }
}
