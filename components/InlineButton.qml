// Copyright (c) 2014-2019, The Dinastycoin Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import "." as DinastycoinComponents
import "./effects/" as DinastycoinEffects

Item {
    id: inlineButton
    height: parent.height
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    property bool small: false
    property string shadowPressedColor: "#B32D00"
    property string shadowReleasedColor: "#FF4304"
    property string pressedColor: "#FF4304"
    property string releasedColor: "#FF6C3C"
    property string icon: ""
    property string textColor: DinastycoinComponents.Style.inlineButtonTextColor
    property int fontSize: small ? 14 : 16
    property int rectHeight: small ? 24 : 24
    property int rectHMargin: small ? 16 : 22
    property alias text: inlineText.text
    property alias fontPixelSize: inlineText.font.pixelSize
    property alias fontFamily: inlineText.font.family
    property alias buttonColor: rect.color
    signal clicked()

    function doClick() {
        // Android workaround
        releaseFocus();
        clicked();
    }

    Rectangle{
        id: rect
        color: DinastycoinComponents.Style.buttonInlineBackgroundColor
        height: 24
        width: inlineText.text ? (inlineText.width + 16) : inlineButton.icon ? (inlineImage.width + 16) : rect.height
        radius: 4

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 4

        DinastycoinComponents.TextPlain {
            id: inlineText
            font.family: DinastycoinComponents.Style.fontBold.name
            font.bold: true
            font.pixelSize: inlineButton.fontSize
            color: inlineButton.textColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            themeTransition: false

            DinastycoinEffects.ColorTransition {
                targetObj: inlineText
                blackColor: DinastycoinComponents.Style._b_inlineButtonTextColor
                whiteColor: DinastycoinComponents.Style._w_inlineButtonTextColor
            }
        }

        Image {
            id: inlineImage
            visible: inlineButton.icon !== ""
            anchors.centerIn: parent
            source: inlineButton.icon
        }

        MouseArea {
            id: buttonArea
            cursorShape: rect.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true
            anchors.fill: parent
            onClicked: doClick()
            onEntered: {
                rect.color = buttonColor ? buttonColor : "#707070";
                rect.opacity = 0.8;
            }
            onExited: {
                rect.opacity = 1.0;
                rect.color = buttonColor ? buttonColor : "#808080";
            }
        }
    }

    DropShadow {
        visible: !DinastycoinComponents.Style.blackTheme
        anchors.fill: rect
        horizontalOffset: 2
        verticalOffset: 2
        radius: 7.0
        samples: 10
        color: "#1B000000"
        cached: true
        source: rect
    }

    Keys.onSpacePressed: doClick()
    Keys.onReturnPressed: doClick()
}
