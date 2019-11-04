import QtQuick 2.9

import "../components" as DinastycoinComponents

TextEdit {
    color: DinastycoinComponents.Style.defaultFontColor
    font.family: DinastycoinComponents.Style.fontRegular.name
    selectionColor: DinastycoinComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
