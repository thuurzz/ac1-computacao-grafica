extends Spatial

var direction = Vector3.FORWARD
var angular_acelaration = 10
export var speed = 0
export var godot_rotation = true


#multiplica ponto 3D por uma matriz 3x3 e retorna o ponto transformado
#func transformPoint(Vector3 point, float[] matrix):
#		float[] pointCoord = { point.x, point.y, point.z };
#	float[] transformedCoord = new float[3];
#	for (int col = 0; col < 3; col++):
#		float soma = 0;
#		for (int lin = 0; lin < 3; lin++)
#			soma += pointCoord[lin] * matrix[lin, col];
#		transformedCoord[col] = soma;
#	return new Vector3(transformedCoord[0], transformedCoord[1], transformedCoord[2]);

func transformPoint(point, matrix):
	var pointCoord = [point.x, point.y, point.z]
	var transformedCoord = [0,0,0]
	for col in range(3):
		var soma = 0
		for lin in range(3):
			soma += pointCoord[lin] * matrix[lin][col]
		transformedCoord[col] = soma
	return Vector3(transformedCoord[0], transformedCoord[1], transformedCoord[2])

func zero_matrix(nX, nY):
	var matrix = []
	for x in range(nX):
		matrix.append([])
		for y in range(nY):
			matrix[x].append(0)
	return matrix




func multiply(a, b):
	var matrix = zero_matrix(a.size(), b[0].size())
	
	for i in range(a.size()):
		for j in range(b[0].size()):
			for k in range(a[0].size()):
				matrix[i][j] = matrix[i][j] + a[i][k] * b[k][j]
	return matrix


func rotateVertices(aX, aY, aZ):
	#define as matrizes de rotacao
	var rotationZ = Basis()
	rotationZ.x = Vector3(cos(aZ), sin(aZ),0)
	rotationZ.y = Vector3(-sin(aZ), cos(aZ),0 )
	rotationZ.z = Vector3( 0,0,1 )
	
	var rotationX = Basis()
	rotationZ.x = Vector3(1,0,0)
	rotationZ.y = Vector3(0, cos(aX),sin(aX) )
	rotationZ.z = Vector3( 0,-sin(aX),cos(aX) )
	
	
	var rotationY = Basis()
	rotationZ.x = Vector3(cos(aY), 0,-sin(aY))
	rotationZ.y = Vector3(0,1,0 )
	rotationZ.z = Vector3(sin(aY), 0,cos(aY))
	
	# multiplica as matrizes, obtendo a matriz de rotacao total
	var transformacao = rotationX * (rotationY * rotationZ)
	
	# multiplica as matrizes, obtendo a matriz de rotacao total
	var mdt = MeshDataTool.new()
	var mesh_hand = $malha_mao.get_mesh()
	mdt.create_from_surface(mesh_hand, 0)
	for vtx in range(mdt.get_vertex_count()):
		var vert= mdt.get_vertex(vtx)
		vert.x += vert.x * transformacao.x.x
		vert.y += vert.y * transformacao.y.y
		vert.z += vert.z * transformacao.z.z
		mdt.set_vertex(vtx, vert)
	mesh_hand.surface_remove(0)
	mdt.commit_to_surface(mesh_hand)
	var mi = MeshInstance.new()
	mi.mesh = mesh_hand
	add_child(mi)


func _physics_process(delta):
	print(direction)
	if Input.is_action_pressed("up") || Input.is_action_pressed("down") || Input.is_action_pressed("left") || Input.is_action_pressed("right"):
		speed = 0.5
		direction = Vector3(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			0,
			Input.get_action_strength("down") - Input.get_action_strength("up")
			).normalized()
	else:
		speed = 0
	if godot_rotation:
		$malha_mao.rotation.y = lerp($malha_mao.rotation.y, atan2(-direction.x, -direction.z), delta * angular_acelaration)
	else:
		rotateVertices(0, atan2(-direction.x, -direction.z), 0)
