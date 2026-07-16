import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root

    property int currentIndex: 0

    readonly property int safeBottom: window.safeBottom
    readonly property int barHeight: 96
    readonly property int raisedExtra: 36
    readonly property color barColor: "#4a5560"
    readonly property color activeColor: "#6d7884"
    readonly property color strokeColor: "#1a1a1a"

    readonly property var tabs: [
        { text: qsTr("Race"), emoji: "🏁", locked: false, badge: false },
        { text: qsTr("Athletes"), emoji: "👥", locked: false, badge: true },
        { text: qsTr("Track"), emoji: "🗺️", locked: false, badge: false },
        { text: qsTr("Bank"), emoji: "💰", locked: false, badge: false }
    ]

    implicitHeight: barHeight + raisedExtra + safeBottom
    implicitWidth: 200

    Row {
        id: tabRow

        anchors.fill: parent

        Repeater {
            model: root.tabs

            AbstractButton {
                id: tabButton

                required property int index
                required property var modelData

                readonly property bool isActive: root.currentIndex === index
                readonly property bool isLocked: modelData.locked

                width: root.width / root.tabs.length
                height: isActive ? root.barHeight + root.raisedExtra + root.safeBottom
                                 : root.barHeight + root.safeBottom
                enabled: !isLocked

                checkable: true
                checked: isActive

                anchors.bottom: parent.bottom

                onClicked: {
                    if (!isLocked)
                        root.currentIndex = index
                }

                background: Rectangle {
                    Rectangle {
                        anchors {
                            fill: parent
                        }
                        color: tabButton.isActive ? root.activeColor : root.barColor
                        border.width: isActive ? 2 : 1
                        border.color: root.strokeColor
                    }
                }

                contentItem: Item {
                    Text {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: (tabButton.isActive ? 20 + root.raisedExtra : 20) + root.safeBottom
                        }
                        text: tabButton.isLocked ? "🔒" : tabButton.modelData.emoji
                        font.pixelSize: 44

                        Rectangle {
                            anchors {
                                top: parent.top
                                right: parent.right
                            }
                            width: 14
                            height: 14
                            radius: 7
                            color: "#e53935"
                            border {
                                width: 2
                                color: root.strokeColor
                            }
                            visible: tabButton.modelData.badge && !tabButton.isLocked
                        }

                    }
                }
            }
        }
    }
}
