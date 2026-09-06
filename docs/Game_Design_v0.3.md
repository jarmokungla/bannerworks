# BANNERWORKS
## A kingdom built from production lines, professions, and military schools

Game design specification • Version 0.3 • 6 September 2026

A personal, single-player mobile game for Jarmo Kungla. Bannerworks is a working title. The proposed systems, balancing values, campaign length, and performance targets are a first design to validate through playtesting.

Revision 0.3: grid construction and player-drawn roads, with separate inventories in every building, warehouse barns, and a player backpack that pays construction costs. The visual concept follows the layout clarity of the supplied Builderment reference.

### The game in one paragraph

Build a living fantasy settlement whose most important production chains create skilled people. Farms feed new arrivals; guilds turn them into miners, smiths, and instructors; workshops equip them; schools combine their military disciplines into specialized troops. Send those troops on expeditions that open new land and new knowledge. Returning veterans improve your schools, while a growing network of outposts creates fresh demand for soldiers, equipment, and supplies.

The defining question is: “How do I build a settlement that can reliably prepare the army I want?”

## 1. Identity and design principles

The main experience is planning, building, watching flows, finding bottlenecks, and improving throughput. Military preparation gives those production chains a purpose. A lively medieval settlement supplies the visual character: readable timber buildings, colorful banners, mines, fields, training yards, and small animated citizens.

Use a square construction grid viewed from overhead, with screen-aligned axes and compact, low-profile 2D sprites. Building footprints and connection points stay visible. The revised mockups test a portrait planning view with a small HUD; validate orientation on the intended phone before locking the interface. The default game is offline, pauseable, and playable in sessions of roughly 5–20 minutes, with longer uninterrupted building sessions equally welcome.

- Make movement visible. Citizens visit schools; carts deliver goods; equipped squads assemble at the gate.
- Make expertise tangible. A smith, teacher, and soldier are different uses of the same limited population.
- Make placement the central planning challenge. Building count, input/output positions, road length, junctions, buffers, and training routes determine throughput.
- Make combinations useful without making one universal unit optimal.
- Give missions several viable solutions after the initial tutorials.
- Make every stoppage explainable and every normal setback recoverable.
- Reward better systems with less repetitive tapping.

### Three distinctive mechanics

**People follow production routes.** A standing order can recruit residents, train professions or combat skills, reserve equipment, and assemble the result. The player designs the process once and watches it operate.

**Veterans become productive infrastructure.** An experienced soldier can remain in the army, teach at a school, or help the Scriptorium write doctrine manuals. Taking a veteran off the front improves the next generation.

**Preparing an army changes the town.** A cavalry contract creates demand for oats, leather, mounts, and road capacity. A siege contract redirects iron and carpenters. Army composition visibly reshapes the economy.

### Product boundaries

Use original characters, artwork, names, factions, and lore. Take broad inspiration from classic fantasy strategy art and industrial automation. There is no need for multiplayer, a live service, advertisements, premium currency, stamina, daily login rewards, or purchases that accelerate timers. All listed timers refer to simulation time while playing. The normal game freezes when closed.

## 2. The world and the repeating loop

The player rebuilds a frontier town after the old kingdom's guild network has fragmented. Manuals and useful knowledge remain in distant settlements, ruined schools, and occupied passes. The settlement becomes a place where those traditions are brought together.

The campaign follows a repeating sequence:

1. Inspect a new mission, territory, or standing supply contract.
2. Identify the capabilities and resources needed.
3. Expand the settlement and assign workers.
4. Connect material deliveries and configure training orders.
5. Equip a force and prepare its supplies.
6. Choose a formation and expedition doctrine.
7. Resolve the expedition and inspect the report.
8. Use the new territory, charter, or recipe to reorganize production.

There are three overlapping timescales. In the next minute, fix a missing bow delivery. In the next 10–20 minutes, automate a new troop type. Over several sessions, build a specialist district and unlock another campaign branch.

### Example of an interesting decision

You need eight mounted archers. Your archery school is fast enough, but the riding school shares its instructor with a cavalry order. Building another riding school alone will not solve the problem. You can train another instructor, pause the other order, or dispatch a smaller force with scouts who reduce the mission's mobility demand. Each option changes something concrete in your town.

## 3. Population, occupations, and knowledge

### Arrival and housing

The Town Hall attracts one new adult resident by consuming 6 rations and completing a 30-second recruitment cycle. It also requires a free housing place and a safe food reserve. This preserves the requested food-to-peasant mechanic while presenting people as new arrivals.

Recruitment has a target rather than an endless queue: “Maintain 6 unassigned residents” or “Grow to 40 population.” Housing counts residents who are working, training, recovering, or deployed. A person cannot occupy two jobs at once. Expedition members keep their home; citizens permanently assigned to an allied settlement leave the local population roster.

Start with eight residents: two foragers, a woodcutter, a guild tutor, a builder, a hauler, and two unassigned adults. The Town Hall houses this founding group. Cottages add 8 places each. Further housing tiers increase density, with construction costs and food capacity as the real constraints.

### Food and recovery rules

At baseline, each resident at home consumes 0.1 ration per simulation minute. Expedition provisions replace home consumption while a resident is away. Horses consume oats while working or deployed; idle housed mounts have a small, separately displayed stable requirement.

If food runs short, recruitment and nonessential training pause first. A sustained shortage reduces nonessential work speed, but basic gathering retains its full rate. Residents do not die of starvation or permanently leave in the normal mode. Free foraging and hand gathering remain available to unassigned adults, so recovery never requires equipment from the stalled production chain.

### Professions

People have separate civilian and military qualifications. A resident can hold two civilian certifications and, as the campaign develops, up to five combat certifications. Only one civilian assignment is active at a time. Civilian certifications do not consume combat slots.

| Profession | Main workplaces | Strategic purpose |
| --- | --- | --- |
| Farmer | Farm, oat field, herb garden | Food and biological inputs |
| Forester | Lumber camp, managed woodland | Timber and charcoal supply |
| Miner | Iron mine, gold mine, crystal mine | Metals, wealth, magic inputs |
| Mason | Quarry, advanced construction | Stone structures and repairs |
| Carpenter | Sawmill, bowyer, engineering workshop | Bows, handles, carts, siege frames |
| Smith | Bloomery, forge, armorer | Metal equipment and spare parts |
| Cook | Mill, bakery, field kitchen | Rations and expedition provisions |
| Tanner / tailor | Tannery, weaver, outfitters | Leather, cloth, saddles, armor |
| Stablekeeper | Paddock, breeding stable | Mounts and animal care |
| Scholar | Scriptorium, academy | Manuals and research |
| Alchemist | Apothecary, essence distillery | Medicine and magical supplies |

