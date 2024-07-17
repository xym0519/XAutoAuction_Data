XAutoAuctionDataFrame = CreateFrame('Frame')

XAuctionInfoList = {}
XAuctionInfoListImport = ''

XBuyList = {}
XBuyExport = ''

XSellList = {}
XSellExport = ''

XScanList = {}
XScanExport = ''

local function import()
    -- if XAuctionInfoListImport ~= nil and XAuctionInfoListImport ~= '' then

    -- end
end

local function export()
    if not XBuyExport or XBuyExport == '' then
        local buyJsonList = {}
        for _, item in ipairs(XBuyList) do
            table.insert(buyJsonList,
                format('{"itemname":"%s","time":%s,"price":%s,"count":%s}',
                    item.itemName, item.time, item.price, item.count))
        end
        XBuyExport = format('[%s]', table.concat(buyJsonList, ','))
        XBuyList = {}
    end

    if not XSellExport or XSellExport == '' then
        local sellJsonList = {}
        for _, item in ipairs(XSellList) do
            table.insert(sellJsonList,
                format('{"itemname":"%s","time":%s,"issuccess":%s,"price":%s,"count":%s}',
                    item.itemName, item.time, item.isSuccess and 'true' or 'false', item.price, item.count))
        end
        XSellExport = format('[%s]', table.concat(sellJsonList, ','))
        XSellList = {}
    end

    if not XScanExport or XScanExport == '' then
        local scanJsonList = {}
        for itemName, item in pairs(XScanList) do
            local listJsonList = {}
            for _, record in ipairs(item['list']) do
                table.insert(listJsonList, format('{"time":%s,"price":%s}', record.time, record.price))
            end
            table.insert(scanJsonList,
                format('"%s":{"timestamp":%s, "list":[%s]}', itemName, item.timestamp, table.concat(listJsonList, ',')))
        end
        XScanExport = format('{%s}', table.concat(scanJsonList, ','))
        XScanList = {}
    end
end

XAutoAuctionDataFrame:RegisterEvent('ADDON_LOADED')
XAutoAuctionDataFrame:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_HIDE')
XAutoAuctionDataFrame:RegisterEvent('AUCTION_HOUSE_CLOSED')

XAutoAuctionDataFrame:SetScript('OnEvent', function(self, event, text, content)
    if event == 'ADDON_LOADED' then
        if text == 'XAutoAuction_Data' then
            import()
        end
    elseif event == 'PLAYER_INTERACTION_MANAGER_FRAME_HIDE' then
        if text == Enum.PlayerInteractionType.MailInfo then export() end
    elseif event == 'AUCTION_HOUSE_CLOSED' then
        export()
    end
end)
