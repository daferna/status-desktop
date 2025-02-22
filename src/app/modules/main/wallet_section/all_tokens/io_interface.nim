type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method findTokenSymbolByAddress*(self: AccessInterface, address: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getHistoricalDataForToken*(self: AccessInterface, symbol: string, currency: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method tokenHistoricalDataResolved*(self: AccessInterface, tokenDetails: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchHistoricalBalanceForTokenAsJson*(self: AccessInterface, address: string, tokenSymbol: string, currencySymbol: string, timeIntervalEnum: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method tokenBalanceHistoryDataResolved*(self: AccessInterface, balanceHistoryJson: string) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
