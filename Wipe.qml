import QtQuick

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property real progress: 0
    readonly property bool running: sweep.running

    function play(text, sub) {
        title = text || ""
        subtitle = sub || ""
        sweep.restart()
        if (titleLoader.item)
            titleLoader.active = false
        titleLoader.active = true
    }

    function slide(from, mid, to) {
        var p = progress
        return p <= 1 ? from + (mid - from) * p : mid + (to - mid) * (p - 1)
    }

    visible: running

    Style { id: ui }

    SequentialAnimation {
        id: sweep
        NumberAnimation { target: root; property: "progress"; from: 0; to: 1; duration: 170; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 190 }
        NumberAnimation { target: root; property: "progress"; to: 2; duration: 210; easing.type: Easing.InCubic }
        ScriptAction { script: titleLoader.active = false }
    }

    Item {
        id: lower
        width: root.width * 1.5
        height: root.height * 0.82
        x: root.slide(root.width + 60, -root.width * 0.25, -width - 60)
        y: root.height * 0.75 - height / 2
        rotation: -8

        JaggedShape {
            width: parent.width / 2
            height: parent.height / 2
            scale: 2
            transformOrigin: Item.TopLeft
            fillColor: ui.black
            jag: 26
            edgeJitter: 8
            teeth: 4
            seed: 11
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: root.width * 0.12
            y: parent.height * 0.6
            text: root.subtitle
            font.family: ui.slash
            font.pixelSize: 40
            font.letterSpacing: 4
            color: ui.white
        }
    }

    Rectangle {
        width: root.width * 1.6
        x: root.slide(-width - 200, -root.width * 0.3, root.width + 200)
        y: root.height * 0.66 + 16
        height: 9
        rotation: -8
        color: ui.white
    }

    Item {
        id: upper
        width: root.width * 1.5
        height: root.height * 0.82
        x: root.slide(-width - 60, -root.width * 0.25, root.width + 60)
        y: root.height * 0.25 - height / 2
        rotation: -8

        JaggedShape {
            width: parent.width / 2
            height: parent.height / 2
            scale: 2
            transformOrigin: Item.TopLeft
            fillColor: ui.red
            jag: 26
            edgeJitter: 8
            teeth: 4
            seed: 5
        }

        Loader {
            id: titleLoader
            active: false
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.63 - height / 2
            sourceComponent: RansomTitle {
                text: root.title
                maxWidth: root.width * 0.8
                pixelSize: 92
                maxLines: 1
                seed: 4
            }
        }
    }
}
