import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0


SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

        CommunityMintTokensSettingsPanel {
            anchors.fill: parent
            anchors.topMargin: 50
            transactionStore: QtObject {
                readonly property var currentAccount: QtObject {
                    readonly property string address: "0x0000001"
                }
            }
            communitiesStore: QtObject {

                property var layer1Networks: NetworksModel.layer1Networks
                property var layer2Networks: NetworksModel.layer2Networks
                property var testNetworks: NetworksModel.testNetworks
                property var enabledNetworks: NetworksModel.enabledNetworks
                property var allNetworks: enabledNetworks

                function mintCollectible(communityId, address, artworkSource, name, symbol, description, supply,
                                         infiniteSupply, transferable, selfDestruct, chainId)
                {
                   logs.logEvent("CommunityMintTokensSettingsPanel::mintCollectible")
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        CheckBox {
            id: isOwnerCheckBox

            text: "Is owner"
        }
    }
}
