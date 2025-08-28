require "AutoMetalWork"

function ISWorldObjectContextMenu_OnFillWorldObjectContextMenu_MetalWork(player, context, worldobjects, test)
	local inventory = getPlayer():getInventory();
	print(player, inventory, context, worldobjects)
	
	local autometalwork_btn = context:addOption("Train MetalWorking", worldobjects, AutoMetalWork.checkForItems);
	local tooltip = ISInventoryPaneContextMenu.addToolTip();
	tooltip.description = getText("Use metalworking tools and metal to train metalworking") .. " <LINE> <LINE> <INDENT:10> "
	tooltip.description = tooltip.description .. getText("Requires: ") .. " <LINE> <INDENT:30> "  
	tooltip.description = tooltip.description .. getText("BlowTorch (for pure metals)") .. " <LINE> <INDENT:30> "
	tooltip.description = tooltip.description .. getText("Screwdriver (for scrap/unusable)") .. " <LINE> <INDENT:30> "
	tooltip.description = tooltip.description .. getText("Metal Materials:") .. " <LINE> <INDENT:30> "
	tooltip.description = tooltip.description .. getText("LeadPipe, MetalBar, MetalPipe") .. " <LINE> <INDENT:30> "
	tooltip.description = tooltip.description .. getText("SheetMetal, SmallSheetMetal") .. " <LINE> <INDENT:30> "
	tooltip.description = tooltip.description .. getText("ScrapMetal, UnusableMetal")
	autometalwork_btn.toolTip = tooltip;	
end

Events.OnFillWorldObjectContextMenu.Add(ISWorldObjectContextMenu_OnFillWorldObjectContextMenu_MetalWork);