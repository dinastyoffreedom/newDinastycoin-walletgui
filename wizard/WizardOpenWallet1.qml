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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import Qt.labs.folderlistmodel 2.1
import dinastycoinComponents.NetworkType 1.0

import "../js/Wizard.js" as Wizard
import "../components"
import "../components" as DinastycoinComponents
import "../components/effects/" as DinastycoinEffects

Rectangle {
    id: wizardOpenWallet1

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardOpenWallet1"
    property int walletCount: walletKeysFilesModel.rowCount()

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            WizardHeader {
                title: qsTr("Open a wallet from file") + translationManager.emptyString
                subtitle: qsTr("Import an existing .keys wallet file from your computer.") + translationManager.emptyString
            }

            GridLayout {
                visible: walletKeysFilesModel.rowCount() > 0
                Layout.topMargin: 10
                Layout.fillWidth: true
                columnSpacing: 20
                columns: 2

                DinastycoinComponents.TextPlain {
                    Layout.fillWidth: true
                    text: qsTr("Recently opened") + ":" + translationManager.emptyString
                    font.family: DinastycoinComponents.Style.fontLight.name
                    font.pixelSize: 16
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            Flow {
                id: flow
                visible: wizardOpenWallet1.walletCount > 0
                spacing: 0
                clip: true

                property int _height: 0
                property int itemHeight: 50
                property int maxRows: 6

                Layout.topMargin: 10
                Layout.fillWidth: true
                Layout.preferredHeight: _height

                function calcHeight(){
                    var itemsHeight = Math.ceil(wizardOpenWallet1.walletCount / 3) * itemHeight;
                    if(itemsHeight >= (flow.itemHeight * flow.maxRows))
                        return flow.itemHeight * flow.maxRows;
                    else
                        return itemsHeight;
                }

                Repeater {
                    id: recentList
                    clip: true
                    model: walletKeysFilesModelProxy
                    Layout.fillWidth: true
                    Layout.minimumWidth: flow.itemHeight
                    Layout.preferredHeight: parent.height

                    delegate: Rectangle {
                        // inherited roles from walletKeysFilesModel:
                        // index, modified, accessed, path, networktype, address
                        id: item
                        height: flow.itemHeight
                        width: {
                            if(wizardController.layoutScale <= 1)
                                return parent.width / 2
                            return parent.width / 3
                        }
                        property string networkType: {
                            if(networktype === 0) return qsTr("Mainnet");
                            else if(networktype === 1) return qsTr("Testnet");
                            else if(networktype === 2) return qsTr("Stagenet");
                            return "";
                        }
                        property string fileName: {
                            var spl = path.split("/");
                            return spl[spl.length - 1].replace(".keys", "");
                        }
                        property string filePath: { return path }
                        color: "transparent"

                        Rectangle {
                            height: 1
                            width: parent.width
                            anchors.top: parent.top
                            color: DinastycoinComponents.Style.appWindowBorderColor
                            visible: index <= 2  // top row

                            DinastycoinEffects.ColorTransition {
                                targetObj: parent
                                blackColor: DinastycoinComponents.Style._b_appWindowBorderColor
                                whiteColor: DinastycoinComponents.Style._w_appWindowBorderColor
                            }
                        }

                        RowLayout {
                            height: flow.itemHeight
                            width: parent.width
                            spacing: 6

                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: flow.itemHeight
                                color: "transparent"

                                Image {
                                    id: icon
                                    height: 48
                                    width: 48
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    fillMode: Image.PreserveAspectFit
                                    source: "qrc:///images/open-wallet-from-file.png"
                                    visible: {
                                        if(!isOpenGL) return true;
                                        if(DinastycoinComponents.Style.blackTheme) return true;
                                        return false;
                                    }
                                }

                                Colorize {
                                    visible: isOpenGL && !DinastycoinComponents.Style.blackTheme
                                    anchors.fill: icon
                                    source: icon
                                    lightness: 0.65 // +65%
                                    saturation: 0.0
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: flow.itemHeight
                                spacing: 0

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                }

                                TextArea {
                                    text: {
                                        // truncate on window width
                                        var maxLength = wizardController.layoutScale <= 1 ? 12 : 16
                                        if(item.fileName.length > maxLength)
                                            return item.fileName.substring(0, maxLength) + "...";
                                        return item.fileName;
                                    }

                                    Layout.preferredHeight: 26
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    font.family: DinastycoinComponents.Style.fontRegular.name
                                    color: DinastycoinComponents.Style.defaultFontColor
                                    font.pixelSize: 16

                                    selectionColor: DinastycoinComponents.Style.dimmedFontColor
                                    selectedTextColor: DinastycoinComponents.Style.defaultFontColor

                                    selectByMouse: false
                                    wrapMode: Text.WordWrap
                                    textMargin: 0
                                    leftPadding: 0
                                    topPadding: networktype !== -1 ? 8 : 4
                                    bottomPadding: 0
                                    readOnly: true
                                }

                                TextArea {
                                    visible: networktype !== -1
                                    Layout.preferredHeight: 24
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: item.networkType
                                    font.family: DinastycoinComponents.Style.fontRegular.name
                                    color: DinastycoinComponents.Style.dimmedFontColor
                                    font.pixelSize: 14

                                    selectionColor: DinastycoinComponents.Style.textSelectionColor
                                    selectedTextColor: DinastycoinComponents.Style.textSelectedColor

                                    selectByMouse: false
                                    wrapMode: Text.WordWrap
                                    textMargin: 0
                                    leftPadding: 0
                                    topPadding: 0
                                    bottomPadding: 0
                                    readOnly: true
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Rectangle {
                            height: 1
                            width: parent.width
                            color: DinastycoinComponents.Style.appWindowBorderColor
                            anchors.bottom: parent.bottom

                            DinastycoinEffects.ColorTransition {
                                targetObj: parent
                                blackColor: DinastycoinComponents.Style._b_appWindowBorderColor
                                whiteColor: DinastycoinComponents.Style._w_appWindowBorderColor
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                parent.color = DinastycoinComponents.Style.titleBarButtonHoverColor;
                            }
                            onExited: {
                                parent.color = "transparent";
                            }
                            onClicked: {
                                persistentSettings.nettype = parseInt(networktype)

                                wizardController.openWalletFile(item.filePath);
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            WizardNav {
                Layout.topMargin: 0
                progressEnabled: false
                btnPrev.text: qsTr("Back to menu") + translationManager.emptyString
                btnNext.text: qsTr("Browse filesystem") + translationManager.emptyString
                btnNext.visible: true
                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
                onNextClicked: {
                    wizardController.openWallet();
                }
            }
        }
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){
            walletKeysFilesModel.refresh(dinastycoinAccountsDir);
            wizardOpenWallet1.walletCount = walletKeysFilesModel.rowCount();
            flow._height = flow.calcHeight();
        }
    }
}
