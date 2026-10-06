import QtQuick

Item {
    id: row

    required property int index
    property Style look: null
    property string label: ""
    property string sublabel: ""
    property bool starred: false
    property real barWidth: width
    property real numberWidth: 40
    property int numberDigits: 2
    readonly property bool selected: ListView.isCurrentItem
    readonly property int distance: ListView.view ? Math.abs(index - ListView.view.currentIndex) : 0
    readonly property real cut: ((index * 7919 + 13) % 5) * 6

    width: ListView.view ? ListView.view.width : 300
    height: 46
    z: selected ? 3 : 1
    readonly property real fade: selected ? 1 : Math.max(0.35, 1 - distance * 0.1)

    Item {
        id: body
        width: row.width
        height: row.height
        transformOrigin: Item.Left
        scale: row.selected ? 1.12 : 1
        x: row.selected ? 16 : 0

        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 2.6 } }
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

        Rectangle {
            x: -240
            width: row.barWidth - row.cut + 240
            height: body.height
            visible: !row.selected
            color: row.look.black
            opacity: 0.93
        }

        Rectangle {
            x: row.barWidth - row.cut - 7
            width: 5
            height: body.height
            visible: !row.selected
            opacity: row.fade
            color: row.distance % 2 === 0 ? row.look.white : row.look.red
        }

        Text {
            id: number
            x: 12
            width: row.numberWidth
            anchors.verticalCenter: parent.verticalCenter
            opacity: row.fade
            text: row.look.pad(row.index + 1, row.numberDigits)
            font.family: row.look.slash
            font.pixelSize: 17
            color: row.selected ? row.look.black : row.look.red
        }

        Text {
            x: labelText.x + 3
            y: labelText.y + 3
            width: labelText.width
            visible: row.selected
            text: labelText.text
            elide: Text.ElideRight
            font: labelText.font
            color: row.look.black
        }

        Text {
            id: labelText
            x: number.x + row.numberWidth + 6
            width: Math.max(40, row.barWidth - row.cut - x - tail.width - 16)
            anchors.verticalCenter: parent.verticalCenter
            opacity: row.fade
            text: row.label
            elide: Text.ElideRight
            font.family: row.look.display
            font.pixelSize: 23
            font.capitalization: Font.AllUppercase
            color: row.look.white
        }

        Row {
            id: tail
            x: labelText.x + labelText.width + 8
            anchors.verticalCenter: parent.verticalCenter
            opacity: row.fade
            spacing: 6

            Rectangle {
                visible: row.starred
                anchors.verticalCenter: parent.verticalCenter
                width: favText.implicitWidth + 10
                height: 18
                color: row.selected ? row.look.white : row.look.red

                Text {
                    id: favText
                    anchors.centerIn: parent
                    text: "FAV"
                    font.family: row.look.slash
                    font.pixelSize: 13
                    color: row.selected ? row.look.red : row.look.white
                }
            }

            Text {
                visible: text !== ""
                anchors.verticalCenter: parent.verticalCenter
                text: row.sublabel
                font.family: row.look.bold
                font.bold: true
                font.pixelSize: 15
                color: row.look.white
                opacity: row.selected ? 1 : 0.62
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (row.ListView.view)
                row.ListView.view.rowClicked(row.index)
        }
    }
}
