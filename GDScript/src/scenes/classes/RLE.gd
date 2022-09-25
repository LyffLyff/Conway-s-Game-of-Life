extends Node

#RLE -> Run Length Encoded
#A format commonly used for storing patterns efficiently

#Header
# a Hashtag signifies a line of the header, followed by a Letter and the corresponding text
#C,c = Comment
#N   = Name of pattern
#O   = Created by whom and when
#P,R = Coordinates of top left corner of the pattern -> 90 100
#R is usually negative since it's made that the pattern is centered in origin

#rules: https://en.wikipedia.org/wiki/Life-like_cellular_automaton#A_selection_of_Life-like_rules
#x,y -> height and width of pattern
#B3/S23 = Conway's Game of Life
#Last line of header:
#x = m, y = n, rule = B3/S23


#Main Data:
#b = dead cell
#o = alive cell
#$ = End of Line
#Number before symbol signiefies the amount of consecutive symbols of this type
# -> 24b = 24 consecutive dead cells 
#Each file ends with a !, marking the end of the file


func Encode() -> void:
	pass


#Returns Array including:
#Idx: 0 = Pattern Name [String]
#1 = all Comments [PoolStringArray]
#2 = Creator/Creation date [String]
#3 = Pattern Top Left Coords [Vector2]
#4 = Height and Width of pattern [Vector2]
#5 = All Alive Cells [PoolVector2Array]
func Decode(var filepath : String) -> Array:
	var decoded_file : Array = ["",PoolStringArray(),"",Vector2(),Vector2(),PoolVector2Array()]
	var file : File = File.new()
	var line : String = ""
	
	if file.open(filepath,File.READ) != OK:
		return []
	
	while !file.eof_reached():
		line = file.get_line()
		match line[0]:
			"#":
				#Header Comments
				match line[1]:
					"C","c":
						decoded_file[1].push_back( line.substr( 3, -1 ) )
					"N":
						decoded_file[0] = line
					"O":
						decoded_file[2] = line
					"P","R":
						var last_digit : int = 0
						var s : int
						var e : int
						var coords : PoolIntArray = []
						for i in 2:
							s = line.find(" ",last_digit)
							e = line.find(" ",s + 1)
							last_digit = e
							coords.push_back( int(line.substr(s, e - s)) )
						decoded_file[3] = Vector2(coords[0],coords[1])
			"x":
				#Last Header Line
				pass
			_:
				#Data Line
				decoded_file[5].append_array()
	
	return decoded_file
