#include "game.h"
#include <QDebug>
#include <QRandomGenerator>
#include <QVariantMap>

Game::Game(QObject *parent)
    : QObject(parent)
    , m_dictionary("./dictionnaire.txt")
    , m_wordLength(4)  // Commencer avec 4 lettres comme dans l'image
    , m_maxAttempts(6)
    , m_score(0)
    , m_gameWon(false)
    , m_gameLost(false)
    , m_gameActive(false)
    , m_currentAttempt(0)
{
    qDebug() << "Game instance created";
    initializeKeyboard();
}

void Game::startNewGame()
{
    // Réinitialisation des états du jeu
    m_gameWon = false;
    m_gameLost = false;
    m_gameActive = true;
    m_currentAttempt = 0;
    m_currentGuess = "";

    // Réinitialiser les indices révélés
    m_revealedIndices.clear();

    // Sélection d'un mot aléatoire et création du masque
    selectRandomWord();
    m_maskedWord = createMaskedWord();

    // Initialisation de la grille et du clavier
    initializeGrid();
    initializeKeyboard();

    qDebug() << "New game started with word:" << m_currentWord << "Word length:" << m_wordLength;

    // Émission des signaux pour notifier les changements
    emit currentWordChanged();
    emit maskedWordChanged();
    emit attemptsLeftChanged();
    emit currentAttemptChanged();
    emit gameStateChanged();
    emit gridChanged();
    emit keyboardStateChanged();
    emit currentGuessChanged();
    emit gameStarted();
}

QVariantList Game::checkGuess(const QString &guess)
{
    QVariantList result;
    QString upperGuess = guess.toUpper();
    QString upperWord = m_currentWord.toUpper();
    QString remainingLetters = upperWord;

    // Premier passage : lettres correctement placées
    for (int i = 0; i < m_wordLength; ++i) {
        QVariantMap letterInfo;
        letterInfo["letter"] = upperGuess[i];

        if (upperGuess[i] == upperWord[i]) {
            letterInfo["status"] = "correct";
            remainingLetters[i] = ' '; // Marquer comme utilisé
        } else {
            letterInfo["status"] = "wrong"; // Temporaire
        }
        result.append(letterInfo);
    }

    // Deuxième passage : lettres mal placées
    for (int i = 0; i < m_wordLength; ++i) {
        if (result[i].toMap()["status"] == "correct") continue;

        int pos = remainingLetters.indexOf(upperGuess[i]);
        if (pos != -1) {
            QVariantMap letterInfo = result[i].toMap();
            letterInfo["status"] = "misplaced";
            result[i] = letterInfo;  // Met à jour l'entrée dans la liste !
            remainingLetters[pos] = ' '; // Marquer comme utilisé
        }
    }

    return result;
}

bool Game::isValidWord(const QString &word)
{
    if (word.length() != m_wordLength) {
        return false;
    }
    return m_dictionary.containsWord(word.toLower());
}

void Game::abandonGame()
{
    if (m_gameActive) {
        m_gameActive = false;
        m_gameLost = true;
        emit gameStateChanged();
        emit gameEnded(false);
        qDebug() << "Game abandoned";
    }
}


void Game::keyPressed(const QString &key)
{
    if (!m_gameActive)
        return;

    // Converti la touche en majuscule pour uniformité
    QString upperKey = key.toUpper();

    // Assurer que currentGuess est de la bonne longueur
    while (m_currentGuess.length() < m_wordLength) {
        m_currentGuess.append(' ');
    }

    // Chercher la première position non révélée et vide
    for (int i = 0; i < m_wordLength; i++) {
        // Sauter les positions révélées
        if (m_revealedIndices.contains(i))
            continue;

        // Si cette position est vide, on y met la lettre
        if (m_currentGuess[i] == ' ') {
            m_currentGuess[i] = upperKey[0];
            emit letterInserted(m_currentAttempt, i, upperKey);
            emit currentGuessChanged();
            return;
        }
    }
}



