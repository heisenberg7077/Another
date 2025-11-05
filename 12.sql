-- ===============================================
-- 🌱 WEEKLY TASKS: POMEGRANATE, POTATO, RICE, RUBBER, SOYBEAN
-- ===============================================

-- ===== 1️⃣ POMEGRANATE (crop_id = 28) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 28, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Pit Preparation', 'Prepare 1x1x1m pits filled with FYM and topsoil.', 'maintenance', 'High', '3 hours', 'Spade, hoe', 'FYM, soil mix', 'dry', '1. Mix FYM thoroughly\n2. Leave pits open for 15 days', 'Avoid heavy rain during pit work.', 'Aerated, fertile planting pits'),
    (2, 'Planting', 'Plant one-year-old grafted pomegranate saplings.', 'maintenance', 'Critical', '3 hours', 'Spade, rope', 'Grafted saplings, water', 'humid', '1. Place upright\n2. Irrigate immediately', 'Handle grafts carefully.', 'Healthy sapling establishment'),
    (5, 'Irrigation Setup', 'Install drip irrigation for efficient watering.', 'irrigation', 'High', '2 hours', 'Drip set, pump', 'Water', 'dry', '1. Set drippers near root zone\n2. Test flow rate', 'Avoid electrical hazards.', 'Uniform moisture distribution'),
    (8, 'Pruning & Training', 'Remove suckers and shape plant canopy.', 'pruning', 'High', '2 hours', 'Pruning shears', 'None', 'dry', '1. Prune after flush\n2. Apply fungicide to cuts', 'Use gloves and mask.', 'Open canopy for sunlight'),
    (12, 'Fertilizer Application', 'Apply 500g urea + 250g SSP + 250g MOP per plant.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, SSP, MOP', 'cloudy', '1. Apply evenly\n2. Irrigate after', 'Avoid contact with fertilizers.', 'Improved flowering and fruit set'),
    (16, 'Pest Management', 'Spray neem oil for fruit borer and aphid control.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray in evening\n2. Avoid overuse', 'Use mask and gloves.', 'Reduced pest incidence'),
    (20, 'Fruit Bagging', 'Cover fruits with paper bags to avoid pest attack.', 'maintenance', 'Medium', '2 hours', 'Paper bags, ladder', 'None', 'dry', '1. Bag fruits at 50% maturity', 'Avoid using wet bags.', 'Improved fruit quality'),
    (28, 'Harvesting', 'Harvest fully colored, mature fruits.', 'harvesting', 'Critical', '4 hours', 'Scissors, basket', 'None', 'dry', '1. Cut fruit stalk gently\n2. Avoid bruising', 'Use gloves.', 'Fresh, market-ready fruits')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 28 AND w.week_number = t.week_number);

-- ===== 2️⃣ POTATO (crop_id = 5) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 5, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Soil Preparation', 'Prepare fine tilth soil and apply FYM 10 tons/acre.', 'maintenance', 'High', '3 hours', 'Plough, harrow', 'FYM', 'dry', '1. Plough 2–3 times\n2. Mix FYM', 'Avoid over-tillage.', 'Loose, fertile soil'),
    (2, 'Seed Cutting & Treatment', 'Cut seed tubers and treat with fungicide.', 'maintenance', 'Critical', '1 hour', 'Knife, bucket', 'Fungicide', 'dry', '1. Cut tubers\n2. Treat with fungicide\n3. Dry in shade', 'Wear gloves.', 'Disease-free seed pieces'),
    (3, 'Planting', 'Plant treated tubers at 60x20 cm spacing.', 'maintenance', 'High', '2 hours', 'Seeder, rope', 'Seed tubers', 'cool', '1. Plant 5–8 cm deep', 'Avoid deep planting.', 'Uniform germination'),
    (4, 'Irrigation', 'Light irrigation after planting.', 'irrigation', 'High', '1 hour', 'Pump', 'Water', 'dry', '1. Irrigate lightly\n2. Maintain moisture', 'Avoid waterlogging.', 'Uniform sprouting'),
    (6, 'Weeding & Earthing Up', 'Weed manually and earth up around base.', 'maintenance', 'High', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed at 20 DAS\n2. Raise soil around plants', 'Beware of roots.', 'Improved tuber development'),
    (8, 'Fertilizer Application', 'Apply 25kg Urea + 10kg Potash/acre.', 'fertilizer', 'High', '1 hour', 'Spreader', 'Urea, Potash', 'cloudy', '1. Apply evenly\n2. Irrigate after', 'Wear gloves.', 'Enhanced vegetative growth'),
    (10, 'Pest Control', 'Spray neem oil for aphids and blight control.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray evening time', 'Avoid inhalation.', 'Healthy green leaves'),
    (12, 'Harvesting', 'Harvest after 90–100 days when leaves yellow.', 'harvesting', 'Critical', '4 hours', 'Spade, basket', 'None', 'dry', '1. Lift tubers gently\n2. Dry under shade', 'Avoid bruising.', 'Clean, market-ready tubers')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 5 AND w.week_number = t.week_number);

-- ===== 3️⃣ RICE (crop_id = 2) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 2, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Nursery Bed Preparation', 'Prepare 10x1m beds and apply compost.', 'maintenance', 'High', '3 hours', 'Hoe, rake', 'Compost, seeds', 'humid', '1. Mix compost evenly\n2. Level surface', 'Avoid overwatering.', 'Healthy seedling growth'),
    (2, 'Sowing', 'Broadcast seeds evenly on nursery beds.', 'maintenance', 'Critical', '2 hours', 'Hands, bucket', 'Seeds', 'cool', '1. Sow evenly\n2. Cover lightly with soil', 'Avoid thick seeding.', 'Uniform germination'),
    (4, 'Transplanting', 'Transplant 25-day-old seedlings to main field.', 'maintenance', 'High', '4 hours', 'Spade, rope', 'Seedlings', 'humid', '1. Maintain 20x20 cm spacing\n2. Transplant shallowly', 'Avoid midday heat.', 'Healthy establishment'),
    (6, 'Weeding', 'Use cono weeder at 20 DAS.', 'maintenance', 'Medium', '2 hours', 'Cono weeder', 'None', 'sunny', '1. Operate between rows', 'Wear boots.', 'Improved aeration'),
    (8, 'Fertilizer Application', 'Apply 40kg Urea + 30kg SSP/acre.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, SSP', 'cloudy', '1. Apply evenly\n2. Irrigate after', 'Avoid contact.', 'Vigorous tillering'),
    (10, 'Pest Control', 'Spray neem oil for stem borer control.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray at dusk', 'Use mask.', 'Reduced pest damage'),
    (14, 'Harvesting', 'Harvest when grains turn golden.', 'harvesting', 'Critical', '5 hours', 'Sickle, basket', 'None', 'dry', '1. Cut and dry in shade', 'Avoid over-drying.', 'Clean, high-quality paddy')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 2 AND w.week_number = t.week_number);

