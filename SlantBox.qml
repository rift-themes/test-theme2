import QtQuick

Item {
    id: root

    property real skew: -0.22
    property color color: "#050505"
    property color shadowColor: "transparent"
    property real shadowX: 5
    property real shadowY: 5
    property color borderColor: "transparent"
    property real borderWidth: 0
    readonly property real lean: Math.abs(skew) * height / 2
    readonly property matrix4x4 shear: Qt.matrix4x4(1, skew, 0, -skew * height / 2,
                                                     0, 1, 0, 0,
                                                     0, 0, 1, 0,
                                                     0, 0, 0, 1)
    default property alias content: holder.data

    Rectangle {
        x: root.shadowX
        y: root.shadowY
        width: root.width
        height: root.height
        visible: root.shadowColor.a > 0
        color: root.shadowColor
        transform: Matrix4x4 { matrix: root.shear }
    }

    Rectangle {
        width: root.width
        height: root.height
        color: root.color
        border.color: root.borderColor
        border.width: root.borderWidth
        transform: Matrix4x4 { matrix: root.shear }
    }

    Item {
        id: holder
        anchors.fill: parent
    }
}