Building, basic hauling, and emergency gathering need no certificate. A trained logistics specialist can be a later upgrade rather than an opening requirement.

### How teachers avoid circular dependencies

The founding Guild Lodge has a resident tutor who can teach unlocked basic trades using food, time, and simple practice supplies. Mining never requires a miner to create the first miner; smithing never requires a finished sword.

Each newly unlocked military discipline includes a founding instructor for the first school. This guest occupies the instructor slot until a qualified resident replaces them. Extra copies of that school need resident instructors. If all resident instructors become unavailable, the original school can recall its guest at basic speed. Rebuilding that school preserves its founding-instructor entitlement. Guests cannot work elsewhere, join expeditions, or multiply through copied buildings.

Reserve rules protect the last active food worker, the founding tutor, and explicitly protected specialists from military recruitment. The roster explains these exclusions. The player can change a reserve deliberately in the worker screen.

### Mastery

Use three ranks: trained, experienced, and master. Productive work advances civilian mastery; expeditions and instruction advance the relevant military mastery. Benefits are modest and capped, with a maximum proposed 25% teaching-speed bonus. A veteran's main value is new assignments and doctrine access, not a large stack of damage multipliers.

## 4. Resources and production

### Resource vocabulary

Introduce resources by campaign stage instead of exposing the entire catalog at the start. Keep the top HUD limited to population, pause, and a labeled player-backpack button. Item quantities belong to their building or backpack panels; pinned shortages name the affected building.

| Stage | New material families | New decisions |
| --- | --- | --- |
| Founding | Timber, stone, grain, flour, rations | Space, housing, food surplus |
| First army | Ore, charcoal, iron bars, planks, swords, bows, shields, arrows | Equipment throughput and training |
| Cavalry | Oats, hides, leather, saddles, mounts | Land use and transport |
| Learned orders | Herbs, linen, paper, ink, medicine, manuals | Teaching and support capacity |
| Arcane industry | Crystals, distilled essence, focuses, rune plates | Scarce inputs and alternative recipes |
| Siege and endgame | Steel, mechanisms, siege frames, ammunition, field kits | Heavy logistics and specialist crews |

Gold is a physical trade item produced into a gold mine's output inventory or received at a trading building. It must be carried like other materials. Construction spends gold from the player backpack; courses, research, and expedition services spend it from their own building inventories. Early lessons do not depend on a gold income. There is no shared treasury or globally spendable material pool.

### Representative production chains

**Food:** grain field → mill → bakery → rations → Town Hall, training schools, and expedition stores. The prototype can start with a direct farm-to-food recipe, then unlock milling as a more productive process.

**Swords:** iron mine → bloomery with charcoal → iron bars → sword forge with planks → swords → sword school or armory. The mine needs a miner, the forge a smith, and each workstation requires a delivery connection.

**Archery:** managed woodland → planks; linen → cord; bowyer combines both into bows. Arrow production combines shafts and metal heads, with an early all-wood practice-arrow recipe so archery does not add several mandatory buildings immediately.

**Cavalry:** oat field → paddock; hides → leather; carpenter and outfitter → saddle; stable combines a mount and saddle into an available riding kit. Mounts are persistent assets allocated to riders, not consumed every time the riding lesson is repeated. Paddocks keep protected breeding stock outside the army's available-mount pool; the player cannot accidentally transfer the last breeding animals to a garrison.

**Magic:** crystal mine → essence distillery; timber and essence → focus; linen and ink → scrolls. Magical schools consume practice reagents; expeditions consume replenishment supplies. Restoration uses herbs and medicine as its introductory path, keeping it distinct from Arcana.

**Siege:** iron or steel + planks → mechanisms and frame; engineering workshop assembles a ballista or field cannon; qualified crew and ammunition make the platform deployable. Cannons are a late fantasy technology. Ballistae introduce the system first.

**Knowledge:** paper + ink + scholar time + service reports → doctrine manuals. First-clear charters unlock the next required system automatically. Manuals improve throughput, capacity, and optional doctrines; a player cannot spend away the only key to the campaign.

### Proposed baseline rates

These values apply to one fully staffed workstation at normal speed, without mastery or upgrades. Transport can reduce delivered throughput. A station with several available recipes runs one recipe at a time unless it has an explicitly purchased extra workstation.

| Station | Recipe per cycle | Cycle | Maximum output / minute |
| --- | --- | --- | --- |
| Grain farm | 6 grain | 30 sec | 12 grain |
| Mill | 6 grain → 6 flour | 15 sec | 24 flour |
| Bakery | 6 flour + 1 timber → 6 rations | 30 sec | 12 rations |
| Lumber camp | 2 timber | 10 sec | 12 timber |
| Sawmill | 2 timber → 2 planks | 10 sec | 12 planks |
| Iron mine | 4 ore | 20 sec | 12 ore |
| Charcoal kiln | 2 timber → 2 charcoal | 20 sec | 6 charcoal |
| Bloomery | 2 ore + 1 charcoal → 1 bar | 10 sec | 6 bars |
| Sword forge | 2 bars + 1 plank → 1 sword | 20 sec | 3 swords |
| Sword school | 1 recruit + 1 sword + 2 rations | 60 sec | 1 swordsman |
| Town Hall | 6 rations + housing place → 1 arrival | 30 sec | 2 arrivals |
| Gold mine | 2 gold items | 30 sec | 4 gold |

The sword becomes the student's equipment; it is transferred from the school inventory to that citizen. It is not both destroyed by training and required again at the armory. Training rations and practice consumables are spent. Stored equipment can be recovered through reassignment.

### A useful first bottleneck

One mine, kiln, bloomery, and sword forge can theoretically supply three sword schools. With one school, the visible equipment line therefore fills its buffers and pauses. The useful next investment is teaching capacity, followed by recruits, food, and transport. Adding a second forge first does not increase soldiers per minute.

At one new swordsman per minute, the steady-state requirement is 4 ore, 2 charcoal, 2 bars, 1 plank, 1 sword, 6 recruitment rations, and 2 training rations per minute. With 20 people at home, upkeep adds 2 rations, for a total of 10. One full farm–mill–bakery chain produces 12 rations per minute. Growing beyond 40 people removes that spare food margin. The estimate excludes construction, other lessons, expedition supplies, and delivery delays.