-- ===== 4️⃣ RUBBER (crop_id = 30) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 30, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Clearing & Pit Preparation', 'Clear weeds and prepare 60x60x60 cm pits.', 'maintenance', 'High', '3 hours', 'Spade, hoe', 'Compost, lime', 'dry', '1. Mix compost\n2. Leave open 2 weeks', 'Avoid working under rain.', 'Fertile pits ready for planting'),
    (2, 'Planting', 'Plant 1-year-old budded stumps.', 'maintenance', 'Critical', '3 hours', 'Spade, rope', 'Seedlings, water', 'humid', '1. Place upright\n2. Irrigate lightly', 'Handle plants carefully.', 'Healthy plantation'),
    (8, 'Weeding & Mulching', 'Weed basins and apply mulch.', 'maintenance', 'High', '2 hours', 'Hoe, gloves', 'Dry leaves', 'sunny', '1. Weed around plants\n2. Spread mulch', 'Beware of insects.', 'Clean basins, retained moisture'),
    (12, 'Fertilizer Application', 'Apply NPK 20:10:10 per plant.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, SSP, MOP', 'cloudy', '1. Mix evenly\n2. Irrigate after', 'Avoid skin contact.', 'Improved growth'),
    (24, 'Pest Management', 'Inspect for leaf diseases and spray Bordeaux mixture.', 'pesticide', 'High', '2 hours', 'Sprayer', 'Bordeaux mix', 'humid', '1. Spray thoroughly', 'Use gloves and mask.', 'Reduced disease incidence'),
    (36, 'Tapping Preparation', 'Select mature trees for tapping.', 'maintenance', 'High', '3 hours', 'Knife, gloves', 'Tapping tools', 'dry', '1. Mark tapping height\n2. Train worker', 'Avoid injuries.', 'Ready trees for latex collection')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 30 AND w.week_number = t.week_number);

-- ===== 5️⃣ SOYBEAN (crop_id = 9) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 9, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation', 'Prepare soil to fine tilth and apply FYM 5 tons/acre.', 'maintenance', 'High', '3 hours', 'Tractor, harrow', 'FYM', 'dry', '1. Level field\n2. Mix FYM evenly', 'Avoid compaction.', 'Prepared seedbed'),
    (2, 'Seed Treatment', 'Treat seeds with Rhizobium and Trichoderma.', 'maintenance', 'Critical', '1 hour', 'Bucket, gloves', 'Rhizobium, Trichoderma', 'dry', '1. Mix and dry seeds in shade', 'Use gloves.', 'Healthy germination'),
    (3, 'Sowing', 'Drill seeds 30x10 cm apart.', 'maintenance', 'High', '2 hours', 'Seeder', 'Seeds', 'cloudy', '1. Sow at 3–5 cm depth\n2. Maintain spacing', 'Avoid deep planting.', 'Uniform emergence'),
    (5, 'Weeding', 'Manual or chemical weeding at 20 DAS.', 'maintenance', 'Medium', '2 hours', 'Hoe, sprayer', 'Pendimethalin', 'sunny', '1. Apply pre-emergence herbicide', 'Use protective mask.', 'Weed-free crop'),
    (6, 'Fertilizer Application', 'Apply DAP 25kg/acre.', 'fertilizer', 'High', '1 hour', 'Spreader', 'DAP', 'cloudy', '1. Apply evenly\n2. Irrigate lightly', 'Avoid over-application.', 'Healthy crop growth'),
    (8, 'Pest Control', 'Spray neem oil for defoliator management.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray in evening', 'Use gloves.', 'Reduced leaf damage'),
    (10, 'Irrigation', 'Provide irrigation at flowering stage.', 'irrigation', 'High', '1 hour', 'Pump', 'Water', 'dry', '1. Irrigate lightly\n2. Maintain moisture', 'Avoid flooding.', 'Improved pod set'),
    (12, 'Harvesting', 'Harvest when pods turn yellow-brown.', 'harvesting', 'Critical', '3 hours', 'Sickle, basket', 'None', 'dry', '1. Cut plants early morning\n2. Dry in shade', 'Avoid shattering.', 'Good-quality soybean grains')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 9 AND w.week_number = t.week_number);

-- ===============================================
-- ✅ END OF WEEKLY TASKS FOR POMEGRANATE, POTATO, RICE, RUBBER, SOYBEAN
-- ===============================================
-- ===============================================
-- 🌱 DETAILED WEEKLY TASKS: MAIZE, MANGO, ONION, PAPAYA, PIGEON PEA
-- ===============================================

-- ===== 1️⃣ MAIZE (crop_id = 4) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 4, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation', 'Prepare field with 2–3 ploughings and apply FYM 5 tons/acre.', 'maintenance', 'High', '3 hours', 'Tractor, harrow', 'FYM', 'dry', '1. Plough and level soil\n2. Apply FYM evenly', 'Avoid deep tilling in wet soil.', 'Fertile and fine tilth soil ready for sowing'),
    (2, 'Seed Sowing', 'Sow treated maize seeds in rows at 60x20 cm spacing.', 'maintenance', 'Critical', '2 hours', 'Seeder', 'Seeds, fungicide', 'humid', '1. Treat seeds with fungicide\n2. Sow at 3–5 cm depth', 'Wear gloves.', 'Uniform germination'),
    (3, 'First Irrigation', 'Light irrigation immediately after sowing.', 'irrigation', 'High', '1 hour', 'Pump, hose', 'Water', 'dry', '1. Irrigate gently', 'Avoid erosion.', 'Uniform seedling emergence'),
    (5, 'Weeding', 'Manual or mechanical weeding at 20 DAS.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed at base\n2. Avoid damaging roots', 'Wear gloves.', 'Weed-free crop stand'),
    (6, 'Top Dressing', 'Apply 25 kg Urea/acre for vegetative growth.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea', 'cloudy', '1. Apply along rows\n2. Irrigate after', 'Avoid skin contact.', 'Enhanced leaf growth'),
    (8, 'Pest Control', 'Spray neem oil against stem borer.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray evening time', 'Avoid inhalation.', 'Reduced pest incidence'),
    (10, 'Earthing Up', 'Raise soil around plant base for support.', 'maintenance', 'High', '2 hours', 'Hoe', 'None', 'dry', '1. Raise soil gently\n2. Avoid root damage', 'Wear protective footwear.', 'Stable plants with strong stems'),
    (12, 'Harvesting', 'Harvest when cobs are mature and husk turns yellow.', 'harvesting', 'Critical', '4 hours', 'Knife, basket', 'None', 'dry', '1. Cut cobs\n2. Dry under shade', 'Avoid over-drying.', 'Fully matured maize cobs')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 4 AND w.week_number = t.week_number);

