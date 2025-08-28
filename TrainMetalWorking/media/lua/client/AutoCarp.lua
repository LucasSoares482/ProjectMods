require "ISWork"

AutoCarp = {}
AutoCarp.mat_basenames = { "Base.Plank", "Base.UnusableWood" } --"Base.Nails" }
AutoCarp.tool_types = { "Saw", "Hammer", "Screwdriver" }
AutoCarp.tools = {};
AutoCarp.wooditem = nil;
AutoCarp.woodwobj = nil;
AutoCarp.invwood = {}
AutoCarp.floorcontainer = nil;
AutoCarp.dir = { IsoDirections.E, IsoDirections.W, IsoDirections.N, IsoDirections.S, IsoDirections.NE, IsoDirections.NW, IsoDirections.SE, IsoDirections.SW }

function AutoCarp:checkForItems(playr, context, worldobjects, test)
	print("ACCFI_start: ", playr, context, test);
	--print(context[1]);
	if test and ISWorldObjectContextMenu.Test then return true end --For controller support (apparently)
	
	--TODO check for tools first, then based on tools choose resources, nails for hammer, screw for screwdriver, saw is needed in both cases
	
	local player = getPlayer();
	--print("player: ", player);	
	local inventory = player:getInventory();
	--print("items: ", items);
	local bags = ISInventoryPaneContextMenu.getContainers(player);
	--print("bags: ", bags);
	
	--print("Looking for tools..", AutoCarp.tool_types);		
	for i=1, #AutoCarp.tool_types do
				
		for ii=0, bags:size()-1 do
			local bag = bags:get(ii);
			--print("looking for ", AutoCarp.tool_types[i], " bag ", ii, bag:getType());
			if i == 2 and #AutoCarp.tools == 0 then
				--print("Saw not found! Returning..");
				return
			end			
			local item = bag:getFirstTag(AutoCarp.tool_types[i]);
			--print("item: ", item:getType());
			if item ~= nil then
				--print("Tool found: ", item:getType());
				--print("item container: ", item:getContainer());
				local container = item:getContainer()
				if container ~= inventory then
					local action = ISInventoryTransferAction:new(player, item, container, inventory, 60); -- moving tool to inventory
					ISTimedActionQueue.add(action);
				end
				table.insert(AutoCarp.tools, item); -- tools are in the table, use them
				break
			end		
		end
	end
	--print("inv: ", inventory, "items", items);
	
	
	for i=0, bags:size()-1 do
		--print("bag", i, bags:get(i):getType());
		local bag = bags:get(i);
		local items = bag:getItemsFromFullType(AutoCarp.mat_basenames[1]);
		local scrap = bag:getItemsFromFullType(AutoCarp.mat_basenames[2]);
		if items:size() > 0 and bag:getType() ~= "floor" then
			--print("items: ", items)
			AutoCarp.wooditem = items:get(0);
			table.insert(AutoCarp.invwood, items);
		end
		if scrap:size() > 0 and bag:getType() ~= "floor" then
			if AutoCarp.wooditem == nil then 
				AutoCarp.wooditem = scrap:get(0);
			end
			table.insert(AutoCarp.invwood, scrap);
		elseif AutoCarp.floorcontainer == nil and bag:getType() == "floor" then 
			--print("floor container found.. saving.. ", bag);
			AutoCarp.floorcontainer = bag;
		end
	end
	--print("allwood ", AutoCarp.invwood);
	local square = player:getCurrentSquare();
	--print("square: ", square);
	--print("squarecontainer: ", square:getContainer());
	local wobj = square:getWorldObjects();
	--print("worldobj: ", wobj:size());
		
	for ii=1, #AutoCarp.mat_basenames do --another for loop so that planks have priority over scrap wood
		for i=0, wobj:size()-1 do
			local wob = wobj:get(i)
			local item = wob:getItem();
			--print("wob: ", wob, "item: ", item);
			--print("item: ", item:getFullType(), "basename: ", AutoCarp.mat_basenames[ii]);
			if item:getFullType() == AutoCarp.mat_basenames[ii] then	
				--print("Item ", item, "container ", item:getContainer()); 
				AutoCarp.wooditem = item;
				AutoCarp.woodwobj = wob;
				--print(item:getDisplayName(), " found on ground, checking for tools..");
			end
			if AutoCarp.woodwobj ~= nil then print("break!") break end
		end
		print("dir", #AutoCarp.dir);
		for i=1, #AutoCarp.dir do
			if AutoCarp.woodwobj == nil then				
				local adj_sq = square:getAdjacentSquare(AutoCarp.dir[i])
				print(i, "square: ", adj_sq);
				local adj_wobj = adj_sq:getWorldObjects();
				for i=0, adj_wobj:size()-1 do
					local a_wob = adj_wobj:get(i)
					local a_item = a_wob:getItem();
					--print(a_item, a_wob);
					if a_item:getFullType() == AutoCarp.mat_basenames[ii] then	
						--print("Item ", a_item, "container ", a_item:getContainer()); ---REENABLE
						--player:faceThisObject(wob);
						AutoCarp.wooditem = a_item;
						AutoCarp.woodwobj = a_wob;
						--print(AutoCarp.wooditem, a_item:getDisplayName(), " found on ground, checking for tools..");
						break
					end
				end				
			else break end
		end
		if AutoCarp.woodwobj ~= nil then break end
	end
	--print("world objects checked.. wobj:", AutoCarp.woodwobj, " item", AutoCarp.wooditem);		
	
	if context == nil then AutoCarp.trainCarpentry(); end	
end

function AutoCarp:trainCarpentry()
	if AutoCarp.wooditem == nil then print("No materials! Returning..") return end
	local player = getPlayer();
	local inventory = player:getInventory();
	--print(items);
	--print("Checking for ", AutoCarp.mat_basenames[1], " in item table ", AutoCarp.invwood);
	--print("table size: ", #AutoCarp.invwood);
	for i=1, #AutoCarp.invwood do		
		local list = AutoCarp.invwood[i];
		--print(i, " i loop", list);
		--print("size ", list:size())
		for ii=0, list:size()-1 do
			--print(ii, " ii loop", list);
			local item = list:get(ii);
			local container = item:getContainer()
			--print(item)
			--print(ii, " container ", container, " inventory ", inventory);
			--print(ii, " container ", container:getType());
			if container ~= inventory then
				--print("Action!")
				local action = ISInventoryTransferAction:new(player, item, container, inventory, 60); -- moving planks to inventory
				ISTimedActionQueue.add(action); -- DEBUG OFF
			end
				local action = ISDropItemAction:new(player, item, 10); -- dropping inventory planks
				ISTimedActionQueue.add(action); -- DEBUG OFF
			--end
		end
	end
	--local tool1 = inventory:getFirstTag(AutoCarp.tool_types[1]); -- getFirstTag(String) returns inv item
	print("woodwobj name/parent: ", AutoCarp.woodwobj);
	print("floor container: ", AutoCarp.floorcontainer);
	player:faceThisObject(AutoCarp.woodwobj);	
	if #AutoCarp.tools > 2 then
		local randtool = ZombRand(#AutoCarp.tools-1)+2		
		--print("randtool ", randtool, AutoCarp.tools[randtool]:getType());
		local action = ISEquipWeaponAction:new(player, AutoCarp.tools[randtool], 50, true, false); -- Equip saw.. TODO check and implement vanilla time values		
		ISTimedActionQueue.add(action);	-- Equip Tool
	elseif #AutoCarp.tools == 2 then
		local action = ISEquipWeaponAction:new(player, AutoCarp.tools[2], 50, true, false); -- Equip saw.. TODO check and implement vanilla time values		
		ISTimedActionQueue.add(action);	-- Equip Tool
	end
	local action = ISEquipWeaponAction:new(player, AutoCarp.tools[1], 50, false, false); -- Equip saw.. TODO check and implement vanilla time values		
	ISTimedActionQueue.add(action);	-- Equip Tool
	local action = ISWork:new(AutoCarp, AutoCarp.wooditem, AutoCarp.woodwobj, AutoCarp.floorcontainer, player, 700, AutoCarp.mat_basenames, AutoCarp.tool_types, AutoCarp.tools, worldobjs);
	ISTimedActionQueue.add(action); -- Start training timed action
	AutoCarp.woodwobj = nil;
	AutoCarp.wooditem = nil;
	AutoCarp.invwood = {}
	AutoCarp.tools = {}
	--close menu
end

function AutoCarp:new(player)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.player = player;
    o.addAction = nil;
    
    return o;
end