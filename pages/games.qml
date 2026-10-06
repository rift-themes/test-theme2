import QtQuick
import Rift 1.0
import ".."

FocusScope {
    id: root
    focus: true

    Style { id: ui }

    property var platform: Rift.platforms.get(0)
    property int initialGameIndex: 0
    property int revision: 0
    property int lastGameId: -1
    property bool launching: false
    readonly property var gamesModel: Rift.getGamesModelForPlatform(platform?.id ?? -1)
    readonly property var game: {
        root.revision
        return gamesModel && list.count > 0 ? gamesModel.get(list.currentIndex) : null
    }
    readonly property real listWidth: Math.round(Math.min(520, Math.max(350, width * 0.39)))
    readonly property real rightX: listWidth + 52
    readonly property real artMaxWidth: Math.round(Math.min(310, (width - rightX - 26) * 0.47))
    readonly property real artMaxHeight: 392
    readonly property real infoWidth: width - rightX - artMaxWidth - 76
    readonly property int digits: Math.max(2, String(list.count).length)

    onInitialGameIndexChanged: list.setIndex(initialGameIndex)
    Component.onCompleted: list.setIndex(initialGameIndex)
    Component.onDestruction: Rift.contextGame = {}

    onGameChanged: {
        if (!game || !game.id)
            return
        if (game.id !== lastGameId) {
            lastGameId = game.id
            Rift.selectedGameId = game.id
            Rift.setContextGameById(game.id)
            slam.restart()
            if (game.favorite)
                stamp.slam()
        }
    }

    function yearOf(g) {
        var y = g && g.releaseDate ? parseInt(String(g.releaseDate).substring(0, 4), 10) : 0
        return y > 1970 ? y : 0
    }

    function lastPlayedText(g) {
        if (!g || !g.lastPlayed)
            return ui.t("never")
        var d = new Date(g.lastPlayed)
        return isNaN(d.getTime()) || d.getFullYear() <= 1970 ? ui.t("never") : Qt.formatDate(d, "dd.MM.yy")
    }

    function launch() {
        if (!game || launching || list.shuffling)
            return
        hints.flash("A")
        launching = true
        launchFx.restart()
        shake.restart()
        launchTimer.start()
    }

    function toggleFavorite() {
        if (!game || launching)
            return
        hints.flash("Y")
        var next = !game.favorite
        Rift.setGameFavorite(game.id, next)
        root.revision++
        if (next)
            stamp.slam()
    }

    function pickRandom() {
        if (launching)
            return
        hints.flash("X")
        list.shuffle()
    }

    Connections {
        target: Rift
        function onGameArtworkUpdated(gameId) {
            if (root.game && root.game.id === gameId)
                root.revision++
        }
    }

    Connections {
        target: Rift.input
        enabled: root.activeFocus
        function onNavigationUp() { if (!root.launching) list.move(-1) }
        function onNavigationDown() { if (!root.launching) list.move(1) }
        function onNavigationLeft() { if (!root.launching) list.jump(-10) }
        function onNavigationRight() { if (!root.launching) list.jump(10) }
        function onAccept() { root.launch() }
        function onFavoriteToggle() { root.toggleFavorite() }
        function onSearchToggle() { root.pickRandom() }
        function onPageUp() { hints.flash("L") }
        function onPageDown() { hints.flash("R") }
    }

    Keys.onUpPressed: if (!root.launching) list.move(-1)
    Keys.onDownPressed: if (!root.launching) list.move(1)
    Keys.onLeftPressed: if (!root.launching) list.jump(-10)
    Keys.onRightPressed: if (!root.launching) list.jump(10)
    Keys.onReturnPressed: root.launch()
    Keys.onEnterPressed: root.launch()
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_F) {
            root.toggleFavorite()
            event.accepted = true
        } else if (event.key === Qt.Key_I) {
            root.pickRandom()
            event.accepted = true
        } else if (event.key === Qt.Key_Q || event.key === Qt.Key_PageUp) {
            hints.flash("L")
        } else if (event.key === Qt.Key_E || event.key === Qt.Key_PageDown) {
            hints.flash("R")
        }
    }

    Timer {
        id: launchTimer
        interval: 460
        onTriggered: {
            if (root.game)
                Rift.launchGame(root.game.id)
            resetTimer.start()
        }
    }

    Timer {
        id: resetTimer
        interval: 900
        onTriggered: root.launching = false
    }

    Item {
        id: content
        width: root.width
        height: root.height
        transform: Translate { id: shakeOffset }

        SequentialAnimation {
            id: shake
            NumberAnimation { target: shakeOffset; property: "x"; to: -9; duration: 40 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 8; duration: 60 }
            NumberAnimation { target: shakeOffset; property: "x"; to: -5; duration: 50 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 3; duration: 45 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 40 }
        }

        ParallelAnimation {
            id: slam
            NumberAnimation { target: info; property: "scale"; from: 1.06; to: 1; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
            NumberAnimation { target: info; property: "rotation"; from: -2.5; to: 0; duration: 160; easing.type: Easing.OutBack }
            NumberAnimation { target: info; property: "opacity"; from: 0.3; to: 1; duration: 90 }
            NumberAnimation { target: art; property: "scale"; from: 1.12; to: 1; duration: 180; easing.type: Easing.OutBack; easing.overshoot: 2.4 }
            NumberAnimation { target: art; property: "rotation"; from: 9; to: 4; duration: 180; easing.type: Easing.OutBack; easing.overshoot: 2 }
        }

        Item {
            id: art
            readonly property real border: 14
            readonly property bool hasArt: boxImage.status === Image.Ready
            readonly property real pw: hasArt ? boxImage.paintedWidth : root.artMaxWidth * 0.86
            readonly property real ph: hasArt ? boxImage.paintedHeight : root.artMaxHeight * 0.72
            readonly property real px: border + root.artMaxWidth - pw
            readonly property real py: border
            visible: list.count > 0
            x: root.width - 30 - width
            y: 70
            width: root.artMaxWidth + border * 2
            height: root.artMaxHeight + border * 2
            rotation: 4

            Rectangle {
                x: art.px - art.border + 14
                y: art.py - art.border + 16
                width: art.pw + art.border * 2
                height: art.ph + art.border * 2
                color: ui.red
            }

            Rectangle {
                x: art.px - art.border
                y: art.py - art.border
                width: art.pw + art.border * 2
                height: art.ph + art.border * 2
                color: ui.black
            }

            Rectangle {
                x: art.px - 8
                y: art.py - 8
                width: art.pw + 16
                height: art.ph + 16
                color: ui.white
            }

            Rectangle {
                x: art.px
                y: art.py
                width: art.pw
                height: art.ph
                visible: !art.hasArt
                color: ui.black

                Text {
                    anchors.fill: parent
                    anchors.margins: 16
                    text: root.game?.name ?? ""
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 16
                    font.family: ui.display
                    font.pixelSize: 54
                    font.capitalization: Font.AllUppercase
                    color: ui.white
                }
            }

            Image {
                id: boxImage
                x: art.border
                y: art.border
                width: root.artMaxWidth
                height: root.artMaxHeight
                source: root.game ? Rift.imageSource(root.game.boxart || root.game.screenshot || "") : ""
                sourceSize.height: 520
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignTop
                asynchronous: true
                visible: art.hasArt
            }

            StarStamp {
                id: stamp
                x: art.px - width * 0.55
                y: art.py - height * 0.45
                visible: root.game?.favorite ?? false
                label: ui.t("fav")
            }
        }

        Item {
            id: info
            x: root.rightX
            y: 64
            width: root.infoWidth
            height: 720 - y - 74
            visible: list.count > 0
            transformOrigin: Item.TopLeft

            Text {
                x: 8
                text: ui.t("game") + "  " + ui.pad(list.currentIndex + 1, root.digits) + " / " + list.count
                font.family: ui.slash
                font.pixelSize: 18
                font.letterSpacing: 3
                color: ui.white
            }

            SlantBox {
                id: titleBox
                y: 28
                width: info.width
                height: 128
                rotation: -2
                color: ui.black
                shadowColor: ui.white
                shadowX: 7
                shadowY: 7

                Text {
                    x: 24
                    y: 12
                    width: titleBox.width - 48
                    height: titleBox.height - 24
                    text: root.game?.name ?? ""
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 18
                    font.family: ui.display
                    font.pixelSize: 44
                    font.capitalization: Font.AllUppercase
                    lineHeight: 0.92
                    color: ui.white
                }

                Rectangle {
                    x: titleBox.width - 70
                    y: titleBox.height - 12
                    width: 54
                    height: 6
                    color: ui.red
                }
            }

            Flow {
                id: tags
                x: 6
                y: titleBox.y + titleBox.height + 26
                width: info.width - 6
                spacing: 14

                SlantTag {
                    visible: value !== ""
                    caption: ui.t("genre")
                    value: root.game?.genre ?? ""
                    variant: "white"
                    valueSize: 22
                    maxValueWidth: tags.width - 50
                    rotation: -3
                }

                SlantTag {
                    visible: value !== ""
                    caption: ui.t("developer")
                    value: root.game?.developer ?? ""
                    variant: "black"
                    valueSize: 22
                    maxValueWidth: tags.width - 50
                    rotation: 2
                }

                SlantTag {
                    caption: ui.t("year")
                    value: root.yearOf(root.game) > 0 ? String(root.yearOf(root.game)) : ui.t("unknown")
                    variant: "red"
                    valueSize: 22
                    rotation: -2
                }

                SlantTag {
                    caption: ui.t("lastPlayed")
                    value: root.lastPlayedText(root.game)
                    variant: "white"
                    valueSize: 22
                    rotation: 3
                }

                SlantTag {
                    visible: (root.game?.playCount ?? 0) > 0
                    caption: ui.t("plays")
                    value: String(root.game?.playCount ?? 0)
                    variant: "black"
                    valueSize: 22
                    rotation: -4
                }
            }

            Item {
                id: descriptionCard
                readonly property real room: info.height - y
                x: 14
                y: tags.y + tags.height + 26
                width: info.width - 14
                height: Math.min(room, descriptionText.implicitHeight + 28)
                visible: room > 64 && (root.game?.description ?? "") !== ""
                rotation: -1

                SlantBox {
                    anchors.fill: parent
                    skew: -0.1
                    color: ui.white
                    shadowColor: ui.black
                    shadowX: 7
                    shadowY: 7
                }

                Text {
                    id: descriptionText
                    x: 22
                    y: 14
                    width: parent.width - 44
                    height: parent.height - 24
                    text: root.game?.description ?? ""
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: Math.max(1, Math.floor((descriptionCard.room - 28) / 20))
                    font.family: ui.body
                    font.pixelSize: 15
                    lineHeight: 1.04
                    color: ui.black
                }
            }
        }

        RansomTitle {
            visible: list.count === 0
            x: root.listWidth + (root.width - root.listWidth - width) / 2
            y: 300
            maxWidth: root.width - root.listWidth - 80
            pixelSize: 70
            maxLines: 2
            seed: 9
            text: ui.t("noGames")
        }

        SlantList {
            id: list
            x: 0
            y: 84
            width: root.listWidth + 90
            height: 720 - y - 62
            rowWidth: root.listWidth - focusShift - 50
            focusRatio: 0.36
            model: root.gamesModel
            onActivated: root.launch()

            delegate: SlantRow {
                required property string name
                required property var releaseDate
                required property bool favorite
                look: ui
                label: name
                sublabel: {
                    if (list.rowWidth < 300)
                        return ""
                    var y = releaseDate ? parseInt(String(releaseDate).substring(0, 4), 10) : 0
                    return y > 1970 ? String(y) : ""
                }
                starred: favorite
                barWidth: list.rowWidth
                numberWidth: 10 + root.digits * 9
                numberDigits: root.digits
            }
        }

        Item {
            x: 22
            y: 14
            width: root.listWidth
            height: 64
            rotation: -3

            RansomTitle {
                maxWidth: root.listWidth - 20
                pixelSize: 40
                minPixelSize: 18
                maxLines: 1
                seed: 5
                text: root.platform?.displayName ?? ""
            }
        }

        HintBar {
            id: hints
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            caption: "CORAZÓN REBELDE"
            hints: [["A", ui.t("play")], ["Y", root.game?.favorite ? ui.t("unfavorite") : ui.t("favorite")], ["X", ui.t("random")], ["L", ""], ["R", ui.t("system")], ["B", ui.t("back")]]
            onHintClicked: function(key) {
                if (key === "A")
                    root.launch()
                else if (key === "Y")
                    root.toggleFavorite()
                else if (key === "X")
                    root.pickRandom()
                else if (key === "B" && Rift.navigation.canGoBack)
                    Rift.navigateBack()
            }
        }

        Item {
            id: launchLayer
            anchors.fill: parent
            opacity: 0
            visible: opacity > 0

            JaggedShape {
                id: launchBurst
                anchors.centerIn: parent
                width: Math.min(root.width * 0.86, 900)
                height: 250
                rotation: -6
                fillColor: ui.red
                shadowColor: ui.black
                shadowX: 14
                shadowY: 14
                strokeColor: ui.white
                strokeWidth: 4
                jag: 46
                edgeJitter: 14
                teeth: 4
                seed: 21
            }

            Loader {
                id: launchTitle
                anchors.centerIn: launchBurst
                anchors.verticalCenterOffset: -6
                active: root.launching
                rotation: -6
                sourceComponent: RansomTitle {
                    maxWidth: launchBurst.width - 160
                    pixelSize: 110
                    maxLines: 1
                    seed: 13
                    text: ui.t("letsGo")
                }
            }
        }

        SequentialAnimation {
            id: launchFx
            ParallelAnimation {
                NumberAnimation { target: launchLayer; property: "opacity"; from: 0; to: 1; duration: 70 }
                NumberAnimation { target: launchLayer; property: "scale"; from: 0.35; to: 1; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2.6 }
                NumberAnimation { target: launchLayer; property: "rotation"; from: -10; to: 0; duration: 200; easing.type: Easing.OutBack }
            }
            PauseAnimation { duration: 420 }
            ParallelAnimation {
                NumberAnimation { target: launchLayer; property: "opacity"; to: 0; duration: 220 }
                NumberAnimation { target: launchLayer; property: "scale"; to: 1.3; duration: 220; easing.type: Easing.InCubic }
            }
        }
    }
}
