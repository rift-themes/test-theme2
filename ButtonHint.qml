import QtQuick

Item {
    id: root

    property string key: ""
    property string label: ""

    signal clicked()

    function flash() {
        bump.restart()
    }

    implicitWidth: keyBox.width + 8 + labelText.implicitWidth + 4
    implicitHeight: 34

    Style { id: ui }

    Item {
        id: body
        width: root.width
        height: root.height
        transformOrigin: Item.Center

        SlantBox {
            id: keyBox
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(30, keyText.implicitWidth + 18)
            height: 28
            skew: -0.3
            color: ui.red
            shadowColor: ui.white
            shadowX: 2
            shadowY: 2

            Text {
                id: keyText
                anchors.centerIn: parent
                text: root.key
                font.family: ui.display
                font.pixelSize: 17
                color: ui.white
            }
        }

        Text {
            id: labelText
            x: keyBox.width + 8
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            font.family: ui.display
            font.pixelSize: 20
            font.letterSpacing: 0.5
            color: ui.white
        }
    }

    SequentialAnimation {
        id: bump
        ParallelAnimation {
            NumberAnimation { target: body; property: "scale"; to: 1.22; duration: 60 }
            NumberAnimation { target: body; property: "rotation"; to: -5; duration: 60 }
        }
        ParallelAnimation {
            NumberAnimation { target: body; property: "scale"; to: 1; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 2 }
            NumberAnimation { target: body; property: "rotation"; to: 0; duration: 160; easing.type: Easing.OutBack }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.flash()
            root.clicked()
        }
    }
}
