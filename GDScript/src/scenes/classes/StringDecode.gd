extends Reference

class_name StringDecode



func GetAllNumbersFromString(var input : String) -> PoolIntArray:
	var output : PoolIntArray = []
	var reg : RegEx = RegEx.new()
	reg.compile('(\\d+)')
	var matches : Array = reg.search_all(input)
	for i in matches:
		output.push_back( int( i.get_string() ) )
	return output


func GetAllNumbersFollowedBySpecificString(var input : String, var letters : String) -> PoolIntArray:
	var output : PoolIntArray = []
	var reg : RegEx = RegEx.new()
	reg.compile('(\\d+)+[' + letters + "]")
	var matches : Array = reg.search_all(input)
	for i in matches:
		output.push_back( int( i.get_string() ) )
	return output
