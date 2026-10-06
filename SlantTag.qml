import QtQuick

SlantBox {
    id: root

    property string caption: ""
    property string value: ""
    property string variant: "black"
    property real valueSize: 26
    property real maxValueWidth: 280

    Style { id: ui }

    readonly property color textColor: variant === "white" ? ui.black : ui.white
    readonly property color captionColor: variant === "red" ? ui.black : ui.red

    color: variant === "white" ? ui.white : variant === "red" ? ui.red : ui.black
    shadowColor: variant === "black" ? ui.white : ui.black
    shadowX: 4
    shadowY: 4
    borderColor: ui.white
    borderWidth: variant === "red" ? 2 : 0
    skew: -0.24
    implicitWidth: Math.max(captionText.visible ? captionText.implicitWidth : 0, valueText.width) + 28 + lean * 2
    implicitHeight: stack.implicitHeight + 12

    Column {
        id: stack
        x: 14 + root.lean
        y: 6
        spacing: -2

        Text {
            id: captionText
            visible: root.caption !== ""
            text: root.caption
            font.family: ui.bold
            font.bold: true
            font.pixelSize: 12
            font.letterSpacing: 2
            color: root.captionColor
        }

        Text {
            id: valueText
            width: Math.min(implicitWidth, root.maxValueWidth)
            text: root.value
            elide: Text.ElideRight
            font.family: ui.display
            font.pixelSize: root.valueSize
            lineHeight: 0.92
            color: root.textColor
        }
    }
}