-- ===== 2️⃣ MANGO (crop_id = 18) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 18, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Pit Preparation', 'Prepare 1x1x1m pits with compost and soil mix.', 'maintenance', 'High', '3 hours', 'Spade, hoe', 'Compost, topsoil', 'dry', '1. Mix compost evenly\n2. Leave open for sun', 'Avoid during rain.', 'Fertile pits ready for planting'),
    (2, 'Planting', 'Plant healthy grafted mango saplings at 8x8 m spacing.', 'maintenance', 'Critical', '3 hours', 'Spade, rope', 'Grafted plants', 'humid', '1. Place upright\n2. Irrigate gently', 'Avoid deep planting.', 'Healthy plantation established'),
    (6, 'Irrigation', 'Provide basin irrigation every 10 days.', 'irrigation', 'High', '2 hours', 'Pump, hose', 'Water', 'dry', '1. Maintain moist basin\n2. Avoid stagnation', 'Avoid flooding.', 'Proper soil moisture'),
    (8, 'Weeding', 'Weed around tree basins manually.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed early morning\n2. Apply mulch', 'Beware of snakes.', 'Clean basins, conserved moisture'),
    (12, 'Fertilizer Application', 'Apply NPK 700:300:300 g/tree.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, SSP, MOP', 'cloudy', '1. Apply around drip line\n2. Irrigate after', 'Avoid overuse.', 'Healthy vegetative growth'),
    (20, 'Pest Control', 'Spray neem oil or imidacloprid for hopper management.', 'pesticide', 'Critical', '1 hour', 'Sprayer', 'Neem oil, imidacloprid', 'humid', '1. Spray evening time', 'Use gloves and mask.', 'Reduced pest population'),
    (24, 'Pruning & Sanitation', 'Remove dried twigs and infected branches.', 'pruning', 'High', '3 hours', 'Pruning shears', 'Fungicide paste', 'dry', '1. Prune cleanly\n2. Apply paste to wounds', 'Use safety belt.', 'Improved canopy structure'),
    (36, 'Harvesting', 'Harvest mature mangoes when shoulders rise.', 'harvesting', 'Critical', '5 hours', 'Basket, gloves', 'None', 'dry', '1. Pluck using picking pole\n2. Handle gently', 'Avoid dropping fruits.', 'Fresh, market-ready mangoes')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 18 AND w.week_number = t.week_number);

-- ===== 3️⃣ ONION (crop_id = 20) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 20, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Nursery Preparation', 'Prepare raised nursery beds and sow onion seeds.', 'maintenance', 'High', '3 hours', 'Hoe, rake', 'Seeds, compost', 'humid', '1. Prepare fine tilth\n2. Sow seeds evenly', 'Avoid heavy watering.', 'Healthy seedlings'),
    (3, 'Transplanting', 'Transplant 45-day-old seedlings to field.', 'maintenance', 'Critical', '3 hours', 'Spade, rope', 'Seedlings', 'cool', '1. Transplant in evening\n2. Water immediately', 'Avoid root damage.', 'Healthy establishment'),
    (4, 'First Irrigation', 'Light irrigation post-transplant.', 'irrigation', 'High', '1 hour', 'Pump', 'Water', 'dry', '1. Irrigate gently\n2. Maintain moisture', 'Avoid waterlogging.', 'Proper plant stand'),
    (6, 'Fertilizer Application', 'Apply DAP 25kg/acre.', 'fertilizer', 'High', '1 hour', 'Spreader', 'DAP', 'cloudy', '1. Apply evenly\n2. Irrigate after', 'Wear gloves.', 'Improved root growth'),
    (8, 'Weeding & Earthing Up', 'Weed manually and raise soil near bulbs.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed shallowly\n2. Raise soil lightly', 'Avoid bulb injury.', 'Clean bulbs and healthy growth'),
    (10, 'Pest Management', 'Spray neem oil for thrip control.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray evening time', 'Use mask and gloves.', 'Reduced pest population'),
    (14, 'Harvesting', 'Harvest when tops fall and necks dry.', 'harvesting', 'Critical', '3 hours', 'Sickle, basket', 'None', 'dry', '1. Uproot bulbs gently\n2. Cure under shade', 'Avoid bruising.', 'Dry bulbs suitable for storage')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 20 AND w.week_number = t.week_number);

-- ===== 4️⃣ PAPAYA (crop_id = 21) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 21, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Pit Preparation', 'Prepare 60x60x60 cm pits with compost + soil mix.', 'maintenance', 'High', '3 hours', 'Spade, hoe', 'FYM, soil', 'dry', '1. Mix compost\n2. Leave pits open 10 days', 'Avoid heavy rain.', 'Fertile pits ready'),
    (2, 'Planting', 'Plant healthy seedlings in the evening.', 'maintenance', 'Critical', '2 hours', 'Spade, rope', 'Seedlings', 'humid', '1. Place upright\n2. Irrigate immediately', 'Handle gently.', 'Good survival rate'),
    (4, 'Irrigation', 'Light irrigation twice a week.', 'irrigation', 'High', '2 hours', 'Pump', 'Water', 'hot', '1. Maintain moisture\n2. Avoid stagnation', 'Do not over-irrigate.', 'Active growth'),
    (6, 'Fertilizer Application', 'Apply NPK 250:150:150 g/plant monthly.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, SSP, MOP', 'cloudy', '1. Apply near root zone\n2. Irrigate after', 'Avoid direct contact.', 'Improved fruiting'),
    (10, 'Weeding', 'Weed manually and apply mulch.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'Dry leaves', 'sunny', '1. Weed lightly\n2. Apply mulch', 'Beware of snakes.', 'Clean basins'),
    (12, 'Pest Management', 'Spray neem oil for aphid control.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray at dusk', 'Use mask and gloves.', 'Reduced pest infestation'),
    (20, 'Harvesting', 'Harvest fruits when skin turns yellowish.', 'harvesting', 'Critical', '3 hours', 'Knife, basket', 'None', 'dry', '1. Cut fruits carefully\n2. Handle gently', 'Avoid dropping fruits.', 'Market-quality papaya fruits')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 21 AND w.week_number = t.week_number);

