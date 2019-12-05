import QtQuick 2.9
import QtQuick.Layouts 1.1

import "../components" as DinastycoinComponents

ColumnLayout {
    property alias buttonText: button.text
    property alias description: description.text
    property alias title: title.text
    signal clicked()

    id: settingsListItem
    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        // divider
        Layout.preferredHeight: 1
        Layout.fillWidth: true
        Layout.bottomMargin: 8
        color: DinastycoinComponents.Style.dividerColor
        opacity: DinastycoinComponents.Style.dividerOpacity
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            DinastycoinComponents.TextPlain {
                id: title
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                Layout.topMargin: 8
                color: DinastycoinComponents.Style.defaultFontColor
                opacity: DinastycoinComponents.Style.blackTheme ? 1.0 : 0.8
                font.bold: true
                font.family: DinastycoinComponents.Style.fontRegular.name
                font.pixelSize: 16
            }

            DinastycoinComponents.TextPlainArea {
                id: description
                color: DinastycoinComponents.Style.dimmedFontColor
                colorBlackTheme: DinastycoinComponents.Style._b_dimmedFontColor
                colorWhiteTheme: DinastycoinComponents.Style._w_dimmedFontColor
                Layout.fillWidth: true
                horizontalAlignment: TextInput.AlignLeft
            }
        }

        DinastycoinComponents.StandardButton {
            id: button
            small: true
            onClicked: {
                settingsListItem.clicked()
            }
            width: 135
        }
    }
}
