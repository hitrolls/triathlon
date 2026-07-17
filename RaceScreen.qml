import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root

    property bool racing: false

    signal requestHub(int tab)

    function startRace() {
        for (let i = 0; i < athletesModel.count; ++i) {
            athletesModel.setProperty(i, "progress", 0)
            athletesModel.setProperty(i, "pose", "run")
            athletesModel.setProperty(i, "headDetached", false)
        }
        root.racing = true
    }

    function endRace() {
        root.racing = false
    }

    function tickRace(dt) {
        let active = 0
        for (let i = 0; i < athletesModel.count; ++i) {
            if (athletesModel.get(i).pose !== "run")
                continue

            ++active
            let progress = athletesModel.get(i).progress + athletesModel.get(i).speed * dt

            if (progress >= 1) {
                athletesModel.setProperty(i, "progress", 1)
                athletesModel.setProperty(i, "pose", "finish")
                --active
                continue
            }

            if (progress > 0.08 && progress < 0.92 && Math.random() < 0.35 * dt) {
                const dead = Math.random() < 0.45
                athletesModel.setProperty(i, "progress", progress)
                athletesModel.setProperty(i, "headDetached", dead && Math.random() < 0.45)
                athletesModel.setProperty(i, "pose", dead ? "dead" : "injured")
                --active
                continue
            }

            athletesModel.setProperty(i, "progress", progress)
        }

        if (active === 0)
            root.endRace()
    }

    readonly property ListModel athletesModel: ListModel {
        ListElement {
            number: 7
            jerseyColor: "#e85d4c"
            accentColor: "#f2efe8"
            scaleFactor: 1.15
            laneOffset: -56
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.14
        }
        ListElement {
            number: 12
            jerseyColor: "#3d7ea6"
            accentColor: "#ffe08a"
            scaleFactor: 1.05
            laneOffset: 8
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.11
        }
        ListElement {
            number: 3
            jerseyColor: "#5b8c5a"
            accentColor: "#f2efe8"
            scaleFactor: 0.95
            laneOffset: 64
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.17
        }
    }

    readonly property Timer raceTimer: Timer {
        interval: 16
        repeat: true
        running: root.racing
        onTriggered: root.tickRace(interval / 1000)
    }

    Rectangle {
        id: track

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            bottomMargin: root.racing ? raceTabBar.implicitHeight
                                       : hubTabBar.barHeight + safeBottom
        }
        color: "#e8e2d4"

        Rectangle {
            id: lane

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 80
                bottom: parent.bottom
                bottomMargin: 120
            }
            width: Math.min(parent.width * 0.42, 220)
            color: "#d9d0bc"
            border {
                width: 2
                color: "#1a1a1a"
            }

            readonly property real pathStart: height - 28
            readonly property real pathEnd: 28

            function yAtProgress(p) {
                return pathEnd + (1 - p) * (pathStart - pathEnd)
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 18
                }
                height: 10
                color: "#1a1a1a"

                Row {
                    anchors.fill: parent
                    Repeater {
                        model: 8

                        Rectangle {
                            required property int index

                            width: parent.width / 8
                            height: parent.height
                            color: index % 2 === 0 ? "#f2efe8" : "#1a1a1a"
                        }
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: 28
                }
                height: 4
                color: "#1a1a1a"
            }

            Item {
                id: athleteShadows

                anchors.fill: parent
                z: 0
            }

            Repeater {
                model: root.athletesModel

                Item {
                    id: runner

                    required property int number
                    required property string jerseyColor
                    required property string accentColor
                    required property real scaleFactor
                    required property real laneOffset
                    required property real progress
                    required property string pose
                    required property bool headDetached

                    width: athlete.width
                    height: athlete.height
                    x: (lane.width - width) / 2 + laneOffset
                    y: lane.yAtProgress(progress) - height
                    // Depth from on-screen Y; include fall slide so corpses don't float over runners ahead
                    z: Math.max(1, Math.round(y + height + athlete.depthBias))

                    Athlete {
                        id: athlete

                        number: runner.number
                        jerseyColor: runner.jerseyColor
                        accentColor: runner.accentColor
                        scaleFactor: runner.scaleFactor
                        pose: runner.pose
                        headDetached: runner.headDetached
                        shadowsLayer: athleteShadows
                        shadowDepth: runner.z
                    }
                }
            }
        }

        Column {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 28
            }
            spacing: 12

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.racing ? qsTr("Finish race") : qsTr("Start race")
                onClicked: {
                    if (root.racing) {
                        root.endRace()
                        return
                    }
                    root.startRace()
                }

                contentItem: Text {
                    text: parent.text
                    color: "#f2efe8"
                    font {
                        pixelSize: 15
                        bold: true
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    implicitWidth: 160
                    implicitHeight: 44
                    radius: 8
                    color: "#d04545"
                }
            }
        }
    }

    HubTabBar {
        id: hubTabBar

        z: 1
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: -3
        }
        visible: !root.racing
        currentIndex: 0

        onCurrentIndexChanged: {
            if (!visible || currentIndex === 0)
                return
            const tab = currentIndex
            currentIndex = 0
            root.requestHub(tab)
        }
    }

    RaceTabBar {
        id: raceTabBar

        z: 1
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: -3
        }

        visible: root.racing
    }
}