void Game::backspacePressed()
{
    if (!m_gameActive || m_currentGuess.isEmpty())
        return;

    /// Trouver la dernière lettre modifiable (non révélée)
    int pos = m_currentGuess.length() - 1;

    while (pos >= 0 && m_revealedIndices.contains(pos)) {
        pos--;
    }

    if (pos >= 0) {
        // Supprimer la lettre à cette position
        if (pos == m_currentGuess.length() - 1) {
            m_currentGuess.chop(1);
        } else {
            // Remplacer par un espace si c'est au milieu
            m_currentGuess[pos] = ' ';
        }
        emit letterInserted(m_currentAttempt, pos, "");
        emit currentGuessChanged();
    }
}



void Game::enterPressed()
{
    // Remplissons d'abord les espaces vides pour un mot complet
    QString completeGuess = m_currentGuess;
    while (completeGuess.length() < m_wordLength) {
        completeGuess.append(' ');
    }

    // Remplacer les espaces par des lettres aléatoires pour la vérification
    QString checkGuess = completeGuess;
    for (int i = 0; i < checkGuess.length(); i++) {
        if (checkGuess[i] == ' ') {
            checkGuess[i] = 'A'; // N'importe quelle lettre pour la vérification
        }
    }

    if (!m_gameActive || checkGuess.length() != m_wordLength)
        return;

    // Vérification du dictionnaire avant tout
    if (!isValidWord(checkGuess)) {
        qDebug() << "Mot non valide:" << checkGuess;
        emit invalidWord();
        // Ne pas réinitialiser currentGuess pour garder les lettres déjà tapées
        return;
    }

    // Appliquer les lettres révélées à la tentative actuelle
    for (int idx : m_revealedIndices) {
        if (idx < m_currentGuess.length()) {
            m_currentGuess[idx] = m_currentWord[idx];
        } else {
            // Ajouter des espaces si nécessaire
            while (m_currentGuess.length() < idx) {
                m_currentGuess.append(' ');
            }
            m_currentGuess.append(m_currentWord[idx]);
        }
    }

    // Remplacer les espaces restants par des lettres aléatoires pour la vérification
    QString finalGuess = m_currentGuess;
    for (int i = 0; i < finalGuess.length(); i++) {
        if (finalGuess[i] == ' ') {
            finalGuess[i] = 'A'; // N'importe quelle lettre pour la vérification
        }
    }

    // Le reste de la logique existante...
    QVariantList result = this->checkGuess(finalGuess);

    if (result.isEmpty()) return;

    // Mise à jour de la grille avant tout
    updateGrid(m_currentAttempt, result);

    bool won = true;
    for (const QVariant &item : result) {
        if (item.toMap()["status"] != "correct") {
            won = false;
            break;
        }
    }

    if (won) {
        m_gameWon = true;
        m_gameActive = false;
        emit gameEnded(true);
    } else {
        m_currentAttempt++;
        if (m_currentAttempt >= m_maxAttempts) {
            m_gameLost = true;
            m_gameActive = false;
            emit gameEnded(false);
        }
    }

    // Prépare un nouveau guess avec les lettres révélées
    QString newGuess = "";
    for (int i = 0; i < m_wordLength; i++) {
        if (m_revealedIndices.contains(i)) {
            // Ajouter les espaces nécessaires
            while (newGuess.length() < i) {
                newGuess.append(' ');
            }
            newGuess.append(m_currentWord[i]);
        }
    }

    m_currentGuess = newGuess;
    emit currentGuessChanged();
    emit gridChanged();
}




void Game::resetCurrentGuess()
{
    m_currentGuess = "";
    emit currentGuessChanged();
}