### Alternative recipes and continuing demand

Offer tradeoffs: ash bows are cheap but need more frequent field repairs; composite bows use leather and horn for better mounted performance. Herbal medicine is accessible; distilled medicine uses more buildings but supplies more treatments. Crystal focuses use ore logistics; cultivated mana plants use farmland and water access.

Equipment does not wear out merely because the game is open. Expeditions consume ammunition, rations, medicine, and repair parts. Infrastructure expansion consumes construction materials. Optional permanent garrison commissions consume a fully prepared force by transferring it to an allied settlement. These sinks support production without repeatedly erasing the player's favorite army.

## 5. Physical logistics and automation

### Construction grid and building ports

Most workshops use a 2 × 2 tile footprint. Schools and major structures may use 3 × 3, and farms have larger explicit rectangles. Buildings rotate in quarter-turns, moving their connection ports with them. Build mode shows the square grid, footprint, ports, placement cost, and recipe rate. A translucent ghost is green for valid placement or red with the specific obstruction. Buildings leave space for future parallel copies and connecting roads.

Each building has local input and output inventories with visible sockets at its foundation edges. Schools also have student-entry and graduate-exit markers. Selecting a port reveals its accepted goods or qualifications. A worker operates the station; hauling is a separate assignment. Small low-profile sprites keep the ports and neighboring road tiles visible.

### Building inventories and warehouse barns

Every building owns its items. A mine stores extracted ore; a forge stores bars and planks separately from finished swords; a school stores its teaching supplies; a cottage stores household food. The Town Hall consumes its own delivered rations for recruitment. Residents eat from their home inventory, and schools consume their own lesson supplies. Roads and carriers move items between these locations. A full output inventory pauses production before another recipe consumes inputs.

Give production buildings a small, recipe-specific stack capacity. A Warehouse Barn is a dedicated storage building with no production recipe: propose 12 slots, upgradable to 24, with visible per-item stack limits. It has configurable receiving and dispatch ports, item filters, and reserved slots. Separate barns have separate contents, even when connected by roads. A barn near the smithies can hold bars and timber, while one near the schools holds equipment. The earlier generic depot becomes this Warehouse Barn in the prototype.

### Player inventory and construction

The player has a separate backpack, initially 12 slots with a proposed 50-item stack limit for ordinary materials. Equipment uses smaller limits. Tapping any building opens its inventory beside the backpack. Drag a stack between panels; holding it opens a quantity selector. Provide tap-to-transfer and split-stack buttons as alternatives. Transfers immediately subtract from the source and add to the destination. Reject incompatible items, preserve reserved supplies, and move only the quantity that fits, leaving the remainder at its source.

In the first prototype, the planning cursor can access a selected building without walking an avatar. This is a deliberate manual convenience. It never combines inventories or repeatedly transports goods automatically; sustained production still uses roads and carriers. Player-to-building transfers can seed a new production line or return spare materials to a barn.

Buildings, roads, and upgrades are paid from the backpack. A construction card labels each requirement “In backpack / Needed.” For example, a barn costing 20 timber and 10 iron bars requires the player to take those items from their buildings first. Stock elsewhere in town does not enable Place. Show missing materials and a shortcut to locate their storage. Placement consumes the required backpack stacks atomically; canceling a preview costs nothing. Ghost blueprints can wait until stocked, but do not build themselves from remote inventories.

Dismantling returns recoverable materials and stored contents to the backpack. Any overflow remains in a visible pickup crate at the old footprint, preserving items when the bag is full. Moving a stocked building requires unloading it first. Tutorial supplies begin in the backpack; emergency gathering can add basic materials directly to it. Every transfer, construction payment, pickup crate, and backpack slot persists in the save.

### Player-drawn roads and routes

The player selects an output port, drags an orthogonal road path across the grid, and finishes on a compatible input port. The tool previews its length, cost, and disconnected or incompatible endpoints. It may suggest a shortest valid path; the player chooses and confirms its placement. Nearby buildings do not acquire invisible supply links. Roads occupy one tile of width and use straight segments and right-angle turns.

Roads support travel in both directions, including empty-carrier returns. Arrows in the flow overlay show assigned delivery and student directions, with opposing arrows where traffic runs both ways. Each delivery route specifies its source, destination, allowed cargo, and carriers. Each student route specifies a sequence of school ports. Cargo retains its destination through a junction. Unique compatible ports can prefill the obvious cargo filter, keeping setup quick without hiding the route.

Junction signs split deliveries between parallel buildings by round-robin, ratio, priority, or qualification filter. A 50/50 student split alternates citizens; it never duplicates one. Merges combine streams into a shared road. A crossing preview distinguishes a connected junction from a bridge crossing. Advanced filters and road bridges unlock gradually. Full destination buffers stop deliveries and eventually pause upstream production.

Use residents carrying loads, then handcarts and wagons. Show a few identifiable cargo loads and students moving on actual road tiles. Keep traffic constraints explicit and avoid collision physics that can permanently trap a person. Normal view can hide the grid and most direction markers; build and flow modes expose them. Goods use amber crate markers and people use teal person markers, with icons and arrow shapes supporting color-independent reading.

### Throughput and parallel buildings

Selected routes show demand, theoretical capacity, and actual delivered output. The baseline sword line illustrates the planning problem: a mine supplies 12 ore/min; a bloomery produces 6 bars/min with sufficient charcoal; a forge produces 3 swords/min; three sword schools each graduate 1 swordsman/min. Split one forge across three schools. Adding a fourth school reveals a shortage instead of silently increasing production.

Road length affects capacity before advanced traffic is added. A proposed cart carries 4 items at 1 tile/second, with 4 seconds total for loading and unloading. With a clear 12-tile outward and 12-tile return journey, it supplies about 8.6 items/min. At 24 tiles each way, it supplies about 4.6 items/min. A forge needing 6 bars/min works on the shorter route and needs another cart, a transport upgrade, or a shorter layout on the longer one. Junction delays and competing deliveries reduce these ideal rates.

### Important controls

- Draw, erase, reroute, and upgrade roads; rotate buildings with connected-route previews.
- Split deliveries between parallel buildings; filter students by qualifications at a junction.
- Minimum and maximum stock per item at a building or depot.
- Priority order for food, basic tools, construction, schools, and expedition stores.
- Dedicated supply reservations for a selected army order.
- Overflow destination when a local store is full.
- Pause, copy settings, replace supplier, and move building.
- Blueprint copying for a connected group of buildings and its rules.

