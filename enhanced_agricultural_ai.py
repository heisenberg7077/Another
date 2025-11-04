#!/usr/bin/env python3
"""
Enhanced Agricultural AI Model Server - Based on Tamil Nadu Crop Dataset
Provides detailed, accurate responses for Tamil Nadu agricultural practices.
"""

from flask import Flask, jsonify, request
import json
import time
import re

app = Flask(__name__)

# Comprehensive Tamil Nadu Crop Database
CROP_DATABASE = {
    "paddy": {
        "name": "Paddy (Rice)",
        "soil_type": "Clayey loam and loamy soils with good water retention capacity. pH: 5.5 to 6.5",
        "fertilizers": "FYM basal application. Nutrient requirement: 150:50:50 kg/ha N:P:K in split doses. Green manure crops like Daincha or Sunnhemp",
        "water_level": "Water-intensive crop. Fields flooded to 2-5 cm depth. Intermittent irrigation practiced to save water",
        "harvest_time": "25-35 days after flowering when grains are hard and yellow",
        "irrigation_type": "Flood irrigation most common. Drip and sprinkler irrigation promoted for efficiency",
        "sowing_process": "Land ploughed thoroughly, seedlings raised in nursery, transplanted after 20-30 days. Direct sowing with drum seeder also practiced",
        "growing_months": "Kuruvai: June-July; Samba: August; Thaladi: September-October",
        "harvest_months": "Kuruvai: September-October; Samba: January-February; Thaladi: January-February",
        "precautions": "Use disease-resistant varieties, ensure proper drainage, monitor stem borer and leaf folder, avoid excessive nitrogen"
    },
    "sugarcane": {
        "name": "Sugarcane",
        "soil_type": "Well-drained loamy soils. Wide range from sandy loam to clay loam. pH: 6.5 to 7.5",
        "fertilizers": "FYM basal dose. Chemical fertilizers: 275:63:113 kg/ha N:P:K. Nitrogen applied in splits",
        "water_level": "Long-duration crop requiring frequent irrigation. High water requirement during formative and grand growth phases",
        "harvest_time": "10-12 months when lower leaves dry up and brix reading is 18-20%",
        "irrigation_type": "Furrow irrigation traditional. Drip irrigation highly recommended for water saving",
        "sowing_process": "Land ploughed deep for fine tilth. Setts (cuttings from stalk) planted in furrows",
        "growing_months": "December to February",
        "harvest_months": "November to February (following year)",
        "precautions": "Select healthy disease-free setts, practice earthing up, manage early shoot borer and internode borer, detrashing for aeration"
    },
    "cotton": {
        "name": "Cotton",
        "soil_type": "Well-drained black cotton soils and alluvial soils. pH range: 6.0 to 8.0",
        "fertilizers": "FYM during land preparation. General recommendation: 80:40:40 kg/ha N:P:K for irrigated cotton",
        "water_level": "Rainfed in many parts. Critical irrigation stages: sowing, flowering, boll formation. Sensitive to waterlogging",
        "harvest_time": "150-160 days after sowing, harvested in pickings as bolls mature and burst open",
        "irrigation_type": "Furrow and alternate furrow irrigation common. Drip irrigation beneficial for water conservation",
        "sowing_process": "Land ploughed for fine tilth. Seeds sown by dibbling or seed drill",
        "growing_months": "August to September",
        "harvest_months": "January to April",
        "precautions": "Use certified seeds, adopt IPM for pink bollworm and whitefly, timely weeding crucial, avoid insecticide during flowering"
    },
    "maize": {
        "name": "Maize",
        "soil_type": "Well-drained loamy soils rich in organic matter. pH: 6.0 to 7.5",
        "fertilizers": "FYM basal dose. Recommended: 150:75:75 kg/ha N:P:K for hybrid maize",
        "water_level": "Sensitive to water stress and waterlogging. Critical during tasseling, silking, grain-filling stages",
        "harvest_time": "90-110 days after sowing when outer husk turns brownish and grains are hard",
        "irrigation_type": "Ridge and furrow irrigation common. Drip irrigation for better water management",
        "sowing_process": "Land ploughed to fine tilth. Seeds sown on sides of ridges",
        "growing_months": "September to November",
        "harvest_months": "December to February",
        "precautions": "Maintain optimum plant population, control weeds early, manage stem borer and fall armyworm, ensure proper drainage"
    },
    "groundnut": {
        "name": "Groundnut (Peanut)",
        "soil_type": "Well-drained sandy loam and loamy soils. Loose and friable for peg penetration. pH: 6.0 to 7.5",
        "fertilizers": "FYM incorporated. Recommended: 25:50:75 kg/ha N:P:K. Gypsum at pegging stage crucial for pod development",
        "water_level": "Both rainfed and irrigated. Critical stages: flowering, pegging, pod formation",
        "harvest_time": "100-130 days when leaves turn yellow and inner shell is brownish-black",
        "irrigation_type": "Sprinkler and drip irrigation efficient. Check basin or furrow irrigation also used",
        "sowing_process": "Land ploughed to fine tilth. Seeds sown by dibbling or seed drill",
        "growing_months": "Rainfed: June-July; Irrigated: December-January",
        "harvest_months": "Rainfed: September-October; Irrigated: April-May",
        "precautions": "Use quality fungicide-treated seeds, manage leaf miner and red hairy caterpillar, timely gypsum application, avoid deep sowing"
    },
    "tomato": {
        "name": "Tomato",
        "soil_type": "Well-drained sandy loam to clay loam soils rich in organic matter. pH: 6.0 to 7.0",
        "fertilizers": "FYM 25 t/ha incorporated. General recommendation: 150:100:150 kg/ha N:P:K for hybrids",
        "water_level": "Consistent moisture throughout growth. Critical stages: transplanting, flowering, fruit development. 400-600 mm water requirement",
        "harvest_time": "60-70 days after transplanting, continues for 2 months. Harvest based on market demand (green, pink, red stage)",
        "irrigation_type": "Drip irrigation most efficient for water saving and disease reduction. Furrow irrigation common",
        "sowing_process": "Seedlings raised in nursery, transplanted after 25-30 days on raised beds or furrows",
        "growing_months": "Can be grown year-round. Main seasons: June-July and December-January",
        "harvest_months": "August-September and February-March",
        "precautions": "Use disease-resistant hybrid seeds, manage fruit borer and whitefly, provide staking for indeterminate varieties, practice crop rotation"
    },
    "banana": {
        "name": "Banana",
        "soil_type": "Deep, well-drained, fertile loamy soils. pH: 6.5 to 7.5",
        "fertilizers": "Large quantity of FYM required. Dose: 200:40:400 g N:P:K per plant per year in split doses",
        "water_level": "Water-loving plant requiring frequent irrigation to maintain soil moisture",
        "harvest_time": "12-15 months from planting when fruits are slightly or fully mature depending on market requirement",
        "irrigation_type": "Drip irrigation most efficient method for banana cultivation",
        "sowing_process": "Pits dug and filled with topsoil, FYM, fertilizers mixture. Suckers or tissue-cultured plantlets planted in center",
        "growing_months": "Can be planted year-round. Ideal: February-April and August-October",
        "harvest_months": "Year-round depending on planting time",
        "precautions": "Use disease-free planting material, provide support (propping) to prevent falling, manage rhizome weevil and nematodes, remove suckers periodically"
    },
    "coconut": {
        "name": "Coconut",
        "soil_type": "Wide range of soils: laterite, coastal sandy, alluvial. Well-drained soils with pH: 5.2 to 8.0",
        "fertilizers": "FYM or compost applied. Mature palm: 1.3 kg Urea, 2.0 kg Superphosphate, 2.0 kg Muriate of Potash per year in two splits",
        "water_level": "Regular watering required, especially during summer. Mature palm needs 600-800 liters every 4-7 days",
        "harvest_time": "Harvested every 45-60 days. Tender coconuts: 7-8 months after spathe opening. Mature nuts: 12 months",
        "irrigation_type": "Drip irrigation highly efficient. Basin irrigation common",
        "sowing_process": "Seedlings raised in nurseries. Pits filled with topsoil, FYM, fertilizers. One-year-old seedlings planted",
        "growing_months": "June-July or September-October",
        "harvest_months": "Year-round",
        "precautions": "Choose seedlings from high-yielding mother palms, manage rhinoceros beetle and red palm weevil, provide adequate drainage, grow green manure crops in basin"
    },
    "mango": {
        "name": "Mango",
        "soil_type": "Wide variety of soils from alluvial to lateritic. Deep and well-drained. pH: 6.0 to 7.5",
        "fertilizers": "Mature bearing tree (10+ years): 25-50 kg FYM, 1.5 kg N, 1.0 kg P, 1.5 kg K per year in two splits",
        "water_level": "Young trees need regular watering. Mature trees: irrigation withheld 2-3 months before flowering, resumed after fruit set",
        "harvest_time": "12-16 weeks after fruit set when fruit shoulder rises level with stem and color changes to light green/yellowish",
        "irrigation_type": "Basin irrigation traditional. Drip irrigation widely adopted for efficient water use",
        "sowing_process": "Grafts planted in 1x1x1 meter pits filled with topsoil, FYM, fertilizers",
        "growing_months": "June to July (during monsoon)",
        "harvest_months": "April to July",
        "precautions": "Protect from mango hopper and fruit fly, manage powdery mildew and anthracnose, proper pruning and canopy management, control flowering through water and nutrient management"
    },
    "turmeric": {
        "name": "Turmeric",
        "soil_type": "Well-drained, friable, rich loamy or alluvial soils. pH: 4.5 to 7.5",
        "fertilizers": "FYM basal dressing. Recommended: 150:60:108 kg/ha N:P:K",
        "water_level": "Regular irrigation required. Field should be moist but not waterlogged",
        "harvest_time": "7-9 months when leaves and stem turn yellow and dry up",
        "irrigation_type": "Drip or sprinkler irrigation suitable. Raised bed and furrow irrigation practiced",
        "sowing_process": "Land ploughed thoroughly. Rhizomes (mother or finger) planted in raised beds or ridges",
        "growing_months": "May to June",
        "harvest_months": "January to March",
        "precautions": "Select healthy disease-free rhizomes, mulching after planting important, manage rhizome rot and leaf spot, earthing up 1-2 times during crop cycle"
    },
    "black_gram": {
        "name": "Black Gram",
        "soil_type": "Black cotton soils and loamy soils with good drainage. pH: 6.5 to 7.8",
        "fertilizers": "FYM beneficial. Starter dose: 20 kg/ha N, 50 kg/ha P",
        "water_level": "Mostly rainfed. 1-2 irrigations at flowering and pod formation if irrigated",
        "harvest_time": "65-80 days, when pods turn black",
        "irrigation_type": "Sprinkler or furrow irrigation if necessary",
        "sowing_process": "Land to fine tilth. Seeds broadcasted or sown in lines",
        "growing_months": "Rainfed: June-July; Rice fallows: Jan-Feb",
        "harvest_months": "Rainfed: Sep-Oct; Rice fallows: Apr-May",
        "precautions": "Treat seeds with Rhizobium, control pod borers and sucking pests, harvest at right stage to avoid shattering, weed management important"
    },
    "onion": {
        "name": "Onion (Small)",
        "soil_type": "Well-drained red loam to black soils. pH: 6.0 to 7.0",
        "fertilizers": "FYM during land prep. 60:60:30 kg/ha N:P:K",
        "water_level": "Frequent but light irrigation. Moisture critical during bulb formation",
        "harvest_time": "60-90 days, when tops fall over and necks are thin",
        "irrigation_type": "Drip or sprinkler recommended. Furrow can be adopted",
        "sowing_process": "Small bulbs planted on ridges or flatbeds",
        "growing_months": "April-May, Oct-Nov",
        "harvest_months": "June-July, Dec-Jan",
        "precautions": "Use well-cured, uniform bulbs, control thrips and caterpillars, weed management early, stop irrigation 10-15 days before harvest"
    },
    "sorghum": {
        "name": "Sorghum (Cholam)",
        "soil_type": "Clay loam and sandy loam soils with good drainage. pH: 6.0 to 7.5",
        "fertilizers": "FYM 12.5 t/ha. 90:45:45 kg/ha N:P:K for irrigated, in splits",
        "water_level": "Drought-tolerant but irrigation crucial for yield. 450-650 mm water",
        "harvest_time": "90-110 days, grains hard and <25% moisture",
        "irrigation_type": "Furrow irrigation common. Drip for efficiency",
        "sowing_process": "Land fine tilth. Seeds sown by drill or dibbling on ridges",
        "growing_months": "Irrigated: Jan-Feb, Apr-May; Rainfed: Jun-Jul, Sep-Oct",
        "harvest_months": "Irrigated: Apr-May, Jul-Aug",
        "precautions": "Treat seeds with fungicide, manage shoot fly and stem borer, timely weeding, crop rotation"
    },
    "finger_millet": {
        "name": "Finger Millet (Ragi)",
        "soil_type": "Alluvial, clayey loam, black soils. pH: 6.5 to 8.0",
        "fertilizers": "FYM 12.5 t/ha. 60:30:30 kg/ha N:P:K",
        "water_level": "Hardy, drought-tolerant. Irrigation at tillering and flowering boosts yield",
        "harvest_time": "100-120 days, earheads brownish-yellow",
        "irrigation_type": "Rainfed. Furrow or sprinkler if irrigated",
        "sowing_process": "Land fine tilth. Seedlings raised in nursery and transplanted, or direct sown",
        "growing_months": "Rainfed: Jun-Jul; Irrigated: Dec-Jan, Apr-May",
        "harvest_months": "Rainfed: Sep-Oct",
        "precautions": "Use disease-resistant varieties, manage blast disease, maintain plant population, timely harvest"
    },
    "greengram": {
        "name": "Greengram (Pasi Payaru)",
        "soil_type": "Loamy to sandy loam, red and black soils. pH: 6.5 to 7.5",
        "fertilizers": "FYM 12.5 t/ha. 25 kg/ha N, 50 kg/ha P",
        "water_level": "Low water use. Rainfed. 1-2 irrigations at flowering and pod filling if irrigated",
        "harvest_time": "65-90 days, 80% pods brown/black",
        "irrigation_type": "Sprinkler or furrow if needed",
        "sowing_process": "Land fine tilth. Seeds broadcast or sown in lines",
        "growing_months": "Rainfed: Jun-Jul; Rice fallows: Feb-Mar",
        "harvest_months": "Rainfed: Sep-Oct; Rice fallows: May-Jun",
        "precautions": "Treat seeds with Rhizobium, manage yellow mosaic virus, control pod borers, harvest in morning to avoid shattering"
    },
    "sesame": {
        "name": "Sesame (Gingelly / Ellu)",
        "soil_type": "Light to medium textured, sandy loams. pH: 5.5 to 8.0",
        "fertilizers": "FYM 12.5 t/ha. 35:23:23 kg/ha N:P:K",
        "water_level": "Highly drought-tolerant, rainfed. 1 irrigation at 30-35 days if no rain",
        "harvest_time": "80-90 days, leaves/stem/capsules yellow, lower leaves shed",
        "irrigation_type": "Rainfed. Check basin or furrow if needed",
        "sowing_process": "Land fine seedbed. Seeds broadcast and covered",
        "growing_months": "Rainfed: Jun-Jul; Irrigated: Dec-Jan, Apr-May",
        "harvest_months": "Rainfed: Sep-Oct",
        "precautions": "Avoid water stagnation, protect from shoot webber/gall fly, timely harvest, dry well before threshing"
    },
    "tapioca": {
        "name": "Tapioca (Maravalli Kizhangu)",
        "soil_type": "Well-drained, deep loamy, lateritic, red soils. pH: 5.5 to 7.0",
        "fertilizers": "FYM 25 t/ha. 90:90:180 kg/ha N:P:K in splits",
        "water_level": "Rainfed but responds to irrigation, especially first 3-4 months. Drought-tolerant after establishment",
        "harvest_time": "9-10 months, soil cracks, leaves yellow and fall",
        "irrigation_type": "Furrow or basin, drip recommended",
        "sowing_process": "Land fine tilth. Setts (stem cuttings) 15-20 cm planted on ridges/mounds",
        "growing_months": "Apr-May, Sep-Oct",
        "harvest_months": "Jan-Feb, Jul-Aug",
        "precautions": "Select healthy stems, manage Cassava Mosaic Disease, ensure drainage, regular earthing up"
    },
    "brinjal": {
        "name": "Brinjal (Eggplant)",
        "soil_type": "Clay loam, silt loam, pH: 5.5 to 6.5",
        "fertilizers": "FYM 25 t/ha. 100:50:50 kg/ha N:P:K, N in splits",
        "water_level": "Regular water, 5-7 day intervals. Moisture stress at flowering/fruiting reduces yield",
        "harvest_time": "50-60 days after transplanting, harvest when tender",
        "irrigation_type": "Furrow common, drip beneficial",
        "sowing_process": "Seedlings raised in nursery, transplanted after 30-35 days on ridges or raised beds",
        "growing_months": "Dec-Jan, May-Jun",
        "harvest_months": "Feb, Jul (continuous)",
        "precautions": "Manage shoot/fruit borer, control aphids/whiteflies, ensure drainage, choose varieties for market preference"
    },
    "chilli": {
        "name": "Chilli",
        "soil_type": "Loamy, clayey loam, rich in organic matter. pH: 6.5 to 7.5",
        "fertilizers": "FYM 25 t/ha. 120:60:60 kg/ha N:P:K",
        "water_level": "Sensitive to waterlogging. Irrigate regularly, especially flowering/fruiting",
        "harvest_time": "Green: 75 days after transplanting; Red: 100-120 days",
        "irrigation_type": "Furrow common, drip recommended",
        "sowing_process": "Seedlings raised in nursery, transplanted after 35-40 days on ridges or raised beds",
        "growing_months": "Jun-Jul, Sep-Oct",
        "harvest_months": "Aug, Nov (several pickings)",
        "precautions": "Manage thrips/fruit borers, control leaf curl virus, avoid excess nitrogen, dry red chillies well"
    },
    "tea": {
        "name": "Tea",
        "soil_type": "Deep, well-drained, acidic soils (pH 4.5-5.5), rich in organic matter",
        "fertilizers": "High nutrient requirement, balanced NPK in splits, foliar sprays",
        "water_level": "Needs 1500-2500 mm rainfall/year. Irrigate in drought",
        "harvest_time": "Plucking year-round, peak Apr-Jun, Sep-Nov",
        "irrigation_type": "Sprinkler common in dry spells",
        "sowing_process": "Clones raised in nursery 9-12 months, then planted in field",
        "growing_months": "Jun-Jul, Sep-Oct",
        "harvest_months": "Year-round, peak seasons",
        "precautions": "Maintain soil acidity, regular pruning, manage mosquito bug/mite/blister blight, use shade trees"
    },
    "cumbu": {
        "name": "Cumbu (Pearl Millet / Kambu)",
        "soil_type": "Well-drained sandy loams, loamy soils. pH: 6.5 to 7.5",
        "fertilizers": "FYM 12.5 t/ha. 80:40:40 kg/ha N:P:K, N in splits",
        "water_level": "Rainfed, 350-450 mm if irrigated. Critical: tillering, flowering, grain filling",
        "harvest_time": "80-100 days, grains hard, 20% moisture, earheads pale yellow",
        "irrigation_type": "Rainfed, furrow or sprinkler if irrigated",
        "sowing_process": "Land fine tilth. Seeds sown by drill or broadcast, sometimes transplanted",
        "growing_months": "Rainfed: Jun-Jul; Irrigated: Jan-Feb, Apr-May",
        "harvest_months": "Rainfed: Sep-Oct",
        "precautions": "Use certified seeds, manage shoot fly/stem borer, downy mildew/ergot, timely weeding"
    },
    "bengal_gram": {
        "name": "Bengal Gram (Kadalai Paruppu)",
        "soil_type": "Well-drained, light to heavy black soils. pH: 6.0 to 8.0",
        "fertilizers": "FYM 12.5 t/ha. 25:50:25 kg/ha N:P:K",
        "water_level": "Rainfed, 1 pre-sowing and 1 at flowering/pod formation if irrigated",
        "harvest_time": "90-100 days, leaves yellow-brown and shed",
        "irrigation_type": "Rainfed, sprinkler or furrow if needed",
        "sowing_process": "Land ploughed well, seeds sown by drill",
        "growing_months": "Oct-Nov",
        "harvest_months": "Jan-Feb",
        "precautions": "Treat seeds with Rhizobium/Trichoderma, manage pod borer, wilt, harvest in morning"
    },
    "sunflower": {
        "name": "Sunflower",
        "soil_type": "Loamy, black cotton soils, good organic matter. pH: 6.0 to 7.5",
        "fertilizers": "FYM 12.5 t/ha. 60:90:60 kg/ha N:P:K for hybrids, 20 kg/ha Sulphur",
        "water_level": "Moderately drought-tolerant. Critical: bud initiation, flowering, seed filling",
        "harvest_time": "90-100 days, back of head lemon yellow, lower leaves dry",
        "irrigation_type": "Furrow/alternate furrow, drip effective",
        "sowing_process": "Land fine tilth. Seeds dibbled on ridges/furrows",
        "growing_months": "Jun-Jul (rainfed), Dec-Jan (irrigated)",
        "harvest_months": "Sep-Oct, Mar-Apr",
        "precautions": "Correct plant population, bird damage at seed fill, manage head borer/leaf spot/downy mildew, hand pollination helps"
    },
    "jasmine": {
        "name": "Jasmine (Malli)",
        "soil_type": "Well-drained sandy loam/red loamy, rich in organic matter. pH: 6.5 to 7.5",
        "fertilizers": "10 kg FYM/pit at planting. Mature: 120:240:240 g N:P:K/plant/year in 2 splits",
        "water_level": "Regular irrigation, especially flowering. Summer: every 2-3 days. Avoid stagnation",
        "harvest_time": "Plucking of buds in early morning. Peak: Mar-Oct",
        "irrigation_type": "Basin/furrow common, drip recommended",
        "sowing_process": "Rooted cuttings in 45x45x45 cm pits with topsoil/FYM",
        "growing_months": "Jun-Nov",
        "harvest_months": "Flowering starts 6 months after planting, almost year-round",
        "precautions": "Prune after main flowering, manage budworm/gallery worm, control leaf blight/wilt, good nutrient/water management"
    },
    "papaya": {
        "name": "Papaya",
        "soil_type": "Well-drained, deep, fertile loamy soils. pH: 6.0 to 7.0",
        "fertilizers": "10 kg FYM/pit at planting. Bearing: 200-250 g NPK/plant/year in 4-6 splits",
        "water_level": "Regular, moderate irrigation. Over-watering harmful. Higher need during fruit development",
        "harvest_time": "9-10 months after planting, harvest when full size and apical end turns yellow",
        "irrigation_type": "Drip best, ring basin also used",
        "sowing_process": "Seedlings in polybags, 30-45 days old, transplanted in 60x60x60 cm pits",
        "growing_months": "Year-round, monsoon (Jun-Jul) preferred",
        "harvest_months": "Year-round from 9th month",
        "precautions": "Perfect drainage to prevent collar rot, manage ring spot virus, maintain male:female ratio, protect from wind/frost"
    },
    "moringa": {
        "name": "Moringa (Drumstick)",
        "soil_type": "Wide range, prefers well-drained sandy loam, not waterlogged",
        "fertilizers": "Not heavy feeder. Annual: 45:15:30 kg/ha N:P:K. FYM improves growth",
        "water_level": "Drought-tolerant. Young plants need watering for establishment. Irrigate at flowering/pod development for yield",
        "harvest_time": "Annual: pods from 6 months after planting, harvest when tender and finger-thick",
        "irrigation_type": "Mostly rainfed, drip or basin if needed",
        "sowing_process": "Seeds or stem cuttings. Commercial: seeds sown in 45x45x45 cm pits",
        "growing_months": "Year-round",
        "harvest_months": "Year-round from 6th month",
        "precautions": "Avoid waterlogging, manage fruit fly, prune after harvest, use improved varieties"
    }
}

