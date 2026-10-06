import QtQuick

Item {
    id: root

    property string text: ""
    property real pixelSize: 72
    property real minPixelSize: 22
    property real maxWidth: 600
    property int maxLines: 2
    property real maxHeight: 100000
    property int seed: 0
    property bool animate: true

    Style { id: ui }

    readonly property string source: text.toUpperCase().trim()
    readonly property var words: source.length > 0 ? source.split(/\s+/) : []
    readonly property real fitSize: {
        var unit = 0.63
        var size = pixelSize
        while (size > minPixelSize) {
            var lines = 1
            var used = 0
            var fits = true
            for (var i = 0; i < words.length; i++) {
                var w = words[i].length * unit * size
                if (w > maxWidth) {
                    fits = false
                    break
                }
                var next = used > 0 ? used + size * 0.36 + w : w
                if (next > maxWidth) {
                    lines++
                    used = w
                } else {
                    used = next
                }
            }
            if (fits && lines <= maxLines && lines * size * 1.12 + (lines - 1) * size * 0.36 <= maxHeight)
                break
            size *= 0.94
        }
        return Math.max(minPixelSize, size)
    }
    readonly property var glyphs: {
        var out = []
        var prev = -1
        var total = source.replace(/\s+/g, "").length
        var n = 0
        for (var w = 0; w < words.length; w++) {
            var letters = []
            var chars = Array.from(words[w])
            for (var c = 0; c < chars.length; c++) {
                var r1 = ui.hash(source, seed * 7919 + n * 4 + 1)
                var r2 = ui.hash(source, seed * 7919 + n * 4 + 2)
                var r3 = ui.hash(source, seed * 7919 + n * 4 + 3)
                var r4 = ui.hash(source, seed * 7919 + n * 4 + 4)
                var fill = prev < 0 ? Math.floor(r1 * 3) : (prev + 1 + Math.floor(r1 * 2)) % 3
                prev = fill
                letters.push({
                    "c": chars[c],
                    "fill": fill,
                    "rot": (r2 - 0.5) * 16,
                    "size": 0.84 + r3 * 0.3,
                    "alt": r4 < 0.24,
                    "dy": (r4 - 0.5) * 0.14,
                    "delay": Math.round(n * Math.min(22, 240 / Math.max(1, total)))
                })
                n++
            }
            out.push(letters)
        }
        return out
    }

    implicitWidth: flow.childrenRect.width
    implicitHeight: flow.childrenRect.height

    Flow {
        id: flow
        width: root.maxWidth
        spacing: root.fitSize * 0.36

        Repeater {
            model: root.glyphs

            Row {
                id: word
                required property var modelData
                spacing: root.fitSize * 0.03

                Repeater {
                    model: word.modelData

                    Item {
                        id: letter
                        required property var modelData
                        readonly property real size: root.fitSize * modelData.size
                        width: box.width
                        height: root.fitSize * 1.12

                        Item {
                            id: tile
                            width: box.width
                            height: box.height
                            y: (letter.height - height) / 2 + root.fitSize * letter.modelData.dy
                            rotation: letter.modelData.rot
                            opacity: root.animate ? 0 : 1
                            scale: root.animate ? 1.9 : 1

                            Rectangle {
                                x: Math.max(2, letter.size * 0.05)
                                y: Math.max(2, letter.size * 0.05)
                                width: box.width
                                height: box.height
                                color: letter.modelData.fill === 1 ? ui.white : ui.black
                            }

                            Rectangle {
                                id: box
                                width: glyph.advance + letter.size * 0.2
                                height: letter.size * (letter.modelData.alt ? 0.98 : 0.96)
                                color: letter.modelData.fill === 0 ? ui.white : letter.modelData.fill === 1 ? ui.black : ui.red
                                border.color: ui.white
                                border.width: letter.modelData.fill === 2 ? Math.max(1.5, letter.size * 0.035) : 0

                                Text {
                                    id: glyph
                                    readonly property real advance: Math.max(implicitWidth, letter.size * 0.3)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    y: parent.height / 2 + font.pixelSize * 0.35 - baselineOffset
                                    text: letter.modelData.c
                                    font.family: letter.modelData.alt ? ui.slash : ui.display
                                    font.pixelSize: letter.size * (letter.modelData.alt ? 0.98 : 0.8)
                                    color: letter.modelData.fill === 0 ? ui.black : ui.white
                                }
                            }

                            SequentialAnimation {
                                id: intro
                                PauseAnimation { duration: letter.modelData.delay }
                                ParallelAnimation {
                                    NumberAnimation { target: tile; property: "opacity"; to: 1; duration: 70 }
                                    NumberAnimation { target: tile; property: "scale"; to: 1; duration: 170; easing.type: Easing.OutBack; easing.overshoot: 2.4 }
                                }
                            }

                            Component.onCompleted: if (root.animate) intro.start()
                        }
                    }
                }
            }
        }
    }
}