Supplies are reserved by a single owner. A sword promised to a trainee cannot simultaneously satisfy an expedition's armory requirement. Cancelling an order releases unused goods, people, and equipment. Partly consumed practice supplies remain spent.

### Orders for people

The Army Office is initially a panel in the Muster Field, becoming a building upgrade later. Define an order such as “Maintain 10 mounted archers with bows, mounts, and field kits.” Select a training route, role, priority, and population budget.

The scheduler chooses eligible idle residents, checks protected workers, reserves lessons, and sends students along the player-built roads through the selected schools. It does not create or change roads automatically. A resident who already knows Archery skips that lesson when a valid road reaches the next required school. Orders can prefer existing archers when preparing mounted archers. Busy workers remain assigned until the player releases them.

Default roster targets include ready, training, recovering, and deployed members, so deployment does not automatically create a duplicate army. The panel separately displays readiness: “10 assigned: 7 ready, 2 deployed, 1 recovering.” An optional “keep 10 ready at home” setting explicitly permits expansion while soldiers are away.

### School admission rules

Each school has an input filter, instructor assignment, lesson, student capacity, and next destination. Simple routes are ordered lists. Advanced rules can branch: untrained residents visit the bow range; archers visit the riding yard; already qualified riders go to the armory.

Students reserve a real queue place before walking to the next school. Reject routes that require unavailable disciplines, exceed certification capacity, create a loop without progress, or lead to an unreachable building. Blocked students wait at a designated assembly point and release obsolete reservations when the route changes.

### Diagnostics that make automation enjoyable

A building should report one actionable primary reason for stopping: missing worker, no ore source, road disconnected, output full, waiting for instructor, or equipment reserved elsewhere. Selecting the reason highlights the responsible source or route.

An army order can say: “8 mounted archers requested; 3 ready; 2 learning Riding; 3 waiting for saddles. Outfitter needs leather.” The player should reach the original shortage within two taps. Show demand, theoretical capacity, and actual delivery separately.

## 6. Military disciplines and training

Unlock two combat certification slots initially, three with the Army Charter, four with the Academy Charter, and five with the Citadel Charter. The fifth slot also requires the individual to reach experienced rank. Civilian skills remain separate.

Learning a new discipline preserves the previous ones. A soldier has known certifications and an active mission loadout. A learned skill only contributes when its required equipment and role are active. The Academy can replace a certification at the normal course cost, returning unused gear. This provides a recovery path from an experiment without making every resident identical instantly.

| Discipline | School | Teaching inputs | Main capability |
| --- | --- | --- | --- |
| Sword | Sword Hall | Sword, practice rations | Sustained melee pressure |
| Shield | Shield Yard | Shield, repair timber | Protection and formation holding |
| Archery | Bow Range | Bow, practice arrows | Ranged damage and aerial targets |
| Spear | Spear Yard | Spear, practice rations | Reach and cavalry counters |
| Riding | Riding Yard | Allocated mount, saddle, oats | Mobility and mounted actions |
| Arcana | Arcane College | Focus, essence | Wards, spell attacks, disruption |
| Fire | Ember School | Focus, fire reagents | Area damage and burn effects |
| Restoration | Sanctuary | Medicine, restorative focus | Healing and curse treatment |
| Nature | Grove School | Herbs, nature focus | Roots, woodland travel, resilience |
| Scouting | Scout Lodge | Field kit, maps | Reconnaissance and route access |
| Engineering | Engineers' Hall | Tools, mechanisms | Repairs, bridges, fortifications |
| Artillery | Siege School | Engineering certification, ammunition | Operating heavy weapons |
| Command | Officers' College | Experienced rank, manuals | Formation orders and squad support |

Arcana, Fire, Restoration, and Nature are separate disciplines, not a prerequisite chain. This allows a two-skill Shield + Restoration paladin. Artillery specifically requires Engineering and therefore occupies at least two combat slots. Starting courses take about 30–90 seconds, with advanced courses up to 120 seconds before bonuses; tune these against the time spent designing the supply line.

### Equipment and action rules

A loadout has a main weapon, a compatible secondary weapon or shield, armor, a focus or field tool, and either a mount or an assigned siege platform. Two-handed weapons cannot be used simultaneously with a held shield. A Pavise Archer carries a deployable shield that requires setup and limits movement. A restorative shield bearer uses a small mounted focus rather than simultaneously holding a staff, weapon, and shield.

All abilities share a finite action budget. A mounted mage-archer cannot shoot, cast, charge, and heal at once. Formation doctrine sets priorities: protect allies, heal below a threshold, fire at flyers, or attack the objective. Heavy armor can reduce speed and casting frequency; mounts have terrain restrictions. State these effects before deployment.

### Command capacity

Use command points to compare large basic forces with compact elites. Proposed individual cost is 1, plus 1 for each active discipline beyond two, plus 1 for a mount and 1 for heavy armor. A siege platform adds 2 points once, in addition to its crew's individual costs. Count only active, usable disciplines.

Examples: an ordinary swordsman costs 1; a mounted archer costs 2; a five-discipline, heavily armored mounted officer costs 6. A ballista with two Engineering + Artillery crew costs 4 in total. Start with 20 command points and raise the cap through the campaign, while each mission can impose a smaller deployment limit.

## 7. Named troop combinations

Create a curated roster of 32 named hybrid doctrines around the 13 disciplines. Other legal combinations still work and receive a descriptive label such as “Mounted Fire Adept.” The player does not need to discover a bespoke name for every mathematical combination.

A named doctrine requires its listed active disciplines, compatible equipment, and any stated charter. Only one named doctrine is active at a time. A five-skill unit does not stack every bonus associated with all its two- and three-skill subsets. Ordinary skill actions remain available, subject to the action budget.

### Two-discipline doctrines