def extract_crop_name(user_message):
    """Extract crop name from user message."""
    message_lower = user_message.lower()
    
    # Direct crop name matches
    for crop_key, crop_data in CROP_DATABASE.items():
        if crop_key in message_lower or crop_data["name"].lower() in message_lower:
            return crop_key
    
    # Alternative names and Tamil names
    crop_aliases = {
        "rice": "paddy", "paddy": "paddy", "arisi": "paddy",
        "sugarcane": "sugarcane", "karumbu": "sugarcane",
        "cotton": "cotton", "paruthi": "cotton",
        "corn": "maize", "cholam": "maize", "maize": "maize",
        "peanut": "groundnut", "verkadalai": "groundnut", "groundnut": "groundnut",
        "thakkali": "tomato", "tomato": "tomato",
        "vazhai": "banana", "banana": "banana",
        "thengai": "coconut", "coconut": "coconut",
        "manga": "mango", "mango": "mango",
        "manjal": "turmeric", "turmeric": "turmeric"
    }
    
    for alias, crop_key in crop_aliases.items():
        if alias in message_lower:
            return crop_key
    
    return None

def generate_crop_response(crop_key, question_type, user_message):
    """Generate detailed response based on crop data and question type."""
    if crop_key not in CROP_DATABASE:
        return "I don't have detailed information about that crop in my Tamil Nadu database. I can help you with Paddy, Sugarcane, Cotton, Maize, Groundnut, Tomato, Banana, Coconut, Mango, and Turmeric."
    
    crop_data = CROP_DATABASE[crop_key]
    crop_name = crop_data["name"]
    
    if question_type == "soil":
        return f"**{crop_name} Soil Requirements:**\n{crop_data['soil_type']}\n\n**Sowing Process:**\n{crop_data['sowing_process']}\n\n**Precautions:**\n{crop_data['precautions']}"
    
    elif question_type == "fertilizer":
        return f"**{crop_name} Fertilizer Requirements:**\n{crop_data['fertilizers']}\n\n**Precautions:**\n{crop_data['precautions']}"
    
    elif question_type == "water":
        return f"**{crop_name} Water Management:**\n{crop_data['water_level']}\n\n**Irrigation Type:**\n{crop_data['irrigation_type']}\n\n**Precautions:**\n{crop_data['precautions']}"
    
    elif question_type == "harvest":
        return f"**{crop_name} Harvest Information:**\n**Harvest Time:** {crop_data['harvest_time']}\n**Growing Months:** {crop_data['growing_months']}\n**Harvest Months:** {crop_data['harvest_months']}\n\n**Precautions:**\n{crop_data['precautions']}"
    
    elif question_type == "season":
        return f"**{crop_name} Growing Seasons:**\n**Growing Months:** {crop_data['growing_months']}\n**Harvest Months:** {crop_data['harvest_months']}\n\n**Sowing Process:**\n{crop_data['sowing_process']}\n\n**Precautions:**\n{crop_data['precautions']}"
    
    elif question_type == "pest" or question_type == "disease":
        return f"**{crop_name} Pest and Disease Management:**\n{crop_data['precautions']}\n\n**General Care:**\n**Soil:** {crop_data['soil_type']}\n**Water:** {crop_data['water_level']}\n**Fertilizer:** {crop_data['fertilizers']}"
    
    else:
        # Complete crop information
        return f"""**{crop_name} Complete Cultivation Guide:**

**Soil Requirements:**
{crop_data['soil_type']}

**Fertilizer Requirements:**
{crop_data['fertilizers']}

**Water Management:**
{crop_data['water_level']}
**Irrigation Type:** {crop_data['irrigation_type']}

**Harvest Information:**
**Harvest Time:** {crop_data['harvest_time']}
**Growing Months:** {crop_data['growing_months']}
**Harvest Months:** {crop_data['harvest_months']}

**Sowing Process:**
{crop_data['sowing_process']}

**Important Precautions:**
{crop_data['precautions']}"""