QVariantMap Game::getCellInfo(int row, int col)
{
    QVariantMap cell;
    cell["letter"] = "";
    cell["status"] = "empty";

    if (row < 0 || row >= m_maxAttempts || col < 0 || col >= m_wordLength)
        return cell;

    // Ligne active en cours de saisie
    if (row == m_currentAttempt) {
        if (col < m_currentGuess.length()) {
            // Ne pas afficher les espaces dans la grille
            if (m_currentGuess[col] != ' ') {
                cell["letter"] = m_currentGuess[col];

                // Si c'est une lettre révélée (elle correspond au mot secret), on la marque comme correcte
                if (m_currentGuess[col].toUpper() == m_currentWord[col].toUpper()) {
                    cell["status"] = "correct";
                } else {
                    cell["status"] = "typing";
                }
            }
        }
        return cell;
    }

    // Lignes validées (reste inchangé)
    if (row < m_currentAttempt && row < m_grid.size()) {
        QVariantList rowData = m_grid[row].toList();
        if (col < rowData.size()) {
            return rowData[col].toMap();
        }
    }

    return cell;
}



void Game::setWordLength(int length)
{
    if (m_wordLength != length && length >= 3 && length <= 10) {
        m_wordLength = length;
        emit wordLengthChanged();

        if (m_gameActive)
            startNewGame();
        else {
            initializeGrid();
            emit gridChanged();
        }
    }
}

void Game::initializeGrid()
{
    m_grid.clear();
    // Création d'une grille vide avec m_maxAttempts lignes
    for (int row = 0; row < m_maxAttempts; ++row) {
        QVariantList rowData;
        for (int col = 0; col < m_wordLength; ++col) {
            QVariantMap cellInfo;
            cellInfo["letter"] = "";
            // La première cellule (0,0) affiche toujours la première lettre du mot
            if (row == 0 && col == 0) {
                if (!m_currentWord.isEmpty())
                    cellInfo["letter"] = m_currentWord[0];
                cellInfo["status"] = "correct";
            } else {
                cellInfo["status"] = "empty";
            }
            rowData.append(cellInfo);
        }
        m_grid.append(rowData);
    }
}

void Game::selectRandomWord()
{
    QStringList words = m_dictionary.getWordsOfLength(m_wordLength);
    if (words.isEmpty()) {
        qWarning() << "No words of length" << m_wordLength << "found in dictionary";
        if (m_wordLength == 4)
            m_currentWord = "GAME";
        else if (m_wordLength == 6)
            m_currentWord = "MOTUS";
        else
            m_currentWord = QString("A").repeated(m_wordLength);
        return;
    }
    int randomIndex = QRandomGenerator::global()->bounded(words.size());
    m_currentWord = words.at(randomIndex).toUpper();
}

QString Game::createMaskedWord()
{
    if (m_currentWord.isEmpty())
        return "";
    QString mask = m_currentWord.left(1);
    for (int i = 1; i < m_currentWord.length(); ++i)
        mask.append('*');
    return mask;
}

void Game::updateGrid(int row, const QVariantList &result)
{
    if (row < 0 || row >= m_maxAttempts) return;

    QVariantList newRow;
    for (int col = 0; col < m_wordLength; ++col) {
        QVariantMap cell;
        if (col < result.size()) {
            QVariantMap res = result[col].toMap();
            cell["letter"] = res["letter"].toString();
            cell["status"] = res["status"].toString();
        } else {
            // Cas par défaut si résultat incomplet
            cell["letter"] = "";
            cell["status"] = "empty";
        }
        newRow.append(cell);
    }

    // Mise à jour de la grille
    if (row >= m_grid.size()) {
        m_grid.append(newRow);
    } else {
        m_grid[row] = newRow;
    }

    emit gridChanged();
}

void Game::initializeKeyboard()
{
    m_keyboardState.clear();
    QVariantList keyboardData;

    // Utiliser exactement les mêmes touches que dans votre clavier QML
    QStringList allKeys = {"A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P",
                           "Q", "S", "D", "F", "G", "H", "J", "K", "L", "M",
                           "W", "X", "C", "V", "B", "N"};

    for (const QString &key : allKeys) {
        QVariantMap keyInfo;
        keyInfo["key"] = key;
        keyInfo["status"] = "unused";
        keyboardData.append(keyInfo);
    }

    m_keyboardState.append(keyboardData);
    qDebug() << "Keyboard initialized with" << keyboardData.size() << "keys";
}