-- ===== 5️⃣ PIGEON PEA (crop_id = 11) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 11, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation', 'Plough field twice and level soil.', 'maintenance', 'High', '3 hours', 'Tractor, harrow', 'None', 'dry', '1. Create fine tilth\n2. Remove stubbles', 'Avoid during rain.', 'Well-prepared field'),
    (2, 'Sowing', 'Sow seeds in rows 60x20 cm apart.', 'maintenance', 'Critical', '2 hours', 'Seeder', 'Seeds', 'cloudy', '1. Sow shallowly\n2. Maintain spacing', 'Avoid sowing in wet soil.', 'Uniform germination'),
    (3, 'Weeding', 'Manual weeding at 20 DAS.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed manually', 'Use gloves.', 'Reduced competition'),
    (6, 'Fertilizer Application', 'Apply DAP 25kg/acre at branching.', 'fertilizer', 'High', '2 hours', 'Spreader', 'DAP', 'cloudy', '1. Apply evenly\n2. Irrigate lightly', 'Avoid inhalation.', 'Healthy branching'),
    (8, 'Pest Control', 'Spray neem oil for pod borer management.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray in evening', 'Use mask.', 'Reduced pest attack'),
    (10, 'Irrigation', 'Light irrigation during flowering.', 'irrigation', 'Critical', '1 hour', 'Pump', 'Water', 'dry', '1. Maintain soil moisture', 'Avoid flooding.', 'Better pod formation'),
    (12, 'Harvesting', 'Harvest when 80% pods mature.', 'harvesting', 'Critical', '3 hours', 'Sickle, basket', 'None', 'dry', '1. Cut plants\n2. Dry in shade', 'Avoid over-drying.', 'Good-quality grain yield')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 11 AND w.week_number = t.week_number);

-- ===============================================
-- ✅ END OF WEEKLY TASKS FOR MAIZE, MANGO, ONION, PAPAYA, PIGEON PEA
-- ===============================================
-- ===============================================
-- 🌱 WEEKLY TASKS: GROUNDNUT, GUAVA, JUTE, LENTIL
-- ===============================================

-- ===== 1️⃣ GROUNDNUT (crop_id = 10) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 10, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation', 'Prepare well-drained sandy loam field and apply FYM 5 tons/acre.', 'maintenance', 'High', '3 hours', 'Tractor, harrow', 'FYM', 'dry', '1. Level the field\n2. Mix FYM evenly\n3. Remove stones', 'Avoid soil compaction.', 'Loose soil suitable for sowing'),
    (2, 'Seed Treatment & Sowing', 'Treat seeds with Rhizobium and sow at 30x10 cm spacing.', 'maintenance', 'Critical', '2 hours', 'Seeder, bucket', 'Rhizobium, seeds', 'cloudy', '1. Treat seeds 1 day prior\n2. Sow shallow', 'Use gloves.', 'Healthy germination'),
    (3, 'First Irrigation', 'Light irrigation 7 days after sowing.', 'irrigation', 'High', '1 hour', 'Pump, hose', 'Water', 'dry', '1. Irrigate evenly', 'Avoid flooding.', 'Good establishment'),
    (5, 'Weeding', 'Manual weeding at 15–20 DAS.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Remove weeds manually', 'Wear gloves.', 'Weed-free crop'),
    (6, 'Fertilizer Application', 'Apply 20 kg urea + 40 kg gypsum/acre.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, gypsum', 'cloudy', '1. Mix evenly\n2. Irrigate lightly', 'Avoid inhalation.', 'Enhanced pod development'),
    (8, 'Pest Control', 'Spray neem oil for leaf miner control.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray at dusk', 'Avoid direct contact.', 'Reduced pest infestation'),
    (10, 'Pegging Observation', 'Ensure soil moisture for pegging.', 'monitoring', 'High', '1 hour', 'None', 'Water', 'humid', '1. Irrigate regularly\n2. Maintain soft soil', 'Do not overwater.', 'Proper pod formation'),
    (12, 'Harvesting', 'Harvest when leaves yellow and pods mature.', 'harvesting', 'Critical', '4 hours', 'Hoe, basket', 'None', 'dry', '1. Uproot carefully\n2. Dry pods under shade', 'Avoid crushing pods.', 'Clean, mature pods')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 10 AND w.week_number = t.week_number);

-- ===== 2️⃣ GUAVA (crop_id = 19) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 19, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Pit Preparation', 'Prepare pits 1x1x1m and fill with compost + soil mix.', 'maintenance', 'High', '4 hours', 'Spade, hoe', 'Compost, topsoil', 'dry', '1. Mix compost\n2. Leave pits open 2 weeks', 'Avoid during rains.', 'Well-aerated soil pits'),
    (3, 'Planting', 'Plant guava grafts with spacing 5x5 m.', 'maintenance', 'Critical', '3 hours', 'Spade, rope', 'Grafted plants', 'humid', '1. Place grafts upright\n2. Water gently', 'Handle plants carefully.', 'Healthy plant establishment'),
    (6, 'Irrigation', 'Provide irrigation every 5–7 days.', 'irrigation', 'High', '1 hour', 'Pump, hose', 'Water', 'hot', '1. Maintain moist basin\n2. Avoid stagnation', 'Do not over-irrigate.', 'Active plant growth'),
    (8, 'Weeding', 'Weed around basin and apply mulch.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'Dry leaves', 'sunny', '1. Weed manually\n2. Add mulch layer', 'Beware of snakes.', 'Clean basins, conserved moisture'),
    (10, 'Pruning', 'Remove suckers and overcrowded branches.', 'pruning', 'High', '2 hours', 'Pruning shears', 'None', 'dry', '1. Cut diseased twigs\n2. Apply Bordeaux paste', 'Use gloves/goggles.', 'Better canopy and airflow'),
    (12, 'Fertilizer Application', 'Apply NPK 500:250:250 g/plant.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, SSP, MOP', 'cloudy', '1. Mix around drip line\n2. Irrigate lightly', 'Avoid overuse.', 'Enhanced fruit set'),
    (18, 'Fruit Thinning', 'Remove small or excess fruits for better size.', 'maintenance', 'Medium', '2 hours', 'Hands, gloves', 'None', 'dry', '1. Thin fruits evenly', 'Avoid damaging branches.', 'Uniform, large fruits'),
    (24, 'Harvesting', 'Harvest mature guava fruits by hand picking.', 'harvesting', 'Critical', '3 hours', 'Basket, gloves', 'None', 'dry', '1. Pick carefully\n2. Handle gently', 'Avoid fruit bruises.', 'Fresh, marketable fruits')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 19 AND w.week_number = t.week_number);

