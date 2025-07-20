-- PCL Pet Data
-- Generated from Simple Armory data by generate_data_lua.py
-- This file provides the main pet collection data for the PCL addon

local _, PCLcore = ...;

PCLcore.sectionNames = {
    { name = "General" },
    { name = "Limited Time" },
    { name = "The War Within" },
    { name = "Dragonflight" },
    { name = "Shadowlands" },
    { name = "Battle for Azeroth" },
    { name = "Legion" },
    { name = "Warlords of Draenor" },
    { name = "Mists of Pandaria" },
    { name = "Cataclysm" },
    { name = "Wrath of the Lich King" },
    { name = "The Burning Crusade" },
    { name = "Classic" },
    { name = "World Event" },
    { name = "Profession" },
    { name = "Pet Battle Dungeon" },
    { name = "Raiding With Leashes" },
    { name = "Promotional" },
    { name = "Other" },
    { name = "Multiple Continents" },
}

PCLcore.petList = {
    ["1"] = {
        name = "General",
        categories = {
            ["Collect"] = {
                name = "Collect",
                pets = {
                    "160", "203", "323", "325", "255", "821", "855", "1546", "2401", "2003",
                    "3264", "3263", "3262", "3265",
                },
            },
            ["Toys"] = {
                name = "Toys",
                pets = {
                    "2402",
                },
            },
            ["Honor"] = {
                name = "Honor",
                pets = {
                    "1918", "1979", "1978", "2478",
                },
            },
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "856", "250", "820", "1605", "1184",
                },
            },
        },
    },
    ["2"] = {
        name = "Limited Time",
        categories = {
            ["Trading Post: July"] = {
                name = "Trading Post: July",
                pets = {
                    "3582",
                },
            },
            ["Promotions"] = {
                name = "Promotions",
                pets = {
                    "4595",
                },
            },
            ["Greedy Emissary"] = {
                name = "Greedy Emissary",
                pets = {
                    "3580",
                },
            },
            ["Trading Post Originals"] = {
                name = "Trading Post Originals",
                pets = {
                    "3252", "3250", "3243", "3251", "4253", "3244", "3255", "4311", "3297", "4407",
                    "4408", "4402", "4286", "4436", "4548", "4565", "4566", "4602", "3542", "4669",
                    "4718", "4719", "4729", "4728", "4757", "4793",
                },
            },
            ["Trading Post Re-Releases"] = {
                name = "Trading Post Re-Releases",
                pets = {
                    "168", "179", "249", "248", "242",
                },
            },
        },
    },
    ["3"] = {
        name = "The War Within",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "4517", "4581", "4500", "4490", "4631", "4664", "3518",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "4462", "4520", "4542", "4570", "4582", "4465", "4708", "4642", "4701",
                },
            },
            ["Treasure"] = {
                name = "Treasure",
                pets = {
                    "4467", "4470", "4473", "4513", "4527", "4534", "4536", "4599", "3362", "4594",
                    "4596", "4472",
                },
            },
            ["Renown"] = {
                name = "Renown",
                pets = {
                    "4463", "4464", "4476", "4491", "4492", "4530", "4576", "4455", "4794", "4804",
                },
            },
            ["Raid Renown"] = {
                name = "Raid Renown",
                pets = {
                    "4640", "4643",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "4645", "4632", "4637", "4641",
                },
            },
            ["Delves"] = {
                name = "Delves",
                pets = {
                    "4543", "4489", "4496", "4506", "4537", "4575", "4647",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "4597", "4598", "4727", "4661", "4648", "4649", "4650", "4644", "4638", "4756",
                },
            },
            ["S.C.R.A.P."] = {
                name = "S.C.R.A.P.",
                pets = {
                    "4653", "4655", "4639",
                },
            },
            ["Shipping and Handling"] = {
                name = "Shipping and Handling",
                pets = {
                    "4646", "4636",
                },
            },
            ["Pet Charm"] = {
                name = "Pet Charm",
                pets = {
                    "4495", "4511", "4524", "4546", "4586",
                },
            },
            ["Dungeon Drop"] = {
                name = "Dungeon Drop",
                pets = {
                    "4469", "4759",
                },
            },
            ["Siren Isle"] = {
                name = "Siren Isle",
                pets = {
                    "4726", "2541", "4724", "4628", "4702", "4703", "4710", "4711", "4723", "4731",
                    "4732",
                },
            },
            ["Visions Revisited"] = {
                name = "Visions Revisited",
                pets = {
                    "4747", "4748", "4750", "4749",
                },
            },
            ["Multiple Zones"] = {
                name = "Multiple Zones",
                pets = {
                    "4456", "4457", "4498", "4499", "4510", "4514", "4518", "4521", "4522", "4526",
                    "4533", "4535", "4541", "4571", "4573", "4485", "4515", "4516",
                },
            },
            ["Isle of Dorn"] = {
                name = "Isle of Dorn",
                pets = {
                    "3361", "4525", "4529", "4538", "4539", "4540", "4577",
                },
            },
            ["The Ringing Deeps"] = {
                name = "The Ringing Deeps",
                pets = {
                    "4574", "3547", "4507", "4484",
                },
            },
            ["Hallowfall"] = {
                name = "Hallowfall",
                pets = {
                    "4460", "4461", "4544",
                },
            },
            ["Azj-Kahet"] = {
                name = "Azj-Kahet",
                pets = {
                    "4471", "4477", "4480", "4481", "4483", "3550",
                },
            },
            ["Undermine"] = {
                name = "Undermine",
                pets = {
                    "4651", "4652", "4654", "4656", "4657", "4658", "4660", "4662", "4663", "4667",
                    "4668", "4693",
                },
            },
            ["Zuldazar"] = {
                name = "Zuldazar",
                pets = {
                    "4659", "4666",
                },
            },
        },
    },
    ["4"] = {
        name = "Dragonflight",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "3406", "3279", "3294", "3493", "3557", "3555", "4285", "4288", "4291",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "3302", "3368", "3319", "3350", "3405", "3316", "3286", "3342", "3292", "3536",
                    "3538", "3540", "3578", "3596", "3553", "4297", "3552",
                },
            },
            ["Pet Charm"] = {
                name = "Pet Charm",
                pets = {
                    "3278", "3408", "3416", "3270", "3417", "3530", "3407",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "3287", "3382", "3334", "3303", "3376", "3259", "3330", "3427", "3528", "3529",
                    "3535", "3537", "4255", "4257", "4258", "4259", "4260", "4261", "4262", "4287",
                    "4289", "4290", "4292", "4300", "4307", "4308", "4309", "4310", "3516", "3523",
                },
            },
            ["Storm Events"] = {
                name = "Storm Events",
                pets = {
                    "3289", "3299", "3310", "3355",
                },
            },
            ["Treasure"] = {
                name = "Treasure",
                pets = {
                    "3269", "3275", "3309", "3321", "3365", "3415", "3359", "3338", "3521", "3533",
                    "3545",
                },
            },
            ["Zapthrottle Soul Inhaler"] = {
                name = "Zapthrottle Soul Inhaler",
                pets = {
                    "3409", "3410", "3411", "3412",
                },
            },
            ["Renown"] = {
                name = "Renown",
                pets = {
                    "3380", "3381", "3317", "3284", "3326", "3378", "3379",
                },
            },
            ["Grand Hunt"] = {
                name = "Grand Hunt",
                pets = {
                    "3311", "3325",
                },
            },
            ["Riddle"] = {
                name = "Riddle",
                pets = {
                    "3360", "3581",
                },
            },
            ["Obsidian Citadel"] = {
                name = "Obsidian Citadel",
                pets = {
                    "3414",
                },
            },
            ["The Forbidden Reach"] = {
                name = "The Forbidden Reach",
                pets = {
                    "3261", "3285", "3291", "3293", "3446", "3447", "3448", "3449",
                },
            },
            ["Zskera Vaults"] = {
                name = "Zskera Vaults",
                pets = {
                    "3476", "3331", "3323", "3332", "3333", "3290",
                },
            },
            ["World Events"] = {
                name = "World Events",
                pets = {
                    "3511", "3512", "3524", "4263",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "3541", "3546", "3548", "3551",
                },
            },
            ["Whelp Daycare"] = {
                name = "Whelp Daycare",
                pets = {
                    "3589", "3588", "3590", "3597", "3598", "3515", "3599", "3600", "3601", "3602",
                },
            },
            ["Emerald Bounty"] = {
                name = "Emerald Bounty",
                pets = {
                    "4295", "4296", "4298", "4299", "4305", "4306",
                },
            },
            ["Archives"] = {
                name = "Archives",
                pets = {
                    "4411", "4412",
                },
            },
            ["Pre-launch Event"] = {
                name = "Pre-launch Event",
                pets = {
                    "3348",
                },
            },
            ["Multiple Zones"] = {
                name = "Multiple Zones",
                pets = {
                    "3272", "3276", "3281", "3282", "3283", "3288", "3295", "3296", "3300", "3301",
                    "3307", "3313", "3322", "3328", "3336", "3351", "3353", "3366",
                },
            },
            ["The Waking Shores"] = {
                name = "The Waking Shores",
                pets = {
                    "3273", "3280", "3318", "3367", "3385",
                },
            },
            ["Ohn'ahran Plains"] = {
                name = "Ohn'ahran Plains",
                pets = {
                    "3266", "3327", "3329", "3389",
                },
            },
            ["The Azure Span"] = {
                name = "The Azure Span",
                pets = {
                    "3260", "3320", "3335", "3354", "3356", "3357",
                },
            },
            ["Thaldraszus"] = {
                name = "Thaldraszus",
                pets = {
                    "3352", "3358", "3403", "3404", "3384",
                },
            },
            ["Zaralek Cavern"] = {
                name = "Zaralek Cavern",
                pets = {
                    "3477", "3478", "3479", "3480", "3481", "3482", "3483", "3484", "3485", "3486",
                    "3487", "3488", "3489", "3490",
                },
            },
            ["The Emerald Dream"] = {
                name = "The Emerald Dream",
                pets = {
                    "4275", "4276", "4277", "4278", "4279", "4280", "4302", "4303", "4304",
                },
            },
        },
    },
    ["5"] = {
        name = "Shadowlands",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "3041", "3067", "3079", "3101", "3132", "3221",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "2798", "2878", "2888", "2900", "2928", "3025", "3066", "3127", "3237",
                },
            },
            ["Pet Charm"] = {
                name = "Pet Charm",
                pets = {
                    "2910", "2917", "3017", "3097",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "3104", "3105", "3106", "3113", "3247",
                },
            },
            ["Adventures"] = {
                name = "Adventures",
                pets = {
                    "2922", "2942", "2946", "3020",
                },
            },
            ["Maw Assaults"] = {
                name = "Maw Assaults",
                pets = {
                    "3010", "3098", "3099", "3103", "3114", "3116",
                },
            },
            ["Treasure"] = {
                name = "Treasure",
                pets = {
                    "2894", "2901", "2905", "2909", "2911", "2914", "2921", "2935", "2938", "2947",
                    "2949", "2952", "3008", "3009", "3013", "3022", "3045", "2944", "3047", "3172",
                },
            },
            ["Zone"] = {
                name = "Zone",
                pets = {
                    "2903", "3038", "3039", "3065", "3121", "3125",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "2892", "2891", "2893", "2896", "2897", "2907", "2908", "2920", "2925", "2932",
                    "2940", "2948", "2953", "2955", "2956", "2957", "2960", "2964", "3035", "3037",
                    "3040", "3063", "3117", "3136",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "2899", "2915", "2934", "2962", "3019", "3054", "3138",
                },
            },
            ["Paragon Reputation"] = {
                name = "Paragon Reputation",
                pets = {
                    "2916", "2959", "3064", "3006", "3133", "3137", "3140",
                },
            },
            ["Dungeon Drop"] = {
                name = "Dungeon Drop",
                pets = {
                    "2898", "2961", "3044", "3110",
                },
            },
            ["Raid Drop"] = {
                name = "Raid Drop",
                pets = {
                    "3036", "3122", "3128", "3129", "3131",
                },
            },
            ["Torghast"] = {
                name = "Torghast",
                pets = {
                    "3026", "3027", "3028", "3029", "3030", "3032", "3033", "3034", "3130",
                },
            },
            ["Covenant Sanctum"] = {
                name = "Covenant Sanctum",
                pets = {
                    "2904", "2912", "2931", "2945", "2954", "2923", "2933", "2965",
                },
            },
            ["Kyrian"] = {
                name = "Kyrian",
                pets = {
                    "3042", "2918", "2941", "3061", "3062",
                },
            },
            ["Necrolords"] = {
                name = "Necrolords",
                pets = {
                    "3043", "2958", "2963",
                },
            },
            ["Venthyr"] = {
                name = "Venthyr",
                pets = {
                    "2966", "2967", "3024", "3011", "3012",
                },
            },
            ["Night Fae"] = {
                name = "Night Fae",
                pets = {
                    "3018", "2913", "3016", "3023",
                },
            },
            ["Protoform Synthesis"] = {
                name = "Protoform Synthesis",
                pets = {
                    "3169", "3170", "3171", "3174", "3176", "3178", "3179", "3181", "3189", "3197",
                    "3201", "3204", "3207", "3211", "3220", "3222", "3223", "3224", "3225", "3226",
                    "3227", "3229", "3230", "3231", "3232", "3233", "3234", "3235",
                },
            },
            ["Pre-launch Event"] = {
                name = "Pre-launch Event",
                pets = {
                    "3046",
                },
            },
            ["Ardenweald"] = {
                name = "Ardenweald",
                pets = {
                    "2919", "2924", "3021", "3080", "3081", "3082",
                },
            },
            ["Bastion"] = {
                name = "Bastion",
                pets = {
                    "2926", "2927", "2929", "2930", "2936", "2937", "2939", "2943",
                },
            },
            ["Maldraxxus"] = {
                name = "Maldraxxus",
                pets = {
                    "2950", "3049", "3050", "3051", "3052", "3083",
                },
            },
            ["Revendreth"] = {
                name = "Revendreth",
                pets = {
                    "2895", "2902", "3007", "3014", "3015",
                },
            },
            ["The Maw"] = {
                name = "The Maw",
                pets = {
                    "3115", "3118", "3119", "3120", "3123", "3124", "3126",
                },
            },
            ["Korthia"] = {
                name = "Korthia",
                pets = {
                    "3102", "3134", "3135", "3139", "3141",
                },
            },
            ["Tazavesh"] = {
                name = "Tazavesh",
                pets = {
                    "3108", "3109", "3111", "3112",
                },
            },
            ["Zereth Mortis"] = {
                name = "Zereth Mortis",
                pets = {
                    "3216", "3217", "3212", "3173", "3206", "3210", "3209", "3205", "3214", "3219",
                    "3196", "3208", "3200", "3180", "3190", "3213", "3203", "3202", "3191", "3215",
                    "3218",
                },
            },
        },
    },
    ["6"] = {
        name = "Battle for Azeroth",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "2431", "2418", "2442", "2202", "2535", "2767", "2683", "2844",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "2410", "2409", "2192", "2188", "2190", "2198", "2157", "2526", "2687", "2688",
                    "2872",
                },
            },
            ["Medals"] = {
                name = "Medals",
                pets = {
                    "2539", "2540",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "2430", "2165", "2710",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "2415", "2405", "2404", "2427", "2439", "2429", "2443", "2444", "2699", "2698",
                    "2713", "2849", "2853",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "2538", "2697", "2706", "2707", "2690", "2689", "2708", "2695", "2684", "2681",
                    "2682", "2686", "2703", "2704", "2701", "2709", "2693", "2702", "2700", "2720",
                    "2719", "2715", "2714", "2712", "2753", "2756", "2766",
                },
            },
            ["Treasure"] = {
                name = "Treasure",
                pets = {
                    "2411", "2685", "2765", "2721", "2763", "2762", "2760", "2761", "2758", "2757",
                },
            },
            ["Honey Drop"] = {
                name = "Honey Drop",
                pets = {
                    "2792", "2793", "2794",
                },
            },
            ["Riddle"] = {
                name = "Riddle",
                pets = {
                    "2352", "2795",
                },
            },
            ["Dungeon Drop"] = {
                name = "Dungeon Drop",
                pets = {
                    "2186", "2187", "2711", "2718",
                },
            },
            ["Raid Drop"] = {
                name = "Raid Drop",
                pets = {
                    "2528", "2527", "2529", "2692", "2694", "2696", "2680", "2832", "2834", "2835",
                    "2833", "2836",
                },
            },
            ["Pet Charm"] = {
                name = "Pet Charm",
                pets = {
                    "2420", "2403", "2414", "2424", "2406", "2407", "2408", "2189", "2422", "2421",
                    "2423", "2425", "2426", "2428", "2416", "2417", "2413", "2419", "2412", "2196",
                },
            },
            ["Tinkering"] = {
                name = "Tinkering",
                pets = {
                    "2717", "2716",
                },
            },
            ["Assault"] = {
                name = "Assault",
                pets = {
                    "2564", "2565",
                },
            },
            ["Warfront: Arathi"] = {
                name = "Warfront: Arathi",
                pets = {
                    "2440", "2441", "2432", "2434", "2433", "2435", "2436", "2437", "2438",
                },
            },
            ["Warfront: Darkshore"] = {
                name = "Warfront: Darkshore",
                pets = {
                    "2544", "2545", "2546", "2547", "2548", "2549", "2550", "2563",
                },
            },
            ["Island Expeditions"] = {
                name = "Island Expeditions",
                pets = {
                    "2445", "2455", "2456", "2452", "2462", "2461", "2446", "2447", "2448", "2449",
                    "2450", "2463", "2464", "2469", "2466", "2468", "2465", "2467", "2471", "2472",
                    "2473", "2451", "2459", "2458", "2453", "2454", "2457", "2460", "2561", "2557",
                    "2559", "2560", "2551", "2552", "2553", "2554", "2556", "2558", "2755", "2754",
                },
            },
            ["Dubloons"] = {
                name = "Dubloons",
                pets = {
                    "2562", "2555",
                },
            },
            ["Nazjatar PvP"] = {
                name = "Nazjatar PvP",
                pets = {
                    "2691",
                },
            },
            ["Paragon Reputation"] = {
                name = "Paragon Reputation",
                pets = {
                    "2569", "2566", "2567", "2568", "2850", "2852",
                },
            },
            ["Horrific Visions"] = {
                name = "Horrific Visions",
                pets = {
                    "2842", "2838", "2797", "2796", "2840", "2839", "2841",
                },
            },
            ["Assault: Vale of Eternal Blossoms"] = {
                name = "Assault: Vale of Eternal Blossoms",
                pets = {
                    "2845", "2846", "2867", "2866", "2865",
                },
            },
            ["Assault: Uldum"] = {
                name = "Assault: Uldum",
                pets = {
                    "2848", "2847", "2851", "2843", "2863", "2864",
                },
            },
            ["Multiple Zones"] = {
                name = "Multiple Zones",
                pets = {
                    "2378", "2377",
                },
            },
            ["Drustvar"] = {
                name = "Drustvar",
                pets = {
                    "2386",
                },
            },
            ["Nazmir"] = {
                name = "Nazmir",
                pets = {
                    "2388", "2398", "2400", "2389", "2395", "2394", "2397", "2393", "2392",
                },
            },
            ["Stormsong Valley"] = {
                name = "Stormsong Valley",
                pets = {
                    "2374", "2379", "2373", "2372", "2375", "2376",
                },
            },
            ["Tiragarde Sound"] = {
                name = "Tiragarde Sound",
                pets = {
                    "2383", "2382", "2380", "2381",
                },
            },
            ["Vol'dun"] = {
                name = "Vol'dun",
                pets = {
                    "2399",
                },
            },
            ["Zuldazar"] = {
                name = "Zuldazar",
                pets = {
                    "2385", "2387", "2390", "2384", "2537",
                },
            },
            ["Nazjatar"] = {
                name = "Nazjatar",
                pets = {
                    "2678", "2652", "2648", "2651", "2647", "2650", "2649", "2660", "2645", "2646",
                    "2653",
                },
            },
            ["Mechagon"] = {
                name = "Mechagon",
                pets = {
                    "2662", "2664", "2665", "2663", "2676", "2670", "2667", "2669", "2661", "2673",
                    "2671", "2666",
                },
            },
            ["The Eternal Palace"] = {
                name = "The Eternal Palace",
                pets = {
                    "2657", "2658", "2659",
                },
            },
            ["Operation: Mechagon"] = {
                name = "Operation: Mechagon",
                pets = {
                    "2668", "2672", "2674", "2675",
                },
            },
        },
    },
    ["7"] = {
        name = "Legion",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "1930", "1933", "2113", "1938", "1903", "666", "2158",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "1706", "1720", "1705", "1922", "1921", "1711", "3107",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "1754", "1888", "2115",
                },
            },
            ["Treasure"] = {
                name = "Treasure",
                pets = {
                    "2042",
                },
            },
            ["Emissary"] = {
                name = "Emissary",
                pets = {
                    "1803", "1937",
                },
            },
            ["Pet Charm"] = {
                name = "Pet Charm",
                pets = {
                    "1805", "1760", "1715", "1755", "1453", "1429",
                },
            },
            ["Pet Battle"] = {
                name = "Pet Battle",
                pets = {
                    "2001",
                },
            },
            ["Riddle"] = {
                name = "Riddle",
                pets = {
                    "1926", "382",
                },
            },
            ["Falcosaur"] = {
                name = "Falcosaur",
                pets = {
                    "1975", "1976", "1974", "1977",
                },
            },
            ["Order Hall"] = {
                name = "Order Hall",
                pets = {
                    "1777", "1718", "1932", "1941", "1997", "2035", "2036", "2037", "2047", "1928",
                    "1929",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "1884", "1931", "1717", "1716", "1885", "1927", "2004", "2116",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "1934", "1753", "1752", "1802", "1907", "1804", "1721", "2120", "2136", "2135",
                },
            },
            ["Fel Egg"] = {
                name = "Fel Egg",
                pets = {
                    "2118", "2119",
                },
            },
            ["World Drop"] = {
                name = "World Drop",
                pets = {
                    "1719",
                },
            },
            ["Falanaar"] = {
                name = "Falanaar",
                pets = {
                    "1808",
                },
            },
            ["Deaths of Chromie"] = {
                name = "Deaths of Chromie",
                pets = {
                    "2072", "2071",
                },
            },
            ["Raid Drop"] = {
                name = "Raid Drop",
                pets = {
                    "1723",
                },
            },
            ["Paragon Reputation"] = {
                name = "Paragon Reputation",
                pets = {
                    "2050",
                },
            },
            ["Pre-launch Event"] = {
                name = "Pre-launch Event",
                pets = {
                    "1889",
                },
            },
            ["Multiple Zones"] = {
                name = "Multiple Zones",
                pets = {
                    "1743", "1914", "1708", "1731", "1728", "1713", "1744", "1729", "1736",
                },
            },
            ["Antoran Wastes"] = {
                name = "Antoran Wastes",
                pets = {
                    "2122", "2126",
                },
            },
            ["Eredath"] = {
                name = "Eredath",
                pets = {
                    "2131", "2132", "2133", "2134", "2130", "2129", "2128",
                },
            },
            ["Krokuun"] = {
                name = "Krokuun",
                pets = {
                    "2123", "2124", "2127",
                },
            },
            ["Highmountain"] = {
                name = "Highmountain",
                pets = {
                    "1714", "1726", "1775", "1761", "1762", "1776", "1763",
                },
            },
            ["Val'sharah"] = {
                name = "Val'sharah",
                pets = {
                    "1738", "1913", "1734", "1739", "1735", "1737",
                },
            },
            ["Suramar"] = {
                name = "Suramar",
                pets = {
                    "1807", "1809", "1810",
                },
            },
            ["Stormheim"] = {
                name = "Stormheim",
                pets = {
                    "1712", "1749", "1917", "1750",
                },
            },
            ["Azsuna"] = {
                name = "Azsuna",
                pets = {
                    "1774", "1773", "1709", "1710", "1935",
                },
            },
            ["Dalaran"] = {
                name = "Dalaran",
                pets = {
                    "1915", "1778", "1912",
                },
            },
            ["Emerald Nightmare"] = {
                name = "Emerald Nightmare",
                pets = {
                    "1722",
                },
            },
        },
    },
    ["8"] = {
        name = "Warlords of Draenor",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "1411",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "1387", "1566", "1446", "1567", "1532", "1690",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "1688", "1597", "1596", "1396",
                },
            },
            ["Pet Charm"] = {
                name = "Pet Charm",
                pets = {
                    "1577", "1588", "1598", "1661",
                },
            },
            ["Dungeon Drop"] = {
                name = "Dungeon Drop",
                pets = {
                    "1533",
                },
            },
            ["Mastering the Menagerie"] = {
                name = "Mastering the Menagerie",
                pets = {
                    "1385", "1545", "1568", "1442", "1434", "1570", "1394",
                },
            },
            ["Critters of Draenor"] = {
                name = "Critters of Draenor",
                pets = {
                    "1600", "1656", "1655",
                },
            },
            ["Table Missions"] = {
                name = "Table Missions",
                pets = {
                    "1687", "1662",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "1540", "1564", "1541", "1576", "1524", "1764", "1766", "1765", "1601", "1660",
                },
            },
            ["Treasure"] = {
                name = "Treasure",
                pets = {
                    "1537", "1471", "1543", "1515", "1538", "1416",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "1693", "1458", "1430", "1450", "1542", "1571", "1692", "1575", "1574", "115",
                    "1448",
                },
            },
            ["World Drop"] = {
                name = "World Drop",
                pets = {
                    "1432", "1495", "1428",
                },
            },
            ["Tanaan Pet Battle"] = {
                name = "Tanaan Pet Battle",
                pets = {
                    "1664", "1663", "1539", "1536",
                },
            },
            ["Raid Drop"] = {
                name = "Raid Drop",
                pets = {
                    "1672",
                },
            },
            ["Multiple Zones"] = {
                name = "Multiple Zones",
                pets = {
                    "1587", "1464", "1593",
                },
            },
            ["Frostfire Ridge"] = {
                name = "Frostfire Ridge",
                pets = {
                    "1427", "1578", "1457", "1579",
                },
            },
            ["Shadowmoon Valley"] = {
                name = "Shadowmoon Valley",
                pets = {
                    "1447", "1455", "1582",
                },
            },
            ["Gorgrond"] = {
                name = "Gorgrond",
                pets = {
                    "1465", "1470", "1469", "1594", "1463", "1615",
                },
            },
            ["Talador"] = {
                name = "Talador",
                pets = {
                    "1572", "1589", "1595", "1583", "1599",
                },
            },
            ["Spires of Arak"] = {
                name = "Spires of Arak",
                pets = {
                    "1462", "1573", "1592", "1456",
                },
            },
            ["Nagrand"] = {
                name = "Nagrand",
                pets = {
                    "1435",
                },
            },
            ["Tanaan Jungle"] = {
                name = "Tanaan Jungle",
                pets = {
                    "1468", "1586", "1581", "1591",
                },
            },
            ["Garrison"] = {
                name = "Garrison",
                pets = {
                    "1741", "1740", "1730",
                },
            },
        },
    },
    ["9"] = {
        name = "Mists of Pandaria",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "835",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "847", "1185",
                },
            },
            ["Pet Battle"] = {
                name = "Pet Battle",
                pets = {
                    "381", "1198", "1176", "1197", "1196", "1125", "1126", "1124", "868", "3092",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "652", "1346", "1042",
                },
            },
            ["Celestial Tournament"] = {
                name = "Celestial Tournament",
                pets = {
                    "1303", "1266", "1304", "1305",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "1350", "1344",
                },
            },
            ["Raid Drop"] = {
                name = "Raid Drop",
                pets = {
                    "1200", "1202", "1177", "1183", "1243", "1244", "1334", "1322", "1331", "1332",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "836", "834", "1201", "1323", "1330", "1338", "1348", "1328", "1337", "1345",
                },
            },
            ["World Drop"] = {
                name = "World Drop",
                pets = {
                    "1205", "1245", "1178", "650", "1211", "1212", "1180", "1213", "1321", "1343",
                    "1329", "1333", "1335", "1336",
                },
            },
            ["Multiple Zones"] = {
                name = "Multiple Zones",
                pets = {
                    "708", "740",
                },
            },
            ["Dread Wastes"] = {
                name = "Dread Wastes",
                pets = {
                    "732", "742", "745", "746", "743", "744", "741",
                },
            },
            ["Isle of Thunder"] = {
                name = "Isle of Thunder",
                pets = {
                    "1181", "1179", "1182", "1175",
                },
            },
            ["Krasarang Wilds"] = {
                name = "Krasarang Wilds",
                pets = {
                    "716", "714", "678", "718", "722", "717", "723", "1128", "1013",
                },
            },
            ["Kun-Lai Summit"] = {
                name = "Kun-Lai Summit",
                pets = {
                    "724", "725", "1166", "726", "727", "679", "728", "729", "730", "731",
                },
            },
            ["The Jade Forest"] = {
                name = "The Jade Forest",
                pets = {
                    "380", "562", "564", "753", "571", "699", "565", "570", "703", "566",
                    "573", "754", "572", "567", "819", "818", "817",
                },
            },
            ["Timeless Isle"] = {
                name = "Timeless Isle",
                pets = {
                    "1324", "1325", "1326",
                },
            },
            ["Townlong Steppes"] = {
                name = "Townlong Steppes",
                pets = {
                    "733", "680", "737", "739",
                },
            },
            ["Vale of Eternal Blossoms"] = {
                name = "Vale of Eternal Blossoms",
                pets = {
                    "751", "747", "383", "748", "749", "750", "752",
                },
            },
            ["Valley of the Four Winds"] = {
                name = "Valley of the Four Winds",
                pets = {
                    "706", "707", "709", "710", "677", "711", "712", "713",
                },
            },
        },
    },
    ["10"] = {
        name = "Cataclysm",
        categories = {
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "265",
                },
            },
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "259", "260", "307", "301",
                },
            },
            ["Racial"] = {
                name = "Racial",
                pets = {
                    "630", "629",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "279",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "271", "278",
                },
            },
            ["Molten Front"] = {
                name = "Molten Front",
                pets = {
                    "318", "317", "172",
                },
            },
            ["Mount Hyjal"] = {
                name = "Mount Hyjal",
                pets = {
                    "540", "755", "539", "547",
                },
            },
            ["Uldum"] = {
                name = "Uldum",
                pets = {
                    "851", "545", "543", "542", "544", "546",
                },
            },
            ["Twilight Highlands"] = {
                name = "Twilight Highlands",
                pets = {
                    "550", "823", "645", "552", "548", "549", "2677",
                },
            },
            ["Deepholm"] = {
                name = "Deepholm",
                pets = {
                    "559", "554", "556", "555", "837", "756", "553",
                },
            },
        },
    },
    ["11"] = {
        name = "Wrath of the Lich King",
        categories = {
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "214",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "74", "224", "236", "1727", "190",
                },
            },
            ["Treasure"] = {
                name = "Treasure",
                pets = {
                    "1604", "1073",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "198",
                },
            },
            ["Achievement"] = {
                name = "Achievement",
                pets = {
                    "199",
                },
            },
            ["World Drop"] = {
                name = "World Drop",
                pets = {
                    "234",
                },
            },
            ["Raid Drop"] = {
                name = "Raid Drop",
                pets = {
                    "1953",
                },
            },
            ["Cracked Egg"] = {
                name = "Cracked Egg",
                pets = {
                    "197", "196", "194", "195",
                },
            },
            ["Argent Tournament"] = {
                name = "Argent Tournament",
                pets = {
                    "212", "205", "209", "215", "204", "207", "213", "210", "218", "206",
                    "229",
                },
            },
            ["Multiple Zones"] = {
                name = "Multiple Zones",
                pets = {
                    "641", "536", "1238",
                },
            },
            ["The Storm Peaks"] = {
                name = "The Storm Peaks",
                pets = {
                    "558",
                },
            },
            ["Sholazar Basin"] = {
                name = "Sholazar Basin",
                pets = {
                    "649", "1167", "532",
                },
            },
            ["Borean Tundra"] = {
                name = "Borean Tundra",
                pets = {
                    "639", "530",
                },
            },
            ["Howling Fjord"] = {
                name = "Howling Fjord",
                pets = {
                    "523", "644", "529", "525",
                },
            },
            ["Dragonblight"] = {
                name = "Dragonblight",
                pets = {
                    "537",
                },
            },
            ["Coldarra"] = {
                name = "Coldarra",
                pets = {
                    "1165",
                },
            },
            ["Grizzly Hills"] = {
                name = "Grizzly Hills",
                pets = {
                    "534",
                },
            },
            ["Icecrown"] = {
                name = "Icecrown",
                pets = {
                    "538",
                },
            },
            ["Zul'Drak"] = {
                name = "Zul'Drak",
                pets = {
                    "535",
                },
            },
        },
    },
    ["12"] = {
        name = "The Burning Crusade",
        categories = {
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "149",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "145", "137", "78", "136", "139", "51", "44", "55",
                },
            },
            ["Reputation"] = {
                name = "Reputation",
                pets = {
                    "186", "167",
                },
            },
            ["World Drop"] = {
                name = "World Drop",
                pets = {
                    "146",
                },
            },
            ["Raid Drop"] = {
                name = "Raid Drop",
                pets = {
                    "165", "175",
                },
            },
            ["Nagrand"] = {
                name = "Nagrand",
                pets = {
                    "518",
                },
            },
            ["Netherstorm"] = {
                name = "Netherstorm",
                pets = {
                    "521", "638",
                },
            },
            ["Blade's Edge Mountains"] = {
                name = "Blade's Edge Mountains",
                pets = {
                    "1164", "528", "637",
                },
            },
            ["Hellfire Peninsula"] = {
                name = "Hellfire Peninsula",
                pets = {
                    "514",
                },
            },
            ["Zangarmarsh"] = {
                name = "Zangarmarsh",
                pets = {
                    "515",
                },
            },
            ["Terokkar Forest"] = {
                name = "Terokkar Forest",
                pets = {
                    "517",
                },
            },
        },
    },
    ["13"] = {
        name = "Classic",
        categories = {
            ["Quest"] = {
                name = "Quest",
                pets = {
                    "331", "332", "83", "287", "220", "84", "291",
                },
            },
            ["Vendor"] = {
                name = "Vendor",
                pets = {
                    "52", "254", "47", "792", "227", "306",
                },
            },
            ["Alliance Vendor"] = {
                name = "Alliance Vendor",
                pets = {
                    "138", "40", "41", "68", "67", "43", "45", "72", "46", "141",
                    "140",
                },
            },
            ["Horde Vendor"] = {
                name = "Horde Vendor",
                pets = {
                    "75", "70", "77", "142", "143", "144",
                },
            },
            ["Dungeon Drop"] = {
                name = "Dungeon Drop",
                pets = {
                    "90", "89", "233", "50",
                },
            },
            ["Rare"] = {
                name = "Rare",
                pets = {
                    "2525",
                },
            },
            ["World Drop"] = {
                name = "World Drop",
                pets = {
                    "114",
                },
            },
            ["World Drop: Eastern Kingdoms"] = {
                name = "World Drop: Eastern Kingdoms",
                pets = {
                    "42", "49", "58", "56", "238", "239", "286", "1563",
                },
            },
            ["World Drop: Kalimdor"] = {
                name = "World Drop: Kalimdor",
                pets = {
                    "59", "87", "57", "232", "235", "237", "1237", "1984", "2163",
                },
            },
            ["Alliance Territory"] = {
                name = "Alliance Territory",
                pets = {
                    "507", "508", "464", "465", "493", "374", "1162", "442", "437", "440",
                    "675", "389",
                },
            },
            ["Horde Territory"] = {
                name = "Horde Territory",
                pets = {
                    "474", "468", "477", "1157", "466", "473", "455", "461", "458", "460",
                    "463", "454",
                },
            },
        },
    },
    ["14"] = {
        name = "World Event",
        categories = {
            ["Lunar Festival"] = {
                name = "Lunar Festival",
                pets = {
                    "342", "341",
                },
            },
            ["Love is in the Air"] = {
                name = "Love is in the Air",
                pets = {
                    "122", "251", "1511", "3549", "4704",
                },
            },
            ["Noblegarden"] = {
                name = "Noblegarden",
                pets = {
                    "200", "1514", "1943", "4409",
                },
            },
            ["Children's Week"] = {
                name = "Children's Week",
                pets = {
                    "126", "127", "289", "125", "158", "159", "308", "157", "225", "226",
                    "2575", "2577", "2576", "2578", "4466", "3245", "4635",
                },
            },
            ["Midsummer Fire Festival"] = {
                name = "Midsummer Fire Festival",
                pets = {
                    "253", "128", "1517", "1949",
                },
            },
            ["Brewfest"] = {
                name = "Brewfest",
                pets = {
                    "166", "153", "1518",
                },
            },
            ["Hallow's End"] = {
                name = "Hallow's End",
                pets = {
                    "321", "319", "162", "1521", "1523", "2002", "3491",
                },
            },
            ["DotD"] = {
                name = "DotD",
                pets = {
                    "1351",
                },
            },
            ["Pilgrim's Bounty"] = {
                name = "Pilgrim's Bounty",
                pets = {
                    "201", "1516",
                },
            },
            ["Feast of Winter Veil"] = {
                name = "Feast of Winter Veil",
                pets = {
                    "191", "337", "119", "120", "1349", "117", "118", "1725", "2622", "4694",
                    "4691",
                },
            },
            ["Brawler's Guild"] = {
                name = "Brawler's Guild",
                pets = {
                    "1142", "2022",
                },
            },
            ["Timewalking"] = {
                name = "Timewalking",
                pets = {
                    "4592", "4593", "4689", "4686", "2017", "2018", "4849", "4852",
                },
            },
            ["Darkmoon Faire"] = {
                name = "Darkmoon Faire",
                pets = {
                    "65", "64", "106", "1636", "1384", "1666", "1665", "343", "1061", "330",
                    "335", "336", "338", "339", "2484", "2483", "2482", "848", "1276", "1063",
                    "1478",
                },
            },
            ["Anniversary"] = {
                name = "Anniversary",
                pets = {
                    "202", "1451", "1890", "3100", "4265", "4679",
                },
            },
        },
    },
    ["15"] = {
        name = "Profession",
        categories = {
            ["Alchemy"] = {
                name = "Alchemy",
                pets = {
                    "1756", "1759", "1920", "2474", "2476", "2477", "2475", "4482",
                },
            },
            ["Archaeology"] = {
                name = "Archaeology",
                pets = {
                    "277", "264", "266", "309", "310", "1531", "1530", "1887", "2197", "2199",
                },
            },
            ["Blacksmithing"] = {
                name = "Blacksmithing",
                pets = {
                    "1569", "3274",
                },
            },
            ["Cooking"] = {
                name = "Cooking",
                pets = {
                    "1395",
                },
            },
            ["Enchanting"] = {
                name = "Enchanting",
                pets = {
                    "267", "292", "1699", "1701", "1700", "2201", "3390",
                },
            },
            ["Herbalism"] = {
                name = "Herbalism",
                pets = {
                    "2117",
                },
            },
            ["Mining"] = {
                name = "Mining",
                pets = {
                    "293",
                },
            },
            ["Skinning"] = {
                name = "Skinning",
                pets = {
                    "2121",
                },
            },
            ["Inscription"] = {
                name = "Inscription",
                pets = {
                    "849", "850",
                },
            },
            ["Jewelcrafting"] = {
                name = "Jewelcrafting",
                pets = {
                    "845", "846", "3256", "3344", "3345", "3346", "3347",
                },
            },
            ["Tailoring"] = {
                name = "Tailoring",
                pets = {
                    "1040", "1039", "1426",
                },
            },
            ["Engineering"] = {
                name = "Engineering",
                pets = {
                    "95", "86", "39", "85", "116", "262", "261", "844", "1320", "1256",
                    "1204", "1412", "1403", "1565", "1467", "1886", "1806", "2530", "2889", "3306",
                },
            },
            ["Fishing"] = {
                name = "Fishing",
                pets = {
                    "193", "132", "340", "211", "1207", "1208", "1206", "1209", "174", "164",
                    "173", "163", "1911", "2077", "2837", "3525",
                },
            },
            ["Pickpocketing"] = {
                name = "Pickpocketing",
                pets = {
                    "2065", "2063",
                },
            },
        },
    },
    ["16"] = {
        name = "Pet Battle Dungeon",
        categories = {
            ["Challenge: Wailing Caverns"] = {
                name = "Challenge: Wailing Caverns",
                pets = {
                    "1998", "2000", "1999", "2049",
                },
            },
            ["Challenge: Deadmines"] = {
                name = "Challenge: Deadmines",
                pets = {
                    "2058", "2041", "2057", "2064",
                },
            },
            ["Challenge: Gnomeregan"] = {
                name = "Challenge: Gnomeregan",
                pets = {
                    "2531", "2532", "2533", "2534",
                },
            },
            ["Challenge: Stratholme"] = {
                name = "Challenge: Stratholme",
                pets = {
                    "2748", "2749", "2750", "2747", "2638",
                },
            },
            ["Challenge: Blackrock Depths"] = {
                name = "Challenge: Blackrock Depths",
                pets = {
                    "2868", "2869", "2870",
                },
            },
        },
    },
    ["17"] = {
        name = "Raiding With Leashes",
        categories = {
            ["Raiding With Leashes"] = {
                name = "Raiding With Leashes",
                pets = {
                    "1149", "1150", "1147", "1151", "1153", "1152", "1156", "1155", "1154", "1143",
                    "1144", "1146", "1145",
                },
            },
            ["II: Attunement Edition"] = {
                name = "II: Attunement Edition",
                pets = {
                    "1226", "1227", "1229", "1228", "1231", "1230", "1232", "1233", "1235", "1234",
                    "1236",
                },
            },
            ["III: Drinkin' From the Sunwell"] = {
                name = "III: Drinkin' From the Sunwell",
                pets = {
                    "1623", "1624", "1625", "1627", "1626", "1628", "1629", "1622", "1631", "1632",
                    "1634", "1633", "1635",
                },
            },
            ["IV: Wrath of the Lick King"] = {
                name = "IV: Wrath of the Lick King",
                pets = {
                    "1955", "1956", "1957", "1958", "1959", "1960", "1961", "1962", "1952", "1954",
                    "1963", "1964", "1965", "1966", "1967", "1968", "1969",
                },
            },
            ["V: Cuteaclysm"] = {
                name = "V: Cuteaclysm",
                pets = {
                    "2078", "2079", "2080", "2081", "2082", "2083", "2084", "2085", "2086", "2087",
                    "2088", "2089", "2090", "2091", "2092", "2093",
                },
            },
            ["VI: Pets of Pandaria"] = {
                name = "VI: Pets of Pandaria",
                pets = {
                    "2579", "2580", "2581", "2582", "2583", "2584", "2585", "2586", "2587", "2589",
                    "2590", "2591",
                },
            },
        },
    },
    ["18"] = {
        name = "Promotional",
        categories = {
            ["Authenticator"] = {
                name = "Authenticator",
                pets = {
                    "244",
                },
            },
            ["Blizzard Store"] = {
                name = "Blizzard Store",
                pets = {
                    "256", "297", "316", "311", "347", "1117", "1248", "1363", "1603", "1466",
                    "2051", "2062", "2184", "2780", "3153", "3249", "3253", "4684", "4568", "4264",
                    "4796",
                },
            },
            ["Recruit-A-Friend"] = {
                name = "Recruit-A-Friend",
                pets = {
                    "2776", "3475",
                },
            },
            ["Blizzcon"] = {
                name = "Blizzcon",
                pets = {
                    "107", "228", "294", "329", "1364", "1602", "1454", "1940", "1939", "2778",
                    "3579",
                },
            },
            ["WWI"] = {
                name = "WWI",
                pets = {
                    "189",
                },
            },
            ["Collector's Edition"] = {
                name = "Collector's Edition",
                pets = {
                    "93", "92", "94", "131", "188", "268", "671", "1386", "1691", "2143",
                    "2779", "3175", "3177", "4266", "4589", "4590", "4591",
                },
            },
            ["StarCraft II"] = {
                name = "StarCraft II",
                pets = {
                    "258", "903", "1255",
                },
            },
            ["Diablo III"] = {
                name = "Diablo III",
                pets = {
                    "346", "1365",
                },
            },
            ["Hearthstone"] = {
                name = "Hearthstone",
                pets = {
                    "4406",
                },
            },
            ["Overwatch"] = {
                name = "Overwatch",
                pets = {
                    "1828",
                },
            },
            ["HotS"] = {
                name = "HotS",
                pets = {
                    "1639",
                },
            },
            ["WoW Classic"] = {
                name = "WoW Classic",
                pets = {
                    "4316", "4733",
                },
            },
            ["Warcraft Rumble"] = {
                name = "Warcraft Rumble",
                pets = {
                    "3236",
                },
            },
            ["Mountain Dew"] = {
                name = "Mountain Dew",
                pets = {
                    "4617", "4618",
                },
            },
            ["Razer"] = {
                name = "Razer",
                pets = {
                    "4690",
                },
            },
            ["Trolli"] = {
                name = "Trolli",
                pets = {
                    "4616",
                },
            },
            ["Trading Card Game / Auction House"] = {
                name = "Trading Card Game / Auction House",
                pets = {
                    "130", "156", "169", "183", "241", "285", "302", "303", "328", "333",
                    "348", "665", "1174",
                },
            },
            ["Twitch Drops"] = {
                name = "Twitch Drops",
                pets = {
                    "4762",
                },
            },
            ["Blizzard Gear Store"] = {
                name = "Blizzard Gear Store",
                pets = {
                    "245", "246", "4630", "4629", "4791",
                },
            },
        },
    },
    ["19"] = {
        name = "Other",
        categories = {
            ["Guild Vendor"] = {
                name = "Guild Vendor",
                pets = {
                    "272", "270", "282", "280", "320", "1449",
                },
            },
            ["BMAH"] = {
                name = "BMAH",
                pets = {
                    "802", "2621",
                },
            },
        },
    },
    ["20"] = {
        name = "Multiple Continents",
        categories = {
            ["Multiple Continents"] = {
                name = "Multiple Continents",
                pets = {
                    "635","441","838","427","425","626","406","398","449","459","646","393","447","519","415","541","407","569","2114","430","647","448","483","648","628","627","702","404","450","391","633","385","1441","403","386","378","417","431","452","424","482","414","560","388","568","397","419","387","412","433","379","401","432","1590","497","420","480","469","470","405","418","410"
                }
            },
            ["Darkmoon Island"] = {
                name = "Darkmoon Island",
                pets = {
                    "1062", "1068",
                },
            },
        },
    },
}