void Game::updateKeyboard(const QVariantList &result)
{
    if (m_keyboardState.isEmpty()) {
        qDebug() << "Warning: Keyboard not initialized";
        initializeKeyboard();
        if (m_keyboardState.isEmpty()) {
            qDebug() << "Error: Failed to initialize keyboard";
            return;
        }
    }

    QVariantList keyboardData = m_keyboardState[0].toList();
    for (const QVariant &item : result) {
        QVariantMap letterInfo = item.toMap();
        QString letter = letterInfo["letter"].toString();
        QString status = letterInfo["status"].toString();

        // Recherche de la touche
        bool found = false;
        for (int i = 0; i < keyboardData.size(); ++i) {
            QVariantMap keyInfo = keyboardData[i].toMap();
            // Mettre en majuscule pour comparaison uniforme
            if (keyInfo["key"].toString().toUpper() == letter.toUpper()) {
                found = true;
                QString currentStatus = keyInfo["status"].toString();
                // Mise à jour du statut seulement s'il est meilleur
                if (status == "correct" ||
                    (status == "misplaced" && currentStatus != "correct") ||
                    (status == "wrong" && currentStatus != "correct" && currentStatus != "misplaced")) {
                    keyInfo["status"] = status;
                    keyboardData[i] = keyInfo;
                }
                break;
            }
        }

        // Si la touche n'est pas trouvée, ne pas afficher d'avertissement
        // pour les saisies du clavier physique
        if (!found) {
            // Option 1: supprimer cette ligne pour ne plus voir les avertissements
            // qDebug() << "Warning: Key not found in keyboard layout:" << letter;

            // Option 2: ajouter la touche au clavier
            QVariantMap newKeyInfo;
            newKeyInfo["key"] = letter.toUpper();
            newKeyInfo["status"] = status;
            keyboardData.append(newKeyInfo);
        }
    }

    m_keyboardState[0] = keyboardData;
    emit keyboardStateChanged();
}

QString Game::getKeyStatus(const QString &key) const
{
    if (m_keyboardState.isEmpty())
        return "unused";
    QVariantList keyboardData = m_keyboardState[0].toList();
    for (const QVariant &item : keyboardData) {
        QVariantMap keyInfo = item.toMap();
        if (keyInfo["key"].toString() == key)
            return keyInfo["status"].toString();
    }
    return "unused";
}

void Game::addPoints(int correctLetters)
{
    int points = correctLetters * 10;
    if (correctLetters == m_wordLength)
        points += 50;
    points += (m_maxAttempts - m_currentAttempt) * 5;
    m_score += points;
    emit scoreChanged();
}

QString Game::revealRandomLetter() {
    // Vérifie si le jeu est actif
    if (!m_gameActive) {
        return "";
    }

    // Trouve les indices des lettres qui peuvent être révélées
    QList<int> possibleIndices;
    for (int i = 0; i < m_currentWord.length(); i++) {
        // Exclure les lettres déjà révélées
        if (!m_revealedIndices.contains(i)) {
            possibleIndices.append(i);
        }
    }

    // Aucune lettre à révéler
    if (possibleIndices.isEmpty()) {
        return "";
    }

    // Choisit une lettre aléatoire
    int randomIndex = possibleIndices[QRandomGenerator::global()->bounded(possibleIndices.size())];
    m_revealedIndices.append(randomIndex);

    // Met à jour la tentative actuelle pour inclure la lettre révélée
    if (randomIndex >= m_currentGuess.length()) {
        // Ajoute des espaces si nécessaire
        while (m_currentGuess.length() < randomIndex) {
            m_currentGuess.append(' ');
        }
        // Ajoute la lettre révélée
        m_currentGuess.append(m_currentWord[randomIndex]);
    } else {
        // Remplace la lettre à la position spécifiée
        m_currentGuess[randomIndex] = m_currentWord[randomIndex];
    }

    // Notifie les changements
    emit currentGuessChanged();
    emit letterRevealed(randomIndex, QString(m_currentWord[randomIndex]));

    return QString(m_currentWord[randomIndex]);
}
