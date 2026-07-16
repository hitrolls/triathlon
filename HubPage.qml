import QtQuick

Item {
    id: root

    property string title
    property color pageColor: "#e8e2d4"

    default property alias contentData: content.data

    Rectangle {
        anchors.fill: parent
        color: root.pageColor
    }

    Item {
        id: content

        anchors.fill: parent
    }

    Text {
        anchors.centerIn: parent
        text: root.title
        color: "#1e1c1a"
        visible: root.title.length > 0 && content.children.length === 0
        font {
            pixelSize: 22
            bold: true
        }
        z: 1
    }
}
