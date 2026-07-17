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
    property Item shadowsLayer: null
    property int shadowDepth: 0

    readonly property real u: 4 * scaleFactor
    readonly property color outline: "#1a1a1a"
    readonly property color shade: Qt.darker(jerseyColor, 1.18)
    readonly property color skinShade: Qt.darker(skinColor, 1.12)
    readonly property bool fallen: pose === "injured" || pose === "dead"
    readonly property bool celebrating: pose === "finish"
    readonly property bool running: pose === "run"
    // Fall slide moves the body in local space; RaceScreen uses this for z-order
    readonly property real depthBias: root.fallen ? fallSlide.y : 0

    // Per-athlete timing so pose loops are not synchronized
    readonly property real warmupPhase: Math.random() * 700
    readonly property real warmupBeat: 170 + Math.random() * 110
    readonly property real runPhase: Math.random() * 500
    readonly property real runBeat: 105 + Math.random() * 75
    readonly property real finishPhase: Math.random() * 600
    readonly property real finishBeat: 200 + Math.random() * 140
    readonly property real armLength: root.u * 3.5
    readonly property real armRestAngle: 38
    readonly property real armRaiseAngle: -112
    readonly property real armRunAngle: 58
    readonly property real armRunReach: root.u * 2.1
    readonly property real armRunLiftHigh: -root.u * 2.6
    readonly property real armRunLiftLow: root.u * 2.0
    readonly property real figureOriginX: figure.width * (root.fallen ? 0.5 : 0.42)
    readonly property real figureOriginY: figure.height * (root.fallen ? 0.5 : 0.75)
    readonly property real figureAngle: root.fallen ? fallTilt.angle : lean.angle
    readonly property real figureShiftX: (root.running ? stride.offset : 0) + (root.fallen ? fallSlide.x : 0)
    readonly property real figureShiftY: -bob.offset + (root.fallen ? fallSlide.y : 0)

    width: 18 * u
    height: 22 * u

    function fall(dead) {
        headDetached = dead && Math.random() < 0.45
        pose = dead ? "dead" : "injured"
    }

    function resetLocomotionState() {
        bob.offset = 0
        lean.angle = 0
        stride.offset = 0
        finishHand.angle = root.armRestAngle
        runHand.lift = 0
    }

    function resetFallState() {
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

    function stopFallAnimations() {
        fallAnim.stop()
        headDetachAnim.stop()
        bloodSpreadAnim.stop()
        headBloodSpreadAnim.stop()
    }

    function prepFall() {
        resetLocomotionState()
        resetFallState()
        bloodBleed.amount = 0.1

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

    function pinInLayer(item, localX, localY, layer, groundContact) {
        // Item local → figure local (includes item rotation/position; not figure transforms)
        const inFigure = item.mapToItem(figure, localX, localY)

        // Apply figure.transform manually: Rotation then Translate
        const ox = root.figureOriginX
        const oy = root.figureOriginY
        const rad = (root.figureAngle * Math.PI) / 180
        const cos = Math.cos(rad)
        const sin = Math.sin(rad)
        const dx = inFigure.x - ox
        const dy = inFigure.y - oy
        const rx = ox + dx * cos - dy * sin
        const ry = oy + dx * sin + dy * cos
        const tx = rx + root.figureShiftX
        const ty = ry + (groundContact
                        ? (root.fallen ? root.fallSlide.y : 0)
                        : root.figureShiftY)

        return root.mapToItem(layer, figure.x + tx, figure.y + ty)
    }

    function lowestInLayer(item, layer, groundContact) {
        // World-bottom of a vertical capsule (radius = width/2): max Y in layer space
        const w = item.width
        const h = item.height
        const r = w * 0.5
        const cx = w * 0.5
        const cy = h * 0.5
        const halfSeg = Math.max(0, h * 0.5 - r)

        const c = root.pinInLayer(item, cx, cy, layer, groundContact)
        const px = root.pinInLayer(item, cx + 1, cy, layer, groundContact)
        const py = root.pinInLayer(item, cx, cy + 1, layer, groundContact)
        const gx = px.y - c.y
        const gy = py.y - c.y
        const glen = Math.hypot(gx, gy)
        if (glen < 1e-6)
            return root.pinInLayer(item, cx, h, layer, groundContact)

        const localX = r * gx / glen
        const localY = (gy >= 0 ? halfSeg : -halfSeg) + r * gy / glen
        return root.pinInLayer(item, cx + localX, cy + localY, layer, groundContact)
    }

    // Shadows live on RaceScreen.athleteShadows; follow world-bottom of body/head
    Rectangle {
        id: bodyShadow

        parent: root.shadowsLayer
        visible: false
        width: root.u * (root.fallen ? 14 : 10)
        height: root.u * (root.fallen ? 3.2 : 2.4)
        radius: height / 2
        color: "#33000000"
        z: root.shadowDepth
    }

    Rectangle {
        id: headShadow

        parent: root.shadowsLayer
        visible: false
        width: root.u * 5.5
        height: root.u * 1.6
        radius: height / 2
        color: "#33000000"
        z: root.shadowDepth
    }

    FrameAnimation {
        running: root.visible && root.shadowsLayer !== null

        onRunningChanged: {
            if (running)
                return
            bodyShadow.visible = false
            headShadow.visible = false
        }

        onTriggered: {
            const layer = root.shadowsLayer
            if (!layer)
                return

            const bodyPt = root.lowestInLayer(body, layer, true)
            bodyShadow.x = bodyPt.x - bodyShadow.width * 0.5
            bodyShadow.y = bodyPt.y - bodyShadow.height * 0.5
            bodyShadow.visible = true

            const showHead = root.headDetached && head.visible
            if (showHead) {
                const headPt = root.lowestInLayer(head, layer, true)
                headShadow.x = headPt.x - headShadow.width * 0.5
                headShadow.y = headPt.y - headShadow.height * 0.5
            }
            headShadow.visible = showHead
        }
    }

    // Blood — same slide as figure, no rotation
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
                origin.x: root.figureOriginX
                origin.y: root.figureOriginY
                angle: root.figureAngle
            },
            Translate {
                y: root.figureShiftY
                x: root.figureShiftX
            }
        ]

        // Hands — finish raises the right arm; run pumps both beside the torso (rear view)
        Item {
            id: handPivot

            visible: !root.fallen
            x: body.x + body.width * 0.88
            y: body.y + body.height * 0.22 + (root.running ? runHand.lift : 0)
            width: 0
            height: 0
            rotation: root.celebrating ? finishHand.angle
                        : root.running ? root.armRunAngle
                        : root.armRestAngle
            z: 4

            Rectangle {
                x: (root.running ? root.armRunReach : root.armLength) - width * 0.5
                y: -height * 0.5
                width: root.u * 2.2
                height: root.u * 2.2
                radius: width / 2
                color: root.skinColor
                border {
                    width: Math.max(1, root.u * 0.45)
                    color: root.outline
                }
            }
        }

        Item {
            id: leftHandPivot

            visible: root.running && !root.fallen
            x: body.x + body.width * 0.12
            y: body.y + body.height * 0.22 - runHand.lift
            width: 0
            height: 0
            rotation: -root.armRunAngle
            z: 4

            Rectangle {
                x: -(root.armRunReach + width * 0.5)
                y: -height * 0.5
                width: root.u * 2.2
                height: root.u * 2.2
                radius: width / 2
                color: root.skinColor
                border {
                    width: Math.max(1, root.u * 0.45)
                    color: root.outline
                }
            }
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

    readonly property QtObject bob: QtObject {
        property real offset: 0
    }

    readonly property QtObject lean: QtObject {
        property real angle: 0
    }

    readonly property QtObject stride: QtObject {
        property real offset: 0
    }

    readonly property QtObject finishHand: QtObject {
        property real angle: 0
    }

    readonly property QtObject runHand: QtObject {
        property real lift: 0
    }

    readonly property QtObject fallTilt: QtObject {
        property real angle: 0
    }

    readonly property QtObject fallSlide: QtObject {
        property real x: 0
        property real y: 0
    }

    readonly property QtObject fallTargets: QtObject {
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

    readonly property QtObject headRoll: QtObject {
        property real x: 0
        property real y: 0
        property real rotation: 0
        property bool gone: false
    }

    readonly property QtObject bloodBleed: QtObject {
        property real amount: 0
    }

    readonly property QtObject headBloodBleed: QtObject {
        property real amount: 0
    }

    readonly property SequentialAnimation warmupAnim: SequentialAnimation {
        running: root.visible && root.pose === "warmup"

        PauseAnimation {
            duration: root.warmupPhase
        }
        SequentialAnimation {
            loops: Animation.Infinite

            ParallelAnimation {
                NumberAnimation {
                    target: bob
                    property: "offset"
                    to: root.u * 1.2
                    duration: root.warmupBeat
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: lean
                    property: "angle"
                    to: -8
                    duration: root.warmupBeat
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: bob
                    property: "offset"
                    to: 0
                    duration: root.warmupBeat
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    target: lean
                    property: "angle"
                    to: 8
                    duration: root.warmupBeat
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: bob
                    property: "offset"
                    to: root.u * 1.2
                    duration: root.warmupBeat
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: lean
                    property: "angle"
                    to: 0
                    duration: root.warmupBeat
                }
            }
            NumberAnimation {
                target: bob
                property: "offset"
                to: 0
                duration: root.warmupBeat
                easing.type: Easing.InQuad
            }
        }
    }

    readonly property SequentialAnimation runAnim: SequentialAnimation {
        running: root.visible && root.pose === "run"

        PauseAnimation {
            duration: root.runPhase
        }
        SequentialAnimation {
            loops: Animation.Infinite

            ParallelAnimation {
                NumberAnimation {
                    target: bob
                    property: "offset"
                    to: root.u * 1.6
                    duration: root.runBeat
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: stride
                    property: "offset"
                    to: root.u * 0.8
                    duration: root.runBeat
                }
                NumberAnimation {
                    target: lean
                    property: "angle"
                    to: 6
                    duration: root.runBeat
                }
                NumberAnimation {
                    target: runHand
                    property: "lift"
                    to: root.armRunLiftHigh
                    duration: root.runBeat
                    easing.type: Easing.OutQuad
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: bob
                    property: "offset"
                    to: 0
                    duration: root.runBeat
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    target: stride
                    property: "offset"
                    to: -root.u * 0.8
                    duration: root.runBeat
                }
                NumberAnimation {
                    target: lean
                    property: "angle"
                    to: -4
                    duration: root.runBeat
                }
                NumberAnimation {
                    target: runHand
                    property: "lift"
                    to: root.armRunLiftLow
                    duration: root.runBeat
                    easing.type: Easing.InQuad
                }
            }
        }
    }

    readonly property SequentialAnimation finishAnim: SequentialAnimation {
        running: root.visible && root.pose === "finish"

        PauseAnimation {
            duration: root.finishPhase
        }
        SequentialAnimation {
            loops: Animation.Infinite

            ParallelAnimation {
                NumberAnimation {
                    target: bob
                    property: "offset"
                    to: root.u * 3.2
                    duration: root.finishBeat
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: finishHand
                    property: "angle"
                    from: root.armRestAngle
                    to: root.armRaiseAngle
                    duration: root.finishBeat
                    easing.type: Easing.OutQuad
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: bob
                    property: "offset"
                    to: 0
                    duration: root.finishBeat
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    target: finishHand
                    property: "angle"
                    from: root.armRaiseAngle
                    to: root.armRestAngle
                    duration: root.finishBeat
                    easing.type: Easing.InQuad
                }
            }
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
        if (root.pose === "injured" || root.pose === "dead") {
            prepFall()
            Qt.callLater(() => fallAnim.restart())
            return
        }

        stopFallAnimations()
        resetFallState()
    }
}
