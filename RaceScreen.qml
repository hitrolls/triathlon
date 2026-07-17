import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root

    property bool racing: false

    signal requestHub(int tab)

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

        // Simple vertical lane
        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 48
                bottom: parent.bottom
                bottomMargin: 120
            }
            width: Math.min(parent.width * 0.42, 220)
            color: "#d9d0bc"
            border {
                width: 2
                color: "#1a1a1a"
            }

            // Finish line
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

            // Start line
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

        Athlete {
            id: athleteA

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: -56
                bottom: parent.bottom
                bottomMargin: 150
            }
            number: 7
            jerseyColor: "#e85d4c"
            pose: "warmup"
            scaleFactor: 1.15
        }

        Athlete {
            id: athleteB

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: 8
                bottom: parent.bottom
                bottomMargin: 168
            }
            number: 12
            jerseyColor: "#3d7ea6"
            accentColor: "#ffe08a"
            pose: "warmup"
            scaleFactor: 1.05
        }

        Athlete {
            id: athleteC

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: 64
                bottom: parent.bottom
                bottomMargin: 142
            }
            number: 3
            jerseyColor: "#5b8c5a"
            pose: "warmup"
            scaleFactor: 0.95
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
                        athleteA.pose = "finish"
                        athleteB.fall(false)
                        athleteC.fall(true)
                        root.racing = false
                        return
                    }
                    athleteA.pose = "run"
                    athleteB.pose = "run"
                    athleteC.pose = "run"
                    root.racing = true
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
