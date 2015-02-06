
--
-- this is physics, where phys* tables are defined and used.
-- An initial MOAI physics setup is assumed; we access
-- mainLayers according to the rule that we assume
-- it is already there and properly working and all we
-- care about here, then, is physics..
--

physPolygons = {}
physBodies = {}
physFixtures = {}

physBoxWorld = MOAIBox2DWorld.new ()

-- we go straight to "main"
mainLayers["main"]:setBox2DWorld ( physBoxWorld )

physBoxWorld:setGravity ( -0, -9 )
physBoxWorld:setUnitsToMeters ( 1/30, 10 )
physBoxWorld:start ()

-- Establish a ground for sanity
physPolygons["ground_shape"] = { -(appDefs.STAGE_WIDTH / 2), -(appDefs.STAGE_HEIGHT / 2),
								appDefs.STAGE_WIDTH / 2, -(appDefs.STAGE_HEIGHT / 2),
								(appDefs.STAGE_WIDTH / 2), appDefs.GROUND_Y_POS}
physPolygons["sky_shape"] = { -(appDefs.STAGE_WIDTH / 2), appDefs.SKY_Y_POS,
								(appDefs.STAGE_WIDTH / 2), appDefs.SKY_Y_POS,
								(appDefs.STAGE_WIDTH / 2), (appDefs.STAGE_HEIGHT / 2),
								-(appDefs.STAGE_WIDTH / 2), (appDefs.STAGE_HEIGHT / 2)}

physPolygons["hexbumper_1"] = { -10, 20, -20, 0, -10, -20, 10, -20, 20, 0, 10, 20, }

physBodies['ground'] = physBoxWorld:addBody(MOAIBox2DBody.STATIC)
physBodies['sky'] = physBoxWorld:addBody(MOAIBox2DBody.STATIC)
physBodies['hexbumper'] = physBoxWorld:addBody(MOAIBox2DBody.STATIC)
physBodies['hexbumper']:setTransform(0,10)

physBodies['newedges'] = physBoxWorld:addBody(MOAIBox2DBody.STATIC)
physBodies['newedges']:setTransform(0,10)

physFixtures["ground_fixture"] = physBodies["ground"]:addPolygon(physPolygons["ground_shape"])
physFixtures["sky_fixture"] = physBodies["sky"]:addPolygon(physPolygons["sky_shape"])
physFixtures["sky_fixture"]:setDensity(0.0)

physFixtures["hexbumperfix"] = physBodies["hexbumper"]:addPolygon(physPolygons["hexbumper_1"])

-- !J! Hak
function addEdgesToWorld(edges)
	physBodies['drawpoints_edge'..#physBodies] = physBoxWorld:addBody(MOAIBox2DBody.STATIC)

	user_data.new_edges  = {}
	in_e = 1
	in_x = 1
	while (in_e <= (#edges * 2) + 1) do
		for in_d = 0, 3, 1 do
			user_data.new_edges [in_e + in_d] = edges[in_x + in_d]
		end
		in_x = in_x + 2
		in_e = in_e + 4
	end

--print(table.show(edges, "edges:"))
--print(table.show(new_edges, "new_edges:"))
	physFixtures["drawpoints_fixture" .. #physFixtures] = physBodies["ground"]:addEdges(user_data.new_edges)
	sync_user_data()
end

-- randomly drops a sould into the playfield
function dropASoul (which_soul)

	print("" .. table.show(which_soul))

	soulId = which_soul.name .. #which_soul.name -- for picking

	which_soul.prop.name = soulId
	--which_soul.name = soulId

	physBodies[soulId] = physBoxWorld:addBody ( MOAIBox2DBody.DYNAMIC )
	physBodies[soulId]:setTransform ( math.random ( -(appDefs.STAGE_WIDTH / 2), (appDefs.STAGE_WIDTH / 2) ), 200 )
	physFixtures[soulId] = physBodies[soulId]:addRect ( - math.random ( 10, 20 ), - math.random ( 10, 30 ),  math.random ( 10, 30 ),  math.random ( 10, 15 ) )
	physFixtures[soulId].name = "fixture#" .. #soulId

	-- assume that resources has done its job and that prop is already assigned
	which_soul.prop:setParent ( physBodies[soulId] )
	which_soul.prop.body = physBodies[soulId]

--	physBodies[soulId]:setTransform ( math.random ( -(STAGE_WIDTH / 2), (STAGE_WIDTH / 2) ), 200 )
	physBodies[soulId]:setTransform ( 0, 0, 200 )


	physFixtures[soulId] = physBodies[soulId]:addRect ( - math.random ( 10, 20 ), - math.random ( 10, 30 ),  math.random ( 10, 30 ),  math.random ( 10, 15 ) )
	physFixtures[soulId].name = "fixture#" .. soulId

-- print(physFixtures[soulId].name)

	physFixtures[soulId]:setFriction ( 0.25)
	physFixtures[soulId]:setDensity ( 1 )
	physFixtures[soulId]:setRestitution ( 0.5 )

	physBodies[soulId]:resetMassData()

	-- put the prop in the right layer
	mainLayers["main"]:insertProp(which_soul.prop)
	-- print("w soulId:" .. which_soul.name)
	-- print("" .. table.show(which_soul))

end
