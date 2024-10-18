XJewToolDataFrame = CreateFrame('Frame')
XJewToolData = {}
local moduleName = 'XJewToolData'

XItemInfoList = {}
XItemInfoListImport = ''

XItemUpdateList = {}
XItemUpdateExport = ''

XBuyList = {}
XBuyExport = ''

XSellList = {}
XSellExport = ''

XScanList = {}
XScanExport = ''

local function parseItemInfoObject(jsonStr)
    -- itemname, category, group
    local item = {}
    for k, v in jsonStr:gmatch('"([^"]+)":"([^"]*)"') do
        if k ~= 'itemname' and k ~= 'itemlink' and k ~= 'category' and k ~= 'class' and k ~= 'group' then
            item[k] = tonumber(v)
        else
            item[k] = v
        end
    end
    return item
end

local function import()
    if XItemInfoListImport ~= nil and XItemInfoListImport ~= '' then
        local results = {}

        -- 去除数组括号
        local jsonStr = string.sub(XItemInfoListImport, 2, -2)
        local count = 0
        for objectStr in jsonStr:gmatch("{(.-)}") do
            local obj = parseItemInfoObject(objectStr)
            results[obj['itemname']] = obj
            count = count + 1
        end
        XItemInfoList = results
        XItemInfoListImport = ''
        print('----------XItemInfoList----------')
        print(count .. ' items loaded.')
    end
end

local function fieldEncode(item)
    local listFields = {}
    for k, v in pairs(item) do
        local valueType = type(v)
        if valueType == 'number' then
            table.insert(listFields, format('"%s":%s', k, v))
        elseif valueType == 'boolean' then
            if v then
                table.insert(listFields, format('"%s":true', k))
            else
                table.insert(listFields, format('"%s":false', k))
            end
        else
            table.insert(listFields, format('"%s":"%s"', k, v))
        end
    end
    return table.concat(listFields, ',')
end


local function export()
    if not XItemUpdateList or XItemUpdateExport == '' or XItemUpdateExport == '[]' then
        local list = {}
        local count = 0
        for itemName, item in pairs(XItemUpdateList) do
            item.itemname = itemName
            local fields = fieldEncode(item)

            table.insert(list, format('{%s}', fields))

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
                record.itemname = itemName
                local fields = fieldEncode(record)

                table.insert(list, format('{%s}', fields))
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
            local fields = fieldEncode(item)
            table.insert(list, format('{%s}', fields))
        end
        XBuyExport = format('[%s]', table.concat(list, ','))
        XBuyList = {}
        print('Export buy history: ' .. count)
    end

    if not XSellExport or XSellExport == '' or XSellExport == '[]' then
        local list = {}
        local count = #XSellList
        for _, item in ipairs(XSellList) do
            local fields = fieldEncode(item)
            table.insert(list, format('{%s}', fields))
        end
        XSellExport = format('[%s]', table.concat(list, ','))
        XSellList = {}
        print('Export sell history: ' .. count)
    end
end

XJewToolDataFrame:RegisterEvent('ADDON_LOADED')

XJewToolDataFrame:SetScript('OnEvent', function(self, event, text, content)
    if event == 'ADDON_LOADED' then
        if text == 'XJewTool_Data' then
            import()
        end
    end
end)

-- Commands
SlashCmdList['XJEWTOOLDATAEXPORT'] = function()
    export()
end
SLASH_XJEWTOOLDATAEXPORT1 = '/xjewtooldata_export'
