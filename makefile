a_out.vvp: ALU.v test_ALU.v
	iverilog -o "a_out.vvp" test_ALU.v ALU.v
	vvp a_out.vvp
