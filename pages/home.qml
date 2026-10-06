import QtQuick
import Rift 1.0
import ".."

FocusScope {
    id: root
    focus: true

    Style { id: ui }

    property int initialPlatformIndex: 0
    property int revision: 0
    readonly property real listWidth: Math.round(Math.min(430, Math.max(340, width * 0.33)))
    readonly property real infoX: listWidth + 34
    readonly property real infoWidth: width - infoX - 30
    readonly property var platform: {
        root.revision
        return list.count > 0 ? Rift.platforms.get(list.currentIndex) : null
    }
    readonly property string shortName: platform && !platform.isVirtual ? (platform.name ?? "") : ""

    onInitialPlatformIndexChanged: list.setIndex(initialPlatformIndex)
    Component.onCompleted: list.setIndex(initialPlatformIndex)

    onPlatformChanged: slam.restart()

    function assetUrl(folder, ext) {
        return root.shortName ? Rift.assetsPath + "/" + folder + "/" + root.shortName + ext : ""
    }

    function typeLabel(p) {
        if (!p)
            return ""
        if (p.isVirtual)
            return ui.t("collection")
        var key = { "console": "console", "handheld": "handheld", "arcade": "arcade", "computer": "computer" }[p.type]
        return key ? ui.t(key) : String(p.type || "").toUpperCase()
    }

    function openPlatform() {
        if (list.count <= 0 || list.shuffling)
            return
        hints.flash("A")
        var p = Rift.platforms.get(list.currentIndex)
        if (p)
            Rift.navigation.push("games", { platform: p, platformIndex: list.currentIndex })
    }

    function pickRandom() {
        hints.flash("X")
        list.shuffle()
    }

    Connections {
        target: Rift.platforms
        function onCountChanged() { root.revision++ }
        function onModelReset() { root.revision++ }
    }

    Connections {
        target: list
        function onCurrentIndexChanged() {
            if (list.count > 0)
                Rift.platforms.currentIndex = list.currentIndex
        }
    }

    Connections {
        target: Rift.input
        enabled: root.activeFocus
        function onNavigationUp() { list.move(-1) }
        function onNavigationDown() { list.move(1) }
        function onNavigationLeft() { list.jump(-5) }
        function onNavigationRight() { list.jump(5) }
        function onAccept() { root.openPlatform() }
        function onSearchToggle() { root.pickRandom() }
    }

    Keys.onUpPressed: list.move(-1)
    Keys.onDownPressed: list.move(1)
    Keys.onLeftPressed: list.jump(-5)
    Keys.onRightPressed: list.jump(5)
    Keys.onReturnPressed: root.openPlatform()
    Keys.onEnterPressed: root.openPlatform()
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_I) {
            root.pickRandom()
            event.accepted = true
        }
    }

    ParallelAnimation {
        id: slam
        NumberAnimation { target: info; property: "scale"; from: 1.07; to: 1; duration: 170; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
        NumberAnimation { target: info; property: "rotation"; from: 2; to: 0; duration: 170; easing.type: Easing.OutBack }
        NumberAnimation { target: info; property: "opacity"; from: 0.35; to: 1; duration: 90 }
        NumberAnimation { target: band; property: "rotation"; from: -9; to: -5; duration: 190; easing.type: Easing.OutBack; easing.overshoot: 2.6 }
        NumberAnimation { target: bandShift; property: "x"; from: 40; to: 0; duration: 150; easing.type: Easing.OutCubic }
    }

    Item {
        id: band
        x: root.listWidth - 40
        y: 82
        width: root.width - x + 140
        height: 200
        rotation: -5
        transformOrigin: Item.Left
        transform: Translate { id: bandShift }

        Rectangle {
            x: 14
            y: 14
            width: band.width
            height: band.height
            color: ui.black
        }

        Rectangle {
            width: band.width
            height: band.height
            color: ui.red
        }

        Rectangle {
            y: 10
            width: band.width
            height: 4
            color: ui.white
        }

        Rectangle {
            y: band.height - 18
            width: band.width * 0.7
            height: 6
            color: ui.black
        }

        Text {
            x: 108
            y: 16
            text: "No." + ui.pad(list.currentIndex + 1, 2) + "  /  " + root.typeLabel(root.platform)
            font.family: ui.slash
            font.pixelSize: 19
            font.letterSpacing: 3
            color: ui.black
        }

        RansomTitle {
            id: title
            x: 104
            y: 44 + (band.height - 58 - height) / 2
            maxWidth: root.width - band.x - 170
            maxHeight: band.height - 62
            pixelSize: 88
            minPixelSize: 30
            maxLines: 2
            seed: list.currentIndex
            text: root.platform?.displayName ?? ""
        }
    }

    Item {
        id: info
        x: root.infoX
        y: 336
        width: root.infoWidth
        height: 720 - y - 70
        transformOrigin: Item.TopLeft

        Image {
            id: photo
            readonly property real boxWidth: Math.min(400, root.infoWidth * 0.46)
            x: info.width - boxWidth + 10
            y: 6
            width: boxWidth
            height: info.height - 10
            source: root.assetUrl("systems", ".png")
            sourceSize.width: 520
            fillMode: Image.PreserveAspectFit
            verticalAlignment: Image.AlignBottom
            asynchronous: true
            visible: status === Image.Ready
            rotation: 5
        }

        Flow {
            id: tags
            x: 10
            width: info.width - 20
            spacing: 18

            SlantBox {
                id: logoTag
                width: 190
                height: 78
                rotation: -4
                color: ui.black
                shadowColor: ui.white
                shadowX: 5
                shadowY: 5

                Image {
                    id: logo
                    anchors.centerIn: parent
                    width: parent.width - 54
                    height: parent.height - 22
                    source: root.assetUrl("logos-white", ".svg")
                    sourceSize: Qt.size(280, 120)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 50
                    height: parent.height - 18
                    visible: logo.status !== Image.Ready
                    text: root.platform?.displayName ?? ""
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 12
                    font.family: ui.display
                    font.pixelSize: 26
                    font.capitalization: Font.AllUppercase
                    color: ui.white
                }
            }

            SlantTag {
                visible: root.platform !== null && root.platform.releaseYear > 0
                caption: ui.t("year")
                value: root.platform ? String(root.platform.releaseYear) : ""
                variant: "white"
                valueSize: 34
                rotation: 3
            }

            SlantTag {
                visible: value !== ""
                caption: ui.t("maker")
                value: root.platform && !root.platform.isVirtual ? (root.platform.manufacturer ?? "") : ""
                variant: "black"
                valueSize: 30
                maxValueWidth: 220
                rotation: -3
            }

            SlantTag {
                caption: ui.t("games")
                value: String(root.platform?.gameCount ?? 0)
                variant: "red"
                valueSize: 34
                rotation: 4
            }
        }

        Item {
            id: descriptionCard
            x: 22
            y: tags.height + 30
            width: Math.max(260, Math.min(560, info.width - photo.boxWidth * 0.72))
            height: Math.min(info.height - y - 6, descriptionText.implicitHeight + 34)
            rotation: -1.5

            SlantBox {
                anchors.fill: parent
                skew: -0.12
                color: ui.white
                shadowColor: ui.black
                shadowX: 8
                shadowY: 8
            }

            Text {
                id: descriptionText
                x: 26
                y: 18
                width: parent.width - 52
                height: parent.height - 30
                text: root.platform && root.platform.description ? root.platform.description : ui.t("noDescription")
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 5
                lineHeight: 1.05
                font.family: ui.body
                font.pixelSize: 17
                color: ui.black
            }

            SlantTag {
                x: -14
                y: -height + 8
                visible: value !== ""
                value: root.typeLabel(root.platform)
                variant: "red"
                valueSize: 18
                rotation: -6
            }
        }
    }

    SlantList {
        id: list
        x: 0
        y: 84
        width: root.listWidth + 90
        height: 720 - y - 62
        rowWidth: root.listWidth - focusShift - 34
        focusRatio: 0.4
        model: Rift.platforms
        onActivated: root.openPlatform()

        delegate: SlantRow {
            required property string displayName
            required property int gameCount
            look: ui
            label: displayName
            sublabel: gameCount > 0 ? String(gameCount) : ""
            barWidth: list.rowWidth
            numberWidth: 30
            numberDigits: 2
        }
    }

    Item {
        x: 22
        y: 14
        width: root.listWidth
        height: 64
        rotation: -3

        RansomTitle {
            id: header
            maxWidth: root.listWidth - 120
            pixelSize: 38
            maxLines: 1
            animate: false
            seed: 2
            text: ui.t("systems")
        }

        SlantBox {
            x: header.width + 16
            y: 8
            width: counterText.implicitWidth + 30
            height: 34
            color: ui.black
            shadowColor: ui.red
            shadowX: 4
            shadowY: 4

            Text {
                id: counterText
                anchors.centerIn: parent
                text: ui.pad(list.count > 0 ? list.currentIndex + 1 : 0, 2) + "/" + ui.pad(list.count, 2)
                font.family: ui.display
                font.pixelSize: 20
                color: ui.white
            }
        }
    }

    HintBar {
        id: hints
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        caption: "CORAZÓN REBELDE"
        hints: [["A", ui.t("open")], ["X", ui.t("random")]]
        onHintClicked: function(key) {
            if (key === "A")
                root.openPlatform()
            else if (key === "X")
                root.pickRandom()
        }
    }
}
