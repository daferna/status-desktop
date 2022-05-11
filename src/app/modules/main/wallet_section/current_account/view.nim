import NimQml, sequtils, sugar

import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ./io_interface
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      name: string
      address: string
      mixedcaseAddress: string
      path: string
      color: string
      publicKey: string
      walletType: string
      isChat: bool
      currencyBalance: float64
      assets: token_model.Model
      emoji: string

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getName(self: View): QVariant {.slot.} =
    return newQVariant(self.name)

  proc nameChanged(self: View) {.signal.}

  QtProperty[QVariant] name:
    read = getName
    notify = nameChanged

  proc getAddress(self: View): QVariant {.slot.} =
    return newQVariant(self.address)
  proc addressChanged(self: View) {.signal.}
  QtProperty[QVariant] address:
    read = getAddress
    notify = addressChanged

  proc getMixedcaseAddress(self: View): string {.slot.} =
    return self.mixedcaseAddress
  proc mixedcaseAddressChanged(self: View) {.signal.}
  QtProperty[string] mixedcaseAddress:
    read = getMixedcaseAddress
    notify = mixedcaseAddressChanged

  proc getPath(self: View): QVariant {.slot.} =
    return newQVariant(self.path)

  proc pathChanged(self: View) {.signal.}

  QtProperty[QVariant] path:
    read = getPath
    notify = pathChanged

  proc getColor(self: View): QVariant {.slot.} =
    return newQVariant(self.color)

  proc colorChanged(self: View) {.signal.}

  QtProperty[QVariant] color:
    read = getColor
    notify = colorChanged

  proc getPublicKey(self: View): QVariant {.slot.} =
    return newQVariant(self.publicKey)

  proc publicKeyChanged(self: View) {.signal.}

  QtProperty[QVariant] publicKey:
    read = getPublicKey
    notify = publicKeyChanged

  proc getWalletType(self: View): QVariant {.slot.} =
    return newQVariant(self.walletType)

  proc walletTypeChanged(self: View) {.signal.}

  QtProperty[QVariant] walletType:
    read = getWalletType
    notify = walletTypeChanged

  proc getIsChat(self: View): QVariant {.slot.} =
    return newQVariant(self.isChat)

  proc isChatChanged(self: View) {.signal.}

  QtProperty[QVariant] isChat:
    read = getIsChat
    notify = isChatChanged

  proc getCurrencyBalance(self: View): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)

  proc currencyBalanceChanged(self: View) {.signal.}

  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalance
    notify = currencyBalanceChanged

  proc getAssets(self: View): QVariant {.slot.} =
    return newQVariant(self.assets)

  proc assetsChanged(self: View) {.signal.}

  QtProperty[QVariant] assets:
    read = getAssets
    notify = assetsChanged

  proc getEmoji(self: View): QVariant {.slot.} =
    return newQVariant(self.emoji)

  proc emojiChanged(self: View) {.signal.}

  QtProperty[QVariant] emoji:
    read = getEmoji
    notify = emojiChanged

  proc update(self: View, address: string, accountName: string, color: string, emoji: string) {.slot.} =
    self.delegate.update(address, accountName, color, emoji)

  proc setData*(self: View, dto: wallet_account_service.WalletAccountDto) =
    if(self.name != dto.name):
      self.name = dto.name
      self.nameChanged()
    if(self.address != dto.address):
      self.address = dto.address
      self.addressChanged()
    if(self.mixedcaseAddress != dto.mixedcaseAddress):
      self.mixedcaseAddress = dto.mixedcaseAddress
      self.mixedcaseAddressChanged()
    if(self.path != dto.path):
      self.path = dto.path
      self.pathChanged()
    if(self.color != dto.color):
      self.color = dto.color
      self.colorChanged()
    if(self.publicKey != dto.publicKey):
      self.publicKey = dto.publicKey
      self.publicKeyChanged()
    if(self.walletType != dto.walletType):
      self.walletType = dto.walletType
      self.walletTypeChanged()
    if(self.isChat != dto.isChat):
      self.isChat = dto.isChat
      self.isChatChanged()
    if(self.currencyBalance != dto.getCurrencyBalance()):
      self.currencyBalance = dto.getCurrencyBalance()
      self.currencyBalanceChanged()
    if(self.emoji != dto.emoji):
      self.emoji = dto.emoji
      self.emojiChanged()

    let assets = token_model.newModel()

    assets.setItems(
      dto.tokens.map(t => token_item.initItem(
          t.name,
          t.symbol,
          t.balance,
          t.address,
          t.currencyBalance,
        ))
    )
    self.assets = assets
    self.assetsChanged()
