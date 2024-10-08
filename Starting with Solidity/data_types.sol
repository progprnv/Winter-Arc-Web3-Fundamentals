
/// @title A contract for demonstrate Value types
///
/// @notice For now, this contract just show how Value types works in solidity
contract Types {

	// Initializing Bool variable
	bool public boolean = false;
	
	// Initializing Integer variable
	int32 public int_var = -60313;

	// Initializing String variable
	string public str = "PRog prnv";

	// Initializing Byte variable
	bytes1 public b = "a";


SOURCE: https://www.geeksforgeeks.org/solidity-types/
 
	// Defining an enumerator
	enum my_enum { geeks_, _for, _geeks }

	// Defining a function to return
	// values stored in an enumerator
	function Enum() public pure returns(
	my_enum) {
		return my_enum._geeks;
	}
}
