local AnimalConfig = {}

AnimalConfig.Data = [[
ID,Name,Rarity,Icon,Prefab,Size,ShowInShop,ActivityKey,OffsetX,OffsetY,OffsetZ,CostCoin,CostRobux,CostWins,Acceleration1,Acceleration2,Acceleration3,DisplayAcceleration,GetCoinFactor1,GetCoinFactor2,GetCoinFactor3,DisplayGetCoinFactor,MaxSpeedFactor1,MaxSpeedFactor2,MaxSpeedFactor3,DisplayMaxSpeedFactor,ProductKey
1,Doggy,1,rbxassetid://121105320530199,Animal/Animal_01,Tiny,True,nil,0,0,0,100,0,0,0,0.25,0,+25% Acceleration,0.15,0,0,+15% Wins,0.0,0,0,nan,nil
2,Rustfire,2,rbxassetid://127463403218182,Animal/Animal_02_Fox,Tiny,True,nil,0,0,0,200,0,0,0,0.5,0,+50% Acceleration,0.0,0,0,nan,0.05,0,0,+5% Move Speed,nil
3,Emberstripe,2,rbxassetid://88456620173136,Animal/Animal_03_Raccoon,Tiny,True,nil,0,0,0,1000,0,0,0,0.75,0,+75% Acceleration,0.3,0,0,+30% Wins,0.0,0,0,nan,nil
4,Willowhoof,2,rbxassetid://78441707075220,Animal/Animal_04_Dear,Tiny,True,nil,0,0,-2,4000,0,0,0,1.0,0,+100% Acceleration,0.45,0,0,+45% Wins,0.0,0,0,nan,nil
5,Frostfang,2,rbxassetid://80457989468887,Animal/Animal_05_Wolf,Tiny,True,nil,0,0,0,16000,0,0,0,2.5,0,+250% Acceleration,0.6,0,0,+60% Wins,0.0,0,0,nan,nil
6,Stormmane,3,rbxassetid://134436002441261,Animal/Animal_06_PloyHorse,Tiny,True,nil,0,0,-2,260000,0,0,0,4.0,0,+400% Acceleration,0.75,0,0,+75% Wins,0.0,0,0,nan,nil
7,Cougar,3,rbxassetid://72192169232508,Animal/Animal_07_Cougar,Tiny,True,nil,0,0,0,1000000,0,0,0,5.0,0,+500% Acceleration,0.96,0,0,+96% Wins,0.0,0,0,nan,nil
8,Aurorantler,3,rbxassetid://78361267116075,Animal/Animal_08_Moose,Tiny,True,nil,0,0,-1,2000000,0,0,0,5.0,0,+500% Acceleration,1.2,0,0,+120% Wins,0.0,0,0,nan,nil
9,Ironbristle,3,rbxassetid://130691732600843,Animal/Animal_09_Boar,Tiny,True,nil,0,0,-1,4200000,0,0,0,7.5,0,+750% Acceleration,1.38,0,0,+138% Wins,0.0,0,0,nan,nil
10,Scaleblade,3,rbxassetid://73436434075102,Animal/Animal_10_Veloraptor,Tiny,True,nil,0,0,0,16800000,0,0,0,9.0,0,+900% Acceleration,1.59,0,0,+159% Wins,0.0,0,0,nan,nil
11,Blazestripe,4,rbxassetid://89987824088101,Animal/Animal_11_Tiger,Tiny,True,nil,0,0,0,68000000,0,0,0,10.0,0,+1000% Acceleration,0.0,0,0,nan,0.1,0,0,+10% Move Speed,nil
12,Stonegrizzly,4,rbxassetid://75524627370417,Animal/Animal_12_Bear,Tiny,True,nil,0,0,0,280000000,0,0,0,11.0,0,+1100% Acceleration,1.83,0,0,+183% Wins,0.0,0,0,nan,nil
13,Neonmask,4,rbxassetid://106089172006712,Animal/Animal_13_RaccoonNeno,Tiny,True,nil,0,0,0,1120000000,0,0,0,12.0,0,+1200% Acceleration,0.0,0,0,nan,0.15,0,0,+15% Move Speed,nil
14,Neoflame,4,rbxassetid://83576401326835,Animal/Animal_14_FoxNeno,Tiny,True,nil,0,0,0,4400000000,0,0,0,13.25,0,+1325% Acceleration,2.16,0,0,+216% Wins,0.0,0,0,nan,nil
15,Stormwolf,4,rbxassetid://116069254559595,Animal/Animal_15_WolfNeno,Tiny,True,nil,0,0,0,17600000000,0,0,0,14.0,0,+1400% Acceleration,2.46,0,0,+246% Wins,0.0,0,0,nan,nil
16,TitanBoar,6,rbxassetid://73189067621199,Animal/Animal_16_BoarNeno,Tiny,True,nil,0,0,0,70000000000,0,0,0,15.0,0,+1500% Acceleration,0.0,0,0,nan,0.2,0,0,+20% Move Speed,nil
17,Neomoose,6,rbxassetid://113698894778201,Animal/Animal_17_MooseNeno,Tiny,True,nil,0,0,0,280000000000,0,0,0,17.5,0,+1750% Acceleration,2.7,0,0,+270% Wins,0.0,0,0,nan,nil
18,Nightclaw,6,rbxassetid://116327783333291,Animal/Animal_18_CougarNeno,Tiny,True,nil,0,0,0,1120000000000,0,0,0,20.0,0,+2000% Acceleration,0.0,0,0,nan,0.5,0,0,+50% Move Speed,nil
19,NenoBear,6,rbxassetid://105977390350925,Animal/Animal_19_BearNeno,Tiny,True,nil,0,0,0,4400000000000,0,0,0,22.5,0,+2250% Acceleration,3.0,0,0,+300% Wins,0.0,0,0,nan,nil
20,Gleamtiger,6,rbxassetid://71362363157834,Animal/Animal_20_TigerWhite,Tiny,True,nil,0,0,0,17600000000000,0,0,0,25.0,0,+2500% Acceleration,3.6,0,0,+360% Wins,0.0,0,0,nan,nil
21,Panda,5,rbxassetid://75392199000979,Animal/Animal_RB01_Panda,Tiny,True,nil,0,0,0,0,69,0,0,2.5,0,+250% Acceleration,4.5,0,0,+450% Wins,0.25,0,0,+25% Move Speed,ProductStoreAnimal21
22,Circuithound,5,rbxassetid://112702381015142,Animal/Animal_RB02_DogRobot,Tiny,True,nil,0,0,0,0,169,0,0,5.0,0,+500% Acceleration,10.5,0,0,+1050% Wins,0.75,0,0,+75% Move Speed,ProductStoreAnimal22
23,Ironhoof,5,rbxassetid://132508056479597,Animal/Animal_RB03_ArmorHorse,Tiny,True,nil,0,0,-2,0,299,0,0,12.5,0,+1250% Acceleration,18.0,0,0,+1800% Wins,1.5,0,0,+150% Move Speed,ProductStoreAnimal23
24,Pyromare,5,rbxassetid://140422912193015,Animal/Animal_RB04_FireHorse,Tiny,True,nil,0,0,0,0,569,0,0,27.5,0,+2750% Acceleration,25.5,0,0,+2550% Wins,3.0,0,0,+300% Move Speed,ProductStoreAnimal24
25,Unicorn,5,rbxassetid://135891639689786,Animal/Animal_Season01_Unicorn,Tiny,True,nil,0,0,-2,0,399,0,0,15.0,0,+1500% Acceleration,13.5,0,0,+1350% Wins,1.2,0,0,+120% Move Speed,ProductStoreAnimal25
26,Santa Deer,5,rbxassetid://97157855341253,Animal/Animal_ChristmasDear,Tiny,True,Christmas2025,0,0,0,0,39,0,0,3.75,0,+375% Acceleration,3.0,0,0,+300% Wins,0.5,0,0,+50% Move Speed,ProductStoreAnimal26
]]

return AnimalConfig