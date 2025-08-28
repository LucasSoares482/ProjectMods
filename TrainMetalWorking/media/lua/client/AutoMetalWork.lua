require "ISMetalWork"

AutoMetalWork = {}
AutoMetalWork.mat_basenames = { "Base.LeadPipe", "Base.MetalBar", "Base.MetalPipe", "Base.SheetMetal", "Base.SmallSheetMetal", "Base.ScrapMetal", "Base.UnusableMetal" }
AutoMetalWork.tool_types = { "BlowTorch", "Screwdriver" }
AutoMetalWork.tools = {};
AutoMetalWork.metalitem = nil;
AutoMetalWork.metalwobj = nil;
AutoMetalWork.invmetal = {}
AutoMetalWork.floorcontainer = nil;
AutoMetalWork.dir = { IsoDirections.E, IsoDirections.W, IsoDirections.N, IsoDirections.S, IsoDirections.NE, IsoDirections.NW, IsoDirections.SE, IsoDirections.SW }

function AutoMetalWork:checkForItems(playr, context, worldobjects, test)
	print("AMWCFI_start: ", playr, context, test);
	if test and ISWorldObjectContextMenu.Test then return true end --For controller support
	
	local player = getPlayer();
	local inventory = player:getInventory();
	local bags = ISInventoryPaneContextMenu.getContainers(player);
	
	--print("Looking for metalworking tools..", AutoMetalWork.tool_types);		
	for i=1, #AutoMetalWork.tool_types do
		for ii=0, bags:size()-1 do
			local bag = bags:get(ii);
			--print("looking for ", AutoMetalWork.tool_types[i], " bag ", ii, bag:getType());
			
			local item = nil;
			-- Check for specific tool types
			if AutoMetalWork.tool_types[i] == "BlowTorch" then
				item = bag:getFirstTypeRecurse("BlowTorch");
			elseif AutoMetalWork.tool_types[i] == "Screwdriver" then
				item = bag:getFirstTag("Screwdriver");
			end
			
			if item ~= nil then
				--print("Tool found: ", item:getType());
				local container = item:getContainer()
				if container ~= inventory then
					local action = ISInventoryTransferAction:new(player, item, container, inventory, 60);
					ISTimedActionQueue.add(action);
				end
				table.insert(AutoMetalWork.tools, item);
				break
			end		
		end
	end
	
	-- Both BlowTorch and Screwdriver are required
	if #AutoMetalWork.tools < 2 then
		print("Missing required tools! Need BlowTorch and Screwdriver. Returning..");
		return
	end
	
	-- Look for metal materials in bags
	for i=0, bags:size()-1 do
		local bag = bags:get(i);
		for j=1, #AutoMetalWork.mat_basenames do
			local items = bag:getItemsFromFullType(AutoMetalWork.mat_basenames[j]);
			if items:size() > 0 and bag:getType() ~= "floor" then
				if AutoMetalWork.metalitem == nil then
					AutoMetalWork.metalitem = items:get(0);
				end
				table.insert(AutoMetalWork.invmetal, items);
			end
		end
		
		if AutoMetalWork.floorcontainer == nil and bag:getType() == "floor" then 
			--print("floor container found.. saving.. ", bag);
			AutoMetalWork.floorcontainer = bag;
		end
	end
	
	-- Look for metal materials on ground
	local square = player:getCurrentSquare();
	local wobj = square:getWorldObjects();
		
	for ii=1, #AutoMetalWork.mat_basenames do
		for i=0, wobj:size()-1 do
			local wob = wobj:get(i)
			local item = wob:getItem();
			if item:getFullType() == AutoMetalWork.mat_basenames[ii] then	
				AutoMetalWork.metalitem = item;
				AutoMetalWork.metalwobj = wob;
				--print(item:getDisplayName(), " found on ground");
			end
			if AutoMetalWork.metalwobj ~= nil then break end
		end
		
		-- Check adjacent squares
		for i=1, #AutoMetalWork.dir do
			if AutoMetalWork.metalwobj == nil then				
				local adj_sq = square:getAdjacentSquare(AutoMetalWork.dir[i])
				if adj_sq then
					local adj_wobj = adj_sq:getWorldObjects();
					for k=0, adj_wobj:size()-1 do
						local a_wob = adj_wobj:get(k)
						local a_item = a_wob:getItem();
						if a_item:getFullType() == AutoMetalWork.mat_basenames[ii] then	
							AutoMetalWork.metalitem = a_item;
							AutoMetalWork.metalwobj = a_wob;
							break
						end
					end
				end				
			else 
				break 
			end
		end
		if AutoMetalWork.metalwobj ~= nil then break end
	end
	
	if context == nil then AutoMetalWork.trainMetalWorking(); end	