-- Section metadata with icons and expansion info
-- Update section names with additional metadata

PCLcore.sectionNames[1].icon = "Interface\\AddOns\\PCL\\icons\\other.blp"
PCLcore.sectionNames[1].isExpansion = false
PCLcore.sectionNames[1].includeInClassic = true
PCLcore.sectionNames[1].pets = PCLcore.petList["1"]

PCLcore.sectionNames[2].icon = "Interface\\AddOns\\PCL\\icons\\other.blp"
PCLcore.sectionNames[2].isExpansion = false
PCLcore.sectionNames[2].includeInClassic = true
PCLcore.sectionNames[2].pets = PCLcore.petList["2"]

PCLcore.sectionNames[3].icon = "Interface\\AddOns\\PCL\\icons\\tww.blp"
PCLcore.sectionNames[3].isExpansion = true
PCLcore.sectionNames[3].includeInClassic = false
PCLcore.sectionNames[3].pets = PCLcore.petList["3"]

PCLcore.sectionNames[4].icon = "Interface\\AddOns\\PCL\\icons\\df.blp"
PCLcore.sectionNames[4].isExpansion = true
PCLcore.sectionNames[4].includeInClassic = false
PCLcore.sectionNames[4].pets = PCLcore.petList["4"]

PCLcore.sectionNames[5].icon = "Interface\\AddOns\\PCL\\icons\\sl.blp"
PCLcore.sectionNames[5].isExpansion = true
PCLcore.sectionNames[5].includeInClassic = false
PCLcore.sectionNames[5].pets = PCLcore.petList["5"]

