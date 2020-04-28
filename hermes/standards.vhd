--
--! @file standards.vhd
--! @brief Constants and types generation for Hermes generic NoC with output buffers.
--! @author ?
--! @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
--! @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
--! @date 2020/04
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use work.constants.all;

package standards is
	--! Number of NoC nodes
	constant NODE_NO: integer := X_SIZE*Y_SIZE;
	
	--! Hermes node port number
	constant PORT_NO: integer := 5;

	--! Port range and default enumerations
	subtype port_t is integer range 0 to PORT_NO-1;
	constant EAST	: integer := 0;
	constant WEST	: integer := 1;
	constant NORTH : integer := 2;
	constant SOUTH : integer := 3;
	constant LOCAL : integer := 4;

	--! Fraction flit sizes
	constant HALF_FLIT : integer range 1 to 32 := (FLIT_SIZE/2);
	constant QUARTER_FLIT : integer range 1 to 16 := (FLIT_SIZE/4);

	--! Ringbuffer pointer size
	constant POINTER_SIZE : integer range 1 to 32 := integer(ceil(log2(real(BUFFER_SIZE))));
	
	--! Vector for number control
	subtype reg_port_no is std_logic_vector((PORT_NO-1) downto 0);

	--! Vector for node number control
	subtype reg_node_no is std_logic_vector((NODE_NO-1) downto 0);

	--! Vector for flit size register
	subtype reg_flit_size is std_logic_vector((FLIT_SIZE-1) downto 0);

	--! Vector for fration of flit sizes registers
	subtype reg_half_flit is std_logic_vector(((HALF_FLIT)-1) downto 0);
	subtype reg_quarter_flit is std_logic_vector((QUARTER_FLIT-1) downto 0);

	--! Pointer type for ringbuffer
	subtype pointer is std_logic_vector((POINTER_SIZE-1) downto 0);

	--! Ringbuffer storage type
	type buffer_t is array(0 to BUFFER_SIZE-1) of reg_flit_size;

	--! Data bus of flit size for the number of ports
	type port_no_reg_flit_size is array((PORT_NO-1) downto 0) of reg_flit_size;

	--! Data bus of flit size for the number of nodes
	type node_no_reg_flit_size is array((NODE_NO-1) downto 0) of reg_flit_size;

	--! Control array for all ports from all nodes
	type node_no_reg_port_no is array (NODE_NO-1 downto 0) of reg_port_no;

	--! Data bus for all ports from all nodes
	type node_no_port_no_reg_flit_size is array((NODE_NO-1) downto 0) of port_no_reg_flit_size;

	--! Router position
	constant SW: integer := 0;	--! South-West
	constant SC: integer := 1;	--! Center-South
	constant SE: integer := 2;	--! South-East
	constant CW: integer := 3;	--! Center-West
	constant CC: integer := 4;	--! Center
	constant CE: integer := 5; 	--! Center-East
	constant NW: integer := 6;	--! North-West
	constant NC: integer := 7;	--! Center-North
	constant NE: integer := 8;	--! North-East
	subtype position is integer range 0 to NE;
	
	function router_position(index: integer) return integer;
	function router_address(index: integer) return std_logic_vector;

end package;

package body standards is 
				
	--
	--! @brief Returns the router position in the mesh.
	--! @detail See position subtype
	--! @param index The index of the node.
	--! @return position The position enum in the mesh.
	function router_position(index: integer) return position is
		variable pos: position;
		variable line, column: integer;
	begin

		column := index mod X_SIZE;
		
		--! NORTH
		if index >= (NODE_NO)-X_SIZE then
			--! EAST
			if column = X_SIZE-1 then
				pos := NE;
			
			--! WEST
			elsif column = 0 then
				pos := NW;

			--! CENTER X
			else
				pos := NC;
			end if;

		--! SOUTH
		elsif index < X_SIZE then
			--! EAST
			if column = X_SIZE-1 then
				pos := SE;

			--! WEST
			elsif column = 0 then
				pos := SW;
			
			--! CENTER X
			else
				pos := SC;
			end if;
		
		--! CENTER Y
		else
			--! EAST
			if column = X_SIZE-1 then
				pos := CE; 

			--! WEST
			elsif column = 0 then
				pos := CW;

			--! CENTER X
			else
				pos := CC;
			end if;
		end if; 
		
		--report "POS "	& integer'image(pos) & "	" & integer'image(router)	& "	" &	integer'image(X_ROUTERS) & "	" & integer'image(Y_ROUTERS);
		
		return pos;
	end function;
	
	--
	--! @brief Get router address based on iterator index
	--! @param index Iterator index
	--! @return std_logic_vector Of address x & y
	--
	function router_address(index: integer) return std_logic_vector is
		variable x_pos, y_pos:	reg_quarter_flit; 
		variable address:		reg_half_flit;
		variable aux:			integer;
	begin 
		x_pos := conv_std_logic_vector((index mod X_SIZE), QUARTER_FLIT);
		y_pos := conv_std_logic_vector((index / X_SIZE), QUARTER_FLIT); 
			
		address := x_pos & y_pos;
		return address;
	end function;
							 
end package body;