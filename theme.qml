import QtQuick
import Rift 1.0

FocusScope {
    id: root
    focus: true

    Style { id: ui }

    property bool footerVisible: false
    property color menuBackgroundColor: "#0b0b0b"
    property color menuTextColor: ui.white
    property color menuAccentColor: ui.red
    property color menuSecondaryColor: "#1e1e1e"
    property color menuBorderColor: "#3a0008"
    property real menuBackgroundOpacity: 0.97
    property string menuFontFamily: ui.bold

    property bool animatedBackground: Rift.themeSettingBool("animatedBackground", true)
    property bool screenWipe: Rift.themeSettingBool("screenWipe", true)
    readonly property real canvasScale: height > 0 ? height / 720 : 1
    readonly property string page: Rift.navigation.currentPage

    Connections {
        target: Rift
        function onThemeSettingChanged(key, value) {
            if (key === "animatedBackground") root.animatedBackground = value
            else if (key === "screenWipe") root.screenWipe = value
        }
        function onSelectedGameIdChanged() { background.kick() }
    }

    Connections {
        target: Rift.platforms
        function onCurrentIndexChanged() { background.kick() }
    }

    Connections {
        target: Rift.navigation
        function onPagePushed() { Qt.callLater(root.playWipe) }
        function onPageReplaced() { Qt.callLater(root.playWipe) }
    }

    Connections {
        target: Rift.input
        enabled: root.page === "games"
        function onPageUp() { root.switchPlatform(-1) }
        function onPageDown() { root.switchPlatform(1) }
    }

    Keys.onPressed: function(event) {
        if (root.page !== "games" || event.isAutoRepeat)
            return
        if (event.key === Qt.Key_Q || event.key === Qt.Key_PageUp) {
            root.switchPlatform(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_E || event.key === Qt.Key_PageDown) {
            root.switchPlatform(1)
            event.accepted = true
        }
    }

    function switchPlatform(step) {
        var count = Rift.platforms.count
        if (count < 2)
            return
        var index = ((Rift.navigation.params.platformIndex ?? 0) + step + count) % count
        Rift.navigation.updateBackPlatformIndex(index)
        Rift.navigation.replace("games", { platform: Rift.platforms.get(index), platformIndex: index })
    }

    function playWipe() {
        if (!root.screenWipe || Rift.navigation.currentPage !== "games")
            return
        var p = Rift.navigation.params.platform
        if (!p)
            return
        var count = p.gameCount ?? 0
        wipe.play(p.displayName ?? "", count > 0 ? count + " " + ui.t("games") : "")
    }

    BurstBackground {
        id: background
        anchors.fill: parent
        animated: root.animatedBackground
        centerX: root.page === "games" ? 0.8 : 0.68
        centerY: root.page === "games" ? 0.4 : 0.3
    }

    Item {
        id: canvas
        width: root.width / root.canvasScale
        height: 720
        scale: root.canvasScale
        transformOrigin: Item.TopLeft

        RiftRouter {
            anchors.fill: parent
            focus: true
            transition: "scale"
            transitionDuration: 170
        }

        SlantBox {
            id: clockTag
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 26
            anchors.topMargin: 16
            width: clockText.implicitWidth + 34
            height: 36
            rotation: 3
            skew: -0.3
            color: ui.white
            shadowColor: ui.black
            shadowX: 4
            shadowY: 4

            Text {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatTime(clock.now, "hh:mm")
                font.family: ui.display
                font.pixelSize: 24
                color: ui.black
            }

            Rectangle {
                x: 6
                y: 6
                width: 6
                height: 6
                color: ui.red
            }
        }

        Wipe {
            id: wipe
            anchors.fill: parent
        }
    }

    QtObject {
        id: clock
        property date now: new Date()
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: clock.now = new Date()
    }
}
