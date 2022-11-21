import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Qt.labs.settings 1.0

import StatusQ.Core.Theme 0.1
import Storybook 1.0

ApplicationWindow {
    id: root

    width: 1450
    height: 840
    visible: true

    property string currentPage

    font.pixelSize: 13

    HotReloader {
        id: reloader

        loader: viewLoader
        enabled: hotReloaderControls.enabled
        onReloaded: hotReloaderControls.notifyReload()
    }

    ListModel {
        id: pagesModel

        ListElement {
            title: "ProfileDialogView"

            figma: [
                ListElement {
                    link: "https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=733%3A12552"
                },
                ListElement {
                    link: "https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=682%3A15078"
                },
                ListElement {
                    link: "https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=682%3A17655"
                },
                ListElement {
                    link: "https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=682%3A17087"
                },
                ListElement {
                    link: "https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=4%3A23525"
                },
                ListElement {
                    link: "https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?node-id=4%3A23932"
                }
            ]
            section: "Views"
        }
        ListElement {
             title: "CommunitiesPortalLayout"

             figma: [
                 ListElement {
                     link: "https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A415655"
                 },
                 ListElement {
                     link: "https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A415935"
                 }
             ]
             section: "Views"
        }
        ListElement {
             title: "LoginView"
             section: "Views"
        }
        ListElement {
             title: "AboutView"
             section: "Views"
        }
        ListElement {
            title: "CommunityProfilePopupInviteFriendsPanel"
            section: "Panels"
        }
        ListElement {
            title: "CommunityProfilePopupInviteMessagePanel"
            section: "Panels"
        }
        ListElement {
             title: "StatusCommunityCard"

             figma: [
                 ListElement {
                     link: "https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A416159"
                 },
                 ListElement {
                     link: "https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A416160"
                 }
             ]
             section: "Panels"
        }
        ListElement {
            title: "InviteFriendsToCommunityPopup"
            section: "Popups"
        }
        ListElement {
             title: "CreateChannelPopup"
             section: "Popups"
        }
        ListElement {
            title: "LanguageCurrencySettings"
            section: "Settings"
        }
        ListElement {
             title: "BrowserSettings"
             section: "Settings"
        }
        ListElement {
            title: "UserListPanel"
        }
        ListElement {
             title: "ProfileFetchingView"
        }
        ListElement {
            title: "MembersSelector"
        }
    }

    SplitView {
        anchors.fill: parent

        Pane {
            SplitView.preferredWidth: 270

            ColumnLayout {
                width: parent.width
                height: parent.height

                Button {
                    Layout.fillWidth: true

                    text: "Settings"

                    onClicked: settingsPopup.open()
                }

                CheckBox {
                    id: darkModeCheckBox

                    Layout.fillWidth: true

                    text: "Dark mode"

                    StatusLightTheme { id: lightTheme }
                    StatusDarkTheme { id: darkTheme }

                    Binding {
                        target: Theme
                        property: "palette"
                        value: darkModeCheckBox.checked ? darkTheme : lightTheme
                    }
                }

                HotReloaderControls {
                    id: hotReloaderControls

                    Layout.fillWidth: true

                    onForceReloadClicked: reloader.forceReload()
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                FilteredPagesList {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    currentPage: root.currentPage
                    model: pagesModel

                    onPageSelected: root.currentPage = page
                }
            }
        }

        Page {
            SplitView.fillWidth: true

            Loader {
                id: viewLoader

                anchors.fill: parent
                clip: true

                source: `pages/${root.currentPage}Page.qml`
                asynchronous: settingsLayout.loadAsynchronously
                visible: status === Loader.Ready

                // force reload when `asynchronous` changes
                onAsynchronousChanged: {
                    active = false
                    active = true
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                visible: viewLoader.status === Loader.Loading
            }

            Label {
                anchors.centerIn: parent
                visible: viewLoader.status === Loader.Error
                text: "Loading page failed"
            }

            footer: PageToolBar {
                id: pageToolBar

                title: `pages/${root.currentPage}Page.qml`
                figmaPagesCount: currentPageModelItem.object
                                 ? currentPageModelItem.object.figmaCount : 0

                Instantiator {
                    id: currentPageModelItem

                    model: SingleItemProxyModel {
                        sourceModel: pagesModel
                        roleName: "title"
                        value: root.currentPage
                    }

                    delegate: QtObject {
                        readonly property string title: model.title
                        readonly property var figma: model.figma
                        readonly property int figmaCount: figma ? figma.count : 0
                    }
                }

                onFigmaPreviewClicked: {
                    if (!settingsLayout.figmaToken) {
                        noFigmaTokenDialog.open()
                        return
                    }

                    const window = figmaWindow.createObject(root, {
                        figmaModel: currentPageModelItem.object.figma,
                        title: currentPageModelItem.object.title + " - Figma"
                    })
                }
            }
        }
    }

    Dialog {
        id: settingsPopup

        anchors.centerIn: Overlay.overlay
        width: 420
        modal: true

        header: Pane {
            background: null

            Label {
                text: "Settings"
            }
        }

        SettingsLayout {
            id: settingsLayout

            width: parent.width
        }
    }

    Dialog {
        id: noFigmaTokenDialog

        anchors.centerIn: Overlay.overlay

        title: "Figma token not set"
        standardButtons: Dialog.Ok

        Label {
            text: "Please set Figma personal token in \"Settings\""
        }
    }

    FigmaLinksCache {
        id: figmaImageLinksCache

        figmaToken: settingsLayout.figmaToken
    }

    Component {
        id: figmaWindow

        FigmaPreviewWindow {
            property alias figmaModel: figmaImagesProxyModel.sourceModel

            model: FigmaImagesProxyModel {
                id: figmaImagesProxyModel

                figmaLinksCache: figmaImageLinksCache
            }

            onClosing: Qt.callLater(destroy)
        }
    }

    Settings {
        property alias currentPage: root.currentPage
        property alias loadAsynchronously: settingsLayout.loadAsynchronously
        property alias darkMode: darkModeCheckBox.checked
        property alias hotReloading: hotReloaderControls.enabled
        property alias figmaToken: settingsLayout.figmaToken
    }
}
