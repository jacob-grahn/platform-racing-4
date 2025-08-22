class_name Tiles

var map = {}
var rows: int = 10
var columns: int = 5
var total_blocks_in_atlas_coords: int = rows * columns
var blocks_for_each_category: int = 100
var styles: Array = ["classic", "desert", "metal", "jungle", "space", "underwater", "pr4"]

# PR3 non-custom block data goes like this: block: b(X + (100 * Y)),
# where X is the block ID and Y is the block category

# For X, the block id list goes like this:
# (0 = start, 1-4 = basics (2-4 (white, x, and waffle) are unused in pr3.), 5 = brick, 6 = crumble, 7 = finish,
# 8 = happy, 9 = ice, 10 = infinite, 11 = item, 12 = mine, 13 = move, 14 = push, 15 = rotateleft,
# 16 = rotateright, 17 = sad, 18 = safetynet, 19 = vanish, 20 = water, 21 = redteleport, 22 = blueteleport,
# 23 = yellowteleport, 24 = bounce, 25 = change, 26 = up, 27 = down, 28 = left, 29 = right)

# For Y, the block category goes like this:
# (0 = classic, 1 = desert, 2 = industrial, 3 = jungle, 4 = space, 5 = underwater).

# Therefore, the formula should give numbers like this:
# (b1-99 = classic, b100-199 = desert, b200-299 = industrial, b300-399 = jungle,
# b400-499 = space, b500-599 = underwater.)

# This setup only supports 100 blocks, and I don't know if PR4 will have 100 blocks, but if it does,
# we'll cross the bridge when we get to it (probably increase the increment by 1000 or something).

