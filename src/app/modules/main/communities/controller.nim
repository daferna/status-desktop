import stint, std/strutils
import ./io_interface

import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../../app_service/service/chat/dto/chat
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/network/service as networks_service
import ../../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import backend/collectibles as backend_collectibles
import ../../shared_modules/keycard_popup/io_interface as keycard_shared_module

const UNIQUE_COMMUNITIES_MODULE_AUTH_IDENTIFIER* = "CommunitiesModule-Action-Authentication"

type
  AuthenticationAction* {.pure.} = enum
    None = 0,
    CommunityJoin = 1,
    CommunitySharedAddressesJoin = 2,

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    communityService: community_service.Service
    contactsService: contacts_service.Service
    communityTokensService: community_tokens_service.Service
    networksService: networks_service.Service
    tokenService: token_service.Service
    chatService: chat_service.Service
    tmpCommunityId: string
    tmpAuthenticationAction: AuthenticationAction
    tmpRequestToJoinEnsName: string
    tmpAddressesToShare: seq[string]
    tmpAirdropAddress: string
    tmpAuthenticationWithCallbackInProgress: bool

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service,
    contactsService: contacts_service.Service,
    communityTokensService: community_tokens_service.Service,
    networksService: networks_service.Service,
    tokenService: token_service.Service,
    chatService: chat_service.Service,
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.communityService = communityService
  result.contactsService = contactsService
  result.communityTokensService = communityTokensService
  result.networksService = networksService
  result.tokenService = tokenService
  result.chatService = chatService
  result.tmpCommunityId = ""
  result.tmpRequestToJoinEnsName = ""
  result.tmpAirdropAddress = ""
  result.tmpAddressesToShare = @[]
  result.tmpAuthenticationWithCallbackInProgress = false

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_COMMUNITY_DATA_LOADED) do(e:Args):
    self.delegate.communityDataLoaded()

  self.events.on(SIGNAL_COMMUNITY_CREATED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityAdded(args.community)

  self.events.on(SIGNAL_COMMUNITY_DATA_IMPORTED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityDataImported(args.community)

  self.events.on(SIGNAL_COMMUNITY_LOAD_DATA_FAILED) do(e: Args):
    let args = CommunityArgs(e)
    self.delegate.onImportCommunityErrorOccured(args.community.id, args.error)

  self.events.on(SIGNAL_COMMUNITY_INFO_ALREADY_REQUESTED) do(e: Args):
    self.delegate.communityInfoAlreadyRequested()

  self.events.on(SIGNAL_CURATED_COMMUNITY_FOUND) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.curatedCommunityAdded(args.community)

  self.events.on(SIGNAL_COMMUNITY_ADDED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityAdded(args.community)

  self.events.on(SIGNAL_COMMUNITY_PRIVATE_KEY_REMOVED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityEdited(args.community)
    self.delegate.communityPrivateKeyRemoved(args.community.id)

  self.events.on(SIGNAL_COMMUNITY_IMPORTED) do(e:Args):
    let args = CommunityArgs(e)
    if(args.error.len > 0):
      self.delegate.onImportCommunityErrorOccured(args.community.id, args.error)
    else:
      self.delegate.communityImported(args.community)

  self.events.on(SIGNAL_COMMUNITIES_UPDATE) do(e:Args):
    let args = CommunitiesArgs(e)
    for community in args.communities:
      self.delegate.communityEdited(community)
      self.delegate.curatedCommunityEdited(community)

  self.events.on(SIGNAL_COMMUNITY_MUTED) do(e:Args):
    let args = CommunityMutedArgs(e)
    self.delegate.communityMuted(args.communityId, args.muted)

  self.events.on(SIGNAL_COMMUNITY_MY_REQUEST_ADDED) do(e:Args):
    let args = CommunityRequestArgs(e)
    self.delegate.communityAccessRequested(args.communityRequest.communityId)

  self.events.on(SIGNAL_COMMUNITY_MY_REQUEST_FAILED) do(e:Args):
    let args = CommunityRequestFailedArgs(e)
    self.delegate.communityAccessFailed(args.communityId, args.error)

  self.events.on(SIGNAL_COMMUNITY_EDIT_SHARED_ADDRESSES_SUCCEEDED) do(e:Args):
    let args = CommunityIdArgs(e)
    self.delegate.communityEditSharedAddressesSucceeded(args.communityId)

  self.events.on(SIGNAL_COMMUNITY_EDIT_SHARED_ADDRESSES_FAILED) do(e:Args):
    let args = CommunityRequestFailedArgs(e)
    self.delegate.communityEditSharedAddressesFailed(args.communityId, args.error)

  self.events.on(SIGNAL_DISCORD_CATEGORIES_AND_CHANNELS_EXTRACTED) do(e:Args):
    let args = DiscordCategoriesAndChannelsArgs(e)
    self.delegate.discordCategoriesAndChannelsExtracted(args.categories, args.channels, args.oldestMessageTimestamp, args.errors, args.errorsCount)

  self.events.on(SIGNAL_DISCORD_COMMUNITY_IMPORT_PROGRESS) do(e:Args):
    let args = DiscordImportProgressArgs(e)
    self.delegate.discordImportProgressUpdated(args.communityId, args.communityName, args.communityImage, args.tasks, args.progress, args.errorsCount, args.warningsCount, args.stopped, args.totalChunksCount, args.currentChunk)

  self.events.on(SIGNAL_COMMUNITY_HISTORY_ARCHIVES_DOWNLOAD_STARTED) do(e:Args):
    let args = CommunityIdArgs(e)
    self.delegate.communityHistoryArchivesDownloadStarted(args.communityId)

  self.events.on(SIGNAL_COMMUNITY_HISTORY_ARCHIVES_DOWNLOAD_FINISHED) do(e:Args):
    let args = CommunityIdArgs(e)
    self.delegate.communityHistoryArchivesDownloadFinished(args.communityId)

  self.events.on(SIGNAL_CURATED_COMMUNITIES_LOADING) do(e:Args):
    self.delegate.curatedCommunitiesLoading()

  self.events.on(SIGNAL_CURATED_COMMUNITIES_LOADING_FAILED) do(e:Args):
    self.delegate.curatedCommunitiesLoadingFailed()

  self.events.on(SIGNAL_CURATED_COMMUNITIES_LOADED) do(e:Args):
    let args = CommunitiesArgs(e)
    self.delegate.curatedCommunitiesLoaded(args.communities)

  self.events.on(SIGNAL_COMMUNITY_TOKEN_METADATA_ADDED) do(e: Args):
    let args = CommunityTokenMetadataArgs(e)
    self.delegate.onCommunityTokenMetadataAdded(args.communityId, args.tokenMetadata)

  self.events.on(SignalType.Wallet.event, proc(e: Args) =
    var data = WalletSignal(e)
    if data.eventType == backend_collectibles.eventCollectiblesOwnershipUpdateFinished:
      self.delegate.onOwnedCollectiblesUpdated()
  )

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e: Args):
    self.delegate.onWalletAccountTokensRebuilt()

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_COMMUNITIES_MODULE_AUTH_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.pin, args.password, args.keyUid)
    if self.tmpAuthenticationWithCallbackInProgress:
      let authenticated = not (args.password == "" and args.pin == "")
      self.delegate.callbackFromAuthentication(authenticated)
      self.tmpAuthenticationWithCallbackInProgress = false

proc getCommunityTags*(self: Controller): string =
  result = self.communityService.getCommunityTags()

proc getAllCommunities*(self: Controller): seq[CommunityDto] =
  result = self.communityService.getAllCommunities()

proc getCommunityById*(self: Controller, communityId: string): CommunityDto =
  result = self.communityService.getCommunityById(communityId)

proc getCuratedCommunities*(self: Controller): seq[CommunityDto] =
  result = self.communityService.getCuratedCommunities()

proc spectateCommunity*(self: Controller, communityId: string): string =
  self.communityService.spectateCommunity(communityId)

proc cancelRequestToJoinCommunity*(self: Controller, communityId: string) =
  self.communityService.cancelRequestToJoinCommunity(communityId)

proc createCommunity*(
    self: Controller,
    name: string,
    description: string,
    introMessage: string,
    outroMessage: string,
    access: int,
    color: string,
    tags: string,
    imageUrl: string,
    aX: int, aY: int, bX: int, bY: int,
    historyArchiveSupportEnabled: bool,
    pinMessageAllMembersEnabled: bool,
    bannerJsonStr: string) =
  self.communityService.createCommunity(
    name,
    description,
    introMessage,
    outroMessage,
    access,
    color,
    tags,
    imageUrl,
    aX, aY, bX, bY,
    historyArchiveSupportEnabled,
    pinMessageAllMembersEnabled,
    bannerJsonStr)

proc requestImportDiscordCommunity*(
    self: Controller,
    name: string,
    description: string,
    introMessage: string,
    outroMessage: string,
    access: int,
    color: string,
    tags: string,
    imageUrl: string,
    aX: int, aY: int, bX: int, bY: int,
    historyArchiveSupportEnabled: bool,
    pinMessageAllMembersEnabled: bool,
    filesToImport: seq[string],
    fromTimestamp: int) =
  self.communityService.requestImportDiscordCommunity(
    name,
    description,
    introMessage,
    outroMessage,
    access,
    color,
    tags,
    imageUrl,
    aX, aY, bX, bY,
    historyArchiveSupportEnabled,
    pinMessageAllMembersEnabled,
    filesToImport,
    fromTimestamp)

proc reorderCommunityChat*(
    self: Controller,
    communityId: string,
    categoryId: string,
    chatId: string,
    position: int) =
  self.communityService.reorderCommunityChat(
    communityId,
    categoryId,
    chatId,
    position)

proc getChatDetailsByIds*(self: Controller, chatIds: seq[string]): seq[ChatDto] =
  return self.chatService.getChatsByIds(chatIds)

proc requestCommunityInfo*(self: Controller, communityId: string, importing: bool) =
  self.communityService.requestCommunityInfo(communityId, importing)

proc removePrivateKey*(self: Controller, communityId: string) =
  self.communityService.removePrivateKey(communityId)

proc importCommunity*(self: Controller, communityKey: string) =
  self.communityService.asyncImportCommunity(communityKey)

proc setCommunityMuted*(self: Controller, communityId: string, mutedType: int) =
  self.communityService.setCommunityMuted(communityId, mutedType)

proc getContactNameAndImage*(self: Controller, contactId: string):
    tuple[name: string, image: string, largeImage: string] =
  return self.contactsService.getContactNameAndImage(contactId)

proc getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactsService.getContactDetails(contactId)

proc isUserMemberOfCommunity*(self: Controller, communityId: string): bool =
  return self.communityService.isUserMemberOfCommunity(communityId)

proc userCanJoin*(self: Controller, communityId: string): bool =
  return self.communityService.userCanJoin(communityId)

proc isCommunityRequestPending*(self: Controller, communityId: string): bool =
  return self.communityService.isCommunityRequestPending(communityId)

proc asyncLoadCuratedCommunities*(self: Controller) =
  self.communityService.asyncLoadCuratedCommunities()

proc getStatusForContactWithId*(self: Controller, publicKey: string): StatusUpdateDto =
  return self.contactsService.getStatusForContactWithId(publicKey)

proc requestExtractDiscordChannelsAndCategories*(self: Controller, filesToImport: seq[string]) =
  self.communityService.requestExtractDiscordChannelsAndCategories(filesToImport)

proc requestCancelDiscordCommunityImport*(self: Controller, id: string) =
  self.communityService.requestCancelDiscordCommunityImport(id)

proc getCommunityTokens*(self: Controller, communityId: string): seq[CommunityTokenDto] =
  self.communityTokensService.getCommunityTokens(communityId)

proc getNetwork*(self:Controller, chainId: int): NetworkDto =
  self.networksService.getNetwork(chainId)

proc getTokenList*(self: Controller): seq[TokenDto] =
  return self.tokenService.getTokenList()

proc shareCommunityUrlWithChatKey*(self: Controller, communityId: string): string =
  return self.communityService.shareCommunityUrlWithChatKey(communityId)

proc shareCommunityUrlWithData*(self: Controller, communityId: string): string =
  return self.communityService.shareCommunityUrlWithData(communityId)

proc shareCommunityChannelUrlWithChatKey*(self: Controller, communityId: string, chatId: string): string =
  return self.communityService.shareCommunityChannelUrlWithChatKey(communityId, chatId)

proc shareCommunityChannelUrlWithData*(self: Controller, communityId: string, chatId: string): string =
  return self.communityService.shareCommunityChannelUrlWithData(communityId, chatId)

proc userAuthenticationCanceled*(self: Controller) =
  self.tmpAuthenticationAction = AuthenticationAction.None
  self.tmpCommunityId = ""
  self.tmpRequestToJoinEnsName = ""
  self.tmpAirdropAddress = ""
  self.tmpAddressesToShare = @[]

proc requestToJoinCommunityAuthenticated*(self: Controller, password: string) =
  self.communityService.asyncRequestToJoinCommunity(
    self.tmpCommunityId,
    self.tmpRequestToJoinEnsName,
    password,
    self.tmpAddressesToShare,
    self.tmpAirdropAddress
  )
  self.tmpAuthenticationAction = AuthenticationAction.None
  self.tmpCommunityId = ""
  self.tmpRequestToJoinEnsName = ""
  self.tmpAirdropAddress = ""
  self.tmpAddressesToShare = @[]

proc editSharedAddressesAuthenticated*(self: Controller, password: string) =
  self.communityService.asyncEditSharedAddresses(
    self.tmpCommunityId,
    password,
    self.tmpAddressesToShare,
    self.tmpAirdropAddress,
  )
  self.tmpAuthenticationAction = AuthenticationAction.None
  self.tmpCommunityId = ""
  self.tmpAirdropAddress = ""
  self.tmpAddressesToShare = @[]

proc userAuthenticated*(self: Controller, password: string) =
  if self.tmpAuthenticationAction == AuthenticationAction.CommunityJoin:
    self.requestToJoinCommunityAuthenticated(password)
  elif self.tmpAuthenticationAction == AuthenticationAction.CommunitySharedAddressesJoin:
    self.editSharedAddressesAuthenticated(password)

proc authenticate*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_COMMUNITIES_MODULE_AUTH_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc authenticateToRequestToJoinCommunity*(self: Controller, communityId: string, ensName: string, addressesToShare: seq[string], airdropAddress: string) =
  self.tmpCommunityId = communityId
  self.tmpAuthenticationAction = AuthenticationAction.CommunityJoin
  self.tmpRequestToJoinEnsName = ensName
  self.tmpAirdropAddress = airdropAddress
  self.tmpAddressesToShare = addressesToShare
  self.authenticate()

proc authenticateToEditSharedAddresses*(self: Controller, communityId: string, addressesToShare: seq[string], airdropAddress: string) =
  self.tmpCommunityId = communityId
  self.tmpAuthenticationAction = AuthenticationAction.CommunitySharedAddressesJoin
  self.tmpAirdropAddress = airdropAddress
  self.tmpAddressesToShare = addressesToShare
  self.authenticate()

proc authenticateWithCallback*(self: Controller) =
  self.tmpAuthenticationWithCallbackInProgress = true
  self.authenticate()

proc getCommunityPublicKeyFromPrivateKey*(self: Controller, communityPrivateKey: string): string =
  result = self.communityService.getCommunityPublicKeyFromPrivateKey(communityPrivateKey)
