import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: gameScreen

    // Signal pour retourner à l'écran d'accueil
    signal backToHomeClicked()

    // Couleurs du jeu
    property color colorBackground: "#4b86f0"        // Fond bleu
    property color colorHeader: "#f0a044"            // En-tête orange
    property color colorAccent: "#4b86f0"            // Bleu accent
    property color colorCorrect: "#42a642"           // Vert pour lettre correcte
    property color colorMisplaced: "#f0a044"         // Orange pour lettre mal placée
    property color colorWrong: "#7f8c8d"             // Gris pour lettre incorrecte
    property color colorKeyboardBg: "#a7c5f4"        // Fond du clavier (bleu clair)

    // Fonction utilitaire pour obtenir le statut d'une touche de manière sécurisée
    function getKeyStatus(letter) {
        if (game && typeof game.getKeyStatus === "function") {
            // Si une fonction existe côté backend, utiliser celle-ci
            return game.getKeyStatus(letter) || "unused";
        } else if (game && game.keyboardState) {
            // Sinon, parcourir manuellement le tableau keyboardState
            for (var i = 0; i < game.keyboardState.length; i++) {
                var row = game.keyboardState[i];
                for (var j = 0; j < row.length; j++) {
                    if (row[j] && row[j].key === letter) {
                        return row[j].status || "unused";
                    }
                }
            }
        }
        return "unused";
    }

    // Fonction pour mettre à jour toutes les touches du clavier
    function updateKeyboardColors() {
        // Désactivé - les touches ne changent plus de couleur
    }

    Connections {
        target: game
        function onGridChanged() {
            // Force la mise à jour de toutes les cellules
            for (var i = 0; i < cellRepeater.count; i++) {
                var cell = cellRepeater.itemAt(i);
                if (cell) {
                    cell.displayText = Qt.binding(function() {
                        if (this.row === game.currentAttempt && this.col < game.currentGuess.length) {
                            return game.currentGuess.charAt(this.col).toUpperCase();
                        }
                        var info = game.getCellInfo(this.row, this.col);
                        return info.letter || "";
                    });

                    cell.cellColor = Qt.binding(function() {
                        var info = game.getCellInfo(this.row, this.col);
                        if (info.status === "correct") return colorCorrect;
                        if (info.status === "misplaced") return colorMisplaced;
                        if (info.status === "wrong") return colorWrong;
                        return colorBackground;  // Fond par défaut
                    });
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: colorBackground  // Bleu vif
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // En-tête
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: colorHeader  // Orange

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // Icône menu
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: "qrc:/icons/menu.png"
                        fillMode: Image.PreserveAspectFit
                        visible: false // Remplacer par votre vraie icône
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "≡"
                        color: colorAccent
                        font.pixelSize: 24
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: backToHomeClicked()
                    }
                }

                Text {
                    text: "Le jeu du Motus"
                    font.pixelSize: 24
                    font.bold: true
                    color: colorAccent
                }

                Item { Layout.fillWidth: true }

                // Bouton utilisateur
                Rectangle {
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 180
                    color: colorAccent
                    radius: 20

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 10

                        // Icône utilisateur
                        Rectangle {
                            width: 30
                            height: 30
                            radius: 15
                            color: "white"

                            Text {
                                anchors.centerIn: parent
                                text: "👤"
                                color: colorAccent
                                font.pixelSize: 16
                            }
                        }

                        Text {
                            text: "User1272629202"
                            color: "white"
                            font.pixelSize: 14
                            Layout.fillWidth: true
                            leftPadding: 8  // Ajoute un petit espace après l'icône
                        }
                    }
                }
            }
        }

        // Barre d'outils
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: colorBackground

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                // Bouton nouvelle partie
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    color: colorBackground
                    border.color: "white"
                    border.width: 2
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: "white"
                        font.pixelSize: 24
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            game.startNewGame();
                            timer.reset();
                            timer.start();
                        }
                    }
                }

                // Bouton sélection longueur mot
                Rectangle {
                    id: wordLengthButton
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 50
                    color: colorBackground
                    border.color: "white"
                    border.width: 2
                    radius: 5
                    layer.enabled: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 5

                        Text {
                            text: "📏"
                            font.pixelSize: 16
                            color: "white"
                        }

                        Text {
                            text: "Mot"
                            font.pixelSize: 16
                            color: "white"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: "▼"
                            font.pixelSize: 12
                            color: "white"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: wordLengthMenu.open()
                    }

                    // Menu déroulant modifié
                    Popup {
                        id: wordLengthMenu
                        y: wordLengthButton.height + 2
                        width: wordLengthButton.width
                        height: 180
                        padding: 0

                        background: Rectangle {
                            color: "white"
                            border.color: "#ddd"
                            radius: 4
                        }

                        Column {
                            width: parent.width
                            Repeater {
                                model: [3, 4, 5, 6, 7, 8]
                                Rectangle {
                                    width: parent.width
                                    height: 30
                                    color: mouseArea.containsMouse ? "#f0f0f0" : "white"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData + " lettres"
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            game.wordLength = modelData;
                                            game.startNewGame();
                                            wordLengthMenu.close();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Espace entre les boutons
                Item {
                    Layout.fillWidth: true
                }

                // Bouton aide
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    color: colorBackground
                    border.color: "white"
                    border.width: 2
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        color: "white"
                        font.pixelSize: 24
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            helpDialog.visible = true
                        }
                    }
                }
            }
        }

        // Zone de score et info
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: colorBackground

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                // Numéro de partie
                Text {
                    text: "Partie"
                    color: "white"
                    font.pixelSize: 18
                }

                // Longueur du mot
                Rectangle {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 120
                    color: "#3CB371"  // Vert
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "en " + game.wordLength + " lettres"
                        color: "white"
                        font.pixelSize: 14
                    }
                }

                Item { Layout.fillWidth: true }

                // Score
                Text {
                    text: game.score + " Pts"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Chronomètre
                Text {
                    text: "⏱ " + timer.displayTime
                    color: "white"
                    font.pixelSize: 16
                }
            }
        }

        // Grille de jeu
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridLayout {
                id: gameGrid
                anchors.centerIn: parent
                columns: game.wordLength
                rows: 6 // Nombre maximum de tentatives
                columnSpacing: 2
                rowSpacing: 2

                Repeater {
                    id: cellRepeater
                    model: 6 * game.wordLength

                    Rectangle {
                        id: cell
                        width: 60
                        height: 60
                        radius: 0
                        border.width: 2
                        border.color: "white"

                        property int row: Math.floor(index / game.wordLength)
                        property int col: index % game.wordLength

                        // Texte à afficher
                        property string displayText: {
                            if (row === game.currentAttempt && col < game.currentGuess.length) {
                                return game.currentGuess.charAt(col).toUpperCase();
                            }
                            var info = game.getCellInfo(row, col);
                            return info.letter || "";
                        }

                        // Couleur de fond
                        property color cellColor: {
                            if (row === game.currentAttempt && col < game.currentGuess.length) {
                                return colorAccent;
                            }

                            var info = game.getCellInfo(row, col);
                            switch(info.status) {
                                case "correct": return colorCorrect;
                                case "misplaced": return colorMisplaced;
                                case "wrong": return colorWrong;
                                default: return colorBackground;
                            }
                        }

                        color: cellColor

                        Text {
                            anchors.centerIn: parent
                            text: parent.displayText
                            font.pixelSize: 36
                            font.bold: true
                            color: "white"
                        }

                        // Animation seulement pour la ligne active
                        Rectangle {
                            anchors.centerIn: parent
                            width: 8
                            height: 8
                            radius: 4
                            color: "white"
                            visible: row === game.currentAttempt
                                    && col === game.currentGuess.length
                                    && displayText === ""
                        }
                    }
                }
            }
        }

        // Bouton d'indice
        Rectangle {
            id: hintBanner
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#65c1e6"  // Bleu clair
            opacity: mouseArea.containsMouse ? 0.8 : 1.0

            Text {
                anchors.centerIn: parent
                text: "Bloqué ? Affichez une lettre"
                font.pixelSize: 18
                color: "black"
            }

            MouseArea {
                id: hintMouseArea  // Nouvel ID unique
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    const revealed = game.revealRandomLetter();
                    if (revealed === "") {
                        hintAnimation.start();
                    }
                }
            }

            SequentialAnimation {
                id: hintAnimation
                PropertyAnimation {
                    target: hintBanner
                    property: "color"
                    to: "#ff5555"
                    duration: 200
                }
                PropertyAnimation {
                    target: hintBanner
                    property: "color"
                    to: "#65c1e6"
                    duration: 200
                }
            }
        }

        // Clavier virtuel
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            color: colorKeyboardBg  // Bleu clair pour le fond du clavier

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                // Première rangée de touches (AZERTY)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    spacing: 5

                    Repeater {
                        id: row1Repeater
                        model: ["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"]

                        Rectangle {
                            id: keyButton
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            radius: 5

                            property string letter: modelData
                            // Utiliser la fonction getKeyStatus pour obtenir l'état
                            property string keyStatus: getKeyStatus(letter)

                            // Couleurs dynamiques selon l'état de la touche
                            color: {
                                return colorKeyboardBg;  // Fond par défaut
                            }
                            border.color: "#ffffff"

                            Text {
                                anchors.centerIn: parent
                                text: letter
                                font.pixelSize: 24
                                font.bold: true
                                color: parent.keyStatus !== "unused" ? "white" : "black"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onPressed: parent.scale = 0.95
                                onReleased: parent.scale = 1.0
                                onClicked: {
                                    if (game && game.gameActive) {
                                        game.keyPressed(letter);
                                    }
                                }
                            }

                            // Animation de la touche
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }

                // Deuxième rangée de touches
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    spacing: 5

                    Repeater {
                        id: row2Repeater
                        model: ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"]

                        Rectangle {
                            id: keyButton2
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            radius: 5

                            property string letter: modelData
                            // Utiliser la fonction getKeyStatus pour obtenir l'état
                            property string keyStatus: getKeyStatus(letter)

                            color: {
                                return colorKeyboardBg;  // Fond par défaut
                            }
                            border.color: "#ffffff"

                            Text {
                                anchors.centerIn: parent
                                text: letter
                                font.pixelSize: 24
                                font.bold: true
                                color: parent.keyStatus !== "unused" ? "white" : "black"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onPressed: parent.scale = 0.95
                                onReleased: parent.scale = 1.0
                                onClicked: {
                                    if (game && game.gameActive) {
                                        game.keyPressed(letter);
                                    }
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }

                // Troisième rangée de touches
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    spacing: 5

                    // Touche supprimer (backspace)
                    Rectangle {
                        id: backspaceButton
                        Layout.fillHeight: true
                        Layout.preferredWidth: 60
                        radius: 5
                        color: "#222222"

                        Text {
                            anchors.centerIn: parent
                            text: "⌫"
                            font.pixelSize: 24
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.scale = 0.95
                            onReleased: parent.scale = 1.0
                            onClicked: {
                                if (game && game.gameActive) {
                                    game.backspacePressed();
                                }
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 50
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    // Autres touches
                    Repeater {
                        id: row3Repeater
                        model: ["W", "X", "C", "V", "B", "N"]

                        Rectangle {
                            id: keyButton3
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            radius: 5

                            property string letter: modelData
                            // Utiliser la fonction getKeyStatus pour obtenir l'état
                            property string keyStatus: getKeyStatus(letter)

                            color: {
                                return colorKeyboardBg;  // Fond par défaut
                            }
                            border.color: "#ffffff"

                            Text {
                                anchors.centerIn: parent
                                text: letter
                                font.pixelSize: 24
                                font.bold: true
                                color: parent.keyStatus !== "unused" ? "white" : "black"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onPressed: parent.scale = 0.95
                                onReleased: parent.scale = 1.0
                                onClicked: {
                                    if (game && game.gameActive) {
                                        game.keyPressed(letter);
                                    }
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }

                    // Touche entrée
                    Rectangle {
                        id: enterButton
                        Layout.fillHeight: true
                        Layout.preferredWidth: 60
                        radius: 5
                        color: "#222222"

                        Text {
                            anchors.centerIn: parent
                            text: "↩"
                            font.pixelSize: 24
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.scale = 0.95
                            onReleased: parent.scale = 1.0
                            onClicked: {
                                if (game && game.gameActive) {
                                    game.enterPressed();
                                }
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 50
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }
    }

    // Dialog d'aide
    Rectangle {
        id: helpDialog
        anchors.centerIn: parent
        width: 400
        height: 500
        color: "white"
        radius: 10
        visible: false
        z: 100

        Rectangle {
            id: helpHeader
            width: parent.width
            height: 50
            color: colorHeader
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "Règles du jeu"
                font.pixelSize: 20
                font.bold: true
                color: "white"
            }

            Rectangle {
                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: 30
                                height: 30
                                radius: 15
                                color: "white"

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    font.pixelSize: 20
                                    color: colorHeader
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: helpDialog.visible = false
                                }
                            }
                        }

                        Flickable {
                            anchors.top: helpHeader.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 20
                            contentHeight: helpContent.height
                            clip: true

                            Column {
                                id: helpContent
                                width: parent.width
                                spacing: 15

                                Text {
                                    width: parent.width
                                    text: "Comment jouer au Motus"
                                    font.pixelSize: 18
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    text: "1. Trouvez le mot dans un nombre limité d'essais. La première lettre est donnée."
                                    wrapMode: Text.WordWrap
                                }

                                Text {
                                    width: parent.width
                                    text: "2. Pour chaque essai, les lettres sont colorées selon ces règles:"
                                    wrapMode: Text.WordWrap
                                }

                                Row {
                                    spacing: 10

                                    Rectangle {
                                        width: 30
                                        height: 30
                                        color: colorCorrect
                                    }

                                    Text {
                                        text: "Lettre correcte, bien placée"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    spacing: 10

                                    Rectangle {
                                        width: 30
                                        height: 30
                                        color: colorMisplaced
                                    }

                                    Text {
                                        text: "Lettre présente mais mal placée"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    spacing: 10

                                    Rectangle {
                                        width: 30
                                        height: 30
                                        color: colorWrong
                                    }

                                    Text {
                                        text: "Lettre absente du mot"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    // Dialog pour mot invalide
                    Rectangle {
                        id: invalidWordDialog
                        anchors.centerIn: parent
                        width: 300
                        height: 150
                        color: "white"
                        radius: 10
                        visible: false
                        z: 100

                        // Conteneur pour le texte (ajouté)
                            Column {
                                anchors.top: parent.top
                                anchors.topMargin: 25  // Ajustez cette valeur pour positionner verticalement
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - 40
                                spacing: 5

                                Text {
                                    width: parent.width
                                    text: "Ce mot n'existe pas"
                                    font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.Wrap
                                }

                                Text {
                                    width: parent.width
                                    text: "dans le dictionnaire"
                                    font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.Wrap
                                }
                            }


                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 20
                            width: 100
                            height: 40
                            color: colorAccent
                            radius: 5

                            Text {
                                anchors.centerIn: parent
                                text: "OK"
                                color: "white"
                                font.pixelSize: 16
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: invalidWordDialog.visible = false
                            }
                        }

                        Connections {
                            target: game
                            function onInvalidWord() {
                                invalidWordDialog.visible = true

                                // Animation de secousse
                                shakeAnimation.start()
                            }
                        }

                        SequentialAnimation {
                            id: shakeAnimation
                            running: false

                            NumberAnimation {
                                target: invalidWordDialog
                                property: "x"
                                from: invalidWordDialog.x
                                to: invalidWordDialog.x - 10
                                duration: 50
                            }
                            NumberAnimation {
                                target: invalidWordDialog
                                property: "x"
                                from: invalidWordDialog.x - 10
                                to: invalidWordDialog.x + 10
                                duration: 50
                            }
                            NumberAnimation {
                                target: invalidWordDialog
                                property: "x"
                                from: invalidWordDialog.x + 10
                                to: invalidWordDialog.x - 10
                                duration: 50
                            }
                            NumberAnimation {
                                target: invalidWordDialog
                                property: "x"
                                from: invalidWordDialog.x - 10
                                to: invalidWordDialog.x
                                duration: 50
                            }
                        }
                    }

                    // Dialog de fin de partie
                    Rectangle {
                        id: endGameDialog
                        anchors.centerIn: parent
                        width: 350
                        height: 300
                        color: "white"
                        radius: 10
                        visible: false
                        z: 100

                        property bool won: false

                        Rectangle {
                            id: endGameHeader
                            width: parent.width
                            height: 60
                            color: endGameDialog.won ? colorCorrect : colorWrong  // Correction : référence explicite à endGameDialog.won
                            radius: 10

                            Text {
                                anchors.centerIn: parent
                                text: endGameDialog.won ? "Félicitations !" : "Partie terminée"  // Correction ici aussi
                                font.pixelSize: 22
                                font.bold: true
                                color: "white"
                            }
                        }

                        Column {
                            anchors.top: endGameHeader.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: buttonsRow.top
                            anchors.margins: 20
                            spacing: 15

                            Text {
                                width: parent.width
                                text: endGameDialog.won ?
                                    "Vous avez trouvé le mot !" :
                                    "Vous n'avez pas trouvé le mot.\nLe mot était : " + game.currentWord
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#dddddd"
                            }

                            // Stats
                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 10

                                Text {
                                    text: "Temps :"
                                    font.pixelSize: 16
                                }

                                Text {
                                    text: timer.displayTime
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: colorAccent
                                }
                            }
                        }

                        // Boutons
                        Row {
                            id: buttonsRow
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 20
                            spacing: 20

                            // Bouton retour
                            Rectangle {
                                width: 120
                                height: 40
                                color: "#e74c3c"
                                radius: 5

                                Text {
                                    anchors.centerIn: parent
                                    text: "Quitter"
                                    color: "white"
                                    font.pixelSize: 16
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        endGameDialog.visible = false;
                                        backToHomeClicked();
                                    }
                                }
                            }

                            // Bouton rejouer
                            Rectangle {
                                width: 120
                                height: 40
                                color: colorCorrect
                                radius: 5

                                Text {
                                    anchors.centerIn: parent
                                    text: "Rejouer"
                                    color: "white"
                                    font.pixelSize: 16
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        endGameDialog.visible = false;
                                        game.startNewGame();
                                        timer.reset();
                                        timer.start();
                                    }
                                }
                            }
                        }

                        // Émoji de confettis pour victoire
                        Text {
                            visible: endGameDialog.won
                            text: "🎉"
                            font.pixelSize: 40
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 10

                            SequentialAnimation on y {
                                running: endGameDialog.visible && endGameDialog.won
                                loops: Animation.Infinite
                                NumberAnimation { from: parent.y + 10; to: parent.y - 10; duration: 500; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: parent.y - 10; to: parent.y + 10; duration: 500; easing.type: Easing.InOutQuad }
                            }
                        }
                    }

                    // Capture des touches du clavier physique
                    focus: true

                    Keys.onPressed: function(event) {
                        if (!game.gameActive) return;

                        // A-Z et a-z
                        if ((event.key >= Qt.Key_A && event.key <= Qt.Key_Z) ||
                            (event.key >= Qt.Key_A + 32 && event.key <= Qt.Key_Z + 32)) {
                            var pressedLetter = String.fromCharCode(event.key).toUpperCase();
                            game.keyPressed(pressedLetter);
                            event.accepted = true;

                            // Actualisation des cellules avec des noms de variables uniques
                            for (var cellIdx = 0; cellIdx < cellRepeater.count; cellIdx++) {
                                var currentCell = cellRepeater.itemAt(cellIdx);
                                if (currentCell && currentCell.row === game.currentAttempt) {
                                    currentCell.displayText = Qt.binding(function() {
                                        if (this.col < game.currentGuess.length) {
                                            return game.currentGuess.charAt(this.col).toUpperCase();
                                        }
                                        var cellInfo = game.getCellInfo(this.row, this.col);
                                        return cellInfo.letter || "";
                                    });
                                }
                            }
                        }
                        // Backspace
                        else if (event.key === Qt.Key_Backspace) {
                            game.backspacePressed();
                            event.accepted = true;

                            for (var bsCellIdx = 0; bsCellIdx < cellRepeater.count; bsCellIdx++) {
                                var bsCell = cellRepeater.itemAt(bsCellIdx);
                                if (bsCell && bsCell.row === game.currentAttempt) {
                                    bsCell.displayText = Qt.binding(function() {
                                        if (this.col < game.currentGuess.length) {
                                            return game.currentGuess.charAt(this.col).toUpperCase();
                                        }
                                        return "";
                                    });
                                }
                            }
                        }
                        // Enter
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            game.enterPressed();
                            event.accepted = true;
                        }
                    }

                    // Connexions pour les événements du jeu
                    Connections {
                        target: game

                        function onGameEnded(won) {
                            timer.stop();
                            endGameDialog.won = won;
                            endGameDialog.visible = true;
                        }

                        function onGameStarted() {
                            // Réinitialiser la grille
                            if (cellRepeater && cellRepeater.count > 0) {
                                for (var i = 0; i < cellRepeater.count; i++) {
                                    var cell = cellRepeater.itemAt(i);
                                    if (cell) {
                                        cell.displayText = "";
                                        cell.cellColor = colorBackground; // Réinitialiser la couleur
                                    }
                                }
                            }
                            updateKeyboardColors(); // Mettre à jour le clavier
                        }

                        function onCurrentGuessChanged() {
                            if (cellRepeater && cellRepeater.count > 0) {
                                for (var gcIdx = 0; gcIdx < cellRepeater.count; gcIdx++) {
                                    var gcCell = cellRepeater.itemAt(gcIdx);
                                    if (gcCell && gcCell.row === game.currentAttempt) {
                                        gcCell.displayText = Qt.binding(function() {
                                            if (this.col < game.currentGuess.length) {
                                                return game.currentGuess.charAt(this.col).toUpperCase();
                                            }
                                            var gcInfo = game.getCellInfo(this.row, this.col);
                                            return gcInfo.letter || "";
                                        });
                                    }
                                }
                            }
                        }

                        function updateKeyboardColors() {
                            // Désactivé - les touches ne changent plus de couleur
                        }

                        function onAttemptSubmitted() {
                                updateKeyboardColors();
                        }
                    }

                    // Démarre le chronomètre quand la page est active
                    onVisibleChanged: {
                        if (visible) {
                            timer.start();
                        } else {
                            timer.stop();
                        }
                    }

                    // Force le focus au chargement
                    Component.onCompleted: {
                        forceActiveFocus();
                        timer.start();
                    }

                }