| Unit | Disciplines | Distinct role |
| --- | --- | --- |
| Man-at-Arms | Sword + Shield | Affordable protected frontline |
| Skirmisher | Sword + Archery | Switches from ranged to melee |
| Horse Archer | Archery + Riding | Mobile ranged pressure |
| Lancer | Spear + Riding | Strong charge in open terrain |
| Cavalier | Sword + Riding | Mobile melee and pursuit |
| Pavise Archer | Shield + Archery | Deploys cover for stationary shooting |
| Phalanx Guard | Shield + Spear | Holds against charges |
| Paladin | Shield + Restoration | Protected healer; requires Sanctuary charter |
| Wardguard | Shield + Arcana | Protects against magical pressure |
| Spellblade | Sword + Arcana | Mixed physical and magical offense |
| Warden | Archery + Nature | Ranged control in forests |
| Ranger | Archery + Scouting | Reconnaissance and precise shots |
| Raider | Sword + Scouting | Ambushes and supply disruption |
| Siege Gunner | Engineering + Artillery | Operates a shared siege platform |
| Druid | Nature + Restoration | Sustained recovery and terrain control |
| Emberblade | Sword + Fire | Close-range area pressure |

### Three-discipline doctrines

| Unit | Disciplines | Distinct role |
| --- | --- | --- |
| Knight | Sword + Shield + Riding | Armored mobile frontline |
| Crusader | Sword + Shield + Restoration | Fighting healer with limited action time |
| Outrider | Archery + Riding + Scouting | Reconnaissance and mobile escort |
| Cataphract | Spear + Shield + Riding | Expensive protected charge unit |
| Battlemage | Sword + Arcana + Fire | Flexible assault and spell damage |
| Spellshot | Archery + Arcana + Fire | Enchanted volleys; high reagent demand |
| Templar | Shield + Arcana + Restoration | Anti-magic protection and recovery |
| Flame Artillerist | Engineering + Artillery + Fire | Incendiary siege payloads |
| Rune Gunner | Engineering + Artillery + Arcana | Precise magical siege payloads |
| Grove Keeper | Nature + Restoration + Scouting | Woodland support and safe approaches |

### Four- and five-discipline doctrines

| Unit | Disciplines | Distinct role |
| --- | --- | --- |
| Holy Knight | Sword + Shield + Riding + Restoration | Mounted rescuer and durable support |
| Wild Hunt | Archery + Riding + Scouting + Nature | Elite open-forest reconnaissance force |
| Arcane Justiciar | Sword + Shield + Arcana + Restoration | Versatile defense against mixed threats |
| Siege Marshal | Spear + Shield + Engineering + Command | Protects engineers and directs assaults |
| Banner Paladin | Sword + Shield + Riding + Restoration + Command | Five-skill mobile formation leader |
| Star Ranger | Archery + Riding + Scouting + Nature + Arcana | Five-skill expedition specialist |

### Discovery and readability

The codex shows named doctrines as visible goals once their first relevant school is unlocked. Reveal ingredients through the next mission preview or school research, with clear silhouettes and question marks for genuinely unknown disciplines. Reward discovery with a banner, story detail, and a new tactical behavior rather than a hidden overpowering bonus.

Keep most unit appearances modular: body, armor, held equipment, mount, and a small discipline badge. Reserve distinctive silhouettes for a few flagship classes. A name never hides the actual certifications or equipment requirements.

## 8. Missions, combat, and consequences

### Mission families

**Expeditions** temporarily deploy residents. Survivors return with their skills and allocated gear, plus repairs or recovery needs. These are the main campaign missions.

**Garrison commissions** explicitly transfer citizens and equipment to allied settlements. They create a renewable production objective and a visible population sink. The mission card states that the force will not return and shows exactly which residents are being assigned.

**Supply contracts** request rations, equipment, or repair kits, sometimes with an escort. These let a strong economy contribute before every school is unlocked.

### Requirements should evolve

Opening tutorials can ask for exact rosters: “5 swordsmen and 10 archers.” These are 15 distinct residents, each assigned to one requested slot; five hybrids cannot count as both groups simultaneously.

Later missions describe threats and objectives, with suggested compositions. Requirements include protection, ranged pressure, mobility, healing, reconnaissance, engineering, and siege power. A hybrid can be useful in several sequential phases, but it cannot supply two simultaneous combat actions or occupy two crew positions.

Keep truly hard checks for physical requirements: a working siege platform needs qualified crew; a mountain route may prohibit mounts; a rescue may require an available medical capability. Avoid making every mission a password that accepts only one named class.

### Battle structure

Use three short phases: approach, engagement, and objective. Before launch, choose squads, front/support/reserve positions, and a doctrine such as Hold, Flank, or Protect the Crew. Those choices change actions in a lightweight automatic simulation. A readable 30–90-second battle presentation can show the result, with pause, fast-forward, and skip after the first viewing.

Approach checks scouting, terrain, and supply delivery. Engagement resolves protection, attacks, healing, and counters. The objective tests holding a bridge, breaking a gate, escorting a caravan, or extracting people. A mission can be won without defeating every enemy.

### Counters and terrain

- Spears punish mounted charges; archers punish exposed slow troops.
- Shields reduce frontal projectile pressure; flanking and magic create alternatives.
- Siege defeats fortifications but needs crew protection and ammunition.
- Restoration improves endurance; burst pressure and interrupted actions can overcome it.
- Scouting changes the approach and reveals hazards; it is useful beyond damage.
- Nature opens woodland options; mounted troops lose some advantages in marshes and dense forest.

Apply counters as readable advantages, not automatic wins. A large economic investment may compensate for a weak counter, at a visible cost in supplies and recovery.

### Forecasts and battle reports

Use deterministic resolution for fully revealed missions in the initial release. Show the expected outcome from the current composition and loadout. Reconnaissance reveals hidden conditions before a committed launch; otherwise uncertainty is explicitly marked. Do not label an estimate “guaranteed” when relevant hazards remain unknown.

The report states what mattered: “Archers suppressed the flyers; frontline protection failed during the second wave; two wounded troops need treatment.” Link each shortfall back to the relevant training order or supply request. Cosmetic battle animation must reflect the same authoritative simulation used for the result.

### Failure and persistent armies

Normal mode allows retreat and produces wounded or exhausted citizens instead of permanent deaths. Gear that is damaged returns as a repair task. Defeat consumes provisions already used and sends some troops to the infirmary for roughly 1–3 minutes of simulation time. Emergency rest eventually heals them without rare medicine; medicine accelerates recovery.

Campaign defeat does not delete the town or remove required unlocks. Optional harder campaigns may introduce permanent losses later, but that is not necessary for the core design. Named veterans can be protected from permanent garrison assignment.

## 9. Campaign and unlock sequence

Plan five acts with 18 authored milestones and reusable contracts between them. Target roughly 15–25 hours for a first full campaign, subject to playtesting. The small initial release should cover only the opening systems. Long-term depth comes from alternative army plans, regional logistics, and improving the town.

