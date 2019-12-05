import QtQuick 2.9
import QtQuick.Controls 2.2

import FontAwesome 1.0
import "../components" as DinastycoinComponents

MouseArea {
    signal paste()

    id: root
    acceptedButtons: Qt.RightButton
    anchors.fill: parent
    onClicked: {
        if (mouse.button === Qt.RightButton)
            contextMenu.open()
    }

    Menu {
        id: contextMenu

        background: Rectangle {
            border.color: DinastycoinComponents.Style.buttonBackgroundColorDisabledHover
            border.width: 1
            radius: 2
            color: DinastycoinComponents.Style.buttonBackgroundColorDisabled
        }

        padding: 1
        width: 100
        x: root.mouseX
        y: root.mouseY

        DinastycoinComponents.ContextMenuItem {
            enabled: root.parent.canPaste === true
            glyphIcon: FontAwesome.paste
            onTriggered: root.paste()
            text: qsTr("Paste") + translationManager.emptyString
        }
    }
}
