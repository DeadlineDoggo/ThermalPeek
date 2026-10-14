import QtQuick

// level: 1..5
Image {
    property int level: 1
    source: Qt.resolvedUrl("../../icons/fire-" + Math.max(1, Math.min(5, level)) + ".svg")
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
}
