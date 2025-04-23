#include "dictionary.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

Dictionary::Dictionary(const QString &dictionaryPath, QObject *parent)
    : QObject(parent)
    , m_dictionaryPath(dictionaryPath)
{
    loadDictionary("./dictionnaire.txt");
}

bool Dictionary::containsWord(const QString &word) const
{
    return m_words.contains(word.toLower());
}

QStringList Dictionary::getWordsOfLength(int length) const
{
    return m_wordsByLength.value(length);
}

int Dictionary::wordCount() const
{
    return m_words.size();
}

bool Dictionary::reloadDictionary()
{
    m_words.clear();
    m_wordsByLength.clear();
    return loadDictionary(m_dictionaryPath);
}

bool Dictionary::loadDictionary(const QString &filePath)
{
    QFile file(filePath);

    if (!file.exists()) {
        qWarning() << "Dictionary file does not exist:" << filePath;
        return false;
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open dictionary file:" << filePath;
        return false;
    }

    QTextStream in(&file);

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    in.setEncoding(QStringConverter::Utf8);
#else
    in.setCodec("UTF-8");
#endif

    int count = 0;
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed().toLower();

        if (line.isEmpty()) {
            continue;
        }

        m_words.append(line);

        // Indexation par longueur
        int length = line.length();
        if (!m_wordsByLength.contains(length)) {
            m_wordsByLength[length] = QStringList();
        }
        m_wordsByLength[length].append(line);

        count++;
    }

    file.close();

    qInfo() << "Loaded" << count << "words from dictionary";

    // Rapporter les statistiques des mots par longueur
    QHashIterator<int, QStringList> i(m_wordsByLength);
    while (i.hasNext()) {
        i.next();
        qDebug() << "Words of length" << i.key() << ":" << i.value().size();
    }

    return true;
}
