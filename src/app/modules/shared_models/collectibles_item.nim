import strformat, stint

type
  Item* = object
    chainId: int
    contractAddress: string
    tokenId: UInt256
    name: string
    mediaUrl: string
    mediaType: string
    imageUrl: string
    backgroundColor: string
    collectionName: string
    isLoading: bool
    isPinned: bool

proc initItem*(
  chainId: int,
  contractAddress: string,
  tokenId: UInt256,
  name: string,
  mediaUrl: string,
  mediaType: string,
  imageUrl: string,
  backgroundColor: string,
  collectionName: string,
  isPinned: bool
): Item =
  result.chainId = chainId
  result.contractAddress = contractAddress
  result.tokenId = tokenId
  result.name = if (name != ""): name else: ("#" & tokenId.toString())
  result.mediaUrl = mediaUrl
  result.mediaType = mediaType
  result.imageUrl = imageUrl
  result.backgroundColor = if (backgroundColor == ""): "transparent" else: ("#" & backgroundColor)
  result.collectionName = collectionName
  result.isLoading = false
  result.isPinned = isPinned

proc initItem*: Item =
  result = initItem(0, "", u256(0), "", "", "", "", "transparent", "Collectibles", false)

proc initLoadingItem*: Item =
  result = initItem()
  result.isLoading = true

proc `$`*(self: Item): string =
  result = fmt"""Collectibles(
    chainId: {self.chainId},
    contractAddress: {self.contractAddress},
    tokenId: {self.tokenId},
    name: {self.name},
    mediaUrl: {self.mediaUrl},
    mediaType: {self.mediaType},
    imageUrl: {self.imageUrl},
    backgroundColor: {self.backgroundColor},
    collectionName: {self.collectionName},
    isLoading: {self.isLoading},
    isPinned: {self.isPinned},
    ]"""

proc getChainId*(self: Item): int =
  return self.chainId

proc getContractAddress*(self: Item): string =
  return self.contractAddress

proc getTokenId*(self: Item): UInt256 =
  return self.tokenId

# Unique ID to identify collectible, generated by us
proc getId*(self: Item): string =
  return fmt"{self.getChainId}+{self.getContractAddress}+{self.getTokenID}"

proc getName*(self: Item): string =
  return self.name

proc getMediaUrl*(self: Item): string =
  return self.mediaUrl

proc getMediaType*(self: Item): string =
  return self.mediaType

proc getImageUrl*(self: Item): string =
  return self.imageUrl

proc getBackgroundColor*(self: Item): string =
  return self.backgroundColor

proc getCollectionName*(self: Item): string =
  return self.collectionName

proc getIsLoading*(self: Item): bool =
  return self.isLoading

proc getIsPinned*(self: Item): bool =
  return self.isPinned
