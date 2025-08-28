require "TimedActions/ISBaseTimedAction"

ISWork = ISBaseTimedAction:derive("ISWork");

function ISWork:isValid()
    --print ("ISWork:isValid")
	--print(self.item1_name, self.item1_owned:size(), self.item2_name, self.item2_owned:size())
	return mat_basenames == nil or tool_types == nil
end

function ISWork:update()
    --print ("ISWork:update, Stage:", self.stage)
	--print(self.action:getJobDelta());
	self.character:faceThisObject(self.target);
	if self.stage == 0 then
		if not self.emitter:isPlaying("Sawing") then
			self.sound = self.emitter:playSound("Sawing");
		end
	elseif self.stage == 1 then	
		self.emitter:stopSoundByName("Sawing");
		if not self.emitter:isPlaying(self.equippedsnd) then
			self.sound = self.emitter:playSound(self.equippedsnd);
		end
	end
	
	
	
	--print("Tags ", self.equipped);
	--TODO Stages for the built item maybe.. and testing for random success
	if #self.tools > 1 then
		if self.action:getJobDelta() > 0.6 and self.stage == 0 then
			local primary = self.character:getPrimaryHandItem();
			self:setOverrideHandModels(primary, nil)
			if primary:getTags():contains("Hammer") then
				self.equippedsnd = "Hammering";
				self:setActionAnim("BuildLow");			
				self.sound = self.emitter:playSound("Hammering");
			elseif primary:getTags():contains("Screwdriver") then
				self.equippedsnd = "Screwdriver";
				self:setActionAnim("Craft");
				self.sound = self.emitter:playSound("Screwdriver");			
			end		
			self.stage = 1;
		end
	end
end

function ISWork:start()
	--print ("ISWork:start")
	if self.target == nil and self.item ~= nil then
		--print("wooditem ", self.item:getWorldItem());
		self.target = self.item:getWorldItem();		
	end
	-- set animation
	--print(self.target)--:getName());
	--self.character:faceThisObject(self.target);
	self:setActionAnim("SawLog");
	self:setOverrideHandModels(self.tools[1], nil)
	self.sound = self.emitter:playSound("Sawing");
	
	--self:setOverrideHandModels("Plank", "Hammer", nil)
	--self.sound = self.emitter:playSound("Hammering");
end

function ISWork:stop()
    --print ("ISWork:stop")
	self.emitter:stopAll();
    ISBaseTimedAction.stop(self);	
end

function ISWork:perform()
		--print("Checking for random.. is material is destroyed?");
		--TODO write random check and influences
		local rand = ZombRand(101);
		--print ("Break Chance: ", self.breakchance, "Roll: ", rand);
		if rand < self.breakchance then
			--print("Destroying target: ", self.target);
			--print("floor container: ", self.floorcont)
			--print("world coords: ", self.target.xoff, self.target.yoff, self.target.zoff)
			--print("other coords: ", self.target:getX(), self.target:getY(), self.target:getZ())
			
			
			self.target:removeFromWorld();
						
			local sq = self.target:getSquare()
			sq:transmitRemoveItemFromSquare(self.target);
			sq:removeWorldObject(self.target);
			--print("Destroying item: ", item);					
			if self.floorcont ~= nil then 
				self.floorcont:Remove(self.item); 
			end
			
			if self.item:getFullType() == self.mat_basenames[1] then -- if plank
				local _item = sq:AddWorldInventoryItem("Base.UnusableWood", 0, 0, 0); --_x, _y, _z);
				_item:getWorldItem():addToWorld();
				self.floorcont:AddItem(_item);
			end
			--sq:addTileObject(_item);
			--sq:transmitAddObjectToSquare(_item);
			
			--print("container: ", self.target:getContainer());			
			--print("Material lost.");
		else
			--print("Material retained.");
		end
		--print("character: ", self.character);
		rand = ZombRand(40+(self.character:getPerkLevel(Perks.Woodwork)*6));
		local xptotal = (10 + rand)/2;
		self.character:getXp():AddXP(Perks.Woodwork, xptotal);
		--[[
		for i=1, self.item1_cost do
			print("Removing Aluminum ", self.item1_owned:get(i-1));
			self.inventory:Remove(self.item1_owned:get(i-1));	-- DEBUG DISABLED --
		end
		for i=1, self.item2_cost do
			print("Removing Scrap ", self.item2_owned:get(i-1));
			self.inventory:Remove(self.item2_owned:get(i-1)); -- DEBUG DISABLED --
		end
		]]--
		--print("Task Finished! Added " .. tostring(xptotal) .. " XP!");		
		self.emitter:stopAll();
		ISBaseTimedAction.perform(self);
		self.parentscript:checkForItems(self.character, nil, self.worldobjs, true);
end

function ISWork:new(parentscript, item, target, floorcont, character, baseTime, mat_basenames, tool_types, tools, worldobjs)
    --print ("ISWork:new")
	--print(mat_basenames[1]);
    local o = {}
    setmetatable(o, self);
    self.__index = self;
	o.parentscript = parentscript;
	o.item = item;
	o.target = target;
	o.character = character;
	o.inventory = character:getInventory();
	o.emitter = character:getEmitter();
	o.mat_basenames = mat_basenames;
	o.tool_types = tool_types;
	o.tools = tools;
	o.worldobjs = worldobjs;
	o.floorcont = floorcont;
	--o.mats = o.inventory:getItemsFromFullType(mat_basenames[1]);	
	o.equippedsnd = nil;  --TODO Set this actually
	o.tool1 = o.inventory:contains(tool_types[1]);
	o.tool2 = o.inventory:contains(tool_types[2]);	
	--print("o.mats ", o.mats);
	o.breakchance = (90 - (character:getPerkLevel(Perks.Woodwork) * 8));
	--print(o.breakchance, character:getPerkLevel(Perks.Woodwork));
	o.stage = 0;
    o.stopOnWalk = true;
    o.stopOnRun = false;
    o.maxTime = baseTime; -- - (o.character:getPerkLevel(Perks.Electricity) * 50);
    return o;
end
