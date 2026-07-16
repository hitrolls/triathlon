import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int currentTab: 1
    property bool tabBarReady: false

    signal requestRace
    signal tabSelected(int index)

    function selectTab(index) {
        if (index <= 0) {
            root.requestRace()
            return
        }
        root.currentTab = index
        if (hubTabBar.currentIndex !== index)
            hubTabBar.currentIndex = index
        root.tabSelected(index)
    }

    StackLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            bottomMargin: hubTabBar.barHeight
        }
        currentIndex: Math.max(0, root.currentTab - 1)

        Rectangle {
            color: "#e8e2d4"

            Text {
                anchors.centerIn: parent
                text: qsTr("Athletes")
                color: "#1e1c1a"
                font {
                    pixelSize: 22
                    bold: true
                }
            }
        }

        Rectangle {
            color: "#e8e2d4"

            Text {
                anchors.centerIn: parent
                text: qsTr("Track")
                color: "#1e1c1a"
                font {
                    pixelSize: 22
                    bold: true
                }
            }
        }

        Rectangle {
            color: "#e8e2d4"

            Text {
                anchors.centerIn: parent
                text: qsTr("Bank")
                color: "#1e1c1a"
                font {
                    pixelSize: 22
                    bold: true
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
        }

        Component.onCompleted: {
            currentIndex = root.currentTab
            root.tabBarReady = true
        }

        onCurrentIndexChanged: {
            if (!root.tabBarReady || currentIndex === root.currentTab)
                return

            if (currentIndex === 0) {
                const previous = root.currentTab
                root.requestRace()
                Qt.callLater(() => {
                    hubTabBar.currentIndex = previous
                })
                return
            }

            root.currentTab = currentIndex
            root.tabSelected(currentIndex)
        }
    }
}
