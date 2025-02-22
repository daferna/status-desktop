import NimQml, chronicles, sequtils, sugar

import ./controller, ./view, ./filter
import ./io_interface as io_interface
import ../io_interface as delegate_interface

import ./accounts/module as accounts_module
import ./all_tokens/module as all_tokens_module
import ./assets/module as assets_module
import ./saved_addresses/module as saved_addresses_module
import ./buy_sell_crypto/module as buy_sell_crypto_module
import ./networks/module as networks_module
import ./overview/module as overview_module
import ./send/module as send_module
import ../../shared_modules/add_account/module as add_account_module

import ./activity/controller as activityc
import ./collectibles/controller as collectiblesc
import ./collectible_details/controller as collectible_detailsc

import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/currency/service as currency_service
import ../../../../app_service/service/transaction/service as transaction_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/saved_address/service as saved_address_service
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/node/service as node_service
import ../../../../app_service/service/network_connection/service as network_connection_service

logScope:
  topics = "wallet-section-module"

export io_interface

type
  ActivityID = enum
    History
    Temporary

  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    moduleLoaded: bool
    controller: controller.Controller
    view: View
    filter: Filter

    accountsModule: accounts_module.AccessInterface
    allTokensModule: all_tokens_module.AccessInterface
    assetsModule: assets_module.AccessInterface
    sendModule: send_module.AccessInterface
    savedAddressesModule: saved_addresses_module.AccessInterface
    buySellCryptoModule: buy_sell_crypto_module.AccessInterface
    addAccountModule: add_account_module.AccessInterface
    overviewModule: overview_module.AccessInterface
    networksModule: networks_module.AccessInterface
    networksService: network_service.Service
    transactionService: transaction_service.Service
    keycardService: keycard_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service

    activityController: activityc.Controller
    collectiblesController: collectiblesc.Controller
    collectibleDetailsController: collectible_detailsc.Controller
    # instance to be used in temporary, short-lived, workflows (e.g. send popup)
    tmpActivityController: activityc.Controller

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  savedAddressService: saved_address_service.Service,
  networkService: network_service.Service,
  accountsService: accounts_service.Service,
  keycardService: keycard_service.Service,
  nodeService: node_service.Service,
  networkConnectionService: network_connection_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.moduleLoaded = false
  result.controller = newController(result, settingsService, walletAccountService, currencyService, networkService)

  result.accountsModule = accounts_module.newModule(result, events, walletAccountService, networkService, currencyService)
  result.allTokensModule = all_tokens_module.newModule(result, events, tokenService, walletAccountService)
  result.assetsModule = assets_module.newModule(result, events, walletAccountService, networkService, tokenService, currencyService)
  result.sendModule = send_module.newModule(result, events, walletAccountService, networkService, currencyService, transactionService)
  result.savedAddressesModule = saved_addresses_module.newModule(result, events, savedAddressService)
  result.buySellCryptoModule = buy_sell_crypto_module.newModule(result, events, transactionService)
  result.overviewModule = overview_module.newModule(result, events, walletAccountService, currencyService)
  result.networksModule = networks_module.newModule(result, events, networkService, walletAccountService, settingsService)
  result.networksService = networkService

  result.transactionService = transactionService
  result.activityController = activityc.newController(int32(ActivityID.History), currencyService, tokenService, events)
  result.tmpActivityController = activityc.newController(int32(ActivityID.Temporary), currencyService, tokenService, events)
  result.collectiblesController = collectiblesc.newController(events)
  result.collectibleDetailsController = collectible_detailsc.newController(networkService, events)
  result.filter = initFilter(result.controller)

  result.view = newView(result, result.activityController, result.tmpActivityController, result.collectiblesController, result.collectibleDetailsController)

method delete*(self: Module) =
  self.accountsModule.delete
  self.allTokensModule.delete
  self.assetsModule.delete
  self.savedAddressesModule.delete
  self.buySellCryptoModule.delete
  self.sendModule.delete
  self.controller.delete
  self.view.delete
  self.activityController.delete
  self.tmpActivityController.delete
  self.collectiblesController.delete
  self.collectibleDetailsController.delete

  if not self.addAccountModule.isNil:
    self.addAccountModule.delete

method updateCurrency*(self: Module, currency: string) =
  self.controller.updateCurrency(currency)

method getCurrentCurrency*(self: Module): string =
  self.controller.getCurrency()

method setTotalCurrencyBalance*(self: Module) =
  var addresses: seq[string] = @[]
  let walletAccounts = self.controller.getWalletAccounts()
  if self.controller.isIncludeWatchOnlyAccount():
    addresses = walletAccounts.map(a => a.address)
  else:
    addresses = walletAccounts.filter(a => a.walletType != "watch").map(a => a.address)

  self.view.setTotalCurrencyBalance(self.controller.getCurrencyBalance(addresses))

method notifyFilterChanged(self: Module) =
  let includeWatchOnly = self.controller.isIncludeWatchOnlyAccount()
  self.overviewModule.filterChanged(self.filter.addresses, self.filter.chainIds, includeWatchOnly, self.filter.allAddresses)
  self.assetsModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.accountsModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.sendModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.activityController.globalFilterChanged(self.filter.addresses, self.filter.chainIds)
  self.collectiblesController.globalFilterChanged(self.filter.addresses, self.filter.chainIds)
  if self.filter.addresses.len > 0:
    self.view.filterChanged(self.filter.addresses[0], includeWatchOnly, self.filter.allAddresses)

