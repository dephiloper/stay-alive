extends Node

func prim(coords: Array) -> PoolIntArray:
	var tree: Array = []
	var reached: Array = []
	var unreached := coords.duplicate(true)
	var rId := 0
	var uId := 0
	
	reached.append(unreached[0])
	unreached.remove(0)

	while len(unreached) > 0:
		var minDist := 1000000000.0
		for i in range(len(reached)):
			for j in range(len(unreached)):
				var dist := (reached[i] as Vector2).distance_squared_to(unreached[j] as Vector2)
				if dist < minDist:
					minDist = dist
					rId = i
					uId = j
			
		tree.append(reached[rId])
		tree.append(unreached[uId])
		reached.append(unreached[uId])
		unreached.remove(uId)
			
	var indices: PoolIntArray
	
	# kind of hacky.. the whole algorithms should work with indices only..
	# TODO fix this
	for node in tree:
		indices.append(coords.find(node))
	
	return indices
	
func roundm(n: float, m: int) -> float:
	return round(n / m) * m
	
func roundv(v: Vector2, m: int) -> Vector2:
	return Vector2(roundm(v.x, m), roundm(v.y, m))
