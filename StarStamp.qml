import QtQuick

Item {
    id: root

    property string label: "FAV"
    property real baseRotation: -14

    function slam() {
        stampAnim.restart()
    }

    width: 104
    height: 104

    Style { id: ui }

    Item {
        id: body
        anchors.fill: parent
        rotation: root.baseRotation

        Canvas {
            id: star
            anchors.fill: parent

            function trace(ctx, cx, cy, outer, inner) {
                ctx.beginPath()
                for (var i = 0; i < 10; i++) {
                    var r = i % 2 === 0 ? outer : inner
                    var a = -Math.PI / 2 + i * Math.PI / 5
                    var px = cx + Math.cos(a) * r
                    var py = cy + Math.sin(a) * r
                    if (i === 0)
                        ctx.moveTo(px, py)
                    else
                        ctx.lineTo(px, py)
                }
                ctx.closePath()
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var outer = Math.min(width, height) / 2 - 8
                var inner = outer * 0.5
                var cx = width / 2 - 2
                var cy = height / 2 - 1
                ctx.fillStyle = String(ui.black)
                trace(ctx, cx + 6, cy + 6, outer, inner)
                ctx.fill()
                ctx.fillStyle = String(ui.red)
                trace(ctx, cx, cy, outer, inner)
                ctx.fill()
                ctx.lineWidth = 3.5
                ctx.lineJoin = "miter"
                ctx.strokeStyle = String(ui.white)
                trace(ctx, cx, cy, outer, inner)
                ctx.stroke()
            }

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 3
            text: root.label
            font.family: ui.display
            font.pixelSize: Math.round(root.height * 0.2)
            color: ui.white
        }
    }

    ParallelAnimation {
        id: stampAnim
        NumberAnimation { target: body; property: "scale"; from: 2.3; to: 1; duration: 190; easing.type: Easing.OutBack; easing.overshoot: 2.4 }
        NumberAnimation { target: body; property: "rotation"; from: root.baseRotation - 50; to: root.baseRotation; duration: 190; easing.type: Easing.OutBack }
        NumberAnimation { target: body; property: "opacity"; from: 0; to: 1; duration: 80 }
    }
}
