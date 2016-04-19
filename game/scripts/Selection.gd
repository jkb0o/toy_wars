
extends Polygon2D

onready var level = get_node("../Level")

func set_selection(unit):
	var moves = find_all_moves(unit)
	draw_moves(moves)

	

func find_all_moves(unit):
	var first = PathFindNode.new()
	first.pos = unit.get_grid_pos()
	first.len = 0
	var open = [first]
	var result = []
	var closed = []
	closed.append(hash(first.pos))
	
	while open.size():
		var current = open[0]
		open.pop_front()
		result.append(current.pos)
		for ix in [-1, 0, 1]:
			for iy in [-1, 0, 1]:
				if ix == 0 && iy == 0 || ix != 0 && iy != 0:
					continue
				if current.len >= unit.actions:
					continue
				var next = PathFindNode.new()
				next.len = current.len + 1
				next.pos = Vector2(current.pos.x + ix, current.pos.y + iy)
				if closed.find(hash(next.pos)) >= 0:
					continue
				if next.pos.x < 0 || next.pos.y < 0 || next.pos.x >= level.grid_size.x || next.pos.y >= level.grid_size.y:
					continue
				
				var tile_type = str(level.grid[next.pos.x][next.pos.y].path_type)
				if str(unit.unit_type) == "Tank" || str(unit.unit_type) == "Soldier":
					if tile_type == "Water":
						continue
				open.append(next)
				closed.append(hash(next.pos))
	return result

func draw_moves(moves):
	# populate all posible vertices
	var half_x = level.node_size.x * 0.5
	var half_y = level.node_size.y * 0.5
	var vertices = {}
	for move in moves:
		var move_verts = [ 
			Vector2(move.x * level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1)* level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1) * level.node_size.x, (move.y + 1) * level.node_size.y),
			Vector2(move.x * level.node_size.x, (move.y + 1) * level.node_size.y),
			Vector2((move.x + 0.5) * level.node_size.x, move.y * level.node_size.y),
			Vector2((move.x + 1)* level.node_size.x, (move.y + 0.5) * level.node_size.y),
			Vector2((move.x + 0.5) * level.node_size.x, (move.y + 1) * level.node_size.y),
			Vector2(move.x * level.node_size.x, (move.y + 0.5) * level.node_size.y)
		]
		for move_vert in move_verts:
			if vertices.has(move_vert):
				vertices[move_vert] += 1
			else:
				vertices[move_vert] = 1
		
	# erase inner corner and half-side vertices
	var erase = []
	for vert in vertices:
		if vertices[vert] > 3:
			erase.append(vert)
		elif vertices[vert] == 2:
			if int(vert.x) % int(level.node_size.x) != 0:
				erase.append(vert)
			elif int(vert.y) % int(level.node_size.y) != 0:
				erase.append(vert)
	for vert in erase:
		vertices.erase(vert)

	# order vertices
	var result = Vector2Array()
	var current
	var first
	var current_weight = 0
	for vert in vertices:
		if vertices[vert] > 1:
			current = vert
			break
	var i = 0
	while vertices.size() > 0:
		i += 1
		if i >= 1000:
			print("endless loop")
			break
		result.push_back(current)
		vertices.erase(current)
		for vert in vertices:
			var dx = abs(current.x - vert.x)
			var dy = abs(current.y - vert.y)
			if dx == 0 && dy == half_y || dy == 0 && dx == half_x:
				current = vert
				break
				
	set_polygon(result)
	update()
	


class PathFindNode:
	var len = 0
	var pos = Vector2(0, 0)

	

	
	

