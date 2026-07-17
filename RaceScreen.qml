import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root

    property bool racing: false
    // Animation test: 3 athletes per discipline at race start. Set false for normal race.
    property bool debugMultiTrackStart: true

    signal requestHub(int tab)

    function isRacingPose(pose) {
        return pose === "swim" || pose === "bike" || pose === "run"
    }

    function poseForProgress(p) {
        const d = course.disciplineAt(p)
        if (d === "transition")
            return "run"

        const local = course.segmentLocal(p)
        if (d === "swim") {
            // Land below water → swim → climb out above water
            if (local < 0.1 || local > 0.9)
                return "run"
            return "swim"
        }
        if (d === "bike") {
            // Mount above → ride → dismount below
            if (local < 0.08 || local > 0.92)
                return "run"
            return "bike"
        }
        return "run"
    }

    // Start of each discipline (shore entry / mount / run start)
    function debugStartProgress(index) {
        const group = Math.floor(index / 3)
        if (group === 1)
            return course.segmentLen * 2
        if (group === 2)
            return course.segmentLen * 4
        return 0
    }

    function placeAthletesForWarmup() {
        const limit = root.debugMultiTrackStart ? athletesModel.count : 3
        for (let i = 0; i < athletesModel.count; ++i) {
            if (i >= limit) {
                athletesModel.setProperty(i, "progress", 0)
                athletesModel.setProperty(i, "pose", "warmup")
                athletesModel.setProperty(i, "headDetached", false)
                continue
            }
            const progress = root.debugMultiTrackStart ? root.debugStartProgress(i) : 0
            athletesModel.setProperty(i, "progress", progress)
            athletesModel.setProperty(i, "pose", "warmup")
            athletesModel.setProperty(i, "headDetached", false)
        }
    }

    function startRace() {
        const limit = root.debugMultiTrackStart ? athletesModel.count : 3
        for (let i = 0; i < athletesModel.count; ++i) {
            if (i >= limit) {
                athletesModel.setProperty(i, "progress", 0)
                athletesModel.setProperty(i, "pose", "warmup")
                athletesModel.setProperty(i, "headDetached", false)
                continue
            }
            const progress = root.debugMultiTrackStart ? root.debugStartProgress(i) : 0
            athletesModel.setProperty(i, "progress", progress)
            athletesModel.setProperty(i, "pose", root.poseForProgress(progress))
            athletesModel.setProperty(i, "headDetached", false)
        }
        root.racing = true
    }

    function endRace() {
        root.racing = false
    }

    Component.onCompleted: root.placeAthletesForWarmup()

    function speedScaleAt(p) {
        const d = course.disciplineAt(p)
        if (d === "transition")
            return 3
        if (d === "swim" && root.poseForProgress(p) === "swim")
            return 0.42
        return 1
    }

    function tickRace(dt) {
        let active = 0
        for (let i = 0; i < athletesModel.count; ++i) {
            const pose = athletesModel.get(i).pose
            if (!root.isRacingPose(pose))
                continue

            ++active
            const prev = athletesModel.get(i).progress
            let progress = prev + athletesModel.get(i).speed * root.speedScaleAt(prev) * dt

            if (progress >= 1) {
                athletesModel.setProperty(i, "progress", 1)
                athletesModel.setProperty(i, "pose", "finish")
                --active
                continue
            }

            // Casualties only on the run segment for now (swim/bike/transitions later)
            const discipline = course.disciplineAt(progress)
            if (discipline === "run" && progress < 0.98 && Math.random() < 0.35 * dt) {
                const dead = Math.random() < 0.45
                athletesModel.setProperty(i, "progress", progress)
                athletesModel.setProperty(i, "headDetached", dead && Math.random() < 0.45)
                athletesModel.setProperty(i, "pose", dead ? "dead" : "injured")
                --active
                continue
            }

            athletesModel.setProperty(i, "progress", progress)
            athletesModel.setProperty(i, "pose", root.poseForProgress(progress))
        }

        if (active === 0)
            root.endRace()
    }

    readonly property ListModel athletesModel: ListModel {
        // Swim trio
        ListElement {
            number: 7
            jerseyColor: "#e85d4c"
            accentColor: "#f2efe8"
            scaleFactor: 1.15
            laneOffset: -14
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.04
        }
        ListElement {
            number: 12
            jerseyColor: "#3d7ea6"
            accentColor: "#ffe08a"
            scaleFactor: 1.05
            laneOffset: 2
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.03
        }
        ListElement {
            number: 3
            jerseyColor: "#5b8c5a"
            accentColor: "#f2efe8"
            scaleFactor: 0.95
            laneOffset: 16
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.05
        }
        // Bike trio (debugMultiTrackStart)
        ListElement {
            number: 21
            jerseyColor: "#c47a2c"
            accentColor: "#f2efe8"
            scaleFactor: 1.1
            laneOffset: -14
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.045
        }
        ListElement {
            number: 18
            jerseyColor: "#6b5b95"
            accentColor: "#ffe08a"
            scaleFactor: 1.0
            laneOffset: 2
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.035
        }
        ListElement {
            number: 9
            jerseyColor: "#2a9d8f"
            accentColor: "#f2efe8"
            scaleFactor: 0.98
            laneOffset: 16
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.042
        }
        // Run trio (debugMultiTrackStart)
        ListElement {
            number: 4
            jerseyColor: "#d64045"
            accentColor: "#ffe08a"
            scaleFactor: 1.12
            laneOffset: -14
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.038
        }
        ListElement {
            number: 15
            jerseyColor: "#457b9d"
            accentColor: "#f2efe8"
            scaleFactor: 1.02
            laneOffset: 2
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.048
        }
        ListElement {
            number: 11
            jerseyColor: "#8a5a44"
            accentColor: "#ffe08a"
            scaleFactor: 0.92
            laneOffset: 16
            progress: 0
            pose: "warmup"
            headDetached: false
            speed: 0.033
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

        Item {
            id: course

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: 16
                rightMargin: 16
                topMargin: 72
                bottomMargin: 120
            }

            readonly property real gap: 10
            readonly property real colW: (width - gap * 2) / 3
            readonly property real pathTop: 36
            readonly property real pathBottom: height - 36
            // Path Y is the shadow/stance point. Banks sit just outside lane edges.
            readonly property real shoreBelow: pathTop + 40
            readonly property real shoreAbove: pathTop + 8
            readonly property real swimX: colW * 0.5
            readonly property real bikeX: colW + gap + colW * 0.5
            readonly property real runX: colW * 2 + gap * 2 + colW * 0.5
            readonly property real segmentLen: 0.2

            function disciplineAt(p) {
                const t = Math.max(0, Math.min(1, p))
                if (t < segmentLen)
                    return "swim"
                if (t < segmentLen * 2)
                    return "transition"
                if (t < segmentLen * 3)
                    return "bike"
                if (t < segmentLen * 4)
                    return "transition"
                return "run"
            }

            function segmentLocal(p) {
                const t = Math.max(0, Math.min(1, p))
                const seg = Math.min(4, Math.floor(t / segmentLen))
                return (t - seg * segmentLen) / segmentLen
            }

            function pointAtProgress(p) {
                const t = Math.max(0, Math.min(1, p))
                const seg = Math.min(4, Math.floor(t / segmentLen))
                const local = (t - seg * segmentLen) / segmentLen
                let x = swimX
                let y = pathBottom
                let nx = 1
                let ny = 0

                if (seg === 0) {
                    // Swim up: land below → water → climb out above
                    x = swimX
                    y = pathBottom + (pathTop - pathBottom) * local
                        + shoreBelow * (1 - local) - shoreAbove * local
                    nx = 1
                    ny = 0
                } else if (seg === 1) {
                    // Top transition above the tracks
                    x = swimX + (bikeX - swimX) * local
                    y = pathTop - shoreAbove
                    nx = 0
                    ny = 1
                } else if (seg === 2) {
                    // Bike down: mount above → dismount below
                    x = bikeX
                    y = pathTop + (pathBottom - pathTop) * local
                        - shoreAbove * (1 - local) + shoreBelow * local
                    nx = 1
                    ny = 0
                } else if (seg === 3) {
                    // Bottom transition below the tracks
                    x = bikeX + (runX - bikeX) * local
                    y = pathBottom + shoreBelow
                    nx = 0
                    ny = 1
                } else {
                    // Run up: below → above
                    x = runX
                    y = pathBottom + (pathTop - pathBottom) * local
                        + shoreBelow * (1 - local) - shoreAbove * local
                    nx = 1
                    ny = 0
                }

                return {
                    x: x,
                    y: y,
                    nx: nx,
                    ny: ny,
                    discipline: disciplineAt(t)
                }
            }

            // Swim column
            Rectangle {
                id: swimLane

                x: 0
                width: course.colW
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: "#6ba3c9"
                border {
                    width: 2
                    color: "#1a1a1a"
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: 10
                    }
                    height: 8
                    color: "#8ec4e0"
                    opacity: 0.85
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
            }

            // Bike column
            Rectangle {
                id: bikeLane

                x: course.colW + course.gap
                width: course.colW
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: "#9a958a"
                border {
                    width: 2
                    color: "#1a1a1a"
                }

                Rectangle {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        bottom: parent.bottom
                        topMargin: 20
                        bottomMargin: 20
                    }
                    width: 3
                    color: "#f2efe8"
                    opacity: 0.55
                }
            }

            // Run column
            Rectangle {
                id: runLane

                x: course.colW * 2 + course.gap * 2
                width: course.colW
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: "#d9d0bc"
                border {
                    width: 2
                    color: "#1a1a1a"
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
                            model: 6

                            Rectangle {
                                required property int index

                                width: parent.width / 6
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
            }

            // Top connector swim → bike (above tracks)
            Rectangle {
                x: course.colW - 2
                y: course.pathTop - course.shoreAbove - 14
                width: course.gap + 4
                height: 28
                color: "#9a958a"
                border {
                    width: 2
                    color: "#1a1a1a"
                }
                z: 1
                visible: false
            }

            // Bottom connector bike → run (below tracks)
            Rectangle {
                x: course.colW + course.gap + course.colW - 2
                y: course.pathBottom + course.shoreBelow - 14
                width: course.gap + 4
                height: 28
                color: "#d9d0bc"
                border {
                    width: 2
                    color: "#1a1a1a"
                }
                z: 1
                visible: false
            }

            Item {
                id: athleteShadows

                anchors.fill: parent
                z: 2
            }

            Item {
                id: athleteBlood

                anchors.fill: parent
                z: 2
            }

            Repeater {
                model: root.athletesModel

                Item {
                    id: runner

                    required property int index
                    required property int number
                    required property string jerseyColor
                    required property string accentColor
                    required property real scaleFactor
                    required property real laneOffset
                    required property real progress
                    required property string pose
                    required property bool headDetached

                    property real moveFacing: -1
                    property real lastTrackY: -1
                    readonly property real facing: (pose === "warmup" || pose === "finish")
                                                   ? 1 : moveFacing
                    readonly property var trackPoint: course.pointAtProgress(progress)

                    visible: index < 3 || root.debugMultiTrackStart
                    width: athlete.width
                    height: athlete.height
                    x: trackPoint.x + trackPoint.nx * laneOffset - width * 0.5
                    // trackPoint.y is the shadow/stance point (not item bottom)
                    y: trackPoint.y + trackPoint.ny * laneOffset - height
                       + ((pose === "swim" && !athlete.fallen) ? 0 : athlete.stanceLift)
                    z: Math.max(1, Math.round(y + height + athlete.depthBias))

                    onYChanged: {
                        if (lastTrackY < 0 || Math.abs(y - lastTrackY) > height * 0.5) {
                            lastTrackY = y
                            return
                        }
                        const dy = y - lastTrackY
                        if (Math.abs(dy) > 0.25)
                            moveFacing = dy > 0 ? 1 : -1
                        lastTrackY = y
                    }

                    onPoseChanged: {
                        if (pose === "swim" || pose === "run")
                            moveFacing = -1
                        else if (pose === "bike")
                            moveFacing = 1
                        else if (pose === "dead")
                            moveFacing = Math.random() < 0.5 ? 1 : -1
                    }

                    Athlete {
                        id: athlete

                        number: runner.number
                        jerseyColor: runner.jerseyColor
                        accentColor: runner.accentColor
                        scaleFactor: runner.scaleFactor
                        pose: runner.pose
                        headDetached: runner.headDetached
                        facing: runner.facing
                        shadowsLayer: athleteShadows
                        bloodLayer: athleteBlood
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
