import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    property var walletModule
    property var accountsModule: root.walletModule.accountsModule
    property var networksModule: root.walletModule.networksModule

    property var accountSensitiveSettings: Global.appIsReady? localAccountSensitiveSettings : null

    readonly property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    readonly property var networks: networksModule.networks
    readonly property var combinedNetworks: networksModule.combinedNetworks
    property var selectedAccount

    function toggleTestNetworksEnabled(){
        networksModule.toggleTestNetworksEnabled()
    }

    // TODO(alaibe): there should be no access to wallet section, create collectible in profile
    property var overview: walletSectionOverview
    property var assets: walletSectionAssets.assets
    property var collectibles: Global.appIsReady ? walletSection.collectiblesController.model : null // To-do: Fetch profile collectibles separately
    property var accounts: Global.appIsReady? accountsModule.accounts : null
    property var originModel: accountsModule.keyPairModel
    property bool includeWatchOnlyAccount: accountsModule.includeWatchOnlyAccount

    function toggleIncludeWatchOnlyAccount() {
       accountsModule.toggleIncludeWatchOnlyAccount()
    }

    property string userProfilePublicKey: userProfile.pubKey
    
    function deleteAccount(address) {
        return accountsModule.deleteAccount(address)
    }

    function deleteKeypair(keyUid) {
        return accountsModule.deleteKeypair(keyUid)
    }

    function updateAccount(address, accountName, colorId, emoji) {
        return accountsModule.updateAccount(address, accountName, colorId, emoji)
    }

    function moveAccount(from, to) {
        root.accountsModule.moveAccount(from, to)
    }

    function moveAccountFinally(from, to) {
        root.accountsModule.moveAccountFinally(from, to)
    }

    function getAllNetworksChainIds() {
        return networksModule.getAllNetworksChainIds()
    }

    function runAddAccountPopup() {
        // TODO:
        // - `runAddAccountPopup` should be part of `root.walletModule`
        // - `AddAccountPopup {}` should be moved from `MainView` to `WalletView`
        // - `Edit account` popup opened from the wallet settings should be the same as one opened from the wallet section
        // - `walletSection` should not be used in the context of wallet settings
        walletSection.runAddAccountPopup(false)
    }

    function runKeypairImportPopup(keyUid, importOption) {
        root.walletModule.runKeypairImportPopup(keyUid, importOption)
    }

    function evaluateRpcEndPoint(url) {
        return networksModule.fetchChainIdForUrl(url)
    }

    function updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl) {
        networksModule.updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl)
    }

    function updateWalletAccountPreferredChains(address, preferredChainIds) {
        if(areTestNetworksEnabled) {
            accountsModule.updateWalletAccountTestPreferredChains(address, preferredChainIds)
        }
        else {
            accountsModule.updateWalletAccountProdPreferredChains(address, preferredChainIds)
        }
    }

    function getNetworkShortNames(chainIds) {
       return networksModule.getNetworkShortNames(chainIds)
    }

    function processPreferredSharingNetworkToggle(preferredSharingNetworks, toggledNetwork) {
        let prefChains = preferredSharingNetworks
        if(prefChains.length === networks.count) {
            prefChains = [toggledNetwork.chainId.toString()]
        }
        else if(!prefChains.includes(toggledNetwork.chainId.toString())) {
            prefChains.push(toggledNetwork.chainId.toString())
        }
        else {
            if(prefChains.length === 1) {
                prefChains = getAllNetworksChainIds().split(":")
            }
            else {
                for(var i = 0; i < prefChains.length;i++) {
                    if(prefChains[i] === toggledNetwork.chainId.toString()) {
                        prefChains.splice(i, 1)
                    }
                }
            }
        }
        return prefChains
    }

    function copyToClipboard(textToCopy) {
        globalUtils.copyToClipboard(textToCopy)
    }

    function getNetworkData(combinedNetwork) {
        return {
            prod: {chainId: combinedNetwork.prod.chainId,
                layer: combinedNetwork.prod.layer,
                chainName: combinedNetwork.prod.chainName,
                iconUrl: combinedNetwork.prod.iconUrl,
                shortName: combinedNetwork.prod.shortName,
                chainColor: combinedNetwork.prod.chainColor,
                rpcURL: combinedNetwork.prod.rpcURL,
                fallbackURL: combinedNetwork.prod.fallbackURL,
                blockExplorerURL: combinedNetwork.prod.blockExplorerURL,
                nativeCurrencySymbol: combinedNetwork.prod.nativeCurrencySymbol},
            test: {chainId: combinedNetwork.test.chainId,
                layer: combinedNetwork.test.layer,
                chainName: combinedNetwork.test.chainName,
                iconUrl: combinedNetwork.test.iconUrl,
                shortName: combinedNetwork.test.shortName,
                chainColor: combinedNetwork.test.chainColor,
                rpcURL: combinedNetwork.test.rpcURL,
                fallbackURL: combinedNetwork.test.fallbackURL,
                blockExplorerURL: combinedNetwork.test.blockExplorerURL,
                nativeCurrencySymbol: combinedNetwork.test.nativeCurrencySymbol},
            layer: combinedNetwork.layer
        }
    }
}
