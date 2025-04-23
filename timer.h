#ifndef TIMER_H
#define TIMER_H

#include <QObject>
#include <QTimer>
#include <QTime>

/**
 * @brief La classe Timer gère le chronomètre du jeu
 */
class Timer : public QObject
{
    Q_OBJECT

    // Propriétés exposées au QML
    Q_PROPERTY(QString displayTime READ displayTime NOTIFY displayTimeChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(int elapsedSeconds READ elapsedSeconds NOTIFY displayTimeChanged)

public:
    explicit Timer(QObject *parent = nullptr);
    ~Timer() = default;

    // Méthodes accessibles depuis QML
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void reset();

    // Getters pour les propriétés
    QString displayTime() const;
    bool isRunning() const;
    int elapsedSeconds() const;

signals:
    // Signaux pour notifier les changements de propriétés
    void displayTimeChanged();
    void isRunningChanged();

private slots:
    void updateTimer();

private:
    QTimer m_timer;
    QTime m_startTime;
    QTime m_currentTime;
    bool m_running;
    int m_elapsed;
};

#endif // TIMER_H