method getCurrencyAmount*(self: Module, amount: float64, symbol: string): CurrencyAmount =
  return self.controller.getCurrencyAmount(amount, symbol)

method toggleWatchOnlyAccounts*(self: Module) =
  self.filter.toggleWatchOnlyAccounts()

method setFilterAddress*(self: Module, address: string) =
  self.filter.setAddress(address)
  self.notifyFilterChanged()

method setFillterAllAddresses*(self: Module) =
  self.filter.setFillterAllAddresses()
  self.notifyFilterChanged()

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSection", newQVariant(self.view))

  self.events.on(SIGNAL_KEYPAIR_SYNCED) do(e: Args):
    let args = KeypairArgs(e)
    self.setTotalCurrencyBalance()
    for acc in args.keypair.accounts:
      if acc.removed:
        self.filter.removeAddress(acc.address)
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    let args = AccountArgs(e)
    self.setTotalCurrencyBalance()
    self.filter.setAddress(args.account.address)
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    let args = AccountArgs(e)
    self.setTotalCurrencyBalance()
    self.filter.removeAddress(args.account.address)
    self.view.emitWalletAccountRemoved(args.account.address)
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.filter.updateNetworks()
    self.setTotalCurrencyBalance()
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.setTotalCurrencyBalance()
    self.notifyFilterChanged()
  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.setTotalCurrencyBalance()
    self.notifyFilterChanged()
  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_POSITION_UPDATED) do(e:Args):
    self.notifyFilterChanged()
  self.events.on(SIGNAL_INCLUDE_WATCH_ONLY_ACCOUNTS_UPDATED) do(e: Args):
    self.filter.includeWatchOnlyToggled()
    self.notifyFilterChanged()
    self.setTotalCurrencyBalance()
  self.events.on(SIGNAL_HISTORY_NON_ARCHIVAL_NODE) do (e:Args):
    self.view.setIsNonArchivalNode(true)
  self.events.on(SIGNAL_TRANSACTION_DECODED) do(e: Args):
    let args = TransactionDecodedArgs(e)
    self.view.txDecoded(args.txHash, args.dataDecoded)

  self.controller.init()
  self.view.load()
  self.accountsModule.load()
  self.allTokensModule.load()
  self.assetsModule.load()
  self.savedAddressesModule.load()
  self.buySellCryptoModule.load()
  self.overviewModule.load()
  self.sendModule.load()
  self.networksModule.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if(not self.accountsModule.isLoaded()):
    return

  if(not self.allTokensModule.isLoaded()):
    return

  if(not self.assetsModule.isLoaded()):
    return

  if(not self.savedAddressesModule.isLoaded()):
    return

  if(not self.buySellCryptoModule.isLoaded()):
    return

  if(not self.overviewModule.isLoaded()):
    return

  if(not self.sendModule.isLoaded()):
    return

  if(not self.networksModule.isLoaded()):
    return

  let signingPhrase = self.controller.getSigningPhrase()
  let mnemonicBackedUp = self.controller.isMnemonicBackedUp()
  self.view.setData(signingPhrase, mnemonicBackedUp)
  self.setTotalCurrencyBalance()
  self.filter.load()
  self.notifyFilterChanged()
  self.moduleLoaded = true
  self.delegate.walletSectionDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method accountsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method allTokensModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method collectiblesModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method assetsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method transactionsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method savedAddressesModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method buySellCryptoModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method overviewModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method sendModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method networksModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method destroyAddAccountPopup*(self: Module) =
  if self.addAccountModule.isNil:
    return

  self.view.emitDestroyAddAccountPopup()
  self.addAccountModule.delete
  self.addAccountModule = nil

method runAddAccountPopup*(self: Module, addingWatchOnlyAccount: bool) =
  self.destroyAddAccountPopup()
  self.addAccountModule = add_account_module.newModule(self, self.events, self.keycardService, self.accountsService,
    self.walletAccountService)
  self.addAccountModule.loadForAddingAccount(addingWatchOnlyAccount)

method runEditAccountPopup*(self: Module, address: string) =
  self.destroyAddAccountPopup()
  self.addAccountModule = add_account_module.newModule(self, self.events, self.keycardService, self.accountsService,
    self.walletAccountService)
  self.addAccountModule.loadForEditingAccount(address)

method getAddAccountModule*(self: Module): QVariant =
  if self.addAccountModule.isNil:
    return newQVariant()
  return self.addAccountModule.getModuleAsVariant()

method onAddAccountModuleLoaded*(self: Module) =
  self.view.emitDisplayAddAccountPopup()

method getNetworkLayer*(self: Module, chainId: int): string =
  return self.networksModule.getNetworkLayer(chainId)

method getChainIdForChat*(self: Module): int =
  return self.networksService.getNetworkForChat().chainId

method getLatestBlockNumber*(self: Module, chainId: int): string =
  return self.transactionService.getLatestBlockNumber(chainId)

method fetchDecodedTxData*(self: Module, txHash: string, data: string) =
  self.transactionService.fetchDecodedTxData(txHash, data)
