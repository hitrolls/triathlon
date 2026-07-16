import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root

    property bool racing: false

    signal requestHub(int tab)

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            bottomMargin: root.racing ? raceTabBar.implicitHeight
                                       : hubTabBar.barHeight + safeBottom
        }
        color: "#e8e2d4"

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Race")
                color: "#1e1c1a"
                font {
                    pixelSize: 22
                    bold: true
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.racing ? qsTr("Finish race") : qsTr("Start race")
                onClicked: root.racing = !root.racing

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
