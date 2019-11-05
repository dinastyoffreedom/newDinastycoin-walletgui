// Parts are Copyright (c) 2019, The Dinastycoin team
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
import QtGraphicalEffects 1.0

import "../components" as DinastycoinComponents

Item {
    id: item
    property alias input: input
    property alias text: input.text

    property alias placeholderText: placeholderLabel.text
    property bool placeholderCenter: false
    property string placeholderFontFamily: DinastycoinComponents.Style.fontRegular.name
    property bool placeholderFontBold: false
    property int placeholderFontSize: 18
    property string placeholderColor: DinastycoinComponents.Style.defaultFontColor
    property real placeholderOpacity: 0.35

    property alias acceptableInput: input.acceptableInput
    property alias validator: input.validator
    property alias readOnly : input.readOnly
    property alias cursorPosition: input.cursorPosition
    property alias echoMode: input.echoMode
    property alias inlineButton: inlineButtonId
    property alias inlineButtonText: inlineButtonId.text
    property alias inlineIcon: inlineIcon.visible
    property bool copyButton: false

    property bool borderDisabled: false
    property string borderColor: {
        if(error && input.text !== ""){
            return DinastycoinComponents.Style.inputBorderColorInvalid;
        } else if(input.activeFocus){
            return DinastycoinComponents.Style.inputBorderColorActive;
        } else {
            return DinastycoinComponents.Style.inputBorderColorInActive;
        }
    }

    property int fontSize: 18
    property bool fontBold: false
    property alias fontColor: input.color
    property bool error: false
    property alias labelText: inputLabel.text
    property alias labelColor: inputLabel.color
    property alias labelTextFormat: inputLabel.textFormat
    property string backgroundColor: "transparent"
    property string tipText: ""
    property int labelFontSize: 16
    property bool labelFontBold: false
    property alias labelWrapMode: inputLabel.wrapMode
    property alias labelHorizontalAlignment: inputLabel.horizontalAlignment
    property bool showingHeader: inputLabel.text !== "" || copyButton
    property int inputHeight: 42

    signal labelLinkActivated(); // input label, rich text <a> signal
    signal editingFinished();
    signal accepted();
    signal textUpdated();

    height: showingHeader ? (inputLabel.height + inputItem.height + 2) : 42

    onTextUpdated: {
        // check to remove placeholder text when there is content
        if(item.isEmpty()){
            placeholderLabel.visible = true;
        } else {
            placeholderLabel.visible = false;
        }
    }

    function isEmpty(){
        var val = input.text;
        if(val === "") {
            return true;
        }
        else {
            return false;
        }
    }

    DinastycoinComponents.TextPlain {
        id: inputLabel
        anchors.top: parent.top
        anchors.left: parent.left
        font.family: DinastycoinComponents.Style.fontRegular.name
        font.pixelSize: labelFontSize
        font.bold: labelFontBold
        textFormat: Text.RichText
        color: DinastycoinComponents.Style.defaultFontColor
        onLinkActivated: item.labelLinkActivated()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    DinastycoinComponents.LabelButton {
        id: copyButtonId
        text: qsTr("Copy") + translationManager.emptyString
        anchors.right: parent.right
        onClicked: {
            if (input.text.length > 0) {
                console.log("Copied to clipboard");
                clipboard.setText(input.text);
                appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
            }
        }
        visible: copyButton && input.text !== ""
    }

    Item{
        id: inputItem
        height: inputHeight
        anchors.top: showingHeader ? inputLabel.bottom : parent.top
        anchors.topMargin: showingHeader ? 12 : 2
        width: parent.width
        clip: true

        DinastycoinComponents.TextPlain {
            id: placeholderLabel
            visible: input.text ? false : true
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: placeholderCenter ? parent.horizontalCenter : undefined
            anchors.left: placeholderCenter ? undefined : parent.left
            anchors.leftMargin: {
                if(placeholderCenter){
                    return undefined;
                }
                else if(inlineIcon.visible){ return 50; }
                else { return 10; }
            }

            opacity: item.placeholderOpacity
            color: item.placeholderColor
            font.family: item.placeholderFontFamily
            font.pixelSize: placeholderFontSize
            font.bold: item.placeholderFontBold
            text: ""
            z: 3
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            color: "transparent"
        }

        Rectangle {
            id: inputFill
            color: backgroundColor
            anchors.fill: parent
            border.width: borderDisabled ? 0 : 1
            border.color: borderColor
            radius: 4
        }

        Image {
            id: inlineIcon
            width: 26
            height: 26
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
            source: "qrc:///images/dinastycoinIcon-28x28.png"
            visible: false
        }

        DinastycoinComponents.Input {
            id: input
            anchors.fill: parent
            anchors.leftMargin: inlineIcon.visible ? 44 : 0
            font.pixelSize: item.fontSize
            font.bold: item.fontBold
            onEditingFinished: item.editingFinished()
            onAccepted: item.accepted();
            onTextChanged: item.textUpdated()
            topPadding: 10
            bottomPadding: 10
        }

        DinastycoinComponents.InlineButton {
            id: inlineButtonId
            visible: item.inlineButtonText ? true : false
            anchors.right: parent.right
            anchors.rightMargin: 8
        }
    }
}
