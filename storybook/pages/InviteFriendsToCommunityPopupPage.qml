import QtQuick 2.14

import AppLayouts.Chat.popups 1.0
import utils 1.0

Item {
    Rectangle {
        color: 'lightgray'
        anchors.fill: parent
    }

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    QtObject {
        function getCompressedPk(publicKey) {
            return "compressed"
        }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            globalUtilsReady = true

        }
        Component.onDestruction: {
            globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        function getContactDetailsAsJson() {
            return JSON.stringify({})
        }

        Component.onCompleted: {
            mainModuleReady = true
            Utils.mainModuleInst = this
        }
        Component.onDestruction: {
            mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    Loader {
        active: globalUtilsReady && mainModuleReady
        anchors.fill: parent

        sourceComponent: InviteFriendsToCommunityPopup {
            parent: parent
            modal: false
            anchors.centerIn: parent

            community: ({
                id: "communityId",
                name: "community-name"
            })

            rootStore: QtObject {
                function communityHasMember(communityId, pubKey) {
                    return false
                }
            }

            contactsStore: QtObject {
                readonly property ListModel myContactsModel: ListModel {
                    Component.onCompleted: {
                        for (let i = 0; i < 20; i++) {
                            const key = `pub_key_${i}`

                            append({
                                alias: "",
                                colorId: "1",
                                displayName: `contact ${i}`,
                                ensName: "",
                                icon: "",
                                isContact: true,
                                localNickname: "",
                                onlineStatus: 1,
                                pubKey: key
                            })
                        }
                    }
                }
            }

            Component.onCompleted: open()
        }
    }
}
