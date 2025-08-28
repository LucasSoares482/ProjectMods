require "AutoCarp"

--local worldobjs = nil; -- do i need this?
--local mat_basenames = { "Base.Plank", "Base.Nails" }
--local tool_types = { "Hammer", "Screwdriver" }

function ISWorldObjectContextMenu_OnFillWorldObjectContextMenu(player, context, worldobjects, test)
	local inventory = getPlayer():getInventory();
	--worldobjs = worldobjects;
	print(player, inventory, context, worldobjects)
	--print("All required tools found! Creating button..");	
	--local autoCook = AutoCook:new(playerObj, recipe, baseItem);
    --context:addOption(getText("ContextMenu_AutoCook_From_Category", fromName), autoCook, AutoCook.continue);
	print(AutoCarp.dir);
	--local autoCarp = AutoCarp:new(getPlayer);
	local autocarp_btn = context:addOption("Train Carpentry", worldobjects, AutoCarp.checkForItems);
	local tooltip = ISInventoryPaneContextMenu.addToolTip();
	tooltip.description = getText("Use tools and wood to train carpentry") .. " <LINE> <LINE> <INDENT:10> "
	tooltip.description = tooltip.description .. getText("Requires: ") .. " <LINE> <INDENT:30> "  
	tooltip.description = tooltip.description .. getText("Saw") .. " <LINE> <INDENT:30> "
	tooltip.description = tooltip.description .. getText("Hammer or Screwdriver") .. " <LINE> <INDENT:30> "
	tooltip.description = tooltip.description .. getText("Planks or Scrap Wood")
	autocarp_btn.toolTip = tooltip;	
	
	--local square = getPlayer():getSquare();
	--local _item = square:AddWorldInventoryItem("Base.UnusableWood", 0, 0, 0);
	
	
	--local AutoCarpStart = AutoCarp:checkForItems(player, context, worldobjects, test);
end
Events.OnFillWorldObjectContextMenu.Add(ISWorldObjectContextMenu_OnFillWorldObjectContextMenu);