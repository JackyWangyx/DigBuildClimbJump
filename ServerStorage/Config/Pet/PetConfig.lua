local PetConfig = {}

PetConfig.Data = [[
ID,Name,Rarity,Icon,Prefab,Size,Indexable,World,MaxExistGetCoinFactor1,GetCoinFactor1,DisplayGetPowerFactor,ProductKey
1,Doggy,1,rbxassetid://86721141310393,PetNew/Rank01/Egg01_01_Doggy,Tiny,true,1,0,1.5,x1.5,nil
2,Doggy,1,rbxassetid://86721141310393,PetNew/Rank01/Egg01_01_Doggy_Mid,Normal,false,1,0,1.8,x1.8,nil
3,Doggy,1,rbxassetid://86721141310393,PetNew/Rank01/Egg01_01_Doggy_Large,Large,false,1,0,2.25,x2.25,nil
4,Doggy,1,rbxassetid://86721141310393,PetNew/Rank01/Egg01_01_Doggy,nil,false,1,0,1,x1,nil
5,Doggy,1,rbxassetid://86721141310393,PetNew/Rank01/Egg01_01_Doggy,nil,false,1,0,1,x1,nil
6,Dino,2,rbxassetid://92374459990750,PetNew/Rank01/Egg01_02_Dino,Tiny,true,1,0,2,x2,nil
7,Dino,2,rbxassetid://92374459990750,PetNew/Rank01/Egg01_02_Dino_Mid,Normal,false,1,0,2.4,x2.4,nil
8,Dino,2,rbxassetid://92374459990750,PetNew/Rank01/Egg01_02_Dino_Large,Large,false,1,0,3,x3,nil
9,Dino,2,rbxassetid://92374459990750,PetNew/Rank01/Egg01_02_Dino,nil,false,1,0,1,x1,nil
10,Dino,2,rbxassetid://92374459990750,PetNew/Rank01/Egg01_02_Dino,nil,false,1,0,1,x1,nil
11,Panda,3,rbxassetid://118920667823004,PetNew/Rank01/Egg01_03_Panda,Tiny,true,1,0,3,x3,nil
12,Panda,3,rbxassetid://118920667823004,PetNew/Rank01/Egg01_03_Panda_Mid,Normal,false,1,0,3.6,x3.6,nil
13,Panda,3,rbxassetid://118920667823004,PetNew/Rank01/Egg01_03_Panda_Large,Large,false,1,0,4.5,x4.5,nil
14,Panda,3,rbxassetid://118920667823004,PetNew/Rank01/Egg01_03_Panda,nil,false,1,0,1,x1,nil
15,Panda,3,rbxassetid://118920667823004,PetNew/Rank01/Egg01_03_Panda,nil,false,1,0,1,x1,nil
16,Piggy,4,rbxassetid://127509215972299,PetNew/Rank01/Egg01_04_Piggy,Tiny,true,1,0,5,x5,nil
17,Piggy,4,rbxassetid://127509215972299,PetNew/Rank01/Egg01_04_Piggy_Mid,Normal,false,1,0,6,x6,nil
18,Piggy,4,rbxassetid://127509215972299,PetNew/Rank01/Egg01_04_Piggy_Large,Large,false,1,0,7.5,x7.5,nil
19,Piggy,4,rbxassetid://127509215972299,PetNew/Rank01/Egg01_04_Piggy,nil,false,1,0,1,x1,nil
20,Piggy,4,rbxassetid://127509215972299,PetNew/Rank01/Egg01_04_Piggy,nil,false,1,0,1,x1,nil
21,Kitty,5,rbxassetid://133950983951104,PetNew/Rank01/Egg01_05_Kitty,Tiny,true,1,0,11,x11,nil
22,Kitty,5,rbxassetid://133950983951104,PetNew/Rank01/Egg01_05_Kitty_Mid,Normal,false,1,0,13.2,x13.2,nil
23,Kitty,5,rbxassetid://133950983951104,PetNew/Rank01/Egg01_05_Kitty_Large,Large,false,1,0,16.5,x16.5,nil
24,Kitty,5,rbxassetid://133950983951104,PetNew/Rank01/Egg01_05_Kitty,nil,false,1,0,1,x1,nil
25,Kitty,5,rbxassetid://133950983951104,PetNew/Rank01/Egg01_05_Kitty,nil,false,1,0,1,x1,nil
26,Wolf,1,rbxassetid://125481752865893,PetNew/Rank01/Egg250_01_Wolf,Tiny,true,1,0,20,x20,nil
27,Wolf,1,rbxassetid://125481752865893,PetNew/Rank01/Egg250_01_Wolf_Mid,Normal,false,1,0,24,x24,nil
28,Wolf,1,rbxassetid://125481752865893,PetNew/Rank01/Egg250_01_Wolf_Large,Large,false,1,0,30,x30,nil
29,Wolf,1,rbxassetid://125481752865893,PetNew/Rank01/Egg250_01_Wolf,nil,false,1,0,1,x1,nil
30,Wolf,1,rbxassetid://125481752865893,PetNew/Rank01/Egg250_01_Wolf,nil,false,1,0,1,x1,nil
31,Bear,2,rbxassetid://108398654343385,PetNew/Rank01/Egg250_02_Bear,Tiny,true,1,0,40,x40,nil
32,Bear,2,rbxassetid://108398654343385,PetNew/Rank01/Egg250_02_Bear_Mid,Normal,false,1,0,48,x48,nil
33,Bear,2,rbxassetid://108398654343385,PetNew/Rank01/Egg250_02_Bear_Large,Large,false,1,0,60,x60,nil
34,Bear,2,rbxassetid://108398654343385,PetNew/Rank01/Egg250_02_Bear,nil,false,1,0,1,x1,nil
35,Bear,2,rbxassetid://108398654343385,PetNew/Rank01/Egg250_02_Bear,nil,false,1,0,1,x1,nil
36,Deer,3,rbxassetid://119658014755716,PetNew/Rank01/Egg250_03_Deer,Tiny,true,1,0,80,x80,nil
37,Deer,3,rbxassetid://119658014755716,PetNew/Rank01/Egg250_03_Deer_Mid,Normal,false,1,0,96,x96,nil
38,Deer,3,rbxassetid://119658014755716,PetNew/Rank01/Egg250_03_Deer_Large,Large,false,1,0,120,x120,nil
39,Deer,3,rbxassetid://119658014755716,PetNew/Rank01/Egg250_03_Deer,nil,false,1,0,1,x1,nil
40,Deer,3,rbxassetid://119658014755716,PetNew/Rank01/Egg250_03_Deer,nil,false,1,0,1,x1,nil
41,Bunny,4,rbxassetid://112465102440206,PetNew/Rank01/Egg250_04_Bunny,Tiny,true,1,0,160,x160,nil
42,Bunny,4,rbxassetid://112465102440206,PetNew/Rank01/Egg250_04_Bunny_Mid,Normal,false,1,0,192,x192,nil
43,Bunny,4,rbxassetid://112465102440206,PetNew/Rank01/Egg250_04_Bunny_Large,Large,false,1,0,240,x240,nil
44,Bunny,4,rbxassetid://112465102440206,PetNew/Rank01/Egg250_04_Bunny,nil,false,1,0,1,x1,nil
45,Bunny,4,rbxassetid://112465102440206,PetNew/Rank01/Egg250_04_Bunny,nil,false,1,0,1,x1,nil
46,Fox,5,rbxassetid://105059624130297,PetNew/Rank01/Egg250_05_Fox,Tiny,true,1,0,320,x320,nil
47,Fox,5,rbxassetid://105059624130297,PetNew/Rank01/Egg250_05_Fox_Mid,Normal,false,1,0,384,x384,nil
48,Fox,5,rbxassetid://105059624130297,PetNew/Rank01/Egg250_05_Fox_Large,Large,false,1,0,480,x480,nil
49,Fox,5,rbxassetid://105059624130297,PetNew/Rank01/Egg250_05_Fox,nil,false,1,0,1,x1,nil
50,Fox,5,rbxassetid://105059624130297,PetNew/Rank01/Egg250_05_Fox,nil,false,1,0,1,x1,nil
51,Voltiki,1,rbxassetid://121931478506491,PetNew/Rank01/Egg3K_01_Voltiki,Tiny,true,1,0,550,x550,nil
52,Voltiki,1,rbxassetid://121931478506491,PetNew/Rank01/Egg3K_01_Voltiki_Mid,Normal,false,1,0,660,x660,nil
53,Voltiki,1,rbxassetid://121931478506491,PetNew/Rank01/Egg3K_01_Voltiki_Large,Large,false,1,0,825,x825,nil
54,Voltiki,1,rbxassetid://121931478506491,PetNew/Rank01/Egg3K_01_Voltiki,nil,false,1,0,1,x1,nil
55,Voltiki,1,rbxassetid://121931478506491,PetNew/Rank01/Egg3K_01_Voltiki,nil,false,1,0,1,x1,nil
56,Spiketra,2,rbxassetid://133991851771294,PetNew/Rank01/Egg3K_02_Spiketra,Tiny,true,1,0,1100,x1.1K,nil
57,Spiketra,2,rbxassetid://133991851771294,PetNew/Rank01/Egg3K_02_Spiketra_Mid,Normal,false,1,0,1320,x1.32K,nil
58,Spiketra,2,rbxassetid://133991851771294,PetNew/Rank01/Egg3K_02_Spiketra_Large,Large,false,1,0,1650,x1.65K,nil
59,Spiketra,2,rbxassetid://133991851771294,PetNew/Rank01/Egg3K_02_Spiketra,nil,false,1,0,1,x1,nil
60,Spiketra,2,rbxassetid://133991851771294,PetNew/Rank01/Egg3K_02_Spiketra,nil,false,1,0,1,x1,nil
61,Frozbite,3,rbxassetid://121954968563489,PetNew/Rank01/Egg3K_03_Frozbite,Tiny,true,1,0,2200,x2.2K,nil
62,Frozbite,3,rbxassetid://121954968563489,PetNew/Rank01/Egg3K_03_Frozbite_Mid,Normal,false,1,0,2640,x2.64K,nil
63,Frozbite,3,rbxassetid://121954968563489,PetNew/Rank01/Egg3K_03_Frozbite_Large,Large,false,1,0,3300,x3.3K,nil
64,Frozbite,3,rbxassetid://121954968563489,PetNew/Rank01/Egg3K_03_Frozbite,nil,false,1,0,1,x1,nil
65,Frozbite,3,rbxassetid://121954968563489,PetNew/Rank01/Egg3K_03_Frozbite,nil,false,1,0,1,x1,nil
66,Halochi,4,rbxassetid://75914773369312,PetNew/Rank01/Egg3K_04_Halochi,Tiny,true,1,0,4400,x4.4K,nil
67,Halochi,4,rbxassetid://75914773369312,PetNew/Rank01/Egg3K_04_Halochi_Mid,Normal,false,1,0,5280,x5.28K,nil
68,Halochi,4,rbxassetid://75914773369312,PetNew/Rank01/Egg3K_04_Halochi_Large,Large,false,1,0,6600,x6.6K,nil
69,Halochi,4,rbxassetid://75914773369312,PetNew/Rank01/Egg3K_04_Halochi,nil,false,1,0,1,x1,nil
70,Halochi,4,rbxassetid://75914773369312,PetNew/Rank01/Egg3K_04_Halochi,nil,false,1,0,1,x1,nil
71,Noctobrax,5,rbxassetid://94388847485730,PetNew/Rank01/Egg3K_05_Noctobrax,Tiny,true,1,0,8800,x8.8K,nil
72,Noctobrax,5,rbxassetid://94388847485730,PetNew/Rank01/Egg3K_05_Noctobrax_Mid,Normal,false,1,0,10560,x10.56K,nil
73,Noctobrax,5,rbxassetid://94388847485730,PetNew/Rank01/Egg3K_05_Noctobrax_Large,Large,false,1,0,13200,x13.2K,nil
74,Noctobrax,5,rbxassetid://94388847485730,PetNew/Rank01/Egg3K_05_Noctobrax,nil,false,1,0,1,x1,nil
75,Noctobrax,5,rbxassetid://94388847485730,PetNew/Rank01/Egg3K_05_Noctobrax,nil,false,1,0,1,x1,nil
76,Solureon,1,rbxassetid://118876479023519,PetNew/Rank02/Egg50K_01_Solureon,Tiny,true,2,0,45000,x45K,nil
77,Solureon,1,rbxassetid://118876479023519,PetNew/Rank02/Egg50K_01_Solureon_Mid,Normal,false,2,0,54000,x54K,nil
78,Solureon,1,rbxassetid://118876479023519,PetNew/Rank02/Egg50K_01_Solureon_Large,Large,false,2,0,67500,x67.5K,nil
79,Solureon,1,rbxassetid://118876479023519,PetNew/Rank02/Egg50K_01_Solureon,nil,false,2,0,1,x1,nil
80,Solureon,1,rbxassetid://118876479023519,PetNew/Rank02/Egg50K_01_Solureon,nil,false,2,0,1,x1,nil
81,Glaciarch,2,rbxassetid://101579878256245,PetNew/Rank02/Egg50K_02_Glaciarch,Tiny,true,2,0,90000,x90K,nil
82,Glaciarch,2,rbxassetid://101579878256245,PetNew/Rank02/Egg50K_02_Glaciarch_Mid,Normal,false,2,0,108000,x108K,nil
83,Glaciarch,2,rbxassetid://101579878256245,PetNew/Rank02/Egg50K_02_Glaciarch_Large,Large,false,2,0,135000,x135K,nil
84,Glaciarch,2,rbxassetid://101579878256245,PetNew/Rank02/Egg50K_02_Glaciarch,nil,false,2,0,1,x1,nil
85,Glaciarch,2,rbxassetid://101579878256245,PetNew/Rank02/Egg50K_02_Glaciarch,nil,false,2,0,1,x1,nil
86,Verdantis,3,rbxassetid://94923582044024,PetNew/Rank02/Egg50K_03_Verdantis,Tiny,true,2,0,180000,x180K,nil
87,Verdantis,3,rbxassetid://94923582044024,PetNew/Rank02/Egg50K_03_Verdantis_Mid,Normal,false,2,0,216000,x216K,nil
88,Verdantis,3,rbxassetid://94923582044024,PetNew/Rank02/Egg50K_03_Verdantis_Large,Large,false,2,0,270000,x270K,nil
89,Verdantis,3,rbxassetid://94923582044024,PetNew/Rank02/Egg50K_03_Verdantis,nil,false,2,0,1,x1,nil
90,Verdantis,3,rbxassetid://94923582044024,PetNew/Rank02/Egg50K_03_Verdantis,nil,false,2,0,1,x1,nil
91,Blightorn,4,rbxassetid://88119698339374,PetNew/Rank02/Egg50K_04_Blightorn,Tiny,true,2,0,360000,x360K,nil
92,Blightorn,4,rbxassetid://88119698339374,PetNew/Rank02/Egg50K_04_Blightorn_Mid,Normal,false,2,0,432000,x432K,nil
93,Blightorn,4,rbxassetid://88119698339374,PetNew/Rank02/Egg50K_04_Blightorn_Large,Large,false,2,0,540000,x540K,nil
94,Blightorn,4,rbxassetid://88119698339374,PetNew/Rank02/Egg50K_04_Blightorn,nil,false,2,0,1,x1,nil
95,Blightorn,4,rbxassetid://88119698339374,PetNew/Rank02/Egg50K_04_Blightorn,nil,false,2,0,1,x1,nil
96,Nexvoidra,5,rbxassetid://140355526560098,PetNew/Rank02/Egg50K_05_Nexvoidra,Tiny,true,2,0,720000,x720K,nil
97,Nexvoidra,5,rbxassetid://140355526560098,PetNew/Rank02/Egg50K_05_Nexvoidra_Mid,Normal,false,2,0,864000,x864K,nil
98,Nexvoidra,5,rbxassetid://140355526560098,PetNew/Rank02/Egg50K_05_Nexvoidra_Large,Large,false,2,0,1080000,x1.08M,nil
99,Nexvoidra,5,rbxassetid://140355526560098,PetNew/Rank02/Egg50K_05_Nexvoidra,nil,false,2,0,1,x1,nil
100,Nexvoidra,5,rbxassetid://140355526560098,PetNew/Rank02/Egg50K_05_Nexvoidra,nil,false,2,0,1,x1,nil
101,Shadowbit,1,rbxassetid://91171164453882,PetNew/Rank02/200K01_Shadowbit,Tiny,true,2,0,1200000,x1.2M,nil
102,Shadowbit,1,rbxassetid://91171164453882,PetNew/Rank02/200K01_Shadowbit_Mid,Normal,false,2,0,1440000,x1.44M,nil
103,Shadowbit,1,rbxassetid://91171164453882,PetNew/Rank02/200K01_Shadowbit_Large,Large,false,2,0,1800000,x1.8M,nil
104,Shadowbit,1,rbxassetid://91171164453882,PetNew/Rank02/200K01_Shadowbit,nil,false,2,0,1,x1,nil
105,Shadowbit,1,rbxassetid://91171164453882,PetNew/Rank02/200K01_Shadowbit,nil,false,2,0,1,x1,nil
106,Lumiboo,2,rbxassetid://100020820025175,PetNew/Rank02/200K02_Lumiboo,Tiny,true,2,0,2400000,x2.4M,nil
107,Lumiboo,2,rbxassetid://100020820025175,PetNew/Rank02/200K02_Lumiboo_Mid,Normal,false,2,0,2880000,x2.88M,nil
108,Lumiboo,2,rbxassetid://100020820025175,PetNew/Rank02/200K02_Lumiboo_Large,Large,false,2,0,3600000,x3.6M,nil
109,Lumiboo,2,rbxassetid://100020820025175,PetNew/Rank02/200K02_Lumiboo,nil,false,2,0,1,x1,nil
110,Lumiboo,2,rbxassetid://100020820025175,PetNew/Rank02/200K02_Lumiboo,nil,false,2,0,1,x1,nil
111,Frosthalo,3,rbxassetid://93640291597129,PetNew/Rank02/200K03_Frosthalo,Tiny,true,2,0,4800000,x4.8M,nil
112,Frosthalo,3,rbxassetid://93640291597129,PetNew/Rank02/200K03_Frosthalo_Mid,Normal,false,2,0,5760000,x5.76M,nil
113,Frosthalo,3,rbxassetid://93640291597129,PetNew/Rank02/200K03_Frosthalo_Large,Large,false,2,0,7200000,x7.2M,nil
114,Frosthalo,3,rbxassetid://93640291597129,PetNew/Rank02/200K03_Frosthalo,nil,false,2,0,1,x1,nil
115,Frosthalo,3,rbxassetid://93640291597129,PetNew/Rank02/200K03_Frosthalo,nil,false,2,0,1,x1,nil
116,Twinklepaw,4,rbxassetid://120136115496341,PetNew/Rank02/200K04_Twinklepaw,Tiny,true,2,0,9600000,x9.6M,nil
117,Twinklepaw,4,rbxassetid://120136115496341,PetNew/Rank02/200K04_Twinklepaw_Mid,Normal,false,2,0,11520000,x11.52M,nil
118,Twinklepaw,4,rbxassetid://120136115496341,PetNew/Rank02/200K04_Twinklepaw_Large,Large,false,2,0,14400000,x14.4M,nil
119,Twinklepaw,4,rbxassetid://120136115496341,PetNew/Rank02/200K04_Twinklepaw,nil,false,2,0,1,x1,nil
120,Twinklepaw,4,rbxassetid://120136115496341,PetNew/Rank02/200K04_Twinklepaw,nil,false,2,0,1,x1,nil
121,Inferbibi,5,rbxassetid://91501088767499,PetNew/Rank02/200K05_Inferbibi,Tiny,true,2,0,19200000,x19.2M,nil
122,Inferbibi,5,rbxassetid://91501088767499,PetNew/Rank02/200K05_Inferbibi_Mid,Normal,false,2,0,23040000,x23.04M,nil
123,Inferbibi,5,rbxassetid://91501088767499,PetNew/Rank02/200K05_Inferbibi_Large,Large,false,2,0,28800000,x28.8M,nil
124,Inferbibi,5,rbxassetid://91501088767499,PetNew/Rank02/200K05_Inferbibi,nil,false,2,0,1,x1,nil
125,Inferbibi,5,rbxassetid://91501088767499,PetNew/Rank02/200K05_Inferbibi,nil,false,2,0,1,x1,nil
126,Chipbot,1,rbxassetid://112954121159805,PetNew/Rank02/800K01_Chipbot,Tiny,true,2,0,32000000,x32M,nil
127,Chipbot,1,rbxassetid://112954121159805,PetNew/Rank02/800K01_Chipbot_Mid,Normal,false,2,0,38400000,x38.4M,nil
128,Chipbot,1,rbxassetid://112954121159805,PetNew/Rank02/800K01_Chipbot_Large,Large,false,2,0,48000000,x48M,nil
129,Chipbot,1,rbxassetid://112954121159805,PetNew/Rank02/800K01_Chipbot,nil,false,2,0,1,x1,nil
130,Chipbot,1,rbxassetid://112954121159805,PetNew/Rank02/800K01_Chipbot,nil,false,2,0,1,x1,nil
131,Mystibot,2,rbxassetid://125525389819467,PetNew/Rank02/800K02_Mystibot,Tiny,true,2,0,65000000,x65M,nil
132,Mystibot,2,rbxassetid://125525389819467,PetNew/Rank02/800K02_Mystibot_Mid,Normal,false,2,0,78000000,x78M,nil
133,Mystibot,2,rbxassetid://125525389819467,PetNew/Rank02/800K02_Mystibot_Large,Large,false,2,0,97500000,x97.5M,nil
134,Mystibot,2,rbxassetid://125525389819467,PetNew/Rank02/800K02_Mystibot,nil,false,2,0,1,x1,nil
135,Mystibot,2,rbxassetid://125525389819467,PetNew/Rank02/800K02_Mystibot,nil,false,2,0,1,x1,nil
136,Heartcore,3,rbxassetid://115293601949519,PetNew/Rank02/800K03_Heartcore,Tiny,true,2,0,130000000,x130M,nil
137,Heartcore,3,rbxassetid://115293601949519,PetNew/Rank02/800K03_Heartcore_Mid,Normal,false,2,0,156000000,x156M,nil
138,Heartcore,3,rbxassetid://115293601949519,PetNew/Rank02/800K03_Heartcore_Large,Large,false,2,0,195000000,x195M,nil
139,Heartcore,3,rbxassetid://115293601949519,PetNew/Rank02/800K03_Heartcore,nil,false,2,0,1,x1,nil
140,Heartcore,3,rbxassetid://115293601949519,PetNew/Rank02/800K03_Heartcore,nil,false,2,0,1,x1,nil
141,Targetron,4,rbxassetid://100481257871322,PetNew/Rank02/800K04_Targetron,Tiny,true,2,0,260000000,x260M,nil
142,Targetron,4,rbxassetid://100481257871322,PetNew/Rank02/800K04_Targetron_Mid,Normal,false,2,0,312000000,x312M,nil
143,Targetron,4,rbxassetid://100481257871322,PetNew/Rank02/800K04_Targetron_Large,Large,false,2,0,390000000,x390M,nil
144,Targetron,4,rbxassetid://100481257871322,PetNew/Rank02/800K04_Targetron,nil,false,2,0,1,x1,nil
145,Targetron,4,rbxassetid://100481257871322,PetNew/Rank02/800K04_Targetron,nil,false,2,0,1,x1,nil
146,Buzzy,5,rbxassetid://139499492939806,PetNew/Rank02/800K05_Buzzy,Tiny,true,2,0,520000000,x520M,nil
147,Buzzy,5,rbxassetid://139499492939806,PetNew/Rank02/800K05_Buzzy_Mid,Normal,false,2,0,624000000,x624M,nil
148,Buzzy,5,rbxassetid://139499492939806,PetNew/Rank02/800K05_Buzzy_Large,Large,false,2,0,780000000,x780M,nil
149,Buzzy,5,rbxassetid://139499492939806,PetNew/Rank02/800K05_Buzzy,nil,false,2,0,1,x1,nil
150,Buzzy,5,rbxassetid://139499492939806,PetNew/Rank02/800K05_Buzzy,nil,false,2,0,1,x1,nil
151,Slimee,6,rbxassetid://110118864895973,PetNew/PetsRoblox/RBLv01_01,Tiny,true,2,0,200,x200,ProductStorePet151
152,Slimee,6,rbxassetid://110118864895973,PetNew/PetsRoblox/RBLv01_01_Mid,Normal,false,2,0,240,x240,nil
153,Slimee,6,rbxassetid://110118864895973,PetNew/PetsRoblox/RBLv01_01_Large,Large,false,2,0,300,x300,nil
154,Slimee,6,rbxassetid://110118864895973,PetNew/PetsRoblox/RBLv01_01,nil,false,2,0,1,x1,nil
155,Slimee,6,rbxassetid://110118864895973,PetNew/PetsRoblox/RBLv01_01,nil,false,2,0,1,x1,nil
156,Bubbloo,6,rbxassetid://130923749805734,PetNew/PetsRoblox/RBLv01_02,Tiny,true,2,0,1000000,x1M,ProductStorePet156
157,Bubbloo,6,rbxassetid://130923749805734,PetNew/PetsRoblox/RBLv01_02_Mid,Normal,false,2,0,1200000,x1.2M,nil
158,Bubbloo,6,rbxassetid://130923749805734,PetNew/PetsRoblox/RBLv01_02_Large,Large,false,2,0,1500000,x1.5M,nil
159,Bubbloo,6,rbxassetid://130923749805734,PetNew/PetsRoblox/RBLv01_02,nil,false,2,0,1,x1,nil
160,Bubbloo,6,rbxassetid://130923749805734,PetNew/PetsRoblox/RBLv01_02,nil,false,2,0,1,x1,nil
161,Cherubee,6,rbxassetid://71445192977824,PetNew/PetsRoblox/RBLv02_01,Tiny,true,2,0,1500000,x1.5M,ProductStorePet161
162,Cherubee,6,rbxassetid://71445192977824,PetNew/PetsRoblox/RBLv02_01_Mid,Normal,false,2,0,1800000,x1.8M,nil
163,Cherubee,6,rbxassetid://71445192977824,PetNew/PetsRoblox/RBLv02_01_Large,Large,false,2,0,2250000,x2.25M,nil
164,Cherubee,6,rbxassetid://71445192977824,PetNew/PetsRoblox/RBLv02_01,nil,false,2,0,1,x1,nil
165,Cherubee,6,rbxassetid://71445192977824,PetNew/PetsRoblox/RBLv02_01,nil,false,2,0,1,x1,nil
166,Mystiboo,6,rbxassetid://138070079030804,PetNew/PetsRoblox/RBLv02_02,Tiny,true,2,0,5000000,x5M,ProductStorePet166
167,Mystiboo,6,rbxassetid://138070079030804,PetNew/PetsRoblox/RBLv02_02_Mid,Normal,false,2,0,6000000,x6M,nil
168,Mystiboo,6,rbxassetid://138070079030804,PetNew/PetsRoblox/RBLv02_02_Large,Large,false,2,0,7500000,x7.5M,nil
169,Mystiboo,6,rbxassetid://138070079030804,PetNew/PetsRoblox/RBLv02_02,nil,false,2,0,1,x1,nil
170,Mystiboo,6,rbxassetid://138070079030804,PetNew/PetsRoblox/RBLv02_02,nil,false,2,0,1,x1,nil
171,Momo,6,rbxassetid://113903719937834,PetNew/PetsRoblox/RBLv03,Tiny,true,2,0,31000000000,x31B,ProductStorePet171
172,Momo,6,rbxassetid://113903719937834,PetNew/PetsRoblox/RBLv03_Mid,Normal,false,2,0,37200000000,x37.2B,nil
173,Momo,6,rbxassetid://113903719937834,PetNew/PetsRoblox/RBLv03_Large,Large,false,2,0,46500000000,x46.5B,nil
174,Momo,6,rbxassetid://113903719937834,PetNew/PetsRoblox/RBLv03,nil,false,2,0,1,x1,nil
175,Momo,6,rbxassetid://113903719937834,PetNew/PetsRoblox/RBLv03,nil,false,2,0,1,x1,nil
176,Zazu,6,rbxassetid://102447346288596,PetNew/PetsRoblox/RBLv04,Tiny,true,2,0,210000000000000,x210T,ProductStorePet176
177,Zazu,6,rbxassetid://102447346288596,PetNew/PetsRoblox/RBLv04_Mid,Normal,false,2,0,252000000000000,x252T,nil
178,Zazu,6,rbxassetid://102447346288596,PetNew/PetsRoblox/RBLv04_Large,Large,false,2,0,315000000000000,x315T,nil
179,Zazu,6,rbxassetid://102447346288596,PetNew/PetsRoblox/RBLv04,nil,false,2,0,1,x1,nil
180,Zazu,6,rbxassetid://102447346288596,PetNew/PetsRoblox/RBLv04,nil,false,2,0,1, ,nil
181,ForRBPets,1,rbxassetid://88351182574814,PetNew/PetsRoblox/Rank01RB01_Slimee,Tiny,true,2,0,1,1X,nil
182,ForRBPets,1,rbxassetid://88351182574814,PetNew/PetsRoblox/Rank01RB01_Slimee,Normal,false,2,0,1,1X,nil
183,ForRBPets,1,rbxassetid://88351182574814,PetNew/PetsRoblox/Rank01RB01_Slimee,Large,false,2,0,1,1X,nil
184,ForRBPets,1,rbxassetid://88351182574814,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
185,ForRBPets,1,rbxassetid://88351182574814,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
186,ForRBPets,1,rbxassetid://97958746390784,PetNew/PetsRoblox/Rank01RB01_Slimee,Tiny,true,2,0,1,1X,nil
187,ForRBPets,1,rbxassetid://97958746390784,PetNew/PetsRoblox/Rank01RB01_Slimee,Normal,false,2,0,1,1X,nil
188,ForRBPets,1,rbxassetid://97958746390784,PetNew/PetsRoblox/Rank01RB01_Slimee,Large,false,2,0,1,1X,nil
189,ForRBPets,1,rbxassetid://97958746390784,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
190,ForRBPets,1,rbxassetid://97958746390784,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
191,ForRBPets,1,rbxassetid://125673790407899,PetNew/PetsRoblox/Rank01RB01_Slimee,Tiny,true,2,0,1,1X,nil
192,ForRBPets,1,rbxassetid://125673790407899,PetNew/PetsRoblox/Rank01RB01_Slimee,Normal,false,2,0,1,1X,nil
193,ForRBPets,1,rbxassetid://125673790407899,PetNew/PetsRoblox/Rank01RB01_Slimee,Large,false,2,0,1,1X,nil
194,ForRBPets,1,rbxassetid://125673790407899,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
195,ForRBPets,1,rbxassetid://125673790407899,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
196,ForRBPets,1,rbxassetid://107423189403607,PetNew/PetsRoblox/Rank01RB01_Slimee,Tiny,true,2,0,1,1X,nil
197,ForRBPets,1,rbxassetid://107423189403607,PetNew/PetsRoblox/Rank01RB01_Slimee,Normal,false,2,0,1,1X,nil
198,ForRBPets,1,rbxassetid://107423189403607,PetNew/PetsRoblox/Rank01RB01_Slimee,Large,false,2,0,1,1X,nil
199,ForRBPets,1,rbxassetid://107423189403607,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
200,ForRBPets,1,rbxassetid://107423189403607,PetNew/PetsRoblox/Rank01RB01_Slimee,nil,false,2,0,1,1X,nil
201,ForRBPets,1,rbxassetid://128833722760603,PetNew/PetsRoblox/Roblox01_Infermo,Tiny,true,4,0,1,1X,nil
202,ForRBPets,1,rbxassetid://128833722760603,PetNew/PetsRoblox/Roblox01_Infermo_Mid,Normal,false,4,0,1,1X,nil
203,ForRBPets,1,rbxassetid://128833722760603,PetNew/PetsRoblox/Roblox01_Infermo_Large,Large,false,4,0,1,1X,nil
204,ForRBPets,1,rbxassetid://128833722760603,PetNew/PetsRoblox/Roblox01_Infermo,nil,false,4,0,1,1X,nil
205,ForRBPets,1,rbxassetid://128833722760603,PetNew/PetsRoblox/Roblox01_Infermo,nil,false,4,0,1,1X,nil
206,ForRBPets,1,rbxassetid://82162367145565,PetNew/PetsRoblox/Roblox02_ Loveli,Tiny,true,4,0,1,1X,nil
207,ForRBPets,1,rbxassetid://82162367145565,PetNew/PetsRoblox/Roblox02_ Loveli_Mid,Normal,false,4,0,1,1X,nil
208,ForRBPets,1,rbxassetid://82162367145565,PetNew/PetsRoblox/Roblox02_ Loveli_Large,Large,false,4,0,1,1X,nil
209,ForRBPets,1,rbxassetid://82162367145565,PetNew/PetsRoblox/Roblox02_ Loveli,nil,false,4,0,1,1X,nil
210,ForRBPets,1,rbxassetid://82162367145565,PetNew/PetsRoblox/Roblox02_ Loveli,nil,false,4,0,1,1X,nil
211,ForRBPets,1,rbxassetid://78390941572868,PetNew/PetsRoblox/Roblox03_HaloHex,Tiny,true,4,0,1,1X,nil
212,ForRBPets,1,rbxassetid://78390941572868,PetNew/PetsRoblox/Roblox03_HaloHex_Mid,Normal,false,4,0,1,1X,nil
213,ForRBPets,1,rbxassetid://78390941572868,PetNew/PetsRoblox/Roblox03_HaloHex_Large,Large,false,4,0,1,1X,nil
214,ForRBPets,1,rbxassetid://78390941572868,PetNew/PetsRoblox/Roblox03_HaloHex,nil,false,4,0,1,1X,nil
215,ForRBPets,1,rbxassetid://78390941572868,PetNew/PetsRoblox/Roblox03_HaloHex,nil,false,4,0,1,1X,nil
216,ForRBPets,1,rbxassetid://100764664840612,PetNew/PetsRoblox/Roblox04_Frostbite,Tiny,true,4,0,1,1X,nil
217,ForRBPets,1,rbxassetid://100764664840612,PetNew/PetsRoblox/Roblox04_Frostbite_Mid,Normal,false,4,0,1,1X,nil
218,ForRBPets,1,rbxassetid://100764664840612,PetNew/PetsRoblox/Roblox04_Frostbite_Large,Large,false,4,0,1,1X,nil
219,ForRBPets,1,rbxassetid://100764664840612,PetNew/PetsRoblox/Roblox04_Frostbite,nil,false,4,0,1,1X,nil
220,ForRBPets,1,rbxassetid://100764664840612,PetNew/PetsRoblox/Roblox04_Frostbite,nil,false,4,0,1,1X,nil
221,Cardbox Demonling,4,rbxassetid://138951244810713,PetNew/SignPet/SignOnline01,Tiny,true,4,0,1,1X,nil
222,Cardbox Demonling,4,rbxassetid://138951244810713,PetNew/SignPet/SignOnline01_Mid,Normal,false,4,0,1,1X,nil
223,Cardbox Demonling,4,rbxassetid://138951244810713,PetNew/SignPet/SignOnline01_Large,Large,false,4,0,1,1X,nil
224,Cardbox Demonling,4,rbxassetid://138951244810713,PetNew/SignPet/SignOnline01,nil,false,4,0,1,1X,nil
225,Cardbox Demonling,4,rbxassetid://138951244810713,PetNew/SignPet/SignOnline01,nil,false,4,0,1,1X,nil
226,Stitched Demonkin,4,rbxassetid://112978571737998,PetNew/SignPet/SignOnline02,Tiny,true,4,0,1,1X,nil
227,Stitched Demonkin,4,rbxassetid://112978571737998,PetNew/SignPet/SignOnline02_Mid,Normal,false,4,0,1,1X,nil
228,Stitched Demonkin,4,rbxassetid://112978571737998,PetNew/SignPet/SignOnline02_Large,Large,false,4,0,1,1X,nil
229,Stitched Demonkin,4,rbxassetid://112978571737998,PetNew/SignPet/SignOnline02,nil,false,4,0,1,1X,nil
230,Stitched Demonkin,4,rbxassetid://112978571737998,PetNew/SignPet/SignOnline02,nil,false,4,0,1,1X,nil
231,Rainbowcorn,5,rbxassetid://121468072938857,PetNew/SignPet/SignOnline03,Tiny,true,4,0,1,1X,nil
232,Rainbowcorn,5,rbxassetid://121468072938857,PetNew/SignPet/SignOnline03_Mid,Normal,false,4,0,1,1X,nil
233,Rainbowcorn,5,rbxassetid://121468072938857,PetNew/SignPet/SignOnline03_Large,Large,false,4,0,1,1X,nil
234,Rainbowcorn,5,rbxassetid://121468072938857,PetNew/SignPet/SignOnline03,nil,false,4,0,1,1X,nil
235,Rainbowcorn,5,rbxassetid://121468072938857,PetNew/SignPet/SignOnline03,nil,false,4,0,1,1X,nil
236,Tinker Wyrmling,4,rbxassetid://121041467889399,PetNew/SignPet/Sign701,Tiny,true,4,0,1,1X,nil
237,Tinker Wyrmling,4,rbxassetid://121041467889399,PetNew/SignPet/Sign701_Mid,Normal,false,4,0,1,1X,nil
238,Tinker Wyrmling,4,rbxassetid://121041467889399,PetNew/SignPet/Sign701_Large,Large,false,4,0,1,1X,nil
239,Tinker Wyrmling,4,rbxassetid://121041467889399,PetNew/SignPet/Sign701,nil,false,4,0,1,1X,nil
240,Tinker Wyrmling,4,rbxassetid://121041467889399,PetNew/SignPet/Sign701,nil,false,4,0,1,1X,nil
241,Magic Queen,5,rbxassetid://118184927311617,PetNew/SignPet/Sign702,Tiny,true,4,0,1,1X,nil
242,Magic Queen,5,rbxassetid://118184927311617,PetNew/SignPet/Sign702_Mid,Normal,false,4,0,1,1X,nil
243,Magic Queen,5,rbxassetid://118184927311617,PetNew/SignPet/Sign702_Large,Large,false,4,0,1,1X,nil
244,Magic Queen,5,rbxassetid://118184927311617,PetNew/SignPet/Sign702,nil,false,4,0,1,1X,nil
245,Magic Queen,5,rbxassetid://118184927311617,PetNew/SignPet/Sign702,nil,false,4,0,1,1X,nil
246,Crimson,6,rbxassetid://130219904784080,PetNew/PetsRoblox/Newbie01,Tiny,true,4,2.5,1,250%,ProductStorePet246
247,Crimson,6,rbxassetid://130219904784080,PetNew/PetsRoblox/Newbie01_Mid,Normal,false,4,3,1,300%,nil
248,Crimson,6,rbxassetid://130219904784080,PetNew/PetsRoblox/Newbie01_Large,Large,false,4,3.75,1,375%,nil
249,Crimson,6,rbxassetid://130219904784080,PetNew/PetsRoblox/Newbie01,nil,false,4,0,1,1X,nil
250,Crimson,6,rbxassetid://130219904784080,PetNew/PetsRoblox/Newbie01,nil,false,4,0,1,1X,nil
251,Abyss,6,rbxassetid://80387007915967,PetNew/PetsRoblox/Newbie02,Tiny,true,4,3.25,1,325%,ProductStorePet251
252,Abyss,6,rbxassetid://80387007915967,PetNew/PetsRoblox/Newbie02_Mid,Normal,false,4,3.9,1,390%,nil
253,Abyss,6,rbxassetid://80387007915967,PetNew/PetsRoblox/Newbie02_Large,Large,false,4,4.875,1,487%,nil
254,Abyss,6,rbxassetid://80387007915967,PetNew/PetsRoblox/Newbie02,nil,false,4,0,1,1X,nil
255,Abyss,6,rbxassetid://80387007915967,PetNew/PetsRoblox/Newbie02,nil,false,4,0,1,1X,nil
256,Holywing,6,rbxassetid://96427321607903,PetNew/PetsRoblox/Newbie03,Tiny,true,4,4.5,1,450%,ProductStorePet256
257,Holywing,6,rbxassetid://96427321607903,PetNew/PetsRoblox/Newbie03_Mid,Normal,false,4,5.4,1,540%,nil
258,Holywing,6,rbxassetid://96427321607903,PetNew/PetsRoblox/Newbie03_Large,Large,false,4,6.75,1,675%,nil
259,Holywing,6,rbxassetid://96427321607903,PetNew/PetsRoblox/Newbie03,nil,false,4,0,1,1X,nil
260,Holywing,6,rbxassetid://96427321607903,PetNew/PetsRoblox/Newbie03,nil,false,4,0,1,1X,nil
261,Cryostel,1,rbxassetid://98793576432233,PetNew/Rank03/12M01_Cryostel,Tiny,true,2,0,390000000,x390M,nil
262,Cryostel,1,rbxassetid://98793576432233,PetNew/Rank03/12M01_Cryostel_Mid,Normal,false,2,0,468000000,x468M,nil
263,Cryostel,1,rbxassetid://98793576432233,PetNew/Rank03/12M01_Cryostel_Large,Large,false,2,0,585000000,x585M,nil
264,Cryostel,1,rbxassetid://98793576432233,PetNew/Rank03/12M01_Cryostel,nil,false,2,0,1,x1,nil
265,Cryostel,1,rbxassetid://98793576432233,PetNew/Rank03/12M01_Cryostel,nil,false,2,0,1,x1,nil
266,Aethergem,2,rbxassetid://88351182574814,PetNew/Rank03/12M02_Aethergem,Tiny,true,2,0,1200000000,x1.2B,nil
267,Aethergem,2,rbxassetid://88351182574814,PetNew/Rank03/12M02_Aethergem_Mid,Normal,false,2,0,1440000000,x1.44B,nil
268,Aethergem,2,rbxassetid://88351182574814,PetNew/Rank03/12M02_Aethergem_Large,Large,false,2,0,1800000000,x1.8B,nil
269,Aethergem,2,rbxassetid://88351182574814,PetNew/Rank03/12M02_Aethergem,nil,false,2,0,1,x1,nil
270,Aethergem,2,rbxassetid://88351182574814,PetNew/Rank03/12M02_Aethergem,nil,false,2,0,1,x1,nil
271,Luminova,3,rbxassetid://97958746390784,PetNew/Rank03/12M03_Luminova,Tiny,true,2,0,3600000000,x3.6B,nil
272,Luminova,3,rbxassetid://97958746390784,PetNew/Rank03/12M03_Luminova_Mid,Normal,false,2,0,4320000000,x4.32B,nil
273,Luminova,3,rbxassetid://97958746390784,PetNew/Rank03/12M03_Luminova_Large,Large,false,2,0,5400000000,x5.4B,nil
274,Luminova,3,rbxassetid://97958746390784,PetNew/Rank03/12M03_Luminova,nil,false,2,0,1,x1,nil
275,Luminova,3,rbxassetid://97958746390784,PetNew/Rank03/12M03_Luminova,nil,false,2,0,1,x1,nil
276,Voidion,4,rbxassetid://107423189403607,PetNew/Rank03/12M04_Pyrocore,Tiny,true,2,0,10800000000,x10.8B,nil
277,Voidion,4,rbxassetid://107423189403607,PetNew/Rank03/12M04_Pyrocore_Mid,Normal,false,2,0,12960000000,x12.96B,nil
278,Voidion,4,rbxassetid://107423189403607,PetNew/Rank03/12M04_Pyrocore_Large,Large,false,2,0,16200000000,x16.2B,nil
279,Voidion,4,rbxassetid://107423189403607,PetNew/Rank03/12M04_Pyrocore,nil,false,2,0,1,x1,nil
280,Voidion,4,rbxassetid://107423189403607,PetNew/Rank03/12M04_Pyrocore,nil,false,2,0,1,x1,nil
281,Pyrocore,5,rbxassetid://125673790407899,PetNew/Rank03/12M05_Voidion,Tiny,true,2,0,32000000000,x32B,nil
282,Pyrocore,5,rbxassetid://125673790407899,PetNew/Rank03/12M05_Voidion_Mid,Normal,false,2,0,38400000000,x38.4B,nil
283,Pyrocore,5,rbxassetid://125673790407899,PetNew/Rank03/12M05_Voidion_Large,Large,false,2,0,48000000000,x48B,nil
284,Pyrocore,5,rbxassetid://125673790407899,PetNew/Rank03/12M05_Voidion,nil,false,2,0,1,x1,nil
285,Pyrocore,5,rbxassetid://125673790407899,PetNew/Rank03/12M05_Voidion,nil,false,2,0,1,x1,nil
286,InfernoShard,1,rbxassetid://133150422484036,PetNew/Rank03/52M01,Tiny,true,3,0,94000000000,x94B,nil
287,InfernoShard,1,rbxassetid://133150422484036,PetNew/Rank03/52M01_Mid,Normal,false,3,0,112800000000,x112.8B,nil
288,InfernoShard,1,rbxassetid://133150422484036,PetNew/Rank03/52M01_Large,Large,false,3,0,141000000000,x141B,nil
289,InfernoShard,1,rbxassetid://133150422484036,PetNew/Rank03/52M01,nil,false,3,0,1,x1,nil
290,InfernoShard,1,rbxassetid://133150422484036,PetNew/Rank03/52M01,nil,false,3,0,1,x1,nil
291,VerdantShard,2,rbxassetid://89029589362419,PetNew/Rank03/52M02,Tiny,true,3,0,280000000000,x280B,nil
292,VerdantShard,2,rbxassetid://89029589362419,PetNew/Rank03/52M02_Mid,Normal,false,3,0,336000000000,x336B,nil
293,VerdantShard,2,rbxassetid://89029589362419,PetNew/Rank03/52M02_Large,Large,false,3,0,420000000000,x420B,nil
294,VerdantShard,2,rbxassetid://89029589362419,PetNew/Rank03/52M02,nil,false,3,0,1,x1,nil
295,VerdantShard,2,rbxassetid://89029589362419,PetNew/Rank03/52M02,nil,false,3,0,1,x1,nil
296,FrostShard,3,rbxassetid://103631935951917,PetNew/Rank03/52M03,Tiny,true,3,0,840000000000,x840B,nil
297,FrostShard,3,rbxassetid://103631935951917,PetNew/Rank03/52M03_Mid,Normal,false,3,0,1008000000000,x1.01T,nil
298,FrostShard,3,rbxassetid://103631935951917,PetNew/Rank03/52M03_Large,Large,false,3,0,1260000000000,x1.26T,nil
299,FrostShard,3,rbxassetid://103631935951917,PetNew/Rank03/52M03,nil,false,3,0,1,x1,nil
300,FrostShard,3,rbxassetid://103631935951917,PetNew/Rank03/52M03,nil,false,3,0,1,x1,nil
301,ArcaneShard,4,rbxassetid://81657116913258,PetNew/Rank03/52M04,Tiny,true,3,0,2520000000000,x2.52T,nil
302,ArcaneShard,4,rbxassetid://81657116913258,PetNew/Rank03/52M04_Mid,Normal,false,3,0,3024000000000,x3.02T,nil
303,ArcaneShard,4,rbxassetid://81657116913258,PetNew/Rank03/52M04_Large,Large,false,3,0,3780000000000,x3.78T,nil
304,ArcaneShard,4,rbxassetid://81657116913258,PetNew/Rank03/52M04,nil,false,3,0,1,x1,nil
305,ArcaneShard,4,rbxassetid://81657116913258,PetNew/Rank03/52M04,nil,false,3,0,1,x1,nil
306,VoidShard,5,rbxassetid://139639986153724,PetNew/Rank03/52M05,Tiny,true,3,0,7560000000000,x7.56T,nil
307,VoidShard,5,rbxassetid://139639986153724,PetNew/Rank03/52M05_Mid,Normal,false,3,0,9072000000000,x9.07T,nil
308,VoidShard,5,rbxassetid://139639986153724,PetNew/Rank03/52M05_Large,Large,false,3,0,11340000000000,x11.34T,nil
309,VoidShard,5,rbxassetid://139639986153724,PetNew/Rank03/52M05,nil,false,3,0,1,x1,nil
310,VoidShard,5,rbxassetid://139639986153724,PetNew/Rank03/52M05,nil,false,3,0,1,x1,nil
311,FlameCore,1,rbxassetid://96769369371376,PetNew/Rank03/210M01,Tiny,true,3,0,1,x1,nil
312,FlameCore,1,rbxassetid://96769369371376,PetNew/Rank03/210M01_Mid,Normal,false,3,0,1.2,x1.2,nil
313,FlameCore,1,rbxassetid://96769369371376,PetNew/Rank03/210M01_Large,Large,false,3,0,1.5,x1.5,nil
314,FlameCore,1,rbxassetid://96769369371376,PetNew/Rank03/210M01,nil,false,3,0,1,x1,nil
315,FlameCore,1,rbxassetid://96769369371376,PetNew/Rank03/210M01,nil,false,3,0,1,x1,nil
316,NatureCore,2,rbxassetid://78483603362131,PetNew/Rank03/210M02,Tiny,true,3,0,1,x1,nil
317,NatureCore,2,rbxassetid://78483603362131,PetNew/Rank03/210M02_Mid,Normal,false,3,0,1.2,x1.2,nil
318,NatureCore,2,rbxassetid://78483603362131,PetNew/Rank03/210M02_Large,Large,false,3,0,1.5,x1.5,nil
319,NatureCore,2,rbxassetid://78483603362131,PetNew/Rank03/210M02,nil,false,3,0,1,x1,nil
320,NatureCore,2,rbxassetid://78483603362131,PetNew/Rank03/210M02,nil,false,3,0,1,x1,nil
321,ShadowCore,3,rbxassetid://107028468395283,PetNew/Rank03/210M03,Tiny,true,3,0,1,x1,nil
322,ShadowCore,3,rbxassetid://107028468395283,PetNew/Rank03/210M03_Mid,Normal,false,3,0,1.2,x1.2,nil
323,ShadowCore,3,rbxassetid://107028468395283,PetNew/Rank03/210M03_Large,Large,false,3,0,1.5,x1.5,nil
324,ShadowCore,3,rbxassetid://107028468395283,PetNew/Rank03/210M03,nil,false,3,0,1,x1,nil
325,ShadowCore,3,rbxassetid://107028468395283,PetNew/Rank03/210M03,nil,false,3,0,1,x1,nil
326,AngelCore,4,rbxassetid://77099667734453,PetNew/Rank03/210M04,Tiny,true,3,0,1,x1,nil
327,AngelCore,4,rbxassetid://77099667734453,PetNew/Rank03/210M04_Mid,Normal,false,3,0,1.2,x1.2,nil
328,AngelCore,4,rbxassetid://77099667734453,PetNew/Rank03/210M04_Large,Large,false,3,0,1.5,x1.5,nil
329,AngelCore,4,rbxassetid://77099667734453,PetNew/Rank03/210M04,nil,false,3,0,1,x1,nil
330,AngelCore,4,rbxassetid://77099667734453,PetNew/Rank03/210M04,nil,false,3,0,1,x1,nil
331,SunCore,5,rbxassetid://71619341682288,PetNew/Rank03/210M05,Tiny,true,3,0,1,x1,nil
332,SunCore,5,rbxassetid://71619341682288,PetNew/Rank03/210M05_Mid,Normal,false,3,0,1.2,x1.2,nil
333,SunCore,5,rbxassetid://71619341682288,PetNew/Rank03/210M05_Large,Large,false,3,0,1.5,x1.5,nil
334,SunCore,5,rbxassetid://71619341682288,PetNew/Rank03/210M05,nil,false,3,0,1,x1,nil
335,SunCore,5,rbxassetid://71619341682288,PetNew/Rank03/210M05,nil,false,3,0,1,x1,nil
336,ForRBPets,1,rbxassetid://99175632344236,PetNew/RB,Tiny,true,3,0,23000000000000,x23T,nil
337,ForRBPets,1,rbxassetid://99175632344236,PetNew/RB,Normal,false,3,0,27600000000000,x27.6T,nil
338,ForRBPets,1,rbxassetid://99175632344236,PetNew/RB,Large,false,3,0,34500000000000,x34.5T,nil
339,ForRBPets,1,rbxassetid://99175632344236,PetNew/RB,nil,false,3,0,1,x1,nil
340,ForRBPets,1,rbxassetid://99175632344236,PetNew/RB,nil,false,3,0,1,x1,nil
341,ForRBPets,1,rbxassetid://122403592627819,PetNew/RB,Tiny,true,3,0,69000000000000,x69T,nil
342,ForRBPets,1,rbxassetid://122403592627819,PetNew/RB,Normal,false,3,0,82800000000000,x82.8T,nil
343,ForRBPets,1,rbxassetid://122403592627819,PetNew/RB,Large,false,3,0,103500000000000,x103.5T,nil
344,ForRBPets,1,rbxassetid://122403592627819,PetNew/RB,nil,false,3,0,1,x1,nil
345,ForRBPets,1,rbxassetid://122403592627819,PetNew/RB,nil,false,3,0,1,x1,nil
346,ForRBPets,1,rbxassetid://111137937410636,PetNew/RB,Tiny,true,3,0,207000000000000,x207T,nil
347,ForRBPets,1,rbxassetid://111137937410636,PetNew/RB,Normal,false,3,0,248400000000000,x248.4T,nil
348,ForRBPets,1,rbxassetid://111137937410636,PetNew/RB,Large,false,3,0,310500000000000,x310.5T,nil
349,ForRBPets,1,rbxassetid://111137937410636,PetNew/RB,nil,false,3,0,1,x1,nil
350,ForRBPets,1,rbxassetid://111137937410636,PetNew/RB,nil,false,3,0,1,x1,nil
351,ForRBPets,1,rbxassetid://87419362750249,PetNew/RB,Tiny,true,3,0,621000000000000,x621T,nil
352,ForRBPets,1,rbxassetid://87419362750249,PetNew/RB,Normal,false,3,0,745200000000000,x745.2T,nil
353,ForRBPets,1,rbxassetid://87419362750249,PetNew/RB,Large,false,3,0,931500000000000,x931.5T,nil
354,ForRBPets,1,rbxassetid://87419362750249,PetNew/RB,nil,false,3,0,1,x1,nil
355,ForRBPets,1,rbxassetid://87419362750249,PetNew/RB,nil,false,3,0,1,x1,nil
356,Hipopotamo,2,rbxassetid://95979472459104,PetNew/PetsRoblox/Brainrot01,Tiny,true,4,1.45,1,145%,nil
357,Hipopotamo,2,rbxassetid://95979472459104,PetNew/PetsRoblox/Brainrot01_Mid,Normal,false,4,1.74,1,174%,nil
358,Hipopotamo,2,rbxassetid://95979472459104,PetNew/PetsRoblox/Brainrot01_Large,Large,false,4,2.175,1,217%,nil
359,Hipopotamo,2,rbxassetid://95979472459104,PetNew/PetsRoblox/Brainrot01,nil,false,4,0,1,1X,nil
360,Hipopotamo,2,rbxassetid://95979472459104,PetNew/PetsRoblox/Brainrot01,nil,false,4,0,1,1X,nil
361,Teapot,2,rbxassetid://93031478294312,PetNew/PetsRoblox/Brainrot02,Tiny,true,4,1.75,1,175%,nil
362,Teapot,2,rbxassetid://93031478294312,PetNew/PetsRoblox/Brainrot02_Mid,Normal,false,4,2.1,1,210%,nil
363,Teapot,2,rbxassetid://93031478294312,PetNew/PetsRoblox/Brainrot02_Large,Large,false,4,2.625,1,262%,nil
364,Teapot,2,rbxassetid://93031478294312,PetNew/PetsRoblox/Brainrot02,nil,false,4,0,1,1X,nil
365,Teapot,2,rbxassetid://93031478294312,PetNew/PetsRoblox/Brainrot02,nil,false,4,0,1,1X,nil
366,Odin DinDin Dun,3,rbxassetid://94959290083015,PetNew/PetsRoblox/Brainrot03,Tiny,true,4,2.1,1,210%,nil
367,Odin DinDin Dun,3,rbxassetid://94959290083015,PetNew/PetsRoblox/Brainrot03_Mid,Normal,false,4,2.52,1,252%,nil
368,Odin DinDin Dun,3,rbxassetid://94959290083015,PetNew/PetsRoblox/Brainrot03_Large,Large,false,4,3.15,1,315%,nil
369,Odin DinDin Dun,3,rbxassetid://94959290083015,PetNew/PetsRoblox/Brainrot03,nil,false,4,0,1,1X,nil
370,Odin DinDin Dun,3,rbxassetid://94959290083015,PetNew/PetsRoblox/Brainrot03,nil,false,4,0,1,1X,nil
371,Chimpanzini Bananini,4,rbxassetid://100896048702275,PetNew/PetsRoblox/Brainrot04,Tiny,true,4,2.7,1,270%,nil
372,Chimpanzini Bananini,4,rbxassetid://100896048702275,PetNew/PetsRoblox/Brainrot04_Mid,Normal,false,4,3.24,1,324%,nil
373,Chimpanzini Bananini,4,rbxassetid://100896048702275,PetNew/PetsRoblox/Brainrot04_Large,Large,false,4,4.05,1,405%,nil
374,Chimpanzini Bananini,4,rbxassetid://100896048702275,PetNew/PetsRoblox/Brainrot04,nil,false,4,0,1,1X,nil
375,Chimpanzini Bananini,4,rbxassetid://100896048702275,PetNew/PetsRoblox/Brainrot04,nil,false,4,0,1,1X,nil
376,Tralalero Tralala,5,rbxassetid://130142716335793,PetNew/PetsRoblox/Brainrot05,Tiny,true,4,3.6,1,360%,nil
377,Tralalero Tralala,5,rbxassetid://130142716335793,PetNew/PetsRoblox/Brainrot05_Mid,Normal,false,4,4.32,1,432%,nil
378,Tralalero Tralala,5,rbxassetid://130142716335793,PetNew/PetsRoblox/Brainrot05_Large,Large,false,4,5.4,1,540%,nil
379,Tralalero Tralala,5,rbxassetid://130142716335793,PetNew/PetsRoblox/Brainrot05,nil,false,4,0,1,1X,nil
380,Tralalero Tralala,5,rbxassetid://130142716335793,PetNew/PetsRoblox/Brainrot05,nil,false,4,0,1,1X,nil
381,Ragekin,2,rbxassetid://107457012377726,PetNew/Season/Season01Pet01,Tiny,true,5,1,1,100%,nil
382,Ragekin,2,rbxassetid://107457012377726,PetNew/Season/Season01Pet01_Mid,Normal,false,5,1.2,1,120%,nil
383,Ragekin,2,rbxassetid://107457012377726,PetNew/Season/Season01Pet01_Large,Large,false,5,1.5,1,150%,nil
384,Ragekin,2,rbxassetid://107457012377726,PetNew/Season/Season01Pet01,nil,false,5,0,1,1X,nil
385,Ragekin,2,rbxassetid://107457012377726,PetNew/Season/Season01Pet01,nil,false,5,0,1,1X,nil
386,Blossom Wisp,3,rbxassetid://112122956502520,PetNew/Season/Season01Pet02,Tiny,true,5,1.5,1,150%,nil
387,Blossom Wisp,3,rbxassetid://112122956502520,PetNew/Season/Season01Pet02_Mid,Normal,false,5,1.8,1,180%,nil
388,Blossom Wisp,3,rbxassetid://112122956502520,PetNew/Season/Season01Pet02_Large,Large,false,5,2.25,1,225%,nil
389,Blossom Wisp,3,rbxassetid://112122956502520,PetNew/Season/Season01Pet02,nil,false,5,0,1,1X,nil
390,Blossom Wisp,3,rbxassetid://112122956502520,PetNew/Season/Season01Pet02,nil,false,5,0,1,1X,nil
391,Frostbite,4,rbxassetid://110869709499336,PetNew/Season/Season01Pet03,Tiny,true,5,2,1,200%,nil
392,Frostbite,4,rbxassetid://110869709499336,PetNew/Season/Season01Pet03_Mid,Normal,false,5,2.4,1,240%,nil
393,Frostbite,4,rbxassetid://110869709499336,PetNew/Season/Season01Pet03_Large,Large,false,5,3,1,300%,nil
394,Frostbite,4,rbxassetid://110869709499336,PetNew/Season/Season01Pet03,nil,false,5,0,1,1X,nil
395,Frostbite,4,rbxassetid://110869709499336,PetNew/Season/Season01Pet03,nil,false,5,0,1,1X,nil
396,Barrel Blitz,6,rbxassetid://134167782460094,PetNew/Season/Season01Pet04,Tiny,true,5,2.5,1,250%,nil
397,Barrel Blitz,6,rbxassetid://134167782460094,PetNew/Season/Season01Pet04_Mid,Normal,false,5,3,1,300%,nil
398,Barrel Blitz,6,rbxassetid://134167782460094,PetNew/Season/Season01Pet04_Large,Large,false,5,3.75,1,375%,nil
399,Barrel Blitz,6,rbxassetid://134167782460094,PetNew/Season/Season01Pet04,nil,false,5,0,1,1X,nil
400,Barrel Blitz,6,rbxassetid://134167782460094,PetNew/Season/Season01Pet04,nil,false,5,0,1,1X,nil
401,ToxiSkull,5,rbxassetid://125967433540956,PetNew/Season/Season01Pet05,Tiny,false,5,3,1,300%,nil
402,ToxiSkull,5,rbxassetid://125967433540956,PetNew/Season/Season01Pet05_Mid,Normal,false,5,3.6,1,360%,nil
403,ToxiSkull,5,rbxassetid://125967433540956,PetNew/Season/Season01Pet05_Large,Large,true,5,4.5,1,450%,nil
404,ToxiSkull,5,rbxassetid://125967433540956,PetNew/Season/Season01Pet05,nil,false,5,0,1,1X,nil
405,ToxiSkull,5,rbxassetid://125967433540956,PetNew/Season/Season01Pet05,nil,false,5,0,1,1X,nil
406,Frost Cub,3,rbxassetid://91005074061121,PetNew/Christmas/ChristmasPet01,Tiny,true,5,0,6,6X,nil
407,Frost Cub,3,rbxassetid://91005074061121,PetNew/Christmas/ChristmasPet01_Mid,Normal,false,5,0,7.2,7.2X,nil
408,Frost Cub,3,rbxassetid://91005074061121,PetNew/Christmas/ChristmasPet01_Large,Large,false,5,0,9,9X,nil
409,Frost Cub,3,rbxassetid://91005074061121,PetNew/Christmas/ChristmasPet01,nil,false,5,0,1,1X,nil
410,Frost Cub,3,rbxassetid://91005074061121,PetNew/Christmas/ChristmasPet01,nil,false,5,0,1,1X,nil
411,Pinky Waddle,4,rbxassetid://70465789424927,PetNew/Christmas/ChristmasPet02,Tiny,true,5,0,6,6X,nil
412,Pinky Waddle,4,rbxassetid://70465789424927,PetNew/Christmas/ChristmasPet02_Mid,Normal,false,5,0,7.2,7.2X,nil
413,Pinky Waddle,4,rbxassetid://70465789424927,PetNew/Christmas/ChristmasPet02_Large,Large,false,5,0,9,9X,nil
414,Pinky Waddle,4,rbxassetid://70465789424927,PetNew/Christmas/ChristmasPet02,nil,false,5,0,1,1X,nil
415,Pinky Waddle,4,rbxassetid://70465789424927,PetNew/Christmas/ChristmasPet02,nil,false,5,0,1,1X,nil
416,Flame Tail,6,rbxassetid://90057588146086,PetNew/Christmas/ChristmasPet03,Tiny,true,5,0,6,6X,nil
417,Flame Tail,6,rbxassetid://90057588146086,PetNew/Christmas/ChristmasPet03_Mid,Normal,false,5,0,7.2,7.2X,nil
418,Flame Tail,6,rbxassetid://90057588146086,PetNew/Christmas/ChristmasPet03_Large,Large,false,5,0,9,9X,nil
419,Flame Tail,6,rbxassetid://90057588146086,PetNew/Christmas/ChristmasPet03,nil,false,5,0,1,1X,nil
420,Flame Tail,6,rbxassetid://90057588146086,PetNew/Christmas/ChristmasPet03,nil,false,5,0,1,1X,nil
421,Sir Whisker,6,rbxassetid://88902898550793,PetNew/Christmas/ChristmasPet04,Tiny,true,5,0,6,6X,nil
422,Sir Whisker,6,rbxassetid://88902898550793,PetNew/Christmas/ChristmasPet04_Mid,Normal,false,5,0,7.2,7.2X,nil
423,Sir Whisker,6,rbxassetid://88902898550793,PetNew/Christmas/ChristmasPet04_Large,Large,false,5,0,9,9X,nil
424,Sir Whisker,6,rbxassetid://88902898550793,PetNew/Christmas/ChristmasPet04,nil,false,5,0,1,1X,nil
425,Sir Whisker,6,rbxassetid://88902898550793,PetNew/Christmas/ChristmasPet04,nil,false,5,0,1,1X,nil
426,Snowmelt,5,rbxassetid://84442185399942,PetNew/Christmas/ChristmasPet05,Tiny,false,5,0,6,6X,nil
427,Snowmelt,5,rbxassetid://84442185399942,PetNew/Christmas/ChristmasPet05_Mid,Normal,false,5,0,7.2,7.2X,nil
428,Snowmelt,5,rbxassetid://84442185399942,PetNew/Christmas/ChristmasPet05_Large,Large,true,5,0,9,9X,nil
429,Snowmelt,5,rbxassetid://84442185399942,PetNew/Christmas/ChristmasPet05,nil,false,5,0,1,1X,nil
430,Snowmelt,5,rbxassetid://84442185399942,PetNew/Christmas/ChristmasPet05,nil,false,5,0,1,1X,nil
431,SlimeBud,1,rbxassetid://120139927477903,PetNew/Rank04/840M01,Tiny,true,3,0,23000000000000,x23T,nil
432,SlimeBud,1,rbxassetid://120139927477903,PetNew/Rank04/840M01_Mid,Normal,false,3,0,27600000000000,x27.6T,nil
433,SlimeBud,1,rbxassetid://120139927477903,PetNew/Rank04/840M01_Large,Large,false,3,0,34500000000000,x34.5T,nil
434,SlimeBud,1,rbxassetid://120139927477903,PetNew/Rank04/840M01,nil,false,3,0,1,x1,nil
435,SlimeBud,1,rbxassetid://120139927477903,PetNew/Rank04/840M01,nil,false,3,0,1,x1,nil
436,CrystalCrab,2,rbxassetid://81273924367666,PetNew/Rank04/840M02,Tiny,true,3,0,69000000000000,x69T,nil
437,CrystalCrab,2,rbxassetid://81273924367666,PetNew/Rank04/840M02_Mid,Normal,false,3,0,82800000000000,x82.8T,nil
438,CrystalCrab,2,rbxassetid://81273924367666,PetNew/Rank04/840M02_Large,Large,false,3,0,103500000000000,x103.5T,nil
439,CrystalCrab,2,rbxassetid://81273924367666,PetNew/Rank04/840M02,nil,false,3,0,1,x1,nil
440,CrystalCrab,2,rbxassetid://81273924367666,PetNew/Rank04/840M02,nil,false,3,0,1,x1,nil
441,ArcaneClaw,3,rbxassetid://105493313037234,PetNew/Rank04/840M03,Tiny,true,3,0,207000000000000,x207T,nil
442,ArcaneClaw,3,rbxassetid://105493313037234,PetNew/Rank04/840M03_Mid,Normal,false,3,0,248400000000000,x248.4T,nil
443,ArcaneClaw,3,rbxassetid://105493313037234,PetNew/Rank04/840M03_Lare,Large,false,3,0,310500000000000,x310.5T,nil
444,ArcaneClaw,3,rbxassetid://105493313037234,PetNew/Rank04/840M03,nil,false,3,0,1,x1,nil
445,ArcaneClaw,3,rbxassetid://105493313037234,PetNew/Rank04/840M03,nil,false,3,0,1,x1,nil
446,FlameBrute,4,rbxassetid://128186301865101,PetNew/Rank04/840M04,Tiny,true,3,0,621000000000000,x621T,nil
447,FlameBrute,4,rbxassetid://128186301865101,PetNew/Rank04/840M04_Mid,Normal,false,3,0,745200000000000,x745.2T,nil
448,FlameBrute,4,rbxassetid://128186301865101,PetNew/Rank04/840M04_Large,Large,false,3,0,931500000000000,x931.5T,nil
449,FlameBrute,4,rbxassetid://128186301865101,PetNew/Rank04/840M04,nil,false,3,0,1,x1,nil
450,FlameBrute,4,rbxassetid://128186301865101,PetNew/Rank04/840M04,nil,false,3,0,1,x1,nil
451,SolarDominator,5,rbxassetid://132828270324812,PetNew/Rank04/840M05,Tiny,true,3,0,1863000000000000,x1.86Qa,nil
452,SolarDominator,5,rbxassetid://132828270324812,PetNew/Rank04/840M05_Mid,Normal,false,3,0,2235600000000000,x2.24Qa,nil
453,SolarDominator,5,rbxassetid://132828270324812,PetNew/Rank04/840M05_Large,Large,false,3,0,2794500000000000,x2.79Qa,nil
454,SolarDominator,5,rbxassetid://132828270324812,PetNew/Rank04/840M05,nil,false,3,0,1,x1,nil
455,SolarDominator,5,rbxassetid://132828270324812,PetNew/Rank04/840M05,nil,false,3,0,1,x1,nil
456,EmeraldGem,1,rbxassetid://99175632344236,PetNew/Rank04/3B01,Tiny,true,3,0,5600000000000000,x5.6Qa,nil
457,EmeraldGem,1,rbxassetid://99175632344236,PetNew/Rank04/3B01_Mid,Normal,false,3,0,6720000000000000,x6.72Qa,nil
458,EmeraldGem,1,rbxassetid://99175632344236,PetNew/Rank04/3B01_Large,Large,false,3,0,8400000000000000,x8.4Qa,nil
459,EmeraldGem,1,rbxassetid://99175632344236,PetNew/Rank04/3B01,nil,false,3,0,1,x1,nil
460,EmeraldGem,1,rbxassetid://99175632344236,PetNew/Rank04/3B01,nil,false,3,0,1,x1,nil
461,SapphireGem,2,rbxassetid://122403592627819,PetNew/Rank04/3B02,Tiny,true,3,0,16800000000000000,x16.8Qa,nil
462,SapphireGem,2,rbxassetid://122403592627819,PetNew/Rank04/3B02_Mid,Normal,false,3,0,20160000000000000,x20.16Qa,nil
463,SapphireGem,2,rbxassetid://122403592627819,PetNew/Rank04/3B02_Large,Large,false,3,0,25200000000000000,x25.2Qa,nil
464,SapphireGem,2,rbxassetid://122403592627819,PetNew/Rank04/3B02,nil,false,3,0,1,x1,nil
465,SapphireGem,2,rbxassetid://122403592627819,PetNew/Rank04/3B02,nil,false,3,0,1,x1,nil
466,Amethyst Crown,3,rbxassetid://111137937410636,PetNew/Rank04/3B03,Tiny,true,3,0,50400000000000000,x50.4Qa,nil
467,Amethyst Crown,3,rbxassetid://111137937410636,PetNew/Rank04/3B03_Mid,Normal,false,3,0,60480000000000000,x60.48Qa,nil
468,Amethyst Crown,3,rbxassetid://111137937410636,PetNew/Rank04/3B03_Large,Large,false,3,0,75600000000000000,x75.6Qa,nil
469,Amethyst Crown,3,rbxassetid://111137937410636,PetNew/Rank04/3B03,nil,false,3,0,1,x1,nil
470,Amethyst Crown,3,rbxassetid://111137937410636,PetNew/Rank04/3B03,nil,false,3,0,1,x1,nil
471,Ruby Wings,4,rbxassetid://87419362750249,PetNew/Rank04/3B04,Tiny,true,3,0,151200000000000000,x151.2Qa,nil
472,Ruby Wings,4,rbxassetid://87419362750249,PetNew/Rank04/3B04_Mid,Normal,false,3,0,181440000000000000,x181.44Qa,nil
473,Ruby Wings,4,rbxassetid://87419362750249,PetNew/Rank04/3B04_Large,Large,false,3,0,226800000000000000,x226.8Qa,nil
474,Ruby Wings,4,rbxassetid://87419362750249,PetNew/Rank04/3B04,nil,false,3,0,1,x1,nil
475,Ruby Wings,4,rbxassetid://87419362750249,PetNew/Rank04/3B04,nil,false,3,0,1,x1,nil
476,Golden Relic,5,rbxassetid://124374738935791,PetNew/Rank04/3B05,Tiny,true,3,0,453600000000000000,x453.6Qa,nil
477,Golden Relic,5,rbxassetid://124374738935791,PetNew/Rank04/3B05_Mid,Normal,false,3,0,544320000000000000,x544.32Qa,nil
478,Golden Relic,5,rbxassetid://124374738935791,PetNew/Rank04/3B05_Large,Large,false,3,0,680400000000000000,x680.4Qa,nil
479,Golden Relic,5,rbxassetid://124374738935791,PetNew/Rank04/3B05,nil,false,3,0,1,x1,nil
480,Golden Relic,5,rbxassetid://124374738935791,PetNew/Rank04/3B05,nil,false,3,0,1,x1,nil
]]

return PetConfig
