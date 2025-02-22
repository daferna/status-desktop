import QtQuick 2.13

import SortFilterProxyModel 0.2
import StatusQ.Core 0.1

import utils 1.0

QtObject {
    id: root

    property var transactionsList: walletSection.activityController.model

    property var activityController: walletSection.activityController
    property bool filtersSet: selectedTime !== Constants.TransactionTimePeriod.All ||
                                typeFilters.length !== 0 ||
                                statusFilters.length !== 0 ||
                                tokensFilter.length !== 0 ||
                                collectiblesFilter.length !== 0 ||
                                recentsFilters.length !== 0 ||
                                savedAddressFilters.length !== 0

    readonly property QtObject _d: QtObject {
        id: d

        function toggleFilterState(filters, attribute, allFiltersCount) {
            let tempFilters = filters
            // if all were selected then only select one of them
            if(tempFilters.length === 0) {
                tempFilters = [attribute]
            }
            else {
                // if last one is being deselected, select all
                if(tempFilters.length === 1 && tempFilters[0] === attribute) {
                    tempFilters = []
                }
                else {
                    let index = tempFilters.indexOf(attribute)
                    if(index === -1) {
                        if(allFiltersCount === tempFilters.length + 1)
                            tempFilters = []
                        else
                            tempFilters.push(attribute)
                    }
                    else {
                        tempFilters.splice(index, 1)
                    }
                }
            }
            return tempFilters
        }

        property bool fromTimestampNoLimit: true
        property bool toTimestampNoLimit: true

        function setFromTimestamp(value) {
            root.fromTimestamp = value
            fromTimestampNoLimit = false
        }
        function resetFromTimestamp() {
            root.fromTimestamp = 0
            fromTimestampNoLimit = true
        }

        function setToTimestamp(value) {
            root.toTimestamp = value
            toTimestampNoLimit = false
        }

        function resetToTimestamp() {
            root.toTimestamp = 0
            toTimestampNoLimit = true
        }
    }

    // Time filters
    property int selectedTime: Constants.TransactionTimePeriod.All
    // If noLimitTimestamp or double timestamp value otherwise
    property double fromTimestamp: 0
    property double toTimestamp: 0
    readonly property double currentActivityStartTimestamp: activityController.status.startTimestamp * 1000.0
    function setSelectedTimestamp(selcTime) {
        selectedTime = selcTime
        switch(selectedTime) {
        case Constants.TransactionTimePeriod.All:
            d.resetFromTimestamp()
            d.resetToTimestamp()
            break
        case Constants.TransactionTimePeriod.Today:
            let dt = new Date()
            d.setFromTimestamp(dt.setHours(0,0,0,0).valueOf()) // Today
            d.resetToTimestamp()
            break
        case Constants.TransactionTimePeriod.Yesterday:
            let dt1 = new Date()
            dt1.setDate(dt1.getDate() - 1)
            dt1.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt1.valueOf()) // Yesterday
            dt1.setDate(dt1.getDate() + 1)
            dt1.setHours(0, 0, 0, -1)
            d.setToTimestamp(dt1.valueOf())
            break
        case Constants.TransactionTimePeriod.ThisWeek:
            let dt2 = LocaleUtils.getFirstDayOfTheCurrentWeek()
            dt2.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt2.valueOf()) // First day of this week
            d.resetToTimestamp()
            break
        case Constants.TransactionTimePeriod.LastWeek:
            let dt3 = LocaleUtils.getFirstDayOfTheCurrentWeek()
            dt3.setDate(dt3.getDate() - 7)
            dt3.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt3.valueOf()) // First day of last week
            dt3.setDate(dt3.getDate() + 6)
            dt3.setHours(23, 59, 59, 0)
            d.setToTimestamp(dt3.valueOf()) // Last day of last week
            break
        case Constants.TransactionTimePeriod.ThisMonth:
            let dt4 = new Date()
            dt4.setDate(1)
            dt4.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt4.valueOf()) // This month
            d.resetToTimestamp()
            break
        case Constants.TransactionTimePeriod.LastMonth:
            let dt5 = new Date()
            dt5.setDate(1)
            dt5.setMonth(dt5.getMonth()-1)
            dt5.setHours(0, 0, 0, 0)
            d.setFromTimestamp(dt5.valueOf()) // Last month
            dt5.setDate(new Date(dt5.getFullYear(), dt5.getMonth(), 0).getDate() + 2)
            dt5.setHours(0, 0, 0, -1)
            d.setToTimestamp(dt5.valueOf())
            break
        default:
            return ""
        }

        applyTimeRange()
    }

    function setCustomTimeRange(fromTimestamp, toTimestamp) {
        d.setFromTimestamp(fromTimestamp)
        d.setToTimestamp(toTimestamp)

        applyTimeRange()
    }

    function applyTimeRange() {
        const startTimestamp = d.fromTimestampNoLimit
                            ? activityController.noLimitTimestamp
                            : fromTimestamp/1000
        const endTimestamp = d.toTimestampNoLimit
                            ? activityController.noLimitTimestamp
                            : toTimestamp/1000
        activityController.setFilterTime(startTimestamp, endTimestamp)
        activityController.updateFilter()
    }

    // Type Filters
    property var typeFilters: []
    function toggleType(type, allFiltersCount) {
        // update filters
        typeFilters = d.toggleFilterState(typeFilters, type, allFiltersCount)
        // Set backend values
        activityController.setFilterType(JSON.stringify(typeFilters))
        activityController.updateFilter()
    }

    // Status Filters
    property var statusFilters: []
    function toggleStatus(status, allFiltersCount) {
        // update filters
        statusFilters = d.toggleFilterState(statusFilters, status, allFiltersCount)
        // Set backend values
        activityController.setFilterStatus(JSON.stringify(statusFilters))
        activityController.updateFilter()
    }

    // Tokens Filters
    property var tokensList: walletSectionAssets.assets
    property var tokensFilter: []
    function toggleToken(symbol) {
        // update filters
        tokensFilter = d.toggleFilterState(tokensFilter, symbol, tokensList.count)
        // Set backend values
        activityController.setFilterAssets(JSON.stringify(tokensFilter), false)
        activityController.updateFilter()
    }

    // Collectibles Filters
    // To-do: Get list of collectibles with activity from backend
    property var collectiblesList: walletSection.collectiblesController.model
    property var collectiblesFilter: []
    function toggleCollectibles(id) {
        // update filters
        collectiblesFilter = d.toggleFilterState(collectiblesFilter, id, collectiblesList.count)
        // TODO go side filtering is pending
        //      activityController.setFilterCollectibles(JSON.stringify(collectiblesFilter))
        //      activityController.updateFilter()
    }


    property var recentsList: activityController.recipientsModel
    property bool loadingRecipients: activityController.status.loadingRecipients
    property var recentsFilters: []
    function updateRecipientsModel() {
        activityController.updateRecipientsModel()
    }
    function toggleRecents(address) {
        // update filters
        recentsFilters = d.toggleFilterState(recentsFilters, address, recentsList.count)
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        activityController.updateFilter()
    }

    function getChainShortNamesForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getChainShortNamesForAddress(address)
    }

    function getEnsForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getEnsForAddress(address)
    }

    readonly property var savedAddressesModel: walletSectionSavedAddresses.model
    property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    property var savedAddressList:  SortFilterProxyModel {
        sourceModel: savedAddressesModel
        filters: [
            ValueFilter {
                roleName: "isTest"
                value: areTestNetworksEnabled
            }
        ]
    }
    property var savedAddressFilters: []
    function toggleSavedAddress(address) {
        // update filters
        savedAddressFilters = d.toggleFilterState(savedAddressFilters, address, savedAddressList.count)
        // Set backend values
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        activityController.updateFilter()
    }

    function updateFilterBase() {
        activityController.updateFilterBase()
    }

    function applyAllFilters() {
        applyTimeRange()
        activityController.setFilterType(JSON.stringify(typeFilters))
        activityController.setFilterStatus(JSON.stringify(statusFilters))
        activityController.setFilterAssets(JSON.stringify(tokensFilter), false)
        activityController.setFilterToAddresses(JSON.stringify(recentsFilters.concat(savedAddressFilters)))
        // TODO call update filter for collectibles

        activityController.updateFilter()
    }

    function resetAllFilters() {
        selectedTime = Constants.TransactionTimePeriod.All
        d.resetFromTimestamp()
        d.resetToTimestamp()
        typeFilters = []
        statusFilters = []
        tokensFilter = []
        collectiblesFilter = []
        recentsFilters = []
        savedAddressFilters = []
        // TODO reset filter for collectibles

        applyAllFilters()
    }
}
