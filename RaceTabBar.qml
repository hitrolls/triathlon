import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Item {
    id: root

    readonly property int barHeight: 96
    readonly property color barColor: "#4a5560"
    readonly property color activeColor: "#6d7884"
    readonly property color strokeColor: "#1a1a1a"

    implicitHeight: barHeight + safeBottom
    implicitWidth: 200

    Rectangle {
        anchors.fill: parent
        color: root.barColor
        border {
            width: 1
            color: root.strokeColor
        }
    }
}
