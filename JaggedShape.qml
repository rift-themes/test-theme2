import QtQuick

Canvas {
    id: root

    property color fillColor: "#e3001b"
    property color shadowColor: "transparent"
    property real shadowX: 6
    property real shadowY: 6
    property color strokeColor: "transparent"
    property real strokeWidth: 0
    property real jag: 16
    property real edgeJitter: 6
    property int teeth: 3
    property int seed: 1
    property bool leftTeeth: true
    property bool rightTeeth: true

    function rnd(i) {
        var v = Math.sin((root.seed * 131 + i) * 12.9898) * 43758.5453
        return v - Math.floor(v)
    }

    function outline() {
        var sx = Math.max(0, shadowX)
        var sy = Math.max(0, shadowY)
        var left = leftTeeth ? jag : 0
        var right = width - sx - (rightTeeth ? jag : 0)
        var top = edgeJitter
        var bottom = height - sy - edgeJitter
        var pts = []
        var steps = 4
        var i
        for (i = 0; i < steps; i++)
            pts.push([left + (right - left) * i / steps + (i > 0 ? (rnd(10 + i) - 0.5) * jag : 0),
                      top + (rnd(20 + i) - 0.5) * edgeJitter * 2])
        var n = teeth * 2
        for (i = 0; i <= n; i++) {
            var out = !rightTeeth ? 0 : (i % 2 === 1 ? jag * (0.55 + 0.45 * rnd(30 + i)) : -jag * 0.35 * rnd(40 + i))
            pts.push([right + out, top + (bottom - top) * i / n])
        }
        for (i = steps - 1; i > 0; i--)
            pts.push([left + (right - left) * i / steps + (rnd(50 + i) - 0.5) * jag,
                      bottom + (rnd(60 + i) - 0.5) * edgeJitter * 2])
        for (i = n; i >= 0; i--) {
            var back = !leftTeeth ? 0 : (i % 2 === 1 ? jag * (0.55 + 0.45 * rnd(70 + i)) : -jag * 0.35 * rnd(80 + i))
            pts.push([left - back, top + (bottom - top) * i / n])
        }
        return pts
    }

    function trace(ctx, pts, dx, dy) {
        ctx.beginPath()
        ctx.moveTo(pts[0][0] + dx, pts[0][1] + dy)
        for (var i = 1; i < pts.length; i++)
            ctx.lineTo(pts[i][0] + dx, pts[i][1] + dy)
        ctx.closePath()
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        if (width <= 0 || height <= 0)
            return
        var pts = outline()
        if (shadowColor.a > 0) {
            ctx.fillStyle = String(shadowColor)
            trace(ctx, pts, shadowX, shadowY)
            ctx.fill()
        }
        ctx.fillStyle = String(fillColor)
        trace(ctx, pts, 0, 0)
        ctx.fill()
        if (strokeWidth > 0 && strokeColor.a > 0) {
            ctx.lineWidth = strokeWidth
            ctx.lineJoin = "miter"
            ctx.strokeStyle = String(strokeColor)
            trace(ctx, pts, 0, 0)
            ctx.stroke()
        }
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onFillColorChanged: requestPaint()
    onShadowColorChanged: requestPaint()
    onStrokeColorChanged: requestPaint()
    onSeedChanged: requestPaint()
}
