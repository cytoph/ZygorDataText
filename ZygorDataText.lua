local addOnName, addOn = ...

local ZGV = ZygorGuidesViewer
local ZGVMapIcon = ZygorGuidesViewerMapIcon
local ZGVname = ZGV.L["name_plain"]
local brokerLabel = "Zygor Guides"
local NC = ZGV.NotificationCenter

local dataBroker

local lib = LibStub:GetLibrary("LibDataBroker-1.1")
local DropDownForkList1 = _G["DropDownForkList1"]
local CloseDropDownForks = _G["CloseDropDownForks"]
local EasyFork = _G["EasyFork"]

local originalUpdateButton = NC.UpdateButton

-- extends original NC:UpdateButton
function NC:UpdateButton()

	counter = 0
	
	if ZGV.db.profile.nc_enable then
		for i,entry in ipairs(NC.Entries) do
			if not entry.data.reviewed then
				counter = counter + 1
			end
		end
	end
	
	if counter == 0 then
		dataBroker.label = brokerLabel
	else
		dataBroker.label = brokerLabel .. " (" .. counter .. ")"
	end

	originalUpdateButton(self)
	
end

-- copied from NC:ShowAll; just replaced fixed parent
local function ShowNotificationCenter(clickedFrame, force)
	if not force and DropDownForkList1 and DropDownForkList1:IsShown() and DropDownForkList1.dropdown==ZGV.Frame.Controls.MenuHostNotifications then
		CloseDropDownForks()
		return
	end
		
	if NC.SingleNotif:IsVisible() then
		NC.SingleNotif:CancelFadeTimer()
		NC.SingleNotif:Hide()
	end

	local menu = {}
	tinsert(menu,{
		text = "",
		customFrame=NC.EntrySettings,
		paddingbottom=0,
		height=20,
		keepShownOnClick=true,
		minWidth=225,
	})
	local LIMIT,COUNTER = 5,0
	
	local parent = clickedFrame

	if #NC.Entries==0 then
		tinsert(menu,{
			title=L["notifcenter_no_entries"],
			text=L["notifcenter_no_entries"],
			notCheckable=1,
		})
	else
		for _,entry in ipairs(NC.Entries) do
			if not entry.data.transient then
				local frame = NC.ButtonPool:Acquire()
				frame:SetParent(parent)
				frame:SetPoint("RIGHT",parent,"LEFT",0,0) -- needs to be anchored for height calculation to work
				frame:SetEntry(entry)

				entry.data.shown = true
				entry.data.reviewed = true

				tinsert(menu,{
					text = "",
					customFrame=frame,
					leftPadding = -10,
				})
				tinsert(menu,UIDropDownFork_separatorInfo)
				COUNTER = COUNTER + 1
				if COUNTER==LIMIT then
					break
				end
			end
		end
	end
	
	ZGV.Frame.Controls.MenuHostNotifications:ClearAllPoints()
	if tonumber(parent:GetLeft())>225 then
		UIDropDownFork_SetAnchor(ZGV.Frame.Controls.MenuHostNotifications, 0, 0, "TOPRIGHT", parent, "BOTTOMRIGHT")
	else
		UIDropDownFork_SetAnchor(ZGV.Frame.Controls.MenuHostNotifications, 0, 0, "TOPLEFT", parent, "BOTTOMLEFT")
	end
	EasyFork(menu,ZGV.Frame.Controls.MenuHostNotifications,nil,0,0,"MENU",10)
	ZGV.Frame.Controls.MenuHostNotifications.noRightPaddingOnLevel = 1

	NC:UpdateButton()
end

local function DataTextClicked(clickedFrame, button)

	if ZGV.Config.Running or ZGV.Tutorial.Running then return end
	
	GameTooltip:Hide()
	
	if button=="LeftButton" then
		if ZGV.db.profile.nc_enable then
			if ZGV.loading then
				ZGV.NotificationCenter.ShowOnLoad = true
			else
				ShowNotificationCenter(clickedFrame)
			end
		else
			ZGV:ToggleFrame()
		end
	else
		ZGV:ToggleFrame()
	end
	
end

local function DataTextTooltip(tooltip)

	tooltip:SetText(ZGV.L['minimap_tooltip'])
	tooltip:Show()
	
end

dataBroker = lib:NewDataObject(ZGVname, {
	type = "launcher",
	icon = "Interface\\AddOns\\" .. tostring(ZGV) .. "\\Skins\\zglogo_single",
	OnClick = DataTextClicked,
	OnTooltipShow = DataTextTooltip,
	text = (Broker2FuBar) and ZGVname or nil, -- only for fubar, not for ldb
	label = brokerLabel,
})
