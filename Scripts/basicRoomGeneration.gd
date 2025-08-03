extends Node2D

@export var mazeTilemap: TileMapLayer
@export var mazeHeight = 10
@export var mazeWidth = 10
var directions = ["up", "down", "left", "right"]
var mazeGrid = []

# Called when the node enters the scene tree for the first time.
# TODO: For some reason this straight up does not work if mazeHeight != mazeWidth
func _ready():
	for i in range(mazeHeight):
		var row = []
		for j in range(mazeWidth):
			if check_outside_ellipse(i, j):
				row.append(-1)
				continue
			row.append(0)
			mazeTilemap.set_cell(Vector2i(i, j), 0, Vector2i(0, 0))
		mazeGrid.append(row)
	traverseMaze(floor(mazeHeight/2), floor(mazeWidth/2))
	remove_dead_ends()
	
	var radius = 10
	for i in range(mazeHeight):
		var row = []
		for j in range(mazeWidth):
			if (pow(i - float(mazeWidth)/2, 2)/ pow(float(radius), 2)) \
			 + (pow(j - float(mazeHeight)/2, 2)/ pow(float(radius), 2)) < 1 \
			and (pow(i - float(mazeWidth)/2, 2)/ pow(float(radius - 1), 2)) \
			 + (pow(j - float(mazeHeight)/2, 2)/ pow(float(radius - 1), 2)) >= 1:
				createCircle_aux(i, j, radius)

# Checks if index is outside of ellipse, if so make sure it is flagged as -1
func check_outside_ellipse(x, y):
	return (pow(x - float(mazeWidth)/2, 2)/ pow(float(mazeWidth)/2, 2)) \
	 + (pow(y - float(mazeHeight)/2, 2)/ pow(float(mazeHeight)/2, 2)) >= 1

# Reverse Backtracking algorithm to create paths in maze
func traverseMaze(x, y):
	directions.shuffle()
	for direc in directions:
		var nx = x
		var ny = y
		match direc:
			"up" : nx -= 1
			"down" : nx += 1
			"left" : ny -= 1
			"right" : ny += 1
		if 0 <= nx and nx < mazeHeight and 0 <= ny and ny < mazeWidth:
			if mazeGrid[nx][ny] != 0:
				continue
			create_path(x, y, nx, ny, direc)
			traverseMaze(nx, ny)

func createCircle_aux(x, y, radius):
	directions.shuffle()
	for direc in directions:
		var nx = x
		var ny = y
		match direc:
			"up" : nx -= 1
			"down" : nx += 1
			"left" : ny -= 1
			"right" : ny += 1
		if 0 <= nx and nx < mazeHeight and 0 <= ny and ny < mazeWidth:
			create_path(x, y, nx, ny, direc)

# Function to remove tiles that have dead ends, I swear this works like half of the time
func remove_dead_ends():
	for i in range(mazeHeight):
		for j in range(mazeWidth):
			if mazeGrid[i][j] not in [0, 1, 2, 4, 8]:
				continue
			directions.shuffle()
			for direc in directions:
				var nx = i
				var ny = j
				match direc:
					"up" : nx -= 1
					"down" : nx += 1
					"left" : ny -= 1
					"right" : ny += 1
				if 0 <= nx and nx < mazeHeight and 0 <= ny and ny < mazeWidth:
					if mazeGrid[nx][ny] == -1:
						continue
					if direc == 'up' and mazeGrid[nx][ny] & 4:
						continue
					if direc == 'down' and mazeGrid[nx][ny] & 1:
						continue
					if direc == 'left' and mazeGrid[nx][ny] & 2:
						continue
					if direc == 'right' and mazeGrid[nx][ny] & 8:
						continue
					create_path(i, j, nx, ny, direc)
					break

func create_path(x, y, nx, ny, direc):
	match direc:
		"up" :
			mazeGrid[x][y] |=  1
			mazeGrid[nx][ny] |=  4
		"down" :
			mazeGrid[x][y] |=  4
			mazeGrid[nx][ny] |=  1
		"left" :
			mazeGrid[x][y] |=  8
			mazeGrid[nx][ny] |=  2
		"right" :
			mazeGrid[x][y] |=  2
			mazeGrid[nx][ny] |=  8
	mazeTilemap.set_cell(Vector2i(y, x), 0, Vector2i(mazeGrid[x][y] % 4, floor(mazeGrid[x][y] / 4)))
	mazeTilemap.set_cell(Vector2i(ny, nx), 0, Vector2i(mazeGrid[nx][ny] % 4, floor(mazeGrid[nx][ny] / 4)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
