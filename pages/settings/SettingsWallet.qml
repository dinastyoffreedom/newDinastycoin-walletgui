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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../../js/Utils.js" as Utils
import "../../components" as DinastycoinComponents

Rectangle {
    color: "transparent"
    height: 1400
    Layout.fillWidth: true

    ColumnLayout {
        id: settingsWallet
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 0

        Rectangle {
            // divider
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.bottomMargin: 8
            color: DinastycoinComponents.Style.dividerColor
            opacity: DinastycoinComponents.Style.dividerOpacity
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            columnSpacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                DinastycoinComponents.TextPlain {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    Layout.topMargin: 8
                    color: DinastycoinComponents.Style.defaultFontColor
                    opacity: DinastycoinComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: DinastycoinComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Close this wallet") + translationManager.emptyString
                }

                DinastycoinComponents.TextPlainArea {
                    color: DinastycoinComponents.Style.dimmedFontColor
                    colorBlackTheme: DinastycoinComponents.Style._b_dimmedFontColor
                    colorWhiteTheme: DinastycoinComponents.Style._w_dimmedFontColor
                    width: parent.width
                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignLeft
                    text: qsTr("Logs out of this wallet.") + translationManager.emptyString
                }
            }

            DinastycoinComponents.StandardButton {
                small: true
                text: qsTr("Close wallet") + translationManager.emptyString
                onClicked: {
                    middlePanel.addressBookView.clearFields();
                    middlePanel.transferView.clearFields();
                    middlePanel.receiveView.clearFields();
                    appWindow.showWizard();
                }
                width: 135
            }
        }

        Rectangle {
            // divider
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            color: DinastycoinComponents.Style.dividerColor
            opacity: DinastycoinComponents.Style.dividerOpacity
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            columnSpacing: 0
            visible: !appWindow.viewOnly

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                DinastycoinComponents.TextPlain {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    Layout.topMargin: 8
                    color: DinastycoinComponents.Style.defaultFontColor
                    opacity: DinastycoinComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: DinastycoinComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Create a view-only wallet") + translationManager.emptyString
                }

                DinastycoinComponents.TextPlainArea {
                    color: DinastycoinComponents.Style.dimmedFontColor
                    colorBlackTheme: DinastycoinComponents.Style._b_dimmedFontColor
                    colorWhiteTheme: DinastycoinComponents.Style._w_dimmedFontColor
                    width: parent.width
                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignLeft
                    text: qsTr("Creates a new wallet that can only view and initiate transactions, but requires a spendable wallet to sign transactions before sending.") + translationManager.emptyString
                }
            }

            DinastycoinComponents.StandardButton {
                small: true
                text: qsTr("Create wallet") + translationManager.emptyString
                onClicked: {
                    var newPath = currentWallet.path + "_viewonly";
                    if (currentWallet.createViewOnly(newPath, appWindow.walletPassword)) {
                        console.log("view only wallet created in " + newPath);
                        informationPopup.title  = qsTr("Success") + translationManager.emptyString;
                        informationPopup.text = qsTr('The view only wallet has been created with the same password as the current wallet. You can open it by closing this current wallet, clicking the "Open wallet from file" option, and selecting the view wallet in: \n%1\nYou can change the password in the wallet settings.').arg(newPath);
                        informationPopup.open()
                        informationPopup.onCloseCallback = null
                    } else {
                        informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                        informationPopup.text = currentWallet.errorString;
                        informationPopup.open()
                    }
                }
                width: 135
            }
        }

        Rectangle {
            // divider
            visible: !appWindow.viewOnly
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            color: DinastycoinComponents.Style.dividerColor
            opacity: DinastycoinComponents.Style.dividerOpacity
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            columnSpacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                DinastycoinComponents.TextPlain {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    Layout.topMargin: 8
                    color: DinastycoinComponents.Style.defaultFontColor
                    opacity: DinastycoinComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: DinastycoinComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Show seed & keys") + translationManager.emptyString
                }

                DinastycoinComponents.TextPlainArea {
                    color: DinastycoinComponents.Style.dimmedFontColor
                    colorBlackTheme: DinastycoinComponents.Style._b_dimmedFontColor
                    colorWhiteTheme: DinastycoinComponents.Style._w_dimmedFontColor
                    width: parent.width
                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignLeft
                    text: qsTr("Store this information safely to recover your wallet in the future.") + translationManager.emptyString
                }
            }

            DinastycoinComponents.StandardButton {
                small: true
                text: qsTr("Show seed") + translationManager.emptyString
                onClicked: {
                    Utils.showSeedPage();
                }
                width: 135
            }
        }

        Rectangle {
            // divider
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            color: DinastycoinComponents.Style.dividerColor
            opacity: DinastycoinComponents.Style.dividerOpacity
        }

        GridLayout {
            visible: appWindow.walletMode >= 2
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            columnSpacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                DinastycoinComponents.TextPlain {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    Layout.topMargin: 8
                    color: DinastycoinComponents.Style.defaultFontColor
                    opacity: DinastycoinComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: DinastycoinComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Rescan wallet balance") + translationManager.emptyString
                }

                DinastycoinComponents.TextPlainArea {
                    color: DinastycoinComponents.Style.dimmedFontColor
                    colorBlackTheme: DinastycoinComponents.Style._b_dimmedFontColor
                    colorWhiteTheme: DinastycoinComponents.Style._w_dimmedFontColor
                    width: parent.width
                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignLeft
                    text: qsTr("Use this feature if you think the shown balance is not accurate.") + translationManager.emptyString
                }
            }

            DinastycoinComponents.StandardButton {
                small: true
                text: qsTr("Rescan") + translationManager.emptyString
                onClicked: {
                    if (!currentWallet.rescanSpent()) {
                        console.error("Error: ", currentWallet.errorString);
                        informationPopup.title = qsTr("Error") + translationManager.emptyString;
                        informationPopup.text  = qsTr("Error: ") + currentWallet.errorString
                        informationPopup.icon  = StandardIcon.Critical
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    } else {
                        informationPopup.title = qsTr("Information") + translationManager.emptyString
                        informationPopup.text  = qsTr("Successfully rescanned spent outputs.") + translationManager.emptyString
                        informationPopup.icon  = StandardIcon.Information
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    }
                }
                width: 135
            }
        }
        Rectangle {
            // divider
            visible: appWindow.walletMode >= 2
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            color: DinastycoinComponents.Style.dividerColor
            opacity: DinastycoinComponents.Style.dividerOpacity
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            columnSpacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                DinastycoinComponents.TextPlain {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    Layout.topMargin: 8
                    color: DinastycoinComponents.Style.defaultFontColor
                    opacity: DinastycoinComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: DinastycoinComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Change wallet password") + translationManager.emptyString
                }

                DinastycoinComponents.TextPlainArea {
                    color: DinastycoinComponents.Style.dimmedFontColor
                    colorBlackTheme: DinastycoinComponents.Style._b_dimmedFontColor
                    colorWhiteTheme: DinastycoinComponents.Style._w_dimmedFontColor
                    width: parent.width
                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignLeft
                    text: qsTr("Change the password of your wallet.") + translationManager.emptyString
                }
            }

            DinastycoinComponents.StandardButton {
                small: true
                text: qsTr("Change password") + translationManager.emptyString
                onClicked: {
                    passwordDialog.onAcceptedCallback = function() {
	                    if(appWindow.walletPassword === passwordDialog.password){
	                        passwordDialog.openNewPasswordDialog()
	                    } else {
	                        informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text = qsTr("Wrong password") + translationManager.emptyString;
	                        informationPopup.open()
	                        informationPopup.onCloseCallback = function() {
	                            passwordDialog.open()
	                        }
	                    }
	                }
                    passwordDialog.onRejectedCallback = null;
                    passwordDialog.open()
                }
                width: 135
            }
        }
    }

    Component.onCompleted: {
        console.log('SettingsWallet loaded');
    }
}