### Act I — The Founding March

Learn population, food, occupations, equipment, and the first hybrid. Keep the home region safe. Founding courses and emergency supplies are available from the beginning.

| Mission | Task | Unlock / purpose |
| --- | --- | --- |
| 1. Pantry and People | Maintain a positive food balance and attract 4 residents | Depot stock rules and Guild Lodge expansion |
| 2. Roadside Bandits | Prepare 3 swordsmen and complete a small expedition | Bow Range, Shield Yard, Muster orders |
| 3. Hold the River Bridge | Deploy 5 swordsmen and 10 archers in distinct slots | Riding Yard, paddock, Spear Yard, meadow parcel |
| 4. Cover the Surveyors | Use protection and ranged support while a civilian survey team works | First hybrid codex page and blueprint copying |

### Act II — Roads and Riders

Introduce horses, land-intensive production, travel time, and a third certification slot. The bridge reward provides the first founding riding instructor and a starter pair of mounts; paddocks can produce further mounts without another locked region.

| Mission | Task | Unlock / purpose |
| --- | --- | --- |
| 5. Courier Through the Plains | Solve a mobility challenge; mounted archers are suggested | Army Charter: 3 combat slots |
| 6. Broken Caravan Road | Escort wagons against riders; spears and ranged cover help | Wagons, dedicated depot routes, quarry expansion |
| 7. The Old Sanctuary | Endure several encounters and rescue its keepers | Restoration, herbs, infirmary, Paladin doctrine |
| 8. Hold Two Crossings | Prepare two separate detachments with shared supply limits | First persistent outpost and garrison commissions |

### Act III — The Learned Orders

Combine support and offense while bringing scholars into the economy. New arcane deposits are guaranteed on the reward parcel or supplied by an unlocked trade route.

| Mission | Task | Unlock / purpose |
| --- | --- | --- |
| 9. Echoes in the Ruins | Rescue an archive; protection and restoration improve endurance | Arcana and crystal access |
| 10. The Ashen Workshop | Break a defended workshop with several viable compositions | Fire school and essence processing |
| 11. Paths Beneath the Canopy | Escort through woodland; scouting route is offered immediately | Scouting during preparation; Nature and woodland on completion |
| 12. Defend the Academy | Sustain a mixed force through successive threats | Academy Charter: 4 slots; Scriptorium and manuals |

### Act IV — Engines of War

Add Engineering, then Artillery, without requiring either to unlock itself. Introduce simultaneous material demands and sustained field support.

| Mission | Task | Unlock / purpose |
| --- | --- | --- |
| 13. Recover the Engineers | Protect a rescue team using existing troops | Engineering, mechanisms, bridge building |
| 14. Reclaim the Siege School | Escort engineers carrying repair supplies | Artillery, ballista blueprint, steel branch |
| 15. The Mountain Gate | Protect siege crews and deliver ammunition through a pass | Command, advanced armor, Officers' College |
| 16. Supply the March | Meet a sustained field-supply contract while holding a fort | Citadel Charter: fifth slot for experienced citizens |

### Act V — The Banner Accord

The last act tests the town as a whole. Repeatable earlier contracts remain available for supplies and experience. All essential manuals have renewable acquisition paths.

| Mission | Task | Unlock / purpose |
| --- | --- | --- |
| 17. The Three Fronts | Prepare distinct forces for forest, fortress, and open-field objectives | Flagship five-skill doctrines and final route |
| 18. The Broken Crown | Complete staged siege, escort, and defense objectives while resupplying | Campaign conclusion and open-ended charter board |

For mission 11, the new scout school becomes available in the preparation step through the allied guide; completion awards Nature and the woodland parcel. The card makes this staged unlock explicit. No mission requires a discipline that is only awarded after winning that same mission.

## 10. Map, expansion, and long-term play

### Home settlement

Begin with a compact, authored region that guarantees food land, timber, iron, stone, and connected areas of buildable terrain. Forests, rivers, rock deposits, and changes in grass texture make the map attractive and shape useful planning decisions. Keep the interiors of clearings open enough for straight roads and repeated building rows. Rivers create bridge sites; trees can be harvested to clear expansion space. Unlock adjacent parcels while preserving the existing town. Home iron and timber retain a renewable, lower-output option, while expansion offers richer sources.

District specializations emerge through practical placement: food near farmland, smithing near ore and charcoal, cavalry near paddocks, and schools near housing and the assembly field. Leave expansion strips beside shared road trunks so another workshop or school can be added without rebuilding the whole district. Building ratios, port orientation, road distance, and delivery capacity account for the main layout benefits. Decorative objects never silently block a road or hide a usable port.

Allow moving unloaded buildings with a preview of rerouting costs and temporary downtime. During the tutorial, moving and undoing construction are free. Afterward, reclaim most construction materials on dismantling; stored contents are returned in full. Show backpack space and any resulting pickup crate before committing.

### Outposts

Introduce one satellite outpost before supporting several. Each has local inventories, a small workforce, a garrison requirement, and a caravan connection. An outpost might provide crystals, rich iron, rare herbs, or horse pasture. Present outpost management through a compact panel; opening its full map is optional.

The caravan route has carrying capacity, a travel interval, and an escort assignment. An escort remains deployed and unavailable for another mission during the route cycle. Threats are revealed before activation and worsen only through explicit campaign steps, not through offline surprise attacks.

### Research and alternative development

Research unlocks tangible changes: extra school seats, larger carts, new recipes, a third certification slot, conditional recruitment, or a new doctrine. Avoid filling the tree with repeated 5% upgrades. Early upgrades can be bought with materials and gold; later improvements use manuals produced from renewable service reports.

Use three optional policy branches: professional army, mass levies, and scholarly orders. Policies modify tradeoffs such as training cost versus deployment flexibility. Let players change policy at a material and reorganization cost. Do not lock essential schools behind mutually exclusive choices.

### Endgame

The charter board offers repeatable objectives with authored constraints: a woodland rescue with no mounts, a fortress relief with a small command cap, an ammunition-intensive siege, or a large allied garrison request. Rewards include decorations, alternative recipes, new map parcels, and personal records.

Add a sandbox mode with resource and unlock controls. Later challenge maps can randomize deposits and mission modifiers while using a validator that guarantees a viable starting economy. The initial campaign should stay authored so its teaching sequence remains reliable.

