require "TimedActions/ISBaseTimedAction"

ISMetalWork = ISBaseTimedAction:derive("ISMetalWork");

function ISMetalWork:isValid()
    --print ("ISMetalWork:isValid")
	--print(self.item1_name, self.item1_owned:size(), self.item2_name, self.item2_owned:size())
	return mat_basenames == nil or tool_types == nil
end

function ISMetalWork:update()
    --print ("ISMetalWork:update, Stage:", self.stage)
	--print(self.action:getJobDelta());
	self.character:faceThisObject(self.target);
	
	-- Determine which tool and animation to use based on material
	local inputType = self.item:getFullType();
	local isPureMetal = (inputType == "Base.LeadPipe" or inputType == "Base.MetalBar" or 
	                    inputType == "Base.MetalPipe" or inputType == "Base.SheetMetal" or 
	                    inputType == "Base.SmallSheetMetal");
	
	--TODO Stages for the built item maybe.. and testing for random success
	if #self.tools > 1 then
		if self.action:getJobDelta() > 0.6 and self.stage == 0 then
			local primary = self.character:getPrimaryHandItem();
			if primary then
				self:setOverrideHandModels(primary, nil)
				if isPureMetal and primary:getType() == "BlowTorch" then
					self:setActionAnim("BlowTorchFloor");			
				elseif not isPureMetal and primary:getTags():contains("Screwdriver") then
					self:setActionAnim("Disassemble");
				end		
			end
			self.stage = 1;
		end
	end
end

function ISMetalWork:start()
	--print ("ISMetalWork:start")
	if self.target == nil and self.item ~= nil then
		--print("metalitem ", self.item:getWorldItem());
		self.target = self.item:getWorldItem();		
	end
	
	-- Determine animation based on material type
	local inputType = self.item:getFullType();
	local isPureMetal = (inputType == "Base.LeadPipe" or inputType == "Base.MetalBar" or 
	                    inputType == "Base.MetalPipe" or inputType == "Base.SheetMetal" or 
	                    inputType == "Base.SmallSheetMetal");
	
	if isPureMetal then
		-- Pure metals use BlowTorch
		self:setActionAnim("BlowTorchFloor");
	else
		-- ScrapMetal and UnusableMetal use Screwdriver
		self:setActionAnim("Disassemble");
	end
	
	self:setOverrideHandModels(self.tools[1], nil)
end

function ISMetalWork:stop()
    --print ("ISMetalWork:stop")
    ISBaseTimedAction.stop(self);	
end

function ISMetalWork:perform()
	--print("Checking for random.. is material is destroyed?");
	--TODO write random check and influences
	local rand = ZombRand(101);
	--print ("Break Chance: ", self.breakchance, "Roll: ", rand);
	if rand < self.breakchance then
		--print("Destroying target: ", self.target);
		self.target:removeFromWorld();
					
		local sq = self.target:getSquare()
		sq:transmitRemoveItemFromSquare(self.target);
		sq:removeWorldObject(self.target);
		
		if self.floorcont ~= nil then 
			self.floorcont:Remove(self.item); 
		end
		
		-- Determine what to create based on input material
		local inputType = self.item:getFullType();
		local outputType = "";
		local outputCount = 1;
		
		-- Pure metals -> ScrapMetal (2x)
		if inputType == "Base.LeadPipe" or inputType == "Base.MetalBar" or 
		   inputType == "Base.MetalPipe" or inputType == "Base.SheetMetal" or 
		   inputType == "Base.SmallSheetMetal" then
			outputType = "Base.ScrapMetal";
			outputCount = 2;
		-- ScrapMetal -> UnusableMetal (2x)
		elseif inputType == "Base.ScrapMetal" then
			outputType = "Base.UnusableMetal";
			outputCount = 2;
		-- UnusableMetal disappears (like UnusableWood)
		elseif inputType == "Base.UnusableMetal" then
			outputType = ""; -- Nothing created, material disappears
			outputCount = 0;
		end
		
		-- Create output items
		for i = 1, outputCount do
			if outputType ~= "" then
				local _item = sq:AddWorldInventoryItem(outputType, 0, 0, 0);
				_item:getWorldItem():addToWorld();
				self.floorcont:AddItem(_item);
			end
		end
		
		--print("Material processed.");
	else
		--print("Material retained.");
	end
	
	--print("character: ", self.character);
	
	-- Calculate XP based on material type
	local inputType = self.item:getFullType();
	local baseXP = 10;
	local bonusXP = 0;
	
	-- Pure metals: high XP (100 total)
	if inputType == "Base.LeadPipe" or inputType == "Base.MetalBar" or 
	   inputType == "Base.MetalPipe" or inputType == "Base.SheetMetal" or 
	   inputType == "Base.SmallSheetMetal" then
		bonusXP = 90; -- 10 + 90 = 100
	-- ScrapMetal: medium XP (50 total)
	elseif inputType == "Base.ScrapMetal" then
		bonusXP = 40; -- 10 + 40 = 50
	-- UnusableMetal: low XP (25 total)
	elseif inputType == "Base.UnusableMetal" then
		bonusXP = 15; -- 10 + 15 = 25
	end
	
	rand = ZombRand(40+(self.character:getPerkLevel(Perks.MetalWelding)*6));
	local xptotal = (baseXP + bonusXP + rand)/2;
	self.character:getXp():AddXP(Perks.MetalWelding, xptotal);
	
	--print("Task Finished! Added " .. tostring(xptotal) .. " MetalWelding XP!");		
	ISBaseTimedAction.perform(self);
	self.parentscript:checkForItems(self.character, nil, self.worldobjs, true);
end

function ISMetalWork:new(parentscript, item, target, floorcont, character, baseTime, mat_basenames, tool_types, tools, worldobjs)
    --print ("ISMetalWork:new")
	--print(mat_basenames[1]);
    local o = {}
    setmetatable(o, self);
    self.__index = self;
	o.parentscript = parentscript;
	o.item = item;
	o.target = target;
	o.character = character;
	o.inventory = character:getInventory();
	o.mat_basenames = mat_basenames;
	o.tool_types = tool_types;
	o.tools = tools;
	o.worldobjs = worldobjs;
	o.floorcont = floorcont;
	o.equippedsnd = nil;
	o.tool1 = o.inventory:contains(tool_types[1]);
	if #tool_types > 1 then
		o.tool2 = o.inventory:contains(tool_types[2]);
	end
	o.breakchance = (90 - (character:getPerkLevel(Perks.MetalWelding) * 8));
	--print(o.breakchance, character:getPerkLevel(Perks.MetalWelding));
	o.stage = 0;
    o.stopOnWalk = true;
    o.stopOnRun = false;
    o.maxTime = baseTime; -- - (o.character:getPerkLevel(Perks.MetalWelding) * 50);
    return o;
end