pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root

    property int number: 1
    property color jerseyColor: "#e85d4c"
    property color skinColor: "#f2c4a0"
    property color accentColor: "#f2efe8"
    property string pose: "warmup"
    property bool headDetached: false
    property real scaleFactor: 1

    readonly property real u: 4 * scaleFactor
    readonly property color outline: "#1a1a1a"
    readonly property color shade: Qt.darker(jerseyColor, 1.18)
    readonly property color skinShade: Qt.darker(skinColor, 1.12)
    readonly property bool fallen: pose === "injured" || pose === "dead"
    readonly property bool celebrating: pose === "finish"
    readonly property bool running: pose === "run"

    width: 18 * u
    height: 22 * u

    function fall(dead) {
        headDetached = dead && Math.random() < 0.45
        pose = dead ? "dead" : "injured"
    }

    function prepFall() {
        bob.offset = 0
        lean.angle = 0
        stride.offset = 0
        bloodBleed.amount = 0.1
        headBloodBleed.amount = 0
        fallTilt.angle = 0
        fallSlide.x = 0
        fallSlide.y = 0
        headRoll.x = 0
        headRoll.y = 0
        headRoll.rotation = 0
        headRoll.gone = false

        const dead = root.pose === "dead"
        // Forward = up the track (−Y); yaw fans left/right around that axis
        const yaw = (Math.random() - 0.5) * (1.1 + Math.random() * 0.9)
        const spin = (yaw >= 0 ? 1 : -1) * (Math.random() < 0.22 ? -1 : 1)
        const travel = root.u * (dead ? 14 + Math.random() * 10 : 10 + Math.random() * 8)
        const hop = root.u * (2 + Math.random() * 4)
        const mid = 0.45 + Math.random() * 0.2
        fallTargets.tilt = spin * (dead ? 300 + Math.random() * 220 : 180 + Math.random() * 180)
        fallTargets.airX = Math.sin(yaw) * travel * mid
        fallTargets.airY = -Math.cos(yaw) * travel * mid - hop
        fallTargets.landX = Math.sin(yaw) * travel
        fallTargets.landY = -Math.cos(yaw) * travel
        fallTargets.airMs = 180 + Math.random() * 100
        fallTargets.landMs = 70 + Math.random() * 60
        fallTargets.headX = spin * root.u * (5 + Math.random() * 5)
        fallTargets.headRot = spin * (360 + Math.random() * 280)
        bloodSpreadAnim.start()
    }

    // Ground shadow — under feet when upright
    Rectangle {
        visible: !root.fallen
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: root.u * 0.4
        }
        width: root.u * 10
        height: root.u * 2.4
        radius: height / 2
        color: "#33000000"
        scale: 1 - bob.offset / (root.u * 18)
    }

    // Fallen shadow + blood — same slide as figure, no rotation
    Item {
        id: groundFx

        visible: root.fallen
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: root.u * 2.2
        }
        width: root.u * 12
        height: root.u * 16
        z: -1

        transform: Translate {
            x: fallSlide.x
            y: fallSlide.y
        }

        // Shadow at body bottom
        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: -height * 0.35
            }
            width: root.u * 14
            height: root.u * 3.2
            radius: height / 2
            color: "#33000000"
            scale: 1.05
        }

        // Blood from body center (body height 11u, bottom-aligned)
        Item {
            id: bloodPuddle

            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.bottom
                verticalCenterOffset: -root.u * 5.5
            }
            width: root.u * 20
            height: root.u * 5
            scale: bloodBleed.amount
            transformOrigin: Item.Center

            Repeater {
                model: 5

                Rectangle {
                    required property int index

                    readonly property real offset: index * 1.05
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: Math.cos(index * 1.5) * root.u * (0.6 + offset * 0.9)
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: Math.sin(index * 1.1) * root.u * (0.15 + offset * 0.12)
                    }
                    width: root.u * (6.5 + index * 1.2)
                    height: root.u * (2.0 + index * 0.25)
                    radius: height / 2
                    color: index < 2 ? "#e53935" : (index < 4 ? "#d32f2f" : "#b71c1c")
                    opacity: 0.92 - index * 0.05
                }
            }
        }
    }

    Item {
        id: figure

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: root.u * 2.2
        }
        width: root.u * 12
        height: root.u * 16

        transform: [
            Rotation {
                origin.x: figure.width * (root.fallen ? 0.5 : 0.42)
                origin.y: figure.height * (root.fallen ? 0.5 : 0.75)
                angle: root.fallen ? fallTilt.angle : lean.angle
            },
            Translate {
                y: -bob.offset + (root.fallen ? fallSlide.y : 0)
                x: (root.running ? stride.offset : 0) + (root.fallen ? fallSlide.x : 0)
            }
        ]

        // Optional floating hand
        Rectangle {
            visible: !root.fallen
            x: figure.width - root.u * 1.2
            y: figure.height * 0.52 + (root.running ? stride.offset * 0.15 : 0)
            width: root.u * 2.2
            height: root.u * 2.2
            radius: width / 2
            color: root.skinColor
            border {
                width: Math.max(1, root.u * 0.45)
                color: root.outline
            }
            z: 0
        }

        // Capsule body
        Item {
            id: body

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            width: root.u * 8.5
            height: root.u * 11

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.jerseyColor
                border {
                    width: Math.max(1, root.u * 0.55)
                    color: root.outline
                }
            }

            // Cel shade
            Rectangle {
                anchors {
                    right: parent.right
                    rightMargin: root.u * 0.9
                    bottom: parent.bottom
                    bottomMargin: root.u * 1.2
                }
                width: parent.width * 0.38
                height: parent.height * 0.55
                radius: width / 2
                color: root.shade
                opacity: 0.55
            }

            // Number banner
            Rectangle {
                anchors.centerIn: parent
                width: root.u * 5.2
                height: root.u * 4.4
                radius: root.u * 0.7
                color: root.accentColor
                border {
                    width: Math.max(1, root.u * 0.4)
                    color: root.outline
                }

                Text {
                    anchors.centerIn: parent
                    text: root.number
                    color: root.outline
                    font {
                        pixelSize: Math.round(root.u * 2.8)
                        bold: true
                    }
                }
            }
        }

        // Blood under detached head — same position space as head, counter-rotated flat
        Item {
            id: headBloodPuddle

            visible: root.fallen && root.headDetached && headBloodBleed.amount > 0
            x: head.x + (head.width - width) * 0.5
            y: head.y + (head.height - height) * 0.5
            width: root.u * 10
            height: root.u * 3.6
            rotation: root.fallen ? -fallTilt.angle : 0
            scale: headBloodBleed.amount
            z: 1

            Repeater {
                model: 4

                Rectangle {
                    required property int index

                    readonly property real offset: index * 1.05
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: Math.cos(index * 1.7) * root.u * (0.4 + offset * 0.7)
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: Math.sin(index * 1.3) * root.u * (0.12 + offset * 0.1)
                    }
                    width: root.u * (4.2 + index * 0.9)
                    height: root.u * (1.5 + index * 0.2)
                    radius: height / 2
                    color: index < 2 ? "#e53935" : (index < 3 ? "#d32f2f" : "#b71c1c")
                    opacity: 0.9 - index * 0.06
                }
            }
        }

        // Head
        Item {
            id: head

            x: body.x + body.width * 0.18 + (root.headDetached ? headRoll.x : 0)
            y: body.y - height * 0.72 + (root.headDetached ? headRoll.y : 0)
            width: root.u * 5.6
            height: root.u * 5.6
            rotation: root.headDetached ? headRoll.rotation : 0
            visible: !(root.pose === "dead" && root.headDetached && headRoll.gone)
            z: 2

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.skinColor
                border {
                    width: Math.max(1, root.u * 0.55)
                    color: root.outline
                }
            }

            Rectangle {
                anchors {
                    right: parent.right
                    rightMargin: root.u * 0.7
                    bottom: parent.bottom
                    bottomMargin: root.u * 0.8
                }
                width: parent.width * 0.42
                height: parent.height * 0.42
                radius: width / 2
                color: root.skinShade
                opacity: 0.5
            }

            // Eyes — two vertical dashes
            Row {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: root.u * 0.35
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -root.u * 0.15
                }
                spacing: root.u * 1.15

                Repeater {
                    model: 2

                    Rectangle {
                        required property int index

                        width: root.u * 0.7
                        height: root.u * 1.55
                        radius: width / 2
                        color: root.outline
                    }
                }
            }

            // Headband
            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: root.u * 0.85
                }
                width: parent.width * 0.92
                height: root.u * 1.15
                radius: height / 2
                color: "#f2efe8"
                border {
                    width: Math.max(1, root.u * 0.35)
                    color: root.outline
                }

                Rectangle {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: parent.width * 0.28
                    }
                    width: parent.width * 0.44
                    height: parent.height * 0.45
                    radius: height / 2
                    color: root.jerseyColor
                }
            }
        }

    }

    QtObject {
        id: bob

        property real offset: 0
    }

    QtObject {
        id: lean

        property real angle: 0
    }

    QtObject {
        id: stride

        property real offset: 0
    }

    QtObject {
        id: fallTilt

        property real angle: 0
    }

    QtObject {
        id: fallSlide

        property real x: 0
        property real y: 0
    }

    QtObject {
        id: fallTargets

        property real tilt: 0
        property real airX: 0
        property real airY: 0
        property real landX: 0
        property real landY: 0
        property real airMs: 220
        property real landMs: 90
        property real headX: 0
        property real headRot: 0
    }

    QtObject {
        id: headRoll

        property real x: 0
        property real y: 0
        property real rotation: 0
        property bool gone: false
    }

    QtObject {
        id: bloodBleed

        property real amount: 0
    }

    QtObject {
        id: headBloodBleed

        property real amount: 0
    }

    readonly property SequentialAnimation warmupAnim: SequentialAnimation {
        loops: Animation.Infinite
        running: root.visible && root.pose === "warmup"

        ParallelAnimation {
            NumberAnimation {
                target: bob
                property: "offset"
                to: root.u * 1.2
                duration: 220
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: lean
                property: "angle"
                to: -8
                duration: 220
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: bob
                property: "offset"
                to: 0
                duration: 220
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: lean
                property: "angle"
                to: 8
                duration: 220
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: bob
                property: "offset"
                to: root.u * 1.2
                duration: 220
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: lean
                property: "angle"
                to: 0
                duration: 220
            }
        }
        NumberAnimation {
            target: bob
            property: "offset"
            to: 0
            duration: 220
            easing.type: Easing.InQuad
        }
    }

    readonly property SequentialAnimation runAnim: SequentialAnimation {
        loops: Animation.Infinite
        running: root.visible && root.pose === "run"

        ParallelAnimation {
            NumberAnimation {
                target: bob
                property: "offset"
                to: root.u * 1.6
                duration: 140
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: stride
                property: "offset"
                to: root.u * 0.8
                duration: 140
            }
            NumberAnimation {
                target: lean
                property: "angle"
                to: 6
                duration: 140
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: bob
                property: "offset"
                to: 0
                duration: 140
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: stride
                property: "offset"
                to: -root.u * 0.8
                duration: 140
            }
            NumberAnimation {
                target: lean
                property: "angle"
                to: -4
                duration: 140
            }
        }
    }

    readonly property SequentialAnimation finishAnim: SequentialAnimation {
        loops: Animation.Infinite
        running: root.visible && root.pose === "finish"

        NumberAnimation {
            target: bob
            property: "offset"
            to: root.u * 3.2
            duration: 260
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: bob
            property: "offset"
            to: 0
            duration: 260
            easing.type: Easing.InQuad
        }
    }

    readonly property SequentialAnimation fallAnim: SequentialAnimation {
        ParallelAnimation {
            NumberAnimation {
                target: fallTilt
                property: "angle"
                from: 0
                to: fallTargets.tilt * 0.72
                duration: fallTargets.airMs
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: fallSlide
                property: "x"
                from: 0
                to: fallTargets.airX
                duration: fallTargets.airMs
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: fallSlide
                property: "y"
                from: 0
                to: fallTargets.airY
                duration: fallTargets.airMs
                easing.type: Easing.OutCubic
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: fallTilt
                property: "angle"
                to: fallTargets.tilt
                duration: fallTargets.landMs
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: fallSlide
                property: "x"
                to: fallTargets.landX
                duration: fallTargets.landMs
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: fallSlide
                property: "y"
                to: fallTargets.landY
                duration: fallTargets.landMs
                easing.type: Easing.InQuad
            }
        }
        ScriptAction {
            script: {
                if (root.headDetached)
                    headDetachAnim.start()
            }
        }
    }

    readonly property NumberAnimation bloodSpreadAnim: NumberAnimation {
        target: bloodBleed
        property: "amount"
        to: 1
        duration: 700
        easing.type: Easing.OutCubic
    }

    readonly property NumberAnimation headBloodSpreadAnim: NumberAnimation {
        target: headBloodBleed
        property: "amount"
        to: 1
        duration: 500
        easing.type: Easing.OutCubic
    }

    readonly property ParallelAnimation headDetachAnim: ParallelAnimation {
        NumberAnimation {
            target: headRoll
            property: "x"
            from: 0
            to: fallTargets.headX
            duration: 260
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: headRoll
            property: "y"
            from: 0
            to: root.u * 5
            duration: 260
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: headRoll
            property: "rotation"
            from: 0
            to: fallTargets.headRot
            duration: 260
        }

        onFinished: {
            if (!root.fallen || !root.headDetached)
                return
            headBloodBleed.amount = 0.15
            headBloodSpreadAnim.start()
        }
    }

    onPoseChanged: {
        if (pose === "injured" || pose === "dead") {
            prepFall()
            Qt.callLater(() => fallAnim.restart())
        } else {
            fallAnim.stop()
            headDetachAnim.stop()
            bloodSpreadAnim.stop()
            headBloodSpreadAnim.stop()
            fallTilt.angle = 0
            fallSlide.x = 0
            fallSlide.y = 0
            headRoll.x = 0
            headRoll.y = 0
            headRoll.rotation = 0
            headRoll.gone = false
            bloodBleed.amount = 0
            headBloodBleed.amount = 0
        }
    }
}