def analyze_question_type(user_message):
    """Analyze what type of information the user is asking for."""
    message_lower = user_message.lower()
    
    if any(word in message_lower for word in ["soil", "dirt", "ground", "land"]):
        return "soil"
    elif any(word in message_lower for word in ["fertilizer", "manure", "nutrient", "fym", "npk"]):
        return "fertilizer"
    elif any(word in message_lower for word in ["water", "irrigation", "watering", "moisture"]):
        return "water"
    elif any(word in message_lower for word in ["harvest", "yield", "picking", "mature"]):
        return "harvest"
    elif any(word in message_lower for word in ["season", "month", "when", "time", "planting", "sowing"]):
        return "season"
    elif any(word in message_lower for word in ["pest", "disease", "insect", "bug", "control", "management"]):
        return "pest"
    else:
        return "general"

def generate_agricultural_response(user_message):
    """Generate intelligent agricultural responses based on Tamil Nadu crop data."""
    message_lower = user_message.lower()
    
    # Greeting responses
    if any(word in message_lower for word in ["hello", "hi", "hey", "greetings"]):
        return "Hello! I'm your Tamil Nadu Agricultural AI assistant. I can help you with detailed cultivation information for major crops like Paddy, Sugarcane, Cotton, Maize, Groundnut, Tomato, Banana, Coconut, Mango, and Turmeric. What crop would you like to know about?"
    
    # Extract crop name and question type
    crop_key = extract_crop_name(user_message)
    question_type = analyze_question_type(user_message)
    
    if crop_key:
        return generate_crop_response(crop_key, question_type, user_message)
    
    # General agricultural advice
    if any(word in message_lower for word in ["crop", "farming", "agriculture", "cultivation"]):
        return "I can help you with detailed cultivation information for Tamil Nadu crops. I have comprehensive data on: Paddy (Rice), Sugarcane, Cotton, Maize, Groundnut, Tomato, Banana, Coconut, Mango, and Turmeric. Please specify which crop you'd like to know about."
    
    # List available crops
    if any(word in message_lower for word in ["list", "available", "crops", "what crops"]):
        crop_list = "\n".join([f"• {data['name']}" for data in CROP_DATABASE.values()])
        return f"**Available Crops in Tamil Nadu Database:**\n{crop_list}\n\nAsk me about any specific crop for detailed cultivation information!"
    
    # Default response
    return "I'm your Tamil Nadu Agricultural AI assistant. I can provide detailed cultivation information for major crops including soil requirements, fertilizers, water management, harvest timing, and precautions. Please ask about a specific crop like Paddy, Sugarcane, Cotton, Maize, Groundnut, Tomato, Banana, Coconut, Mango, or Turmeric."