PCLcore.sectionNames[6].icon = "Interface\\AddOns\\PCL\\icons\\bfa.blp"
PCLcore.sectionNames[6].isExpansion = true
PCLcore.sectionNames[6].includeInClassic = false
PCLcore.sectionNames[6].pets = PCLcore.petList["6"]

PCLcore.sectionNames[7].icon = "Interface\\AddOns\\PCL\\icons\\legion.blp"
PCLcore.sectionNames[7].isExpansion = true
PCLcore.sectionNames[7].includeInClassic = false
PCLcore.sectionNames[7].pets = PCLcore.petList["7"]

PCLcore.sectionNames[8].icon = "Interface\\AddOns\\PCL\\icons\\wod.blp"
PCLcore.sectionNames[8].isExpansion = true
PCLcore.sectionNames[8].includeInClassic = false
PCLcore.sectionNames[8].pets = PCLcore.petList["8"]

PCLcore.sectionNames[9].icon = "Interface\\AddOns\\PCL\\icons\\mists.blp"
PCLcore.sectionNames[9].isExpansion = true
PCLcore.sectionNames[9].includeInClassic = true
PCLcore.sectionNames[9].pets = PCLcore.petList["9"]

PCLcore.sectionNames[10].icon = "Interface\\AddOns\\PCL\\icons\\cata.blp"
PCLcore.sectionNames[10].isExpansion = true
PCLcore.sectionNames[10].includeInClassic = true
PCLcore.sectionNames[10].pets = PCLcore.petList["10"]

