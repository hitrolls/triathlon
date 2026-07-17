import QtQuick

Window {
    id: window

    property bool isDebug: true

    readonly property string localVersion: "1.0.0"
    readonly property string appBundle: "com.hitrolls.triathlon"

    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isiOS: Qt.platform.os === "ios"
    readonly property bool isPC: Qt.platform.os === "windows"
    readonly property bool isMac: Qt.platform.os === "macx"

    readonly property int figmaWidth: 720
    readonly property int figmaHeight: 1280
    readonly property double figmaCoef: width / figmaWidth

    readonly property double devicePixelRatio: isPC ? 1 : Screen.devicePixelRatio
    readonly property bool isTallScreen: width / height < 9.0 / 17

    readonly property int safeTop: SafeArea.margins.top + (isTallScreen ? 50 : 0)
    readonly property int safeBottom: SafeArea.margins.bottom + (isTallScreen ? 50 : 0)

    readonly property int safeTopScaled: safeTop * figmaCoef
    readonly property int safeBottomScaled: safeBottom * figmaCoef

    property bool isDebugEnabled: false
    property bool isDebugButtonHidden: false


    width: figmaWidth
    height: figmaHeight
    visible: true
    title: qsTr("Hellish triathlon")
    color: "#1e1c1a"

    LoadingScreen {
        id: loadingScreen

        scale: figmaCoef
        transformOrigin: Item.TopLeft
        width: parent.width / scale
        height: parent.height / scale

        Component.onCompleted: loadingScreen.startLoading()
    }
}
