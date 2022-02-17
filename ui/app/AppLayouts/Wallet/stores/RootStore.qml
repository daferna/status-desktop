pragma Singleton

import QtQuick 2.13

QtObject {
    id: root
    property var currentAccount: walletSectionCurrent
    property var accounts: walletSectionAccounts.model
    property var appSettings: localAppSettings
    property var accountSensitiveSettings: localAccountSensitiveSettings
    property string locale: appSettings.locale
    property bool hideSignPhraseModal: accountSensitiveSettings.hideSignPhraseModal
    property bool isMultiNetworkEnabled: accountSensitiveSettings.isMultiNetworkEnabled

    property string currentCurrency: walletSection.currentCurrency
    property string totalCurrencyBalance: walletSection.totalCurrencyBalance
    property string signingPhrase: walletSection.signingPhrase
    property string mnemonicBackedUp: walletSection.isMnemonicBackedUp

    property var walletTokensModule: walletSectionAllTokens
    property var defaultTokenList: walletSectionAllTokens.default
    property var customTokenList: walletSectionAllTokens.custom
    property var tokens: walletSectionAllTokens.all

    property var assets: walletSectionAccountTokens.model

    property CollectiblesStore collectiblesStore: CollectiblesStore { }
    property var collectionList: walletSectionCollectiblesCollections.model

    property var history: walletSectionTransactions
    property var historyTransactions: walletSectionTransactions.model
    property bool isNonArchivalNode:  history.isNonArchivalNode

    property var savedAddresses: walletSectionSavedAddresses.model


    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test
    property var enabledNetworks: networksModule.enabled

    // This should be exposed to the UI via "walletModule", WalletModule should use
    // Accounts Service which keeps the info about that (isFirstTimeAccountLogin).
    // Then in the View of WalletModule we may have either QtProperty or
    // Q_INVOKABLE function (proc marked as slot) depends on logic/need.
    // The only need for onboardingModel here is actually to check if an account
    // has been just created or an old one.

    //property bool firstTimeLogin: onboardingModel.isFirstTimeLogin

    // example wallet model
    property ListModel exampleWalletModel: ListModel {
        ListElement {
            name: "Status account"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            balance: "12.00 USD"
            color: "#7CDA00"
        }

        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            color: "#FA6565"
        }
        ListElement {
            name: "Status account"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            color: "#7CDA00"
        }
    }

    property ListModel exampleAssetModel: ListModel {
        ListElement {
            name: "Ethereum"
            symbol: "ETH"
            balance: "3423 ETH"
            address: "token-icons/eth"
            currencyBalance: "123 USD"
        }
    }

    function setHideSignPhraseModal(value) {
        localAccountSensitiveSettings.hideSignPhraseModal = value;
    }

    function getLatestBlockNumber() {
        // TODO: Move to transaction root module and not wallet
        // Not Refactored Yet
//        return walletModel.getLatestBlockNumber()
    }

    function setInitialRange() {
        // Not Refactored Yet
//        walletModel.setInitialRange()
    }

    function switchAccount(newIndex) {
        walletSection.switchAccount(newIndex)
    }

    function generateNewAccount(password, accountName, color) {
        return walletSectionAccounts.generateNewAccount(password, accountName, color)
    }

    function addAccountsFromPrivateKey(privateKey, password, accountName, color) {
        return walletSectionAccounts.addAccountsFromPrivateKey(privateKey, password, accountName, color)
    }

    function addAccountsFromSeed(seedPhrase, password, accountName, color) {
        return walletSectionAccounts.addAccountsFromSeed(seedPhrase, password, accountName, color)
    }

    function addWatchOnlyAccount(address, accountName, color) {
        return walletSectionAccounts.addWatchOnlyAccount(address, accountName, color)
    }

    function deleteAccount(address) {
        return walletSectionAccounts.deleteAccount(address)
    }

    function updateCurrentAccount(address, accountName, color) {
        return walletSectionCurrent.update(address, accountName, color)
    }

    function updateCurrency(newCurrency) {
        walletSection.updateCurrency(newCurrency)
    }

    function addCustomToken(chainId, address, name, symbol, decimals) {
        return walletSectionAllTokens.addCustomToken(chainId, address, name, symbol, decimals)
    }

    function toggleVisible(chainId, symbol) {
        walletSectionAllTokens.toggleVisible(chainId, symbol)
    }

    function removeCustomToken(chainId, address) {
        walletSectionAllTokens.removeCustomToken(chainId, address)
    }

    function getQrCode(address) {
        return globalUtils.qrCode(address)
    }

    function hex2Dec(value) {
        return globalUtils.hex2Dec(value)
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }

    function checkRecentHistory() {
        history.checkRecentHistory()
    }

    function isFetchingHistory() {
        return history.isFetchingHistory(currentAccount.address)
    }

    function loadTransactionsForAccount(pageSize) {
        history.loadTransactionsForAccount(currentAccount.address,
                                            historyTransactions.getLastTxBlockNumber(),
                                            pageSize, true)
    }

    function fetchCollectionCollectiblesList(slug) {
        walletSectionCollectiblesCollectibles.fetch(slug)
    }

    function getCollectionCollectiblesList(slug) {
        return walletSectionCollectiblesCollectibles.getModelForCollection(slug)
    }

    function getCollectionMaxValue(traitType, value, maxValue, collectionIndex) {
        // Not Refactored Yet
//        if(maxValue !== "")
//            return parseInt(value) + qsTr(" of ") + maxValue;
//        else
//            return parseInt(value) + qsTr(" of ") +
//            walletModelV2Inst.collectiblesView.collections.getCollectionTraitMaxValue(collectionIndex, traitType).toString();
    }

    function createOrUpdateSavedAddress(name, address) {
        walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address)
    }

    function deleteSavedAddress(address) {
        walletSectionSavedAddresses.deleteSavedAddress(address)
    }

    function toggleNetwork(chainId) {
        networksModule.toggleNetwork(chainId)
    }
}