PCLcore.sectionNames[11].icon = "Interface\\AddOns\\PCL\\icons\\wrath.blp"
PCLcore.sectionNames[11].isExpansion = true
PCLcore.sectionNames[11].includeInClassic = true
PCLcore.sectionNames[11].pets = PCLcore.petList["11"]

PCLcore.sectionNames[12].icon = "Interface\\AddOns\\PCL\\icons\\bc.blp"
PCLcore.sectionNames[12].isExpansion = true
PCLcore.sectionNames[12].includeInClassic = true
PCLcore.sectionNames[12].pets = PCLcore.petList["12"]

PCLcore.sectionNames[13].icon = "Interface\\AddOns\\PCL\\icons\\classic.blp"
PCLcore.sectionNames[13].isExpansion = true
PCLcore.sectionNames[13].includeInClassic = true
PCLcore.sectionNames[13].pets = PCLcore.petList["13"]

PCLcore.sectionNames[14].icon = "Interface\\AddOns\\PCL\\icons\\holiday.blp"
PCLcore.sectionNames[14].isExpansion = false
PCLcore.sectionNames[14].includeInClassic = true
PCLcore.sectionNames[14].pets = PCLcore.petList["14"]

PCLcore.sectionNames[15].icon = "Interface\\AddOns\\PCL\\icons\\professions.blp"
PCLcore.sectionNames[15].isExpansion = false
PCLcore.sectionNames[15].includeInClassic = true
PCLcore.sectionNames[15].pets = PCLcore.petList["15"]

