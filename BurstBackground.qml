import QtQuick

Item {
    id: root

    property bool animated: true
    property real centerX: 0.66
    property real centerY: 0.34
    readonly property int lowWidth: 480
    readonly property int lowHeight: 270

    function kick() {
        kickAnim.stop()
        kickAnim.from = burst.spin
        kickAnim.to = burst.spin + 0.09
        kickAnim.start()
    }

    Behavior on centerX { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
    Behavior on centerY { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }

    Rectangle {
        anchors.fill: parent
        color: "#8c0010"
    }

    Item {
        id: lowRes
        width: root.lowWidth
        height: root.lowHeight
        layer.enabled: true
        layer.smooth: true
        layer.textureSize: Qt.size(root.lowWidth, root.lowHeight)
        transform: Scale {
            xScale: root.width / root.lowWidth
            yScale: root.height / root.lowHeight
        }

        ShaderEffect {
            id: burst
            anchors.fill: parent
            property real time
            property real spin: 0
            property real aspect: root.height > 0 ? root.width / root.height : 16 / 9
            property real centerX: root.centerX
            property real centerY: root.centerY
            property real res: root.lowHeight
            property real pulse
            fragmentShader: "shaders/burst.frag.qsb"

            NumberAnimation on time {
                from: 0
                to: 3600
                duration: 3600000
                loops: Animation.Infinite
                running: root.animated && root.visible
            }

            SequentialAnimation on pulse {
                loops: Animation.Infinite
                running: root.animated && root.visible
                NumberAnimation { from: 0; to: 1; duration: 140; easing.type: Easing.OutQuad }
                NumberAnimation { from: 1; to: 0; duration: 760; easing.type: Easing.InQuad }
            }
        }
    }

    NumberAnimation {
        id: kickAnim
        target: burst
        property: "spin"
        duration: 260
        easing.type: Easing.OutBack
        easing.overshoot: 2
    }
}
