import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Chat.views.communities 1.0

import Storybook 1.0
import Models 1.0

import utils 1.0

SplitView {

    QtObject {
        id: d

        // General properties:
        property string name: "Uniswap"
        property string communityDesc: "General channel for the community"
        property color color: "orchid"
        property string channelName: joinCommunity ? "general" : "#vip"
        property string channelDesc: "VIP members only"
        property bool joinCommunity: true // Otherwise it means join channel action

        // Overlay component:
        property bool requirementsMet: true
        property bool isInvitationPending: false
        property bool isJoinRequestRejected: false
        property bool requiresRequest: false
        property var communityHoldings: PermissionsModel.shortPermissionsModel
        property var viewOnlyHoldings: PermissionsModel.shortPermissionsModel
        property var viewAndPostHoldings: PermissionsModel.shortPermissionsModel
        property var moderateHoldings: PermissionsModel.shortPermissionsModel

        // Blur background:
        property int membersCount: 184
        property bool amISectionAdmin: false
        property url image: Style.png("tokens/UNI")
        property var communityItemsModel: model1
        property string chatDateTimeText: "Dec 31, 2020"
        property string  listUsersText: "simon, Mark Cuban "
        readonly property ListModel model1:  ListModel {
            ListElement { name: "welcome"; selected: false; notificationsCount: 0; hasUnreadMessages: false}
            ListElement { name: "general"; selected: false; notificationsCount: 0; hasUnreadMessages: true}
            ListElement { name: "design"; selected: true; notificationsCount: 3; hasUnreadMessages: true}
            ListElement { name: "random"; selected: false; notificationsCount: 0; hasUnreadMessages: false}
            ListElement { name: "vip"; selected: false; notificationsCount: 0; hasUnreadMessages: true}
        }
        readonly property ListModel model2:  ListModel {
            ListElement { name: "general"; selected: false; notificationsCount: 3; hasUnreadMessages: false}
            ListElement { name: "blockchain"; selected: true; notificationsCount: 3; hasUnreadMessages: true}
            ListElement { name: "faq"; selected: false; notificationsCount: 0; hasUnreadMessages: false}
        }
        readonly property var messagesModel: ListModel {
            ListElement {
                timestamp: 1656937930
                senderDisplayName: "simon"
                contentType: StatusMessage.ContentType.Text
                message:  "Hello, this is awesome! Feels like decentralized Discord!"
                isContact: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
                colorId: 4
            }
            ListElement {
                timestamp: 1657937930
                senderDisplayName: "Mark Cuban"
                contentType: StatusMessage.ContentType.Text
                message: "I know a lot of you really seem to get off or be validated by arguing with strangers online but please know it's a complete waste of your time and energy"
                isContact: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
                colorId: 2
            }
        }        
    }

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            clip: true

            JoinCommunityView {
                anchors.fill: parent
                anchors.margins: 50

                // General properties:
                name: d.name
                communityDesc: d.communityDesc
                color: d.color
                channelName: d.channelName
                channelDesc: d.channelDesc
                joinCommunity: d.joinCommunity

                // Blur background properties:
                membersCount: d.membersCount
                image: d.image                
                amISectionAdmin: d.amISectionAdmin
                openCreateChat: false
                communityItemsModel: d.communityItemsModel
                chatDateTimeText: d.chatDateTimeText
                listUsersText: d.listUsersText
                messagesModel: d.messagesModel

                // Permissions properties
                requirementsMet: d.requirementsMet
                isInvitationPending: d.isInvitationPending
                isJoinRequestRejected: d.isJoinRequestRejected
                requiresRequest: d.requiresRequest
                communityHoldings: d.communityHoldings
                viewOnlyHoldings: d.viewOnlyHoldings
                viewAndPostHoldings: d.viewAndPostHoldings
                moderateHoldings: d.moderateHoldings

                onInfoButtonClicked: logs.logEvent("JoinCommunityView::onInfoButtonClicked()")
                onAdHocChatButtonClicked: {
                    logs.logEvent("JoinCommunityView::store.openCloseCreateChatView(): " + openCreateChat.toString())
                    openCreateChat = !openCreateChat
                }
                onNotificationButtonClicked: logs.logEvent("JoinCommunityView::onNotificationButtonClicked()")
                onRevealAddressClicked: logs.logEvent("JoinCommunityView::onRevealAddressClicked()")
                onInvitationPendingClicked: logs.logEvent("JoinCommunityView::onInvitationPendingClicked()")
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ScrollView {
            anchors.fill: parent

            ColumnLayout {
                spacing: 16

                // Blur info editor:
                Label {
                    Layout.fillWidth: true
                    text: "BLUR INFO EDITOR"
                    font.bold: true
                    font.pixelSize: 18
                }

                CommunityInfoEditor {
                    name: d.name
                    membersCount: d.membersCount
                    amISectionAdmin: d.amISectionAdmin
                    color: d.color
                    image: d.image
                    colorVisible: true

                    onNameChanged: d.name = name
                    onMembersCountChanged: d.membersCount = membersCount
                    onAmISectionAdminChanged: d.amISectionAdmin = amISectionAdmin
                    onColorChanged: d.color = color
                    onImageChanged: d.image = image
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: "Community items model:"
                    }

                    RadioButton {
                           checked: true
                           text: qsTr("Model 1")
                           onCheckedChanged: if(checked) d.communityItemsModel =  d.model1
                       }
                       RadioButton {
                           text: qsTr("Model 2")
                            onCheckedChanged: if(checked) d.communityItemsModel = d.model2
                       }
                }

                // Join community overlay editor:
                Label {
                    Layout.fillWidth: true
                    text: "JOIN HOLDINGS EDITOR"
                    font.bold: true
                    font.pixelSize: 18
                }

                JoinCommunityPermissionsEditor {
                    channelName: d.chanelName
                    joinCommunity: d.joinCommunity
                    requirementsMet: d.requirementsMet
                    isInvitationPending: d.isInvitationPending
                    isJoinRequestRejected: d.isJoinRequestRejected
                    requiresRequest: d.requiresRequest

                    onChannelNameChanged: d.channelName = channelName
                    onJoinCommunityChanged: d.joinCommunity = joinCommunity
                    onRequirementsMetChanged: d.requirementsMet = requirementsMet
                    onIsInvitationPendingChanged: d.isInvitationPending = isInvitationPending
                    onIsJoinRequestRejectedChanged: d.isJoinRequestRejected = isJoinRequestRejected
                    onRequiresRequestChanged: d.requiresRequest = requiresRequest
                    onCommunityHoldingsChanged: d.communityHoldings = communityHoldings
                    onViewOnlyHoldingsChanged: d.viewOnlyHoldings = viewOnlyHoldings
                    onViewAndPostHoldingsChanged: d.viewAndPostHoldings = viewAndPostHoldings
                    onModerateHoldingsChanged: d.moderateHoldings = moderateHoldings
                }
            }
        }
    }
}
