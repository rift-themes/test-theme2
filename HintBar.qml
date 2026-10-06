import QtQuick

Item {
    id: root

    property var hints: []
    property string caption: ""

    signal hintClicked(string key)

    function flash(key) {
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i)
            if (item && item.key === key)
                item.flash()
        }
    }

    height: 58

    Style { id: ui }

    Item {
        width: root.width
        height: root.height
        rotation: -0.8

        SlantBox {
            x: -60
            y: 10
            width: root.width + 120
            height: root.height - 8
            skew: 0
            color: ui.black
            shadowColor: ui.red
            shadowX: 0
            shadowY: -5
        }

        Rectangle {
            x: -20
            y: 16
            width: root.width + 40
            height: 2
            color: ui.white
            opacity: 0.85
        }

        Text {
            x: 26
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 3
            visible: text !== "" && x + implicitWidth < hintRow.x - 20
            text: root.caption
            font.family: ui.slash
            font.pixelSize: 18
            font.letterSpacing: 3
            color: ui.red
        }

        Row {
            id: hintRow
            anchors.right: parent.right
            anchors.rightMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 5
            spacing: 22

            Repeater {
                id: repeater
                model: root.hints

                ButtonHint {
                    required property var modelData
                    key: modelData[0]
                    label: modelData[1]
                    onClicked: root.hintClicked(modelData[0])
                }
            }
        }
    }
}
