import QtQuick

Item {
    id: root

    property bool minimumDelayElapsed: false

    readonly property bool ready: gameLoader.status === Loader.Ready && root.minimumDelayElapsed
    readonly property Timer minimumDelay: Timer {
        interval: 100
        onTriggered: root.minimumDelayElapsed = true
    }

    function startLoading() {
        root.minimumDelayElapsed = false
        root.minimumDelay.restart()
        gameLoader.active = true
    }

    Loader {
        id: gameLoader

        anchors.fill: parent
        asynchronous: true
        active: false
        visible: root.ready
        sourceComponent: gameComponent
    }

    Component {
        id: gameComponent

        Game { }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1c1a"
        visible: !root.ready

        Column {
            anchors.centerIn: parent
            spacing: 24

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Hellish triathlon")
                color: "#f2efe8"
                font.pixelSize: 28
                font.bold: true
            }

            Rectangle {
                id: spinner

                anchors.horizontalCenter: parent.horizontalCenter
                width: 36
                height: 36
                radius: 18
                color: "transparent"
                border.color: "#d04545"
                border.width: 3

                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: "#d04545"
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 2
                }

                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 900
                    loops: Animation.Infinite
                    running: !root.ready
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Loading…")
                color: "#888"
                font.pixelSize: 14
            }
        }
    }
}