## 11. Mobile interaction, visual direction, and sound

### Screen layout

Use the world as the main screen, with most of the portrait viewport reserved for the planning map. A slim top bar shows population, pause, and “Backpack”; it has no shared item counters. A compact bottom tray switches between Build, Roads, Flows, and Army. Selecting a building opens a short bottom card with footprint, ports, rate, and Inventory. Inventory expands into two clearly labeled panels: the selected building and “Your Backpack,” each with its own slots and quantities. Keep the selected building visible on the map. People management opens from the population counter, army orders from Army, and material routes from Flows.

One finger pans in normal mode; tapping selects and pinch zooms. Build mode previews a grid-snapped ghost with Rotate, Cancel, and Place. Roads mode starts from a selected port, previews straight segments and right-angle turns, and ends with Cancel or Connect. Flows mode reveals arrows, rates, queues, and the cause of a bottleneck. A visible tool state separates road drawing from camera movement. Long press opens copy and move actions, with equivalent visible buttons. Citizens follow orders and roads without per-person dragging.

### Mobile conveniences

- Snap roads and construction ghosts to the grid, with a reachable entrance preview.
- Offer paint-to-build roads and clear previews of total material cost.
- Pause automatically while editing complex routes, unless the player changes the setting.
- Provide normal, double, and quadruple simulation speed with a conspicuous pause state.
- Keep objectives tappable: “missing 3 saddles” opens that chain.
- Support large text, adjustable UI scale, icons plus words, and color-independent status symbols.
- Use a minimum 48-logical-unit interaction target as a product design target; verify it on the intended phones.
- Add a compact returning-session panel with paused orders and one suggested next action.

### Visual identity

Use compact, readable fantasy sprites with strong silhouettes and restrained detail. Square foundations and edge ports expose a building's usable footprint; low roofs, tools, and small banners distinguish its function. Grass, water, reeds, flowers, woods, and stone deposits provide an attractive natural map while keeping central construction space clear. Green fields, dark forges, pale sanctuaries, and luminous colleges distinguish production districts. Work animations communicate actual state: working forge, queued cart, waiting class, and graduating students.

Readability at the default phone zoom matters more than tiny decorative detail. Use modular equipment layers and four primary facing directions initially. Expand animation directions only after measuring the visual benefit and art workload. Do not commission a separate full animation set for every hybrid class.

### Audio

Use local ambient layers: hammering, wind in fields, wagon wheels, training calls, and gentle arcane sounds. Let a stopped production district become noticeably quieter. Reserve short cues for graduation, mission readiness, unlocks, and actionable shortages. Alerts should be coalesced so a shared ore shortage does not produce ten separate warnings.

## 12. Pacing, safeguards, and playtest questions

### Proposed progression targets

Aim for the first positive food loop within 5 minutes, the first trained swordsman within 10–15, the first hybrid within 25–40, and a working mounted-archer route within the opening 1–2 hours. These are usability targets, not mandatory waits. At faster simulation speed, the player's bottleneck should be planning and capacity rather than waiting for an arbitrary timer.

### Controls against dominant strategies

Basic units remain attractive through low teaching time, cheap equipment, low command cost, and parallel production. Hybrid units earn their cost through flexibility or a mission-specific advantage. Advanced doctrines have one signature effect; overlapping command auras do not stack. Heavy gear and terrain create visible disadvantages, and five active skills compete for actions.

If one roster wins every mission cheaply, first change mission objectives and action tradeoffs. Increasing all enemy health is a weak substitute for creating different preparation problems.

### Recovery and edge cases

- No food: pause growth, keep gathering effective, and offer a clear forage action.
- No miners or smiths: train from the founding lodge using accessible supplies.
- No military instructor: recall the founding guest at the original school.
- No spare population: show protected jobs and allow housing expansion before accepting an impossible order.
- Disconnected road: stop reserving new deliveries and highlight the broken segment.
- Full output: pause production without consuming more inputs.
- Order cancelled mid-lesson: preserve existing skills and return unused reservations; completed practice costs stay spent.
- Every soldier wounded: provide free rest and earlier repeatable low-demand contracts.
- Essential deposit unavailable: use guaranteed starter access or an already unlocked substitute trade source.

### What to measure

Measure whether the player can explain a stoppage, whether fixing it improves output, and whether preparing a new composition changes the settlement. Track median taps to diagnose a blocked order, time to first autonomous hybrid, percentage of session spent repeating assignments, and the range of successful rosters across missions.

An early success criterion is that a player can create and repeat one hybrid route without selecting individual students, diagnose its main shortage within two taps, and complete the same later mission with two meaningfully different compositions. Use external playtests eventually; initially, record personal sessions and inspect where the interface forces unnecessary work.

## 13. First playable scope and build sequence

### Milestone A — Prove the people-production loop

Build a small greybox with a Town Hall, housing, direct-food farm, lumber camp, iron mine, kiln, combined smithy, bowyer, Guild Lodge, Warehouse Barn, three distinct schools, and Muster Field. That is 14 building types. The smithy alternates smelting, swords, and shields; it never performs those recipes simultaneously at one station.

Use nine physical resources: food, timber, ore, charcoal, bars, swords, shields, bows, and arrows. Use five civilian professions: farmer, forester, miner, smith, and carpenter. Basic logistics and building need no qualification. Teach Sword, Shield, and Archery with two combat slots, producing Man-at-Arms, Skirmisher, and Pavise Archer hybrids.

Support a 30-person town, quarter-turn building placement, visible ports, player-drawn roads, one splitter, actual deliveries, one repeatable order, two simple expeditions, pause/speed controls, and save/resume. Include separate building inventories, a Warehouse Barn, backpack transfers, construction payment, and overflow pickup crates. Let the player collect construction materials, add a parallel school, shorten a road, and diagnose an equipment or instructor shortage. A basic mission resolver may use explicit objective thresholds before animated combat exists.

Exit criterion: the town repeatedly equips and trains a hybrid force without manual per-person actions, and different layouts produce a visible throughput difference.

### Milestone B — The first version worth playing regularly

Add Riding and Spear, paddocks, oats, leather, saddles, mounts, gold, wagons, and dedicated supply rules. Split the smithy into specialized production buildings. Add the first six campaign missions, including the 5-swordsmen/10-archers bridge objective, plus repeatable cavalry and escort contracts. Add a three-slot charter, Knight and Cataphract doctrines, basic recovery, and a simple phase-based combat presentation.

