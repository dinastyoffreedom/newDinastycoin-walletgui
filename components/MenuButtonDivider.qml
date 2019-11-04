import QtQuick 2.9

import "." as DinastycoinComponents
import "effects/" as DinastycoinEffects

Rectangle {
    color: DinastycoinComponents.Style.appWindowBorderColor
    height: 1

    DinastycoinEffects.ColorTransition {
        targetObj: parent
        blackColor: DinastycoinComponents.Style._b_appWindowBorderColor
        whiteColor: DinastycoinComponents.Style._w_appWindowBorderColor
    }
}
