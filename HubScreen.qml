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
            bottomMargin: hubTabBar.barHeight + hubTabBar.safeBottom
        }
        currentIndex: Math.max(0, root.currentTab - 1)

        AthletesScreen { }

        TrackScreen { }

        BankScreen { }
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
