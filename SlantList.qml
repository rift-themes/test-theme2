import QtQuick

Item {
    id: root

    property alias model: list.model
    property alias delegate: list.delegate
    readonly property alias currentIndex: list.currentIndex
    readonly property int count: list.count
    readonly property bool shuffling: shuffleTimer.running
    readonly property alias view: list
    property real rowHeight: 46
    property real rowSpacing: 8
    property real rowWidth: width - 60
    property real skew: -0.16
    property real focusRatio: 0.36
    property int anchorIndex: 0
    readonly property real focusShift: -skew * height * (1 - focusRatio)
    property bool instant: false

    signal activated(int index)

    Style { id: ui }

    function wrap(i) {
        return ((i % count) + count) % count
    }

    function place(index, snap) {
        anchorIndex = index
        instant = snap
        list.currentIndex = index
        if (snap)
            list.positionViewAtIndex(index, ListView.SnapPosition)
        instant = false
    }

    function move(step) {
        if (count <= 0 || shuffleTimer.running)
            return
        var target = wrap(list.currentIndex + step)
        place(target, Math.abs(target - list.currentIndex) > 12)
    }

    function jump(step) {
        if (count <= 0 || shuffleTimer.running)
            return
        var target = list.currentIndex + step
        if (target < 0)
            target = list.currentIndex === 0 ? count - 1 : 0
        else if (target >= count)
            target = list.currentIndex === count - 1 ? 0 : count - 1
        place(target, Math.abs(target - list.currentIndex) > 12)
    }

    function setIndex(index) {
        shuffleTimer.stop()
        anchorIndex = Math.max(0, index)
        if (count <= 0)
            return
        place(Math.min(anchorIndex, count - 1), true)
    }

    function select(index) {
        if (index < 0 || index >= count || shuffleTimer.running)
            return
        if (index === list.currentIndex)
            root.activated(index)
        else
            place(index, false)
    }

    function randomOther() {
        if (count < 2)
            return list.currentIndex
        var pick = Math.floor(Math.random() * (count - 1))
        return pick >= list.currentIndex ? pick + 1 : pick
    }

    function shuffle() {
        if (count < 2 || shuffleTimer.running)
            return
        shuffleTimer.step = 0
        shuffleTimer.target = randomOther()
        shuffleTimer.interval = 45
        shuffleTimer.start()
    }

    onCountChanged: {
        if (count > 0 && list.currentIndex !== Math.min(anchorIndex, count - 1))
            setIndex(anchorIndex)
    }

    Timer {
        id: shuffleTimer
        property int step: 0
        property int target: 0
        repeat: true
        onTriggered: {
            step++
            if (root.count < 2) {
                stop()
                return
            }
            if (step >= 8) {
                stop()
                root.place(Math.min(target, root.count - 1), true)
                return
            }
            root.place(root.randomOther(), true)
            interval = 45 + step * step * 7
        }
    }

    Item {
        id: sheared
        width: root.width
        height: root.height
        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, root.skew, 0, -root.skew * root.height,
                                 0, 1, 0, 0,
                                 0, 0, 1, 0,
                                 0, 0, 0, 1)
        }

        ListView {
            id: list

            signal rowClicked(int index)

            anchors.fill: parent
            clip: true
            spacing: root.rowSpacing
            keyNavigationEnabled: false
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: Math.round(root.rowHeight * 4)
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: Math.round(root.height * root.focusRatio - root.rowHeight / 2)
            preferredHighlightEnd: preferredHighlightBegin + root.rowHeight
            highlightMoveDuration: root.instant ? 0 : 130
            highlightMoveVelocity: -1
            highlightResizeDuration: 0
            highlightFollowsCurrentItem: true
            onRowClicked: function(index) { root.select(index) }

            highlight: Item {
                id: highlight
                z: 2
                width: list.width
                height: root.rowHeight

                JaggedShape {
                    id: backShard
                    x: -30
                    y: -root.rowHeight * 0.375
                    width: root.rowWidth + 150
                    height: root.rowHeight * 1.75
                    rotation: 2.5
                    transformOrigin: Item.Left
                    fillColor: ui.black
                    jag: 30
                    edgeJitter: 9
                    teeth: 3
                    leftTeeth: false
                    seed: 3
                }

                JaggedShape {
                    id: shard
                    x: -40
                    y: -root.rowHeight * 0.25
                    width: root.rowWidth + 128
                    height: root.rowHeight * 1.5
                    rotation: -1
                    transformOrigin: Item.Left
                    fillColor: ui.red
                    strokeColor: ui.white
                    strokeWidth: 2.5
                    shadowColor: "transparent"
                    jag: 24
                    edgeJitter: 6
                    teeth: 2
                    leftTeeth: false
                    seed: 7
                }

                Rectangle {
                    x: 10
                    y: root.rowHeight + 5
                    width: root.rowWidth * 0.55
                    height: 4
                    color: ui.white
                }

                Connections {
                    target: list
                    function onCurrentIndexChanged() { slam.restart() }
                }

                ParallelAnimation {
                    id: slam
                    NumberAnimation { target: shard; property: "scale"; from: 1.3; to: 1; duration: 170; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
                    NumberAnimation { target: shard; property: "rotation"; from: -6; to: -1; duration: 170; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
                    NumberAnimation { target: backShard; property: "scale"; from: 0.6; to: 1; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2 }
                    NumberAnimation { target: backShard; property: "rotation"; from: 8; to: 2.5; duration: 200; easing.type: Easing.OutBack }
                }
            }
        }
    }
}