-- ===== 3️⃣ JUTE (crop_id = 12) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 12, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation', 'Plough field 3–4 times and apply compost.', 'maintenance', 'High', '3 hours', 'Tractor, harrow', 'FYM', 'humid', '1. Level field\n2. Apply compost', 'Avoid flooding.', 'Ready seedbed'),
    (2, 'Seed Sowing', 'Broadcast seeds after mixing with sand.', 'maintenance', 'Critical', '2 hours', 'Seeder, bucket', 'Seeds, sand', 'cloudy', '1. Mix 1kg seed with 10kg sand\n2. Sow evenly', 'Avoid thick sowing.', 'Uniform germination'),
    (3, 'First Weeding', 'Remove early weeds manually.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed at 15 DAS', 'Use gloves.', 'Clean crop stand'),
    (4, 'Fertilizer Application', 'Apply 20 kg N + 10 kg P/acre.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, SSP', 'dry', '1. Mix evenly\n2. Irrigate', 'Avoid over-fertilizing.', 'Vigorous vegetative growth'),
    (5, 'Irrigation', 'Irrigate weekly during dry spell.', 'irrigation', 'High', '1 hour', 'Pump', 'Water', 'dry', '1. Maintain soil moisture', 'Avoid overwatering.', 'Healthy stem elongation'),
    (8, 'Pest Control', 'Spray neem oil against semilooper.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray evening time', 'Wear mask.', 'Reduced pest damage'),
    (12, 'Harvesting & Retting', 'Harvest 120 DAS and submerge for retting.', 'harvesting', 'Critical', '5 hours', 'Sickle, rope', 'Water tank', 'humid', '1. Cut close to ground\n2. Ret 15 days', 'Avoid contamination.', 'Good quality jute fiber')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 12 AND w.week_number = t.week_number);

-- ===== 4️⃣ LENTIL (crop_id = 15) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 15, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Seed Treatment', 'Treat seeds with Rhizobium and Trichoderma.', 'maintenance', 'High', '1 hour', 'Bucket, gloves', 'Rhizobium, Trichoderma', 'dry', '1. Mix cultures evenly\n2. Shade dry', 'Avoid direct sunlight.', 'Healthy seedlings'),
    (2, 'Sowing', 'Drill seeds at 25x10 cm spacing.', 'maintenance', 'Critical', '2 hours', 'Seeder', 'Seeds', 'cool', '1. Sow shallow\n2. Firm soil lightly', 'Avoid wet soil.', 'Uniform germination'),
    (4, 'Weeding', 'Manual weeding at 20 DAS.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed early morning', 'Use gloves.', 'Reduced weed competition'),
    (6, 'Fertilizer Application', 'Apply DAP 25kg/acre at branching.', 'fertilizer', 'High', '1 hour', 'Spreader', 'DAP', 'cloudy', '1. Apply evenly\n2. Irrigate', 'Avoid inhalation.', 'Improved growth'),
    (8, 'Pest Control', 'Spray neem oil against pod borer.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray at dusk', 'Avoid contact with eyes.', 'Reduced pest infestation'),
    (10, 'Irrigation at Pod Formation', 'Light irrigation during flowering.', 'irrigation', 'Critical', '1 hour', 'Pump', 'Water', 'dry', '1. Irrigate evenly', 'Avoid waterlogging.', 'Better yield'),
    (12, 'Harvesting', 'Harvest when 80% pods mature.', 'harvesting', 'Critical', '3 hours', 'Sickle, basket', 'None', 'dry', '1. Cut and dry under shade', 'Avoid breaking pods.', 'Clean, dry lentil grains')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 15 AND w.week_number = t.week_number);

-- ===============================================
-- ✅ END OF INSERTS FOR GROUNDNUT, GUAVA, JUTE, LENTIL
-- ===============================================
-- ===============================================
-- 🌱 DETAILED WEEKLY TASKS (COFFEE, CORIANDER, COTTON, CUMIN, GINGER)
-- ===============================================

-- ===== 1️⃣ COFFEE (crop_id = 27) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 27, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Nursery Preparation', 'Prepare seedbeds with loamy soil and compost for coffee seedlings.', 'maintenance', 'High', '4 hours', 'Hoe, rake', 'Compost, soil mix', 'humid', '1. Prepare raised beds\n2. Sow seeds evenly\n3. Water regularly', 'Avoid overwatering.', 'Healthy seed germination'),
    (4, 'Transplanting Seedlings', 'Transplant seedlings to polybags after 8–10 weeks.', 'maintenance', 'High', '3 hours', 'Spade, watering can', 'Seedlings, soil', 'cloudy', '1. Carefully lift seedlings\n2. Place in polybags\n3. Shade for 7 days', 'Wear gloves.', 'Healthy transplant establishment'),
    (10, 'Field Preparation', 'Prepare pits 45x45x45 cm with compost.', 'maintenance', 'High', '4 hours', 'Spade, hoe', 'Compost, lime', 'dry', '1. Dig pits 3x3 ft spacing\n2. Mix compost & lime', 'Avoid direct sunlight.', 'Ready planting pits'),
    (12, 'Planting', 'Plant 6–12 month old seedlings in prepared pits.', 'maintenance', 'Critical', '3 hours', 'Spade, rope', 'Seedlings, water', 'humid', '1. Place seedling upright\n2. Water immediately', 'Do not plant during heavy rain.', 'Healthy plantation'),
    (20, 'Irrigation & Mulching', 'Irrigate every 10 days and mulch base with leaves.', 'irrigation', 'High', '2 hours', 'Pump, hose', 'Water, dry leaves', 'hot', '1. Irrigate evenly\n2. Mulch 5 cm thick', 'Avoid waterlogging.', 'Moist soil, better growth'),
    (28, 'Weeding', 'Remove weeds from coffee basins manually.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed gently around roots', 'Beware of snakes.', 'Clean weed-free basins'),
    (36, 'Pruning', 'Remove old and dead branches to promote new growth.', 'pruning', 'High', '3 hours', 'Pruning shears', 'None', 'dry', '1. Cut branches at base\n2. Apply fungicide on cuts', 'Wear gloves and goggles.', 'Healthy plant canopy'),
    (48, 'Pest Management', 'Apply neem oil for coffee borer control.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray during evening hours', 'Use protective gear.', 'Reduced pest infestation'),
    (52, 'Harvesting', 'Handpick red ripe coffee cherries.', 'harvesting', 'Critical', '5 hours', 'Basket, gloves', 'None', 'dry', '1. Harvest selectively', 'Avoid picking green fruits.', 'Uniform high-quality cherries')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 27 AND w.week_number = t.week_number);

