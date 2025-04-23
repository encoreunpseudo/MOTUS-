#ifndef DICTIONARY_H
#define DICTIONARY_H

#include <QObject>
#include <QStringList>
#include <QHash>

/**
 * @brief La classe Dictionary gère le dictionnaire de mots
 */
class Dictionary : public QObject
{
    Q_OBJECT

public:
    explicit Dictionary(const QString &dictionaryPath, QObject *parent = nullptr);
    ~Dictionary() = default;

    /**
     * @brief Vérifie si un mot existe dans le dictionnaire
     * @param word Le mot à vérifier
     * @return true si le mot existe, false sinon
     */
    bool containsWord(const QString &word) const;

    /**
     * @brief Obtient la liste des mots d'une longueur spécifique
     * @param length La longueur des mots à obtenir
     * @return La liste des mots de la longueur spécifiée
     */
    QStringList getWordsOfLength(int length) const;

    /**
     * @brief Obtient le nombre total de mots dans le dictionnaire
     * @return Le nombre de mots
     */
    int wordCount() const;

    /**
     * @brief Recharge le dictionnaire depuis le fichier
     * @return true si le chargement a réussi, false sinon
     */
    bool reloadDictionary();

private:
    /**
     * @brief Charge le dictionnaire depuis un fichier
     * @param filePath Chemin vers le fichier dictionnaire
     * @return true si le chargement a réussi, false sinon
     */
    bool loadDictionary(const QString &filePath);

    // Le dictionnaire complet
    QStringList m_words;

    // Index des mots par longueur pour un accès rapide
    QHash<int, QStringList> m_wordsByLength;

    // Chemin vers le fichier dictionnaire
    QString m_dictionaryPath;
};

#endif // DICTIONARY_H
