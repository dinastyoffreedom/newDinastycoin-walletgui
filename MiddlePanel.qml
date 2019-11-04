// Copyright (c) 2014-2018, The Dinastycoin Project
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


import QtQml 2.0
import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import dinastycoinComponents.Wallet 1.0

import "./pages"
import "./pages/settings"
import "./pages/merchant"
import "./components" as DinastycoinComponents
import "./components/effects/" as DinastycoinEffects

Rectangle {
    id: root

    property Item currentView
    property Item previousView
    property int minHeight: (appWindow.height > 800) ? appWindow.height : 800
    property alias contentHeight: mainFlickable.contentHeight
    property alias flickable: mainFlickable

    property Transfer transferView: Transfer { }
    property Receive receiveView: Receive { }
    property Merchant merchantView: Merchant { }
    property TxKey txkeyView: TxKey { }
    property SharedRingDB sharedringdbView: SharedRingDB { }
    property History historyView: History { }
    property Sign signView: Sign { }
    property Settings settingsView: Settings { }
    property Mining miningView: Mining { }
    property AddressBook addressBookView: AddressBook { }
    property Keys keysView: Keys { }
    property Account accountView: Account { }

    signal paymentClicked(string address, string paymentId, string amount, int mixinCount, int priority, string description)
    signal sweepUnmixableClicked()
    signal generatePaymentIdInvoked()
    signal getProofClicked(string txid, string address, string message);
    signal checkProofClicked(string txid, string address, string message, string signature);

    Rectangle {
        // grey background on merchantView
        visible: currentView === merchantView
        color: DinastycoinComponents.Style.dinastycoinGrey
        anchors.fill: parent
    }

    DinastycoinEffects.GradientBackground {
        visible: currentView !== merchantView
        anchors.fill: parent
        fallBackColor: DinastycoinComponents.Style.middlePanelBackgroundColor
        initialStartColor: DinastycoinComponents.Style.middlePanelBackgroundGradientStart
        initialStopColor: DinastycoinComponents.Style.middlePanelBackgroundGradientStop
        blackColorStart: DinastycoinComponents.Style._b_middlePanelBackgroundGradientStart
        blackColorStop: DinastycoinComponents.Style._b_middlePanelBackgroundGradientStop
        whiteColorStart: DinastycoinComponents.Style._w_middlePanelBackgroundGradientStart
        whiteColorStop: DinastycoinComponents.Style._w_middlePanelBackgroundGradientStop
        start: Qt.point(0, 0)
        end: Qt.point(height, width)
    }

    onCurrentViewChanged: {
        if (previousView) {
            if (typeof previousView.onPageClosed === "function") {
                previousView.onPageClosed();
            }
        }
        previousView = currentView
        if (currentView) {
            stackView.replace(currentView)
            // Component.onCompleted is called before wallet is initilized
            if (typeof currentView.onPageCompleted === "function") {
                currentView.onPageCompleted();
            }
        }
    }

    function updateStatus(){
        transferView.updateStatus();
    }

    // send from AddressBook
    function sendTo(address, paymentId, description){
        root.state = "Transfer";
        transferView.sendTo(address, paymentId, description);
    }

        states: [
            State {
                name: "History"
                PropertyChanges { target: root; currentView: historyView }
                PropertyChanges { target: mainFlickable; contentHeight: historyView.contentHeight + 80}
            }, State {
                name: "Transfer"
                PropertyChanges { target: root; currentView: transferView }
                PropertyChanges { target: mainFlickable; contentHeight: transferView.transferHeight1 + transferView.transferHeight2 + 80 }
            }, State {
                name: "Receive"
                PropertyChanges { target: root; currentView: receiveView }
                PropertyChanges { target: mainFlickable; contentHeight: receiveView.receiveHeight + 80 }
            }, State {
                name: "Merchant"
                PropertyChanges { target: root; currentView: merchantView }
                PropertyChanges { target: mainFlickable; contentHeight: merchantView.merchantHeight + 80 }
            }, State {
                name: "TxKey"
                PropertyChanges { target: root; currentView: txkeyView }
                PropertyChanges { target: mainFlickable; contentHeight: txkeyView.txkeyHeight + 80 }
            }, State {
                name: "SharedRingDB"
                PropertyChanges { target: root; currentView: sharedringdbView }
                PropertyChanges { target: mainFlickable; contentHeight: sharedringdbView.panelHeight + 80  }
            }, State {
                name: "AddressBook"
                PropertyChanges { target: root; currentView: addressBookView }
                PropertyChanges { target: mainFlickable; contentHeight: addressBookView.addressbookHeight + 80 }
            }, State {
                name: "Sign"
                PropertyChanges { target: root; currentView: signView }
                PropertyChanges { target: mainFlickable; contentHeight: signView.signHeight + 80 }
            }, State {
                name: "Settings"
                PropertyChanges { target: root; currentView: settingsView }
                PropertyChanges { target: mainFlickable; contentHeight: settingsView.settingsHeight }
            }, State {
                name: "Mining"
                PropertyChanges { target: root; currentView: miningView }
                PropertyChanges { target: mainFlickable; contentHeight: miningView.miningHeight + 80 }
            }, State {
                name: "Keys"
                PropertyChanges { target: root; currentView: keysView }
                PropertyChanges { target: mainFlickable; contentHeight: keysView.keysHeight + 80}
            }, State {
                name: "Account"
                PropertyChanges { target: root; currentView: accountView }
                PropertyChanges { target: mainFlickable; contentHeight: accountView.accountHeight + 80 }
            }	
        ]

    // color stripe at the top
    Row {
        id: styledRow
        visible: currentView !== merchantView
        height: 4
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: parent.z + 1

        Rectangle { height: 4; width: parent.width / 5; color: "#FFE00A" }
        Rectangle { height: 4; width: parent.width / 5; color: "#6B0072" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF6C3C" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FFD781" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF4F41" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: {
            if(currentView === merchantView || currentView === historyView)
                return 0;

            return 20;
        }

        anchors.topMargin: appWindow.persistentSettings.customDecorations ? 50 : 0
        spacing: 0

        Flickable {
            id: mainFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ScrollBar.vertical: ScrollBar {
                parent: root
                anchors.left: parent.right
                anchors.leftMargin: -14 // 10 margin + 4 scrollbar width
                anchors.top: parent.top
                anchors.topMargin: persistentSettings.customDecorations ? 60 : 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: persistentSettings.customDecorations ? 15 : 10
            }

            onFlickingChanged: {
                releaseFocus();
            }

            // Views container
            StackView {
                id: stackView
                initialItem: transferView
                anchors.fill:parent
                clip: true // otherwise animation will affect left panel

                delegate: StackViewDelegate {
                    pushTransition: StackViewTransition {
                        PropertyAnimation {
                            target: enterItem
                            property: "x"
                            from: 0 - target.width
                            to: 0
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                        PropertyAnimation {
                            target: exitItem
                            property: "x"
                            from: 0
                            to: target.width
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

        }// flickable
    }

    // border
    Rectangle {
        id: borderLeft
        visible: middlePanel.state !== "Merchant"
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 1
        color: DinastycoinComponents.Style.appWindowBorderColor

        DinastycoinEffects.ColorTransition {
            targetObj: parent
            blackColor: DinastycoinComponents.Style._b_appWindowBorderColor
            whiteColor: DinastycoinComponents.Style._w_appWindowBorderColor
        }
    }

    // border shadow
    Image {
        source: "qrc:///images/middlePanelShadow.png"
        width: 12
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: borderLeft.right
    }

    /* connect "payment" click */
    Connections {
        ignoreUnknownSignals: false
        target: transferView
        onPaymentClicked : {
            console.log("MiddlePanel: paymentClicked")
            paymentClicked(address, paymentId, amount, mixinCount, priority, description)
        }
        onSweepUnmixableClicked : {
            console.log("MiddlePanel: sweepUnmixableClicked")
            sweepUnmixableClicked()
        }
    }
}