end

function AutoMetalWork:trainMetalWorking()
	if AutoMetalWork.metalitem == nil then print("No metal materials! Returning..") return end
	local player = getPlayer();
	local inventory = player:getInventory();
	
	-- Move all metal materials to inventory then drop them
	for i=1, #AutoMetalWork.invmetal do		
		local list = AutoMetalWork.invmetal[i];
		for ii=0, list:size()-1 do
			local item = list:get(ii);
			local container = item:getContainer()
			if container ~= inventory then
				local action = ISInventoryTransferAction:new(player, item, container, inventory, 60);
				ISTimedActionQueue.add(action);
			end
			local action = ISDropItemAction:new(player, item, 10);
			ISTimedActionQueue.add(action);
		end
	end
	
	print("metalwobj: ", AutoMetalWork.metalwobj);
	print("floor container: ", AutoMetalWork.floorcontainer);
	player:faceThisObject(AutoMetalWork.metalwobj);	
	
	-- Determine which tool to equip first based on material type
	local inputType = AutoMetalWork.metalitem:getFullType();
	local isPureMetal = (inputType == "Base.LeadPipe" or inputType == "Base.MetalBar" or 
	                    inputType == "Base.MetalPipe" or inputType == "Base.SheetMetal" or 
	                    inputType == "Base.SmallSheetMetal");
	
	local primaryTool = nil;
	local secondaryTool = nil;
	
	-- Find BlowTorch and Screwdriver in tools
	for i=1, #AutoMetalWork.tools do
		if AutoMetalWork.tools[i]:getType() == "BlowTorch" then
			if isPureMetal then
				primaryTool = AutoMetalWork.tools[i];
			else
				secondaryTool = AutoMetalWork.tools[i];
			end
		elseif AutoMetalWork.tools[i]:getTags():contains("Screwdriver") then
			if isPureMetal then
				secondaryTool = AutoMetalWork.tools[i];
			else
				primaryTool = AutoMetalWork.tools[i];
			end
		end
	end
	
	-- Equip appropriate tools
	if secondaryTool then
		local action = ISEquipWeaponAction:new(player, secondaryTool, 50, true, false);
		ISTimedActionQueue.add(action);
	end
	
	if primaryTool then
		local action = ISEquipWeaponAction:new(player, primaryTool, 50, false, false);
		ISTimedActionQueue.add(action);
	end
	
	local action = ISMetalWork:new(AutoMetalWork, AutoMetalWork.metalitem, AutoMetalWork.metalwobj, AutoMetalWork.floorcontainer, player, 800, AutoMetalWork.mat_basenames, AutoMetalWork.tool_types, AutoMetalWork.tools, worldobjs);
	ISTimedActionQueue.add(action);
	
	-- Reset variables
	AutoMetalWork.metalwobj = nil;
	AutoMetalWork.metalitem = nil;
	AutoMetalWork.invmetal = {}
	AutoMetalWork.tools = {}
end

function AutoMetalWork:new(player)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.player = player;
    o.addAction = nil;
    
    return o;
end