PCLcore.sectionNames[16].icon = "Interface\\AddOns\\PCL\\icons\\other.blp"
PCLcore.sectionNames[16].isExpansion = false
PCLcore.sectionNames[16].includeInClassic = true
PCLcore.sectionNames[16].pets = PCLcore.petList["16"]

PCLcore.sectionNames[17].icon = "Interface\\AddOns\\PCL\\icons\\other.blp"
PCLcore.sectionNames[17].isExpansion = false
PCLcore.sectionNames[17].includeInClassic = true
PCLcore.sectionNames[17].pets = PCLcore.petList["17"]

PCLcore.sectionNames[18].icon = "Interface\\AddOns\\PCL\\icons\\promotion.blp"
PCLcore.sectionNames[18].isExpansion = false
PCLcore.sectionNames[18].includeInClassic = true
PCLcore.sectionNames[18].pets = PCLcore.petList["18"]

PCLcore.sectionNames[19].icon = "Interface\\AddOns\\PCL\\icons\\other.blp"
PCLcore.sectionNames[19].isExpansion = false
PCLcore.sectionNames[19].includeInClassic = true
PCLcore.sectionNames[19].pets = PCLcore.petList["19"]

PCLcore.sectionNames[20].icon = "Interface\\AddOns\\PCL\\icons\\other.blp"
PCLcore.sectionNames[20].isExpansion = false
PCLcore.sectionNames[20].includeInClassic = true
PCLcore.sectionNames[20].pets = PCLcore.petList["20"]

-- Special sections
PCLcore.sectionNames[21] = {
    name = "Pinned",
    pets = {PCL_PINNED},
    icon = "Interface\\AddOns\\PCL\\icons\\pin.blp",
    isExpansion = false,
    includeInClassic = true,
}
PCLcore.sectionNames[22] = {
    name = "Overview",
    pets = {},
    icon = "Interface\\AddOns\\PCL\\icons\\pcl.blp",
    isExpansion = false,
    includeInClassic = true,
}

-- Regional filters (if needed)
PCLcore.regionalFilter = {
    -- Add region-specific pet filters here if needed
}