-- Código atualizado do manager para usar as configurações sandbox

local HearingAidSandbox = require("HearingAid_Sandbox_Logic");

-- Função atualizada para ativar hearing aid usando configurações sandbox
local function onActivateHearingAid(_, playerID, item, manager)
    local player = getPlayer(playerID);
    HearingAidManager.activeManagers[buildActiveIndex(player)] = manager;
    
    local modData = item:getModData();
    local hearingAidType = item:getFullType();
    
    -- Limpar dados anteriores
    modData[HA_CHANGED_TRAITS] = nil;
    
    -- Verificar se o jogador pode usar este tipo de hearing aid
    if not HearingAidSandbox.canUseHearingAid(player, hearingAidType) then
        -- Mostrar mensagem de erro se necessário
        player:Say(getText("IGUI_HearingAid_CannotUse") or "You cannot use this hearing aid with your current hearing level.");
        return;
    end
    
    -- Aplicar o efeito baseado nas configurações sandbox
    HearingAidSandbox.applyHearingAidEffect(player, hearingAidType, modData);
    
    -- Armazenar playerID para verificação posterior
    if modData[HA_CHANGED_TRAITS] then
        modData[HA_CHANGED_TRAITS][3] = playerID;
    end
end

-- Função atualizada para desativar hearing aid
local function onDeactivateHearingAid(_, playerID, item, manager)
    local player = getPlayer(playerID);
    HearingAidManager.activeManagers[buildActiveIndex(player)] = nil;
    
    local modData = item:getModData();
    local changedTraits = modData[HA_CHANGED_TRAITS];
    
    if changedTraits ~= nil then
        local removedTrait, addedTrait, activePlayerID = changedTraits[1], changedTraits[2], changedTraits[3];
        local activePlayer = getPlayer(activePlayerID);
        
        if player ~= activePlayer then
            -- Possível erro se jogador morrer enquanto usando o hearing aid
            error("HearingAid for " .. buildActiveIndex(activePlayer) .. " deactivated on " .. buildActiveIndex(player));
        end
        
        -- Reverter efeito usando sistema sandbox
        HearingAidSandbox.revertHearingAidEffect(activePlayer, modData);
    end
end

-- Função quando bateria acaba
local function onBatteryDead(_, playerID, item, manager)
    onDeactivateHearingAid(_, playerID, item, manager);
end

-- Menu de contexto atualizado para mostrar informações sobre efeitos
local function createMenuHearingAid(playerID, context, items)
    for i, e in ipairs(items) do
        local item;
        if instanceof(e, "InventoryItem") then 
            item = e; 
        else 
            item = e.items[1]; 
        end;

        if isWorkingHearingAid(item) then
            local itemID = getItemID(item);
            if not HearingAidManager.managers[itemID] then
                initializeHearingAid(itemID, playerID, item);
            end
            
            if item:isEquipped() then
                local player = getPlayer(playerID);
                local hearingAidType = item:getFullType();
                
                -- Adicionar informações sobre efeito atual
                local effect = HearingAidSandbox.getHearingAidEffect(player, hearingAidType);
                local effectText = string.format("Current: %s → Target: %s", effect.currentName, effect.targetName);
                
                local effectOption = context:addOption(effectText);
                effectOption.notAvailable = true; -- Apenas informativo
                
                -- Menu normal do hearing aid
                HearingAidManager.managers[itemID]:doActionMenu(context);
            end
            
            HearingAidManager.managers[itemID]:doBatteryMenu(context);
        end
    end
end

-- Função de validação atualizada para verificar configurações
local function isValid(_, playerID, item)
    if getPlayer(playerID) and item then
        local player = getPlayer(playerID);
        local hearingAidType = item:getFullType();
        
        -- Verificar se pode usar o hearing aid
        if not HearingAidSandbox.canUseHearingAid(player, hearingAidType) then
            return false;
        end
        
        return item:isEquipped();
    else
        return false;
    end
end

-- Função para mostrar tooltip com informações de configuração
local function addHearingAidTooltip(item, tooltip)
    if isWorkingHearingAid(item) then
        local hearingAidType = item:getFullType();
        local player = getPlayer():getDisplayName() and getPlayer() or nil;
        
        if player then
            local effect = HearingAidSandbox.getHearingAidEffect(player, hearingAidType);
            
            tooltip:addLine(" ");
            tooltip:addLine("Effect: " .. effect.currentName .. " → " .. effect.targetName);
            
            if not HearingAidSandbox.canUseHearingAid(player, hearingAidType) then
                tooltip:addLineRed("Cannot use with current hearing level");
            end
        end
    end
end

-- Registrar eventos
Events.OnHearingAidActivate.Add(onActivateHearingAid);
Events.OnHearingAidDeactivate.Add(onDeactivateHearingAid);
Events.OnHearingAidBatteryDead.Add(onBatteryDead);
Events.OnFillInventoryObjectContextMenu.Add(createMenuHearingAid);

-- Adicionar tooltip se o evento existir
if Events.OnItemTooltip then
    Events.OnItemTooltip.Add(addHearingAidTooltip);
end