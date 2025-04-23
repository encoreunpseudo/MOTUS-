#ifndef GAME_H
#define GAME_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QVariantList>
#include "dictionary.h"

/**
 * @brief La classe Game gère la logique du jeu Motus
 */
class Game : public QObject
{
    Q_OBJECT

    // Propriétés exposées au QML
    Q_PROPERTY(QString currentWord READ currentWord NOTIFY currentWordChanged)
    Q_PROPERTY(QString maskedWord READ maskedWord NOTIFY maskedWordChanged)
    Q_PROPERTY(int attemptsLeft READ attemptsLeft NOTIFY attemptsLeftChanged)
    Q_PROPERTY(int currentAttempt READ currentAttempt NOTIFY currentAttemptChanged)
    Q_PROPERTY(bool gameWon READ gameWon NOTIFY gameStateChanged)
    Q_PROPERTY(bool gameLost READ gameLost NOTIFY gameStateChanged)
    Q_PROPERTY(bool gameActive READ gameActive NOTIFY gameStateChanged)
    Q_PROPERTY(int wordLength READ wordLength WRITE setWordLength NOTIFY wordLengthChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(QVariantList grid READ grid NOTIFY gridChanged)
    Q_PROPERTY(QVariantList keyboardState READ keyboardState NOTIFY keyboardStateChanged)
    Q_PROPERTY(QString currentGuess READ currentGuess NOTIFY currentGuessChanged)

public:
    explicit Game(QObject *parent = nullptr);
    ~Game() = default;

    // Méthodes accessibles depuis QML
    Q_INVOKABLE void startNewGame();
    Q_INVOKABLE QVariantList checkGuess(const QString &guess);
    Q_INVOKABLE bool isValidWord(const QString &word);
    Q_INVOKABLE void abandonGame();
    Q_INVOKABLE QString revealRandomLetter();

    // Nouvelles méthodes pour le clavier virtuel et grille
    Q_INVOKABLE void keyPressed(const QString &key);
    Q_INVOKABLE void backspacePressed();
    Q_INVOKABLE void enterPressed();
    Q_INVOKABLE void resetCurrentGuess();
    Q_INVOKABLE QVariantMap getCellInfo(int row, int col);
    Q_INVOKABLE QString getKeyStatus(const QString &key) const;

    // Getters pour les propriétés
    QString currentWord() const { return m_currentWord; }
    QString maskedWord() const { return m_maskedWord; }
    int attemptsLeft() const { return m_maxAttempts - m_currentAttempt; }
    int currentAttempt() const { return m_currentAttempt; }
    bool gameWon() const { return m_gameWon; }
    bool gameLost() const { return m_gameLost; }
    bool gameActive() const { return m_gameActive; }
    int wordLength() const { return m_wordLength; }
    int score() const { return m_score; }
    QVariantList grid() const { return m_grid; }
    QVariantList keyboardState() const { return m_keyboardState; }
    QString currentGuess() const { return m_currentGuess; }

    // Setters
    void setWordLength(int length);

signals:
    // Signaux pour notifier les changements de propriétés
    void currentWordChanged();
    void maskedWordChanged();
    void attemptsLeftChanged();
    void currentAttemptChanged();
    void gameStateChanged();
    void gameStarted();
    void gameEnded(bool won);
    void wordLengthChanged();
    void scoreChanged();
    void gridChanged();
    void keyboardStateChanged();
    void currentGuessChanged();
    void invalidWord();
    void letterInserted(int row, int col, const QString &letter);
    void letterRevealed(int position, QString letter);

private:
    // Méthodes privées
    void selectRandomWord();
    QString createMaskedWord();
    void initializeGrid();
    void initializeKeyboard();
    void updateGrid(int row, const QVariantList &result);
    void updateKeyboard(const QVariantList &result);
    void addPoints(int correctLetters);

    // Attributs privés
    Dictionary m_dictionary;
    QString m_currentWord;
    QString m_maskedWord;
    QString m_currentGuess;
    int m_currentAttempt;
    int m_wordLength;
    int m_maxAttempts;
    int m_score;
    bool m_gameWon;
    bool m_gameLost;
    bool m_gameActive;
    QVariantList m_grid;
    QVariantList m_keyboardState;

    QString m_targetWord;
    QList<bool> m_revealedLetters; // Pour suivre les lettres déjà révélées
    QList<int> m_revealedIndices; // Pour stocker les indices des lettres révélées

};

#endif // GAME_H
