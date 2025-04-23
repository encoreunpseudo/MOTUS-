#include "timer.h"
#include <QDebug>

Timer::Timer(QObject *parent)
    : QObject(parent)
    , m_running(false)
    , m_elapsed(0)
{
    connect(&m_timer, &QTimer::timeout, this, &Timer::updateTimer);

    // Réglage du timer pour qu'il se déclenche toutes les secondes
    m_timer.setInterval(1000);
}

void Timer::start()
{
    if (!m_running) {
        qDebug() << "Timer started";
        m_startTime = QTime::currentTime();
        m_timer.start();
        m_running = true;
        emit isRunningChanged();
    }
}

void Timer::stop()
{
    if (m_running) {
        qDebug() << "Timer stopped";
        m_timer.stop();
        m_elapsed = m_startTime.secsTo(m_currentTime);
        m_running = false;
        emit isRunningChanged();
    }
}

void Timer::reset()
{
    qDebug() << "Timer reset";
    m_timer.stop();
    m_elapsed = 0;
    m_running = false;
    emit isRunningChanged();
    emit displayTimeChanged();
}

QString Timer::displayTime() const
{
    int seconds = elapsedSeconds();
    int minutes = seconds / 60;
    seconds %= 60;

    return QString("%1:%2")
        .arg(minutes, 2, 10, QChar('0'))
        .arg(seconds, 2, 10, QChar('0'));
}

bool Timer::isRunning() const
{
    return m_running;
}

int Timer::elapsedSeconds() const
{
    if (m_running) {
        return m_startTime.secsTo(m_currentTime);
    } else {
        return m_elapsed;
    }
}

void Timer::updateTimer()
{
    m_currentTime = QTime::currentTime();
    emit displayTimeChanged();
}
