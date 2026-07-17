import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root

    property int currentIndex: 0

    readonly property int barHeight: 96
    readonly property int raisedExtra: 36
    readonly property int tabCount: tabRow.children.length
    readonly property color barColor: "#4a5560"
    readonly property color activeColor: "#6d7884"
    readonly property color strokeColor: "#1a1a1a"

    implicitHeight: barHeight + raisedExtra + safeBottom
    implicitWidth: 200

    component HubTabButton: AbstractButton {
        id: tabButton

        required property int index
        property string emoji
        property bool locked: false
        property bool badge: false

        readonly property bool isActive: root.currentIndex === index

        width: root.width / root.tabCount
        height: isActive ? root.barHeight + root.raisedExtra + safeBottom
                         : root.barHeight + safeBottom
        enabled: !locked

        checkable: true
        checked: isActive

        anchors.bottom: parent.bottom

        onClicked: {
            if (!locked)
                root.currentIndex = index
        }

        background: Rectangle {
            anchors.fill: parent
            color: tabButton.isActive ? root.activeColor : root.barColor
            border {
                width: tabButton.isActive ? 2 : 1
                color: root.strokeColor
            }
        }

        contentItem: Item {
            Text {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: (tabButton.isActive ? 20 + root.raisedExtra : 20) + safeBottom
                }
                text: tabButton.locked ? "🔒" : tabButton.emoji
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
                    visible: tabButton.badge && !tabButton.locked
                }
            }
        }
    }

    Row {
        id: tabRow

        anchors.fill: parent

        HubTabButton {
            index: 0
            text: qsTr("Race")
            emoji: "🏁"
            badge: true
        }

        HubTabButton {
            index: 1
            text: qsTr("Athletes")
            emoji: "👥"
        }

        HubTabButton {
            index: 2
            text: qsTr("Track")
            emoji: "🗺️"
        }

        HubTabButton {
            index: 3
            text: qsTr("Bank")
            emoji: "💰"
        }
    }
}