-- ===== 2️⃣ CORIANDER (crop_id = 24) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 24, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation', 'Prepare fine tilth soil and apply FYM 5 tons/acre.', 'maintenance', 'High', '3 hours', 'Tractor, harrow', 'FYM', 'dry', '1. Level soil\n2. Mix FYM evenly', 'Avoid uneven land.', 'Prepared seedbed'),
    (2, 'Sowing', 'Broadcast seeds evenly and cover lightly with soil.', 'maintenance', 'Critical', '2 hours', 'Seeder, rake', 'Coriander seeds', 'cool', '1. Soak seeds overnight\n2. Broadcast evenly', 'Avoid thick sowing.', 'Uniform germination'),
    (3, 'Irrigation', 'Light irrigation immediately after sowing.', 'irrigation', 'High', '1 hour', 'Pump, hose', 'Water', 'dry', '1. Irrigate lightly', 'Avoid flooding.', 'Moist soil surface'),
    (5, 'Thinning & Weeding', 'Thin seedlings to maintain spacing.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed at 15 DAS', 'Avoid damaging roots.', 'Healthy spacing'),
    (7, 'Fertilizer Application', 'Apply 20 kg urea/acre.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea', 'cloudy', '1. Apply around base\n2. Irrigate lightly', 'Avoid inhalation.', 'Improved vegetative growth'),
    (8, 'Pest Control', 'Spray neem oil for aphid management.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray during calm weather', 'Wear gloves.', 'Reduced pest attack'),
    (10, 'Harvesting', 'Harvest when seeds turn brown.', 'harvesting', 'Critical', '3 hours', 'Sickle, basket', 'None', 'dry', '1. Cut plants early morning\n2. Dry in shade', 'Avoid over-drying.', 'Aromatic coriander seeds')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 24 AND w.week_number = t.week_number);

-- ===== 3️⃣ COTTON (crop_id = 8) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 8, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Seed Treatment & Sowing', 'Treat seeds with Imidacloprid + fungicide, sow in rows 90x45 cm.', 'maintenance', 'Critical', '3 hours', 'Seeder, sprayer', 'Treated seeds', 'dry', '1. Treat seeds 24h before sowing\n2. Sow at correct spacing', 'Wear gloves.', 'Healthy crop stand'),
    (2, 'First Irrigation', 'Irrigate at 7 DAS to ensure uniform germination.', 'irrigation', 'High', '2 hours', 'Pump, hose', 'Water', 'hot', '1. Maintain light moisture', 'Avoid overwatering.', 'Uniform emergence'),
    (4, 'Weeding', 'Manual weeding or pre-emergence herbicide.', 'maintenance', 'High', '3 hours', 'Hoe, sprayer', 'Pendimethalin', 'sunny', '1. Weed or spray herbicide', 'Wear protective gear.', 'Weed-free field'),
    (6, 'Top Dressing', 'Apply 25 kg DAP + 20 kg Urea/acre.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, DAP', 'cloudy', '1. Mix evenly\n2. Irrigate after application', 'Avoid direct skin contact.', 'Enhanced vegetative growth'),
    (8, 'Pest Management', 'Install pink bollworm traps.', 'pesticide', 'Critical', '2 hours', 'Traps', 'Pheromone lures', 'dry', '1. Install traps @15/ha', 'Avoid windy conditions.', 'Controlled pest population'),
    (12, 'Growth Regulator Spray', 'Apply Mepiquat Chloride to control vegetative growth.', 'pesticide', 'Medium', '1 hour', 'Sprayer', 'Mepiquat chloride', 'humid', '1. Spray uniformly', 'Avoid skin contact.', 'Balanced growth'),
    (16, 'Irrigation at Flowering', 'Maintain moisture for boll formation.', 'irrigation', 'High', '2 hours', 'Pump', 'Water', 'hot', '1. Irrigate weekly', 'Avoid flooding.', 'Better boll retention'),
    (20, 'Harvesting', 'Pick open bolls every 5–7 days.', 'harvesting', 'Critical', '3 hours', 'Basket, gloves', 'None', 'dry', '1. Harvest early morning', 'Wear gloves.', 'Clean white cotton')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 8 AND w.week_number = t.week_number);

-- ===== 4️⃣ CUMIN (crop_id = 25) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 25, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Soil Preparation', 'Prepare sandy soil and mix FYM 3 tons/acre.', 'maintenance', 'High', '3 hours', 'Plough, harrow', 'FYM', 'dry', '1. Mix FYM thoroughly', 'Avoid waterlogged soils.', 'Fertile bed ready'),
    (2, 'Sowing', 'Broadcast treated seeds uniformly.', 'maintenance', 'High', '2 hours', 'Seeder', 'Seeds', 'cool', '1. Sow in moist soil', 'Avoid excess depth.', 'Uniform germination'),
    (3, 'Irrigation', 'Light irrigation after sowing.', 'irrigation', 'High', '1 hour', 'Pump', 'Water', 'dry', '1. Irrigate gently', 'Avoid soil crusting.', 'Seedling emergence'),
    (5, 'Weed Control', 'Hand weeding at 20 DAS.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Remove early weeds', 'Beware of sharp tools.', 'Weed-free soil'),
    (8, 'Fertilizer Application', 'Apply 15 kg urea/acre.', 'fertilizer', 'High', '1 hour', 'Spreader', 'Urea', 'cloudy', '1. Apply evenly\n2. Irrigate lightly', 'Avoid inhalation.', 'Boosted growth'),
    (12, 'Pest & Disease Control', 'Spray Mancozeb for blight prevention.', 'pesticide', 'Critical', '1 hour', 'Sprayer', 'Mancozeb', 'humid', '1. Spray on cloudy days', 'Use gloves and mask.', 'Reduced disease spread'),
    (16, 'Harvesting', 'Harvest when plants turn brown.', 'harvesting', 'Critical', '3 hours', 'Sickle', 'None', 'dry', '1. Cut plants\n2. Dry in shade', 'Avoid breakage.', 'Clean aromatic seeds')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 25 AND w.week_number = t.week_number);

-- ===== 5️⃣ GINGER (crop_id = 22) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 22, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation', 'Prepare raised beds and apply FYM 20 tons/acre.', 'maintenance', 'High', '3 hours', 'Spade, hoe', 'FYM, compost', 'humid', '1. Prepare raised beds\n2. Mix compost', 'Avoid muddy areas.', 'Prepared field'),
    (2, 'Rhizome Treatment', 'Treat rhizomes with fungicide before planting.', 'maintenance', 'Critical', '1 hour', 'Bucket, gloves', 'Mancozeb', 'dry', '1. Dip for 30 min\n2. Dry in shade', 'Use gloves.', 'Disease-free planting material'),
    (3, 'Planting', 'Plant 25–30 g rhizomes at 30 cm spacing.', 'maintenance', 'High', '2 hours', 'Spade, rope', 'Rhizomes', 'humid', '1. Plant 5–6 cm deep\n2. Cover with mulch', 'Avoid overdepth.', 'Uniform sprouting'),
    (5, 'Mulching', 'Apply leaf mulch after planting.', 'maintenance', 'High', '2 hours', 'Hands, basket', 'Dry leaves', 'dry', '1. Spread 5–10 cm layer', 'Avoid wet mulch.', 'Better moisture retention'),
    (7, 'Fertilizer Application', 'Apply 20 kg urea + 10 kg potash/acre.', 'fertilizer', 'High', '1 hour', 'Spreader', 'Urea, potash', 'cloudy', '1. Apply evenly\n2. Irrigate after', 'Avoid skin contact.', 'Enhanced rhizome growth'),
    (10, 'Weeding & Earthing Up', 'Weed and earth up soil around plants.', 'maintenance', 'Medium', '2 hours', 'Hoe', 'None', 'sunny', '1. Pull weeds\n2. Raise soil around base', 'Beware of roots.', 'Improved rhizome size'),
    (14, 'Pest Management', 'Spray neem oil to control shoot borer.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray on calm evenings', 'Avoid eye contact.', 'Reduced pest pressure'),
    (20, 'Harvesting', 'Harvest 8–9 months after planting.', 'harvesting', 'Critical', '4 hours', 'Spade, basket', 'None', 'dry', '1. Lift rhizomes carefully\n2. Clean and dry in shade', 'Use gloves.', 'Healthy, market-ready rhizomes')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 22 AND w.week_number = t.week_number);