The mounted-archer chain is the end-to-end acceptance scenario. The player recruits and equips eight mounted archers, traces an intentional saddle shortage, completes a mission, repairs the force, closes the app, and resumes with the same people and reservations. Target about 2–4 hours of varied initial content; revise after playtesting.

Exit criterion: the game is enjoyable on the actual phone across several sessions, with at least two viable ways to solve a later mission and no repeated roster administration.

### Milestone C — Expand the game that has proved enjoyable

Add Restoration and Arcana first, then Scouting, Nature, and Fire. Introduce the Scriptorium, veterans as instructors, a fourth certification slot, and one outpost. Only then add Engineering, Artillery, Command, multi-front preparation, and five-skill units.

Finish the 18-mission campaign and curated 32-hybrid roster. Add alternate recipes and scenario contracts after the main progression is coherent. A large procedural world, naval warfare, multiple playable factions, real-time base invasions, hero campaigns, multiplayer, and a public economy belong to later separate projects or expansions.

### Suggested implementation order inside each milestone

Implement content definitions and simulation rules first, then a debug inspector, then the touch interface and presentation. Use temporary sprites until routes, inventories, and learning are enjoyable. Export to the intended phone in the first milestone rather than treating mobile deployment as a final packaging step.

## 14. Technical direction and data model

### Engine recommendation

Use Godot with GDScript for the first native implementation. This is a project-specific recommendation: the proposed game benefits from a dedicated 2D scene workflow, tile-based world construction, and a relatively small local simulation. Official Godot documentation describes its dedicated 2D renderer, tile tools, sprite animation, and lighting [1]. Godot also documents Android export [2] and an iOS workflow through Xcode on macOS [3].

For iPhone delivery, plan on a Mac with Xcode and validate device signing early. The official iOS page currently describes C# support as experimental, which supports choosing GDScript for this particular first build [3]. Pin the engine release after a successful device export. The gameplay architecture below is a design proposal, independent of a particular engine version.

### Separate data, simulation, and presentation

Store recipes, buildings, disciplines, doctrines, missions, and unlocks as data with stable identifiers. Keep authoritative inventory and citizen state independent from sprite nodes. UI and animations read the simulation state and issue explicit commands. A person walking into a school is a view of the same scheduled task that owns their lesson reservation.

| Entity | Essential fields |
| --- | --- |
| Citizen | ID, civilian certificates, combat certificates, mastery, assignment, equipment IDs, health, location |
| Building | ID, definition ID, footprint, rotation, ports, staff, recipe, local inventory IDs, queue, progress |
| Inventory | Owner ID and type, slots, stack limits, accepted items, quantities, reserved quantities |
| Player backpack / pickup crate | Inventory ID, capacity; crate tile location when applicable |
| Item / equipment | Definition ID, quantity or instance ID, location, condition, reservation owner |
| Course | Discipline, prerequisites, required gear, consumables, duration, instructor requirement |
| Doctrine | Required active skills, compatible loadout, one signature behavior, command modifiers |
| Army order | Target, candidate filters, training route, roster membership, stock reservations, priority |
| Road / route | Tile path, surface, junction rules, source/destination ports, allowed traffic, assigned carriers |
| Delivery task | Source port, destination port, reserved cargo, selected route, carrier, outward/return progress |
| Mission | Unlock prerequisites, objective phases, terrain, deployment limits, rewards, resolution state |
| World save | Schema version, simulation time, entities, orders, unlocks, task state, random seed if used |

### Simulation and performance targets

Start with a fixed simulation step, for example 5–10 ticks per second, and interpolate visible movement independently. A typical design target is smooth 60 fps presentation with an optional 30 fps battery mode. Begin with 30 citizens, then test 100 and 300 using representative deliveries and school queues. These are budgets to verify, not promises.

Store player-drawn road tiles and assigned port-to-port routes explicitly. Cache validated travel paths and invalidate affected routes when construction changes them; never silently rebuild a removed supply connection. Schedule hauling and teaching centrally or by district instead of searching from every citizen on every rendered frame. Off-screen animation may be reduced while production, travel time, and inventory follow the same rules.

At large scale, group identical off-screen movements into batches only if travel time, capacity, reservations, and results remain equivalent. Do not teleport goods simply because the camera moved away. Avoid building a complicated entity-component framework before profiling shows a concrete need.

### Saving and app lifecycle

Keep the first version fully local, with no backend requirement. Save on important milestones and when the app is backgrounded. Use atomic save replacement and keep a previous valid snapshot. Store schema versions and write explicit migrations as data definitions evolve. Suspend the simulation on close; resuming must not advance unseen wars or drain food.

Provide manual save slots and save export/import for a personal game. If offline progress is added later, make it opt-in, capped, and based on the same resource constraints. It should never be an assumed part of the first version.

### Meaningful verification

Test inventory conservation through crafting, delivery, manual transfers, construction, dismantling, equipping, cancellation, repair, and save/resume. Verify that stock in another building cannot pay backpack construction costs; partial transfers and a full backpack cannot duplicate or delete items; and full outputs stop production. Test that one citizen cannot occupy two assignments, one item cannot have conflicting reservations, and one hybrid cannot fill two simultaneous mission slots. Validate the unlock graph for cycles and unavailable mandatory resources.

Run a scripted starvation-and-recovery scenario, instructor-loss scenario, road-removal scenario, full-buffer scenario, and mid-lesson cancellation. Compare uninterrupted simulation with save/resume at the same tick. Measure frame time and power behavior on the intended phone during a busy late-stage town, not only on an empty desktop scene.

## 15. Immediate decisions and the next concrete deliverable

Prioritize grid buildings, visible ports, player-drawn roads, local inventories, warehouse barns, and backpack-funded construction. The mockups test portrait planning; validate placement, item dragging, and routing on a phone before expanding content. Preserve trained professions, automated student orders, reusable armies, and curated hybrids.

Build Milestone A on a phone with temporary art. Demonstrate recruitment, miner and smith training, equipment production, a student route through two schools, hybrid squad assembly, an expedition, and automatic readiness recovery. This tests the complete loop before wider development.

### Technical references — checked 5 September 2026

[1] Godot documentation, “Introduction to 2D.” https://docs.godotengine.org/en/stable/tutorials/2d/introduction_to_2d.html

[2] Godot documentation, “Exporting for Android.” https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

[3] Godot documentation, “Exporting for iOS.” https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html
