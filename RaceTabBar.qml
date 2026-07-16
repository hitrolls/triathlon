import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Rectangle {
    id: root

    property int athletes: 0
    property int athleteCap: 20
    property real athleteRegen: 0
    property var athleteTypes: [
        { name: qsTr("Runner"), cost: 1, color: "#7cb87c" },
        { name: qsTr("Heavy"), cost: 3, color: "#d4b45a" },
        { name: qsTr("Clown"), cost: 5, color: "#c97b9b" }
    ]

    signal spawnRequested(int typeIndex)

    implicitHeight: 118
    color: "#1e1c1a"

    ColumnLayout {
        anchors {
            fill: parent
            margins: 8
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: qsTr("Athletes %1 / %2").arg(root.athletes).arg(root.athleteCap)
                color: "#c8e0c8"
                font {
                    pixelSize: 13
                    bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                radius: 5
                color: "#333333"

                Rectangle {
                    width: parent.width * Math.min(1, root.athleteRegen)
                    height: parent.height
                    radius: 5
                    color: "#7cb87c"
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Repeater {
                model: root.athleteTypes

                Button {
                    id: spawnButton

                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: modelData.name
                    enabled: root.athletes >= modelData.cost

                    onClicked: root.spawnRequested(index)

                    contentItem: Column {
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: spawnButton.text
                            color: "#f2efe8"
                            font {
                                pixelSize: 13
                                bold: true
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("%1 athletes").arg(spawnButton.modelData.cost)
                            color: "#a8d0a8"
                            font.pixelSize: 11
                        }
                    }

                    background: Rectangle {
                        radius: 8
                        color: spawnButton.enabled ? "#2f4a2f" : "#2a2826"
                        border {
                            width: 2
                            color: spawnButton.enabled ? spawnButton.modelData.color : "#555555"
                        }
                        opacity: spawnButton.enabled ? 1 : 0.45
                    }
                }
            }
        }
    }
}