-- ===============================================
-- ✅ END OF INSERTS FOR COFFEE, CORIANDER, COTTON, CUMIN, GINGER
-- ===============================================
-- ===============================================
-- 🌾 DETAILED WEEKLY TASKS FOR SELECTED CROPS
-- ===============================================

-- ===== 1️⃣ BANANA (crop_id = 16) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 16, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Pit Preparation & FYM Application', 'Prepare 3x3 ft pits and mix 10-15 kg FYM with topsoil.', 'maintenance', 'High', '3 hours', 'Spade, hoe', 'FYM, lime, soil', 'dry', '1. Dig pits 3x3x3 ft\n2. Mix FYM and soil\n3. Leave open for sunlight 10 days', 'Use gloves and avoid deep pits in rainy days.', 'Fertile, aerated pits ready for planting'),
    (2, 'Sucker Planting', 'Plant disease-free suckers in moist pits.', 'maintenance', 'Critical', '4 hours', 'Spade, watering can', 'Healthy suckers, water', 'humid', '1. Place sucker upright\n2. Fill with soil\n3. Water immediately', 'Avoid planting during heavy rain.', 'Healthy, evenly spaced banana stand'),
    (4, 'Irrigation Setup', 'Start regular irrigation every 5–7 days.', 'irrigation', 'High', '2 hours', 'Hose, pump', 'Water', 'hot', '1. Irrigate around base\n2. Avoid waterlogging', 'Do not flood field.', 'Moist soil, active growth'),
    (6, 'Desuckering', 'Remove unwanted side shoots to promote main plant.', 'pruning', 'Medium', '1 hour', 'Knife, gloves', 'None', 'dry', '1. Cut suckers at ground level\n2. Apply ash to cut', 'Handle blade carefully.', 'Stronger main plant growth'),
    (8, 'Fertilizer Application', 'Apply 100g urea + 200g potash per plant.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, potash', 'cloudy', '1. Mix around plant base\n2. Irrigate after application', 'Avoid over-application.', 'Improved vegetative growth'),
    (10, 'Propping & Mulching', 'Use bamboo props to prevent bending and apply mulch.', 'maintenance', 'High', '2 hours', 'Bamboo poles, straw', 'Dry leaves, straw', 'windy', '1. Tie props gently\n2. Cover soil with mulch', 'Ensure props are stable.', 'Stabilized plants, conserved moisture'),
    (12, 'Pest Monitoring', 'Check for banana weevil and leaf spot.', 'monitoring', 'High', '1 hour', 'Magnifier, gloves', 'Traps, neem oil', 'humid', '1. Inspect pseudostem\n2. Apply neem oil if infested', 'Avoid contact with chemicals.', 'Reduced pest damage'),
    (16, 'Bunch Covering', 'Cover bunch with polyethylene bags for quality fruits.', 'maintenance', 'Medium', '2 hours', 'Bags, ladder', 'Poly bags', 'dry', '1. Cover bunch loosely\n2. Tie upper end', 'Avoid slipping while climbing.', 'Clean, uniform fruit color'),
    (20, 'Harvesting', 'Harvest mature bunches carefully with knives.', 'harvesting', 'Critical', '3 hours', 'Knife, rope', 'Basket', 'dry', '1. Cut bunch halfway through stalk\n2. Lower gently', 'Use helmet/gloves.', 'Fresh bananas with minimal damage')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 16 AND w.week_number = t.week_number);

-- ===== 2️⃣ BLACK GRAM (crop_id = 13) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 13, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Land Preparation & Seed Treatment', 'Plough field twice and treat seeds with Rhizobium culture.', 'maintenance', 'Critical', '2 hours', 'Tractor, sprayer', 'Rhizobium culture', 'dry', '1. Treat seeds before sowing\n2. Maintain moisture', 'Wear gloves.', 'Healthy germination'),
    (2, 'Sowing', 'Sow seeds in rows 30cm apart.', 'maintenance', 'High', '3 hours', 'Seeder, rope', 'Seeds', 'cloudy', '1. Sow shallow\n2. Irrigate lightly', 'Avoid waterlogging.', 'Uniform seedling emergence'),
    (3, 'First Irrigation', 'Irrigate after 7 days of sowing.', 'irrigation', 'High', '1 hour', 'Pump, hose', 'Water', 'hot', '1. Maintain 2–3 cm moisture', 'Avoid overwatering.', 'Healthy crop establishment'),
    (5, 'Weeding', 'Manual weeding to remove early weeds.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'None', 'sunny', '1. Weed at 20 DAS', 'Use protective gloves.', 'Reduced weed competition'),
    (7, 'Fertilizer Application', 'Apply DAP 20kg/acre for vegetative growth.', 'fertilizer', 'High', '2 hours', 'Spreader', 'DAP', 'dry', '1. Mix fertilizer in soil', 'Avoid inhalation.', 'Improved pod development'),
    (9, 'Pest Monitoring', 'Monitor for pod borer and apply neem extract.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem extract', 'humid', '1. Spray during evening', 'Wear mask.', 'Reduced pest incidence'),
    (11, 'Irrigation at Flowering', 'Maintain moisture during flowering.', 'irrigation', 'Critical', '1 hour', 'Pump', 'Water', 'dry', '1. Irrigate gently', 'Do not flood field.', 'Better flower retention'),
    (13, 'Harvesting', 'Harvest when 80% pods mature.', 'harvesting', 'High', '3 hours', 'Sickle, basket', 'None', 'dry', '1. Cut and dry pods in shade', 'Use gloves.', 'High-quality grains')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 13 AND w.week_number = t.week_number);

