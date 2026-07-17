import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int currentScreen: 0

    StackLayout {
        anchors.fill: parent
        currentIndex: root.currentScreen

        RaceScreen {
            onRequestHub: tab => {
                root.currentScreen = 1
                hubScreen.selectTab(tab)
            }
        }

        HubScreen {
            id: hubScreen

            onRequestRace: root.currentScreen = 0
        }
    }
}
