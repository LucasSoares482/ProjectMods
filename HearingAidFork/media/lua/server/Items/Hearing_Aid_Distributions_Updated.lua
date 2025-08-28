require "Items/Distributions";
require "Items/ProceduralDistributions";

-- Definição dos spawns para Broken Hearing Aid (chances de 1.0 a 10)
local BrokenHearingAidSpawns = {
    -- Electronics/Technology locations
    CrateElectronics = 8,
    ElectronicStoreMisc = 6,
    ElectronicStoreMusic = 4,
    RadioSpeaker = 5,
    RadioShelf = 5,
    
    -- Medical/Health locations
    MedicalClinicDrugs = 10,
    MedicalClinicTools = 8,
    MedicalOfficeBooks = 3,
    HospitalDrugs = 10,
    HospitalSupplies = 8,
    PharmacyShelves = 7,
    MedicalStorageOutfit = 5,
    
    -- Office locations
    OfficeDesk = 4,
    OfficeDeskHome = 5,
    OfficeCounter = 3,
    OfficeShelfSupplies = 4,
    DeskGeneric = 3,
    
    -- Residential locations
    Bedroom = 2,
    BedroomDresser = 3,
    ClosetShelfGeneric = 4,
    DresserGeneric = 3,
    SideTable = 2,
    Nightstand = 2,
    
    -- Clothing stores
    ClothingStoresEyewear = 6,
    ClothingStoresAccessories = 5,
    ClothingStorageAll = 3,
    
    -- Lockers and storage
    Locker = 2,
    SchoolLockers = 2,
    GymLockers = 2,
    FactoryLockers = 2,
    
    -- Junk/Trash locations
    JunkHoard = 4,
    GarbageMan = 3,
    TrashCan = 1,
    
    -- Other locations
    PawnShopGunsSpecial = 3,
    ThriftShelves = 5,
    OptometristGlasses = 8,
    GiftShelves = 2,
};

-- Definição dos spawns para Inefficient Hearing Aid (chances de 1.0 a 10)
local IneffecientHearingAidSpawns = {
    -- Electronics/Technology locations
    CrateElectronics = 5,
    ElectronicStoreMisc = 4,
    ElectronicStoreMusic = 3,
    RadioSpeaker = 3,
    RadioShelf = 3,
    
    -- Medical/Health locations
    MedicalClinicDrugs = 7,
    MedicalClinicTools = 6,
    MedicalOfficeBooks = 2,
    HospitalDrugs = 7,
    HospitalSupplies = 6,
    PharmacyShelves = 5,
    MedicalStorageOutfit = 4,
    
    -- Office locations
    OfficeDesk = 3,
    OfficeDeskHome = 4,
    OfficeCounter = 2,
    OfficeShelfSupplies = 3,
    DeskGeneric = 2,
    
    -- Residential locations
    Bedroom = 1,
    BedroomDresser = 2,
    ClosetShelfGeneric = 3,
    DresserGeneric = 2,
    SideTable = 1,
    Nightstand = 1,
    
    -- Clothing stores
    ClothingStoresEyewear = 4,
    ClothingStoresAccessories = 3,
    ClothingStorageAll = 2,
    
    -- Other locations
    PawnShopGunsSpecial = 2,
    ThriftShelves = 3,
    OptometristGlasses = 6,
    GiftShelves = 1,
};

-- Definição dos spawns para Efficient Hearing Aid (chances reduzidas)
local EfficientHearingAidSpawns = {
    -- Electronics/Technology locations
    CrateElectronics = 2,
    ElectronicStoreMisc = 1.5,
    ElectronicStoreMusic = 1,
    RadioSpeaker = 1,
    RadioShelf = 1,
    
    -- Medical/Health locations
    MedicalClinicDrugs = 3,
    MedicalClinicTools = 2.5,
    HospitalDrugs = 3,
    HospitalSupplies = 2.5,
    PharmacyShelves = 2,
    MedicalStorageOutfit = 1.5,
    
    -- Office locations
    OfficeDesk = 1,
    OfficeDeskHome = 1.5,
    OfficeCounter = 0.8,
    OfficeShelfSupplies = 1,
    DeskGeneric = 0.8,
    
    -- Clothing stores
    ClothingStoresEyewear = 1.5,
    ClothingStoresAccessories = 1,
    
    -- Other locations
    PawnShopGunsSpecial = 0.8,
    ThriftShelves = 1,
    OptometristGlasses = 2.5,
};

-- Definição dos spawns para Boosted Hearing Aid (chances muito reduzidas)
local BoostedHearingAidSpawns = {
    -- Electronics/Technology locations
    CrateElectronics = 0.8,
    ElectronicStoreMisc = 0.6,
    ElectronicStoreMusic = 0.4,
    RadioSpeaker = 0.4,
    RadioShelf = 0.4,
    
    -- Medical/Health locations
    MedicalClinicDrugs = 1.2,
    MedicalClinicTools = 1,
    HospitalDrugs = 1.2,
    HospitalSupplies = 1,
    PharmacyShelves = 0.8,
    MedicalStorageOutfit = 0.6,
    
    -- Office locations
    OfficeDesk = 0.3,
    OfficeDeskHome = 0.5,
    OfficeCounter = 0.2,
    OfficeShelfSupplies = 0.3,
    DeskGeneric = 0.2,
    
    -- Clothing stores
    ClothingStoresEyewear = 0.5,
    ClothingStoresAccessories = 0.3,
    
    -- Other locations
    PawnShopGunsSpecial = 0.2,
    ThriftShelves = 0.3,
    OptometristGlasses = 1,
};

-- Aplicar spawns para Broken Hearing Aid
for distributionName, rate in pairs(BrokenHearingAidSpawns) do
    local distribution = ProceduralDistributions.list[tostring(distributionName)];
    if distribution then
        table.insert(distribution.items, "hearing_aid.BrokenHearingAid");
        table.insert(distribution.items, rate);
    end
end

-- Aplicar spawns para Inefficient Hearing Aid
for distributionName, rate in pairs(IneffecientHearingAidSpawns) do
    local distribution = ProceduralDistributions.list[tostring(distributionName)];
    if distribution then
        table.insert(distribution.items, "hearing_aid.InefficientHearingAid");
        table.insert(distribution.items, rate);
    end
end

-- Aplicar spawns para Efficient Hearing Aid
for distributionName, rate in pairs(EfficientHearingAidSpawns) do
    local distribution = ProceduralDistributions.list[tostring(distributionName)];
    if distribution then
        table.insert(distribution.items, "hearing_aid.EfficientHearingAid");
        table.insert(distribution.items, rate);
    end
end

-- Aplicar spawns para Boosted Hearing Aid
for distributionName, rate in pairs(BoostedHearingAidSpawns) do
    local distribution = ProceduralDistributions.list[tostring(distributionName)];
    if distribution then
        table.insert(distribution.items, "hearing_aid.BoostedHearingAid");
        table.insert(distribution.items, rate);
    end
end

-- Inventários de zumbis (inventorymale e inventoryfemale) com chances de 0.5
-- Broken Hearing Aid
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "hearing_aid.BrokenHearingAid");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.5);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "hearing_aid.BrokenHearingAid");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.5);

-- Inefficient Hearing Aid
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "hearing_aid.InefficientHearingAid");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.5);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "hearing_aid.InefficientHearingAid");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.5);

-- Efficient Hearing Aid
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "hearing_aid.EfficientHearingAid");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.5);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "hearing_aid.EfficientHearingAid");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.5);

-- Boosted Hearing Aid
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "hearing_aid.BoostedHearingAid");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.5);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "hearing_aid.BoostedHearingAid");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.5);