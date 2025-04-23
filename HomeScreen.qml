import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: homeScreen

    // Signaux pour les actions
    signal playClicked()
    signal rulesClicked()
    signal quitClicked()

    background: Rectangle {
        color: "#f0f0f0"
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        width: parent.width * 0.5

        Label {
            text: "MOTUS"
            font.pixelSize: 48
            font.bold: true
            color: "#e74c3c"
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: qsTr("Nouvelle Partie")
            font.pixelSize: 20
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            background: Rectangle {
                color: parent.down ? "#2980b9" : "#3498db"
                radius: 5
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                playClicked()
            }
        }

        Button {
            text: qsTr("Règles du Jeu")
            font.pixelSize: 20
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            background: Rectangle {
                color: parent.down ? "#27ae60" : "#2ecc71"
                radius: 5
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                rulesClicked()
            }
        }

        Button {
            text: qsTr("Quitter")
            font.pixelSize: 20
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            background: Rectangle {
                color: parent.down ? "#c0392b" : "#e74c3c"
                radius: 5
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                quitClicked()
            }
        }
    }
}
