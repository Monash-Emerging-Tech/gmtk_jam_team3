extends Node2D

@export var mazeTilemap: TileMap
@export var mazeHeight = 10
@export var mazeWidth = 10
var directions = ["up", "down", "left", "right"]
var mazeGrid = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(mazeHeight):
		var row = []
		for j in range(mazeWidth):
			if check_outside_circle(i, j):
				row.append(-1)
				continue
			row.append(0)
			mazeTilemap.set_cell(0, Vector2i(i, j), 0, Vector2i(0, 0))
		mazeGrid.append(row)
	traverseMaze(floor(mazeHeight/2), floor(mazeWidth/2))
	remove_dead_ends()

func check_outside_circle(x, y):
	return (pow(x - float(mazeHeight - 1)/2, 2)) + (pow(y - float(mazeWidth - 1)/2, 2)) > pow((mazeHeight)/2, 2)

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
	mazeTilemap.set_cell(0, Vector2i(y, x), 0, Vector2i(mazeGrid[x][y] % 4, floor(mazeGrid[x][y] / 4)))
	mazeTilemap.set_cell(0, Vector2i(ny, nx), 0, Vector2i(mazeGrid[nx][ny] % 4, floor(mazeGrid[nx][ny] / 4)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