@app.route('/v1/models', methods=['GET'])
def list_models():
    """List available models."""
    return jsonify({
        "object": "list",
        "data": [{
            "id": "tamil-nadu-agricultural-ai",
            "object": "model",
            "created": int(time.time()),
            "owned_by": "tamil-nadu-agricultural-database"
        }]
    })

@app.route('/v1/chat/completions', methods=['POST'])
def chat_completions():
    """Handle chat completion requests with Tamil Nadu agricultural expertise."""
    data = request.get_json()
    messages = data.get('messages', [])
    
    if not messages:
        return jsonify({"error": "No messages provided"}), 400
    
    # Get the last user message
    user_message = ""
    for msg in reversed(messages):
        if msg.get('role') == 'user':
            user_message = msg.get('content', '')
            break
    
    # Generate agricultural response
    response = generate_agricultural_response(user_message)
    
    return jsonify({
        "id": f"chatcmpl-{int(time.time())}",
        "object": "chat.completion",
        "created": int(time.time()),
        "model": "tamil-nadu-agricultural-ai",
        "choices": [{
            "index": 0,
            "message": {
                "role": "assistant",
                "content": response
            },
            "finish_reason": "stop"
        }],
        "usage": {
            "prompt_tokens": len(user_message.split()),
            "completion_tokens": len(response.split()),
            "total_tokens": len(user_message.split()) + len(response.split())
        }
    })

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({"status": "healthy", "model": "tamil-nadu-agricultural-ai", "crops": len(CROP_DATABASE)})

if __name__ == '__main__':
    print("Starting Tamil Nadu Agricultural AI Model Server...")
    print("Based on comprehensive Tamil Nadu crop dataset")
    print(f"Database contains {len(CROP_DATABASE)} major crops")
    print("Available endpoints:")
    print("  GET  /v1/models")
    print("  POST /v1/chat/completions")
    print("  GET  /health")
    print("Server will run on http://127.0.0.1:5001")
    app.run(host='127.0.0.1', port=5001, debug=False)
