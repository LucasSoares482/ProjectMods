# ProjectMods
utilizando IA e algumas ideias, este repositorio trata-se de modificações/fork de outros mods de project zomboid.
- Using AI and some ideas, this repository contains modifications/forks of other Project Zomboid mods.

## acha todos os minrange em arquivos nas subpastas e zera o minrange (Linux)
find . -type f -name "*.txt" -exec sed -i 's/MinRange\s*=\s*[0-9.]\+/MinRange = 0/g' {} \; 

## acha todos os minrange em formato .lua como do melee overhaul (Linux)
find . -type f -exec sed -i 's/"MinRange",\s*[0-9.]\+);/"MinRange", 0);/g' {} \; 

## Para arquivos .txt ConditionLowerChanceOneIn (formato padrão) (Linux) 
find . -type f -name "*.txt" -exec sed -i 's/ConditionLowerChanceOneIn\s*=\s*[0-9.]\+/ConditionLowerChanceOneIn = 70/g' {} \;

## Para arquivos .lua ConditionLowerChanceOneIn (formato melee overhaul) (Linux)
find . -type f -exec sed -i 's/"ConditionLowerChanceOneIn",\s*[0-9.]\+);/"ConditionLowerChanceOneIn", 70);/g' {} \;
