XAutoAuctionDataFrame = CreateFrame('Frame')
XAutoAuctionData = {}
local moduleName = 'XAutoAuctionData'

XAuctionInfoList = {}
XAuctionInfoListImport = ''

XItemUpdateList = {}
XItemUpdateExport = ''

XBuyList = {}
XBuyExport = ''

XSellList = {}
XSellExport = ''

XScanList = {}
XScanExport = ''

local function parseAuctionInfoObject(jsonStr)
    -- itemname, category, group
    local item = {}
    for k, v in jsonStr:gmatch('"([^"]+)":"([^"]*)"') do
        if k ~= 'itemname' and k ~= 'category' and k ~= 'class' and k ~= 'group' then
            item[k] = tonumber(v)
        else
            item[k] = v
        end
    end
    return item
end

local function import()
    if XAuctionInfoListImport ~= nil and XAuctionInfoListImport ~= '' then
        local results = {}

        -- 去除数组括号
        local jsonStr = string.sub(XAuctionInfoListImport, 2, -2)
        local count = 0
        for objectStr in jsonStr:gmatch("{(.-)}") do
            local obj = parseAuctionInfoObject(objectStr)
            results[obj['itemname']] = obj
            count = count + 1
        end
        XAuctionInfoList = results
        XAuctionInfoListImport = ''
        print('----------XAuctionInfoList----------')
        print(count .. ' items loaded.')
    end
end

local function export()
    if not XItemUpdateList or XItemUpdateExport == '' or XItemUpdateExport == '[]' then
        local list = {}
        local count = 0
        for itemName, item in pairs(XItemUpdateList) do
            table.insert(list,
                format('{"itemname":"%s","itemid":%s,"vendorprice":%s,"category":"%s","class":"%s"}',
                    itemName, item.itemid, item.vendorprice, item.category, item.class))
            count = count + 1
        end
        XItemUpdateExport = format('[%s]', table.concat(list, ','))
        XItemUpdateList = {}
        print('Export item update: ' .. count)
    end

    if not XScanExport or XScanExport == '' or XScanExport == '[]' then
        local list = {}
        local count = 0
        for itemName, item in pairs(XScanList) do
            for _, record in ipairs(item['list']) do
                table.insert(list, format('{"itemname":"%s","time":%s,"price":%s}', itemName, record.time, record.price))
                count = count + 1
            end
        end
        XScanExport = format('[%s]', table.concat(list, ','))
        XScanList = {}
        print('Export scan history: ' .. count)
    end

    if not XBuyExport or XBuyExport == '' or XBuyExport == '[]' then
        local list = {}
        local count = #XBuyList
        for _, item in ipairs(XBuyList) do
            table.insert(list,
                format('{"itemname":"%s","time":%s,"price":%s,"count":%s}',
                    item.itemname, item.time, item.price, item.count))
        end
        XBuyExport = format('[%s]', table.concat(list, ','))
        XBuyList = {}
        print('Export buy history: ' .. count)
    end

    if not XSellExport or XSellExport == '' or XSellExport == '[]' then
        local list = {}
        local count = #XSellList
        for _, item in ipairs(XSellList) do
            table.insert(list,
                format('{"itemname":"%s","time":%s,"issuccess":%s,"price":%s,"count":%s}',
                    item.itemname, item.time, item.issuccess and 'true' or 'false', item.price, item.count))
        end
        XSellExport = format('[%s]', table.concat(list, ','))
        XSellList = {}
        print('Export sell history: ' .. count)
    end
end

XAutoAuctionDataFrame:RegisterEvent('ADDON_LOADED')

XAutoAuctionDataFrame:SetScript('OnEvent', function(self, event, text, content)
    if event == 'ADDON_LOADED' then
        if text == 'XAutoAuction_Data' then
            import()
        end
    end
end)

-- Commands
SlashCmdList['XAUTOAUCTIONDATAEXPORT'] = function()
    export()
end
SLASH_XAUTOAUCTIONDATAEXPORT1 = '/xautoauctiondata_export'