-- ===== 3️⃣ CHICKPEA (crop_id = 14) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 14, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Seed Treatment', 'Treat seeds with Trichoderma and Rhizobium for disease prevention.', 'maintenance', 'High', '2 hours', 'Sprayer', 'Trichoderma, Rhizobium', 'dry', '1. Coat seeds\n2. Dry in shade', 'Wear mask.', 'Healthy seedlings'),
    (2, 'Sowing', 'Sow seeds at 30x10 cm spacing.', 'maintenance', 'High', '2 hours', 'Seeder', 'Seeds', 'dry', '1. Sow shallow\n2. Firm soil lightly', 'Avoid sowing in wet soil.', 'Uniform germination'),
    (4, 'Weed Control', 'Spray pre-emergence herbicide Pendimethalin.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Pendimethalin', 'sunny', '1. Spray within 2 days of sowing', 'Wear mask/gloves.', 'Reduced weed pressure'),
    (6, 'Fertilizer Application', 'Apply DAP 25kg/acre before flowering.', 'fertilizer', 'High', '2 hours', 'Spreader', 'DAP', 'cloudy', '1. Apply evenly\n2. Irrigate lightly', 'Avoid skin contact.', 'Improved flowering'),
    (8, 'Irrigation', 'Irrigate at flowering and pod formation.', 'irrigation', 'Critical', '2 hours', 'Pump', 'Water', 'dry', '1. Maintain light moisture', 'Do not flood.', 'Better yield'),
    (10, 'Pest Management', 'Control pod borer using neem oil spray.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray at dusk', 'Avoid eye contact.', 'Reduced pest attack'),
    (12, 'Harvesting', 'Harvest when leaves turn yellow.', 'harvesting', 'Critical', '3 hours', 'Sickle', 'None', 'dry', '1. Cut and dry under shade', 'Avoid over-drying.', 'High-quality grains')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 14 AND w.week_number = t.week_number);

-- ===== 4️⃣ CHILI (crop_id = 23) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 23, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Nursery Preparation', 'Prepare raised nursery beds and sow chili seeds.', 'maintenance', 'High', '3 hours', 'Hoe, watering can', 'Seeds, compost', 'dry', '1. Sow thinly\n2. Water daily', 'Avoid excessive watering.', 'Healthy seedlings'),
    (3, 'Transplanting', 'Transplant 30-day seedlings to main field.', 'maintenance', 'Critical', '3 hours', 'Spade, watering can', 'Seedlings', 'cool', '1. Transplant in evening', 'Avoid sun stress.', 'Healthy establishment'),
    (4, 'Basal Fertilizer Application', 'Apply FYM + 25 kg DAP/acre.', 'fertilizer', 'High', '2 hours', 'Spreader', 'FYM, DAP', 'cloudy', '1. Mix evenly\n2. Irrigate immediately', 'Avoid contact with fertilizer dust.', 'Strong vegetative growth'),
    (6, 'Pest Control', 'Apply neem oil for aphid management.', 'pesticide', 'High', '1 hour', 'Sprayer', 'Neem oil', 'humid', '1. Spray in evening', 'Wear gloves.', 'Reduced aphid population'),
    (8, 'Flowering Support', 'Provide P&K fertilizer for flower retention.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Potash, Phosphorus', 'sunny', '1. Apply near root zone', 'Avoid overdose.', 'Improved flowering'),
    (10, 'Fruit Borer Management', 'Install pheromone traps @10/acre.', 'monitoring', 'High', '1 hour', 'Traps', 'Pheromone lures', 'dry', '1. Place traps evenly', 'Check weekly.', 'Early pest detection'),
    (12, 'Harvesting', 'Pluck mature red fruits every 5–7 days.', 'harvesting', 'Critical', '3 hours', 'Basket, gloves', 'None', 'dry', '1. Harvest early morning', 'Avoid overripe fruits.', 'Fresh red chilies')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 23 AND w.week_number = t.week_number);

-- ===== 5️⃣ COCONUT (crop_id = 29) =====
INSERT INTO weekly_tasks 
(crop_id, week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
SELECT 29, t.week_number, t.task_title, t.task_description, t.task_type, t.priority, t.estimated_duration, t.equipment_needed, t.materials_needed, t.weather_conditions, t.step_by_step_instructions, t.safety_precautions, t.expected_outcome
FROM (
    VALUES
    (1, 'Pit Preparation', 'Prepare 1x1x1m pits with 10kg compost.', 'maintenance', 'High', '3 hours', 'Spade, hoe', 'Compost, soil', 'dry', '1. Mix compost evenly\n2. Expose to sun 10 days', 'Avoid pits filling with water.', 'Prepared pits'),
    (2, 'Planting Seedlings', 'Plant healthy seedlings at pit center.', 'maintenance', 'Critical', '2 hours', 'Spade, rope', 'Seedlings', 'humid', '1. Place seedling upright\n2. Water immediately', 'Avoid planting during heavy rain.', 'Healthy plant establishment'),
    (6, 'Irrigation Setup', 'Install drip or basin irrigation.', 'irrigation', 'High', '2 hours', 'Pipe, pump', 'Water', 'hot', '1. Maintain 20–25 liters per palm weekly', 'Avoid waterlogging.', 'Regular soil moisture'),
    (12, 'Fertilizer Application', 'Apply 500g urea + 1kg superphosphate per palm.', 'fertilizer', 'High', '2 hours', 'Spreader', 'Urea, superphosphate', 'cloudy', '1. Mix with soil around palm', 'Do not apply on wet soil.', 'Better palm growth'),
    (24, 'Weed Control', 'Clean basin and mulch with dry leaves.', 'maintenance', 'Medium', '2 hours', 'Hoe, gloves', 'Dry leaves', 'dry', '1. Weed manually\n2. Apply mulch', 'Beware of snakes.', 'Clean basins, conserved moisture'),
    (36, 'Crown Cleaning', 'Remove dead fronds and dry leaves.', 'pruning', 'High', '3 hours', 'Knife, rope', 'None', 'dry', '1. Cut dry leaves carefully', 'Use safety belt.', 'Healthy crown'),
    (48, 'Harvesting', 'Harvest mature nuts every 45 days.', 'harvesting', 'Critical', '3 hours', 'Climbing gear', 'Basket', 'dry', '1. Cut bunch at base', 'Wear helmet and gloves.', 'Fresh coconuts with minimal loss')
) AS t(week_number, task_title, task_description, task_type, priority, estimated_duration, equipment_needed, materials_needed, weather_conditions, step_by_step_instructions, safety_precautions, expected_outcome)
WHERE NOT EXISTS (SELECT 1 FROM weekly_tasks w WHERE w.crop_id = 29 AND w.week_number = t.week_number);

-- ===============================================
-- ✅ END OF DETAILED WEEKLY TASK INSERTS
-- ===============================================