func init_defaults() -> void:
	map['1'] = Tile.new()
	map['2'] = Tile.new()
	map['3'] = Tile.new()
	map['4'] = Tile.new()
	map['5'] = ClassicBrick.new()
	map['6'] = ClassicArrowDown.new()
	map['7'] = ClassicArrowUp.new()
	map['8'] = ClassicArrowLeft.new()
	map['9'] = ClassicArrowRight.new()
	map['10'] = ClassicMine.new()
	map['11'] = ClassicItemDispenser.new()
	map['12'] = ClassicStart.new()
	map['13'] = ClassicBounce.new()
	map['14'] = ClassicChange.new()
	map['15'] = ClassicHurt.new()
	map['16'] = ClassicIce.new()
	map['17'] = ClassicFinish.new()
	map['18'] = ClassicCrumble.new()
	map['19'] = ClassicVanish.new()
	map['20'] = ClassicMove.new()
	map['21'] = ClassicWater.new()
	map['22'] = ClassicRotateClockwise.new()
	map['23'] = ClassicRotateCounterclockwise.new()
	map['24'] = ClassicPush.new()
	map['25'] = ClassicSafetyNet.new()
	map['26'] = ClassicItemDispenserInfinite.new()
	map['27'] = ClassicHappy.new()
	map['28'] = ClassicSad.new()
	map['29'] = ClassicHeart.new()
	map['30'] = ClassicTimeBlock.new()
	map['31'] = ClassicEggBlock.new()
	map['32'] = ClassicCustomStats.new()
	map['33'] = ClassicTeleport.new()
	map['35'] = ClassicGear.new()
	map['36'] = ClassicPresenceSwitch.new()
	map['37'] = ClassicSun.new()
	map['38'] = ClassicMoon.new()
	map['39'] = ClassicFirefly.new()
	map['40'] = ClassicAppear.new()
	map['41'] = ClassicMega.new()
	map['42'] = ClassicMini.new()
	map['43'] = ClassicSticky.new()
	map['44'] = ClassicCrumble.new()
	map['45'] = ClassicMine.new()
	
	map['101'] = Tile.new()
	map['102'] = Tile.new()
	map['103'] = Tile.new()
	map['104'] = Tile.new()
	map['105'] = DesertBrick.new()
	map['106'] = DesertArrowDown.new()
	map['107'] = DesertArrowUp.new()
	map['108'] = DesertArrowLeft.new()
	map['109'] = DesertArrowRight.new()
	map['110'] = DesertMine.new()
	map['111'] = DesertItemDispenser.new()
	map['112'] = DesertStart.new()
	map['113'] = DesertBounce.new()
	map['114'] = DesertChange.new()
	map['115'] = DesertHurt.new()
	map['116'] = DesertIce.new()
	map['117'] = DesertFinish.new()
	map['118'] = DesertCrumble.new()
	map['119'] = DesertVanish.new()
	map['120'] = DesertMove.new()
	map['121'] = DesertWater.new()
	map['122'] = DesertRotateClockwise.new()
	map['123'] = DesertRotateCounterclockwise.new()
	map['124'] = DesertPush.new()
	map['125'] = DesertSafetyNet.new()
	map['126'] = DesertItemDispenserInfinite.new()
	map['127'] = DesertHappy.new()
	map['128'] = DesertSad.new()
	map['129'] = DesertHeart.new()
	map['130'] = DesertTimeBlock.new()
	map['131'] = DesertEggBlock.new()
	map['132'] = DesertCustomStats.new()
	map['133'] = DesertTeleport.new()
	map['135'] = DesertGear.new()
	map['136'] = DesertPresenceSwitch.new()
	map['137'] = DesertSun.new()
	map['138'] = DesertMoon.new()
	map['139'] = DesertFirefly.new()
	map['140'] = DesertAppear.new()
	map['141'] = DesertMega.new()
	map['142'] = DesertMini.new()
	map['143'] = DesertSticky.new()
	map['144'] = DesertCrumble.new()
	map['145'] = DesertMine.new()
	
	map['201'] = Tile.new()
	map['202'] = Tile.new()
	map['203'] = Tile.new()
	map['204'] = Tile.new()
	map['205'] = IndustrialBrick.new()
	map['206'] = IndustrialArrowDown.new()
	map['207'] = IndustrialArrowUp.new()
	map['208'] = IndustrialArrowLeft.new()
	map['209'] = IndustrialArrowRight.new()
	map['210'] = IndustrialMine.new()
	map['211'] = IndustrialItemDispenser.new()
	map['212'] = IndustrialStart.new()
	map['213'] = IndustrialBounce.new()
	map['214'] = IndustrialChange.new()
	map['215'] = IndustrialHurt.new()
	map['216'] = IndustrialIce.new()
	map['217'] = IndustrialFinish.new()
	map['218'] = IndustrialCrumble.new()
	map['219'] = IndustrialVanish.new()
	map['220'] = IndustrialMove.new()
	map['221'] = IndustrialWater.new()
	map['222'] = IndustrialRotateClockwise.new()
	map['223'] = IndustrialRotateCounterclockwise.new()
	map['224'] = IndustrialPush.new()
	map['225'] = IndustrialSafetyNet.new()
	map['226'] = IndustrialItemDispenserInfinite.new()
	map['227'] = IndustrialHappy.new()
	map['228'] = IndustrialSad.new()
	map['229'] = IndustrialHeart.new()
	map['230'] = IndustrialTimeBlock.new()
	map['231'] = IndustrialEggBlock.new()
	map['232'] = IndustrialCustomStats.new()
	map['233'] = IndustrialTeleport.new()
	map['235'] = IndustrialGear.new()
	map['236'] = IndustrialPresenceSwitch.new()
	map['237'] = IndustrialSun.new()
	map['238'] = IndustrialMoon.new()
	map['239'] = IndustrialFirefly.new()
	map['240'] = IndustrialAppear.new()
	map['241'] = IndustrialMega.new()
	map['242'] = IndustrialMini.new()
	map['243'] = IndustrialSticky.new()
	map['244'] = IndustrialCrumble.new()
	map['245'] = IndustrialMine.new()
	
	map['301'] = Tile.new()
	map['302'] = Tile.new()
	map['303'] = Tile.new()
	map['304'] = Tile.new()
	map['305'] = JungleBrick.new()
	map['306'] = JungleArrowDown.new()
	map['307'] = JungleArrowUp.new()
	map['308'] = JungleArrowLeft.new()
	map['309'] = JungleArrowRight.new()
	map['310'] = JungleMine.new()
	map['311'] = JungleItemDispenser.new()
	map['312'] = JungleStart.new()
	map['313'] = JungleBounce.new()
	map['314'] = JungleChange.new()
	map['315'] = JungleHurt.new()
	map['316'] = JungleIce.new()
	map['317'] = JungleFinish.new()
	map['318'] = JungleCrumble.new()
	map['319'] = JungleVanish.new()
	map['320'] = JungleMove.new()
	map['321'] = JungleWater.new()
	map['322'] = JungleRotateClockwise.new()
	map['323'] = JungleRotateCounterclockwise.new()
	map['324'] = JunglePush.new()
	map['325'] = JungleSafetyNet.new()
	map['326'] = JungleItemDispenserInfinite.new()
	map['327'] = JungleHappy.new()
	map['328'] = JungleSad.new()
	map['329'] = JungleHeart.new()
	map['330'] = JungleTimeBlock.new()
	map['331'] = JungleEggBlock.new()
	map['332'] = JungleCustomStats.new()
	map['333'] = JungleTeleport.new()
	map['335'] = JungleGear.new()
	map['336'] = JunglePresenceSwitch.new()
	map['337'] = JungleSun.new()
	map['338'] = JungleMoon.new()
	map['339'] = JungleFirefly.new()
	map['340'] = JungleAppear.new()
	map['341'] = JungleMega.new()
	map['342'] = JungleMini.new()
	map['343'] = JungleSticky.new()
	map['344'] = JungleCrumble.new()
	map['345'] = JungleMine.new()
	
	map['401'] = Tile.new()
	map['402'] = Tile.new()
	map['403'] = Tile.new()
	map['404'] = Tile.new()
	map['405'] = SpaceBrick.new()
	map['406'] = SpaceArrowDown.new()
	map['407'] = SpaceArrowUp.new()
	map['408'] = SpaceArrowLeft.new()
	map['409'] = SpaceArrowRight.new()
	map['410'] = SpaceMine.new()
	map['411'] = SpaceItemDispenser.new()
	map['412'] = SpaceStart.new()
	map['413'] = SpaceBounce.new()
	map['414'] = SpaceChange.new()
	map['415'] = SpaceHurt.new()
	map['416'] = SpaceIce.new()
	map['417'] = SpaceFinish.new()
	map['418'] = SpaceCrumble.new()
	map['419'] = SpaceVanish.new()
	map['420'] = SpaceMove.new()
	map['421'] = SpaceWater.new()
	map['422'] = SpaceRotateClockwise.new()
	map['423'] = SpaceRotateCounterclockwise.new()
	map['424'] = SpacePush.new()
	map['425'] = SpaceSafetyNet.new()
	map['426'] = SpaceItemDispenserInfinite.new()
	map['427'] = SpaceHappy.new()
	map['428'] = SpaceSad.new()
	map['429'] = SpaceHeart.new()
	map['430'] = SpaceTimeBlock.new()
	map['431'] = SpaceEggBlock.new()
	map['432'] = SpaceCustomStats.new()
	map['433'] = SpaceTeleport.new()
	map['435'] = SpaceGear.new()
	map['436'] = SpacePresenceSwitch.new()
	map['437'] = SpaceSun.new()
	map['438'] = SpaceMoon.new()
	map['439'] = SpaceFirefly.new()
	map['440'] = SpaceAppear.new()
	map['441'] = SpaceMega.new()
	map['442'] = SpaceMini.new()
	map['443'] = SpaceSticky.new()
	map['444'] = SpaceCrumble.new()
	map['445'] = SpaceMine.new()
	
	map['501'] = Tile.new()
	map['502'] = Tile.new()
	map['503'] = Tile.new()
	map['504'] = Tile.new()
	map['505'] = UnderwaterBrick.new()
	map['506'] = UnderwaterArrowDown.new()
	map['507'] = UnderwaterArrowUp.new()
	map['508'] = UnderwaterArrowLeft.new()
	map['509'] = UnderwaterArrowRight.new()
	map['510'] = UnderwaterMine.new()
	map['511'] = UnderwaterItemDispenser.new()
	map['512'] = UnderwaterStart.new()
	map['513'] = UnderwaterBounce.new()
	map['514'] = UnderwaterChange.new()
	map['515'] = UnderwaterHurt.new()
	map['516'] = UnderwaterIce.new()
	map['517'] = UnderwaterFinish.new()
	map['518'] = UnderwaterCrumble.new()
	map['519'] = UnderwaterVanish.new()
	map['520'] = Move.new()
	map['521'] = UnderwaterWater.new()
	map['522'] = UnderwaterRotateClockwise.new()
	map['523'] = UnderwaterRotateCounterclockwise.new()
	map['524'] = UnderwaterPush.new()
	map['525'] = UnderwaterSafetyNet.new()
	map['526'] = UnderwaterItemDispenserInfinite.new()
	map['527'] = UnderwaterHappy.new()
	map['528'] = UnderwaterSad.new()
	map['529'] = UnderwaterHeart.new()
	map['530'] = UnderwaterTimeBlock.new()
	map['531'] = UnderwaterEggBlock.new()
	map['532'] = UnderwaterCustomStats.new()
	map['533'] = UnderwaterTeleport.new()
	map['535'] = UnderwaterGear.new()
	map['536'] = UnderwaterPresenceSwitch.new()
	map['537'] = UnderwaterSun.new()
	map['538'] = UnderwaterMoon.new()
	map['539'] = UnderwaterFirefly.new()
	map['540'] = UnderwaterAppear.new()
	map['541'] = UnderwaterMega.new()
	map['542'] = UnderwaterMini.new()
	map['543'] = UnderwaterSticky.new()
	map['544'] = UnderwaterCrumble.new()
	map['545'] = UnderwaterMine.new()
	
	map['601'] = Tile.new()
	map['602'] = Tile.new()
	map['603'] = Tile.new()
	map['604'] = Tile.new()
	map['605'] = Brick.new()
	map['606'] = ArrowDown.new()
	map['607'] = ArrowUp.new()
	map['608'] = ArrowLeft.new()
	map['609'] = ArrowRight.new()
	map['610'] = Mine.new()
	map['611'] = ItemDispenser.new()
	map['612'] = Start.new()
	map['613'] = Bounce.new()
	map['614'] = Change.new()
	map['615'] = Hurt.new()
	map['616'] = Ice.new()
	map['617'] = Finish.new()
	map['618'] = Crumble.new()
	map['619'] = Vanish.new()
	map['620'] = Move.new()
	map['621'] = Water.new()
	map['622'] = RotateClockwise.new()
	map['623'] = RotateCounterclockwise.new()
	map['624'] = Push.new()
	map['625'] = SafetyNet.new()
	map['626'] = ItemDispenserInfinite.new()
	map['627'] = Happy.new()
	map['628'] = Sad.new()
	map['629'] = Heart.new()
	map['630'] = TimeBlock.new()
	map['631'] = EggBlock.new()
	map['632'] = CustomStats.new()
	map['633'] = Teleport.new()
	map['635'] = Gear.new()
	map['636'] = PresenceSwitch.new()
	map['637'] = Sun.new()
	map['638'] = Moon.new()
	map['639'] = Firefly.new()
	map['640'] = Appear.new()
	map['641'] = Mega.new()
	map['642'] = Mini.new()
	map['643'] = Sticky.new()
	map['644'] = Crumble.new()
	map['645'] = Mine.new()
	
	# init
	#for style_counter in len(styles):
	#	for tile_id in block_map:
	#		map[str((int(tile_id) + (seperator * int(style_counter))))] = block_map[str(int(tile_id))]
	
	for tile_id in map:
		map[tile_id].init()


func on(event: String, tile_type: int, player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		tile.on(event, player, tile_map_layer, coords)
		if event == "bump":
			TileEffects.bump(player, tile_map_layer, coords)


func is_solid(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.ACTIVE
	return false


func is_liquid(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.WATER
	return false


func is_safe(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.ACTIVE && tile.is_safe
	return false


func activate_node(node: Node):
	if node is TileMapLayer:
		activate_tile_map_layer(node)
		return
		
	for child in node.get_children():
		if child is TileMapLayer:
			activate_tile_map_layer(child)
		elif child is Node2D || child is ParallaxBackground:
			activate_node(child)


func activate_tile_map_layer(tile_map_layer: TileMapLayer):
	for tile_id in map:
		map[tile_id].activate_tile_map_layer(tile_map_layer)


func clear():
	for tile_id in map:
		map[tile_id].clear()
