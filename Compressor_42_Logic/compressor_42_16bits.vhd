-- compressor_subtrator 4:2 (Todas as possibilidades)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HALF_ADDER is
port (A, B: in std_logic;
      Cout: out std_logic;
      S: out std_logic
      );
end HALF_ADDER;

architecture Behavioral of HALF_ADDER is

begin

S <= A XOR B;
Cout <= A AND B;

end Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FULL_ADDER IS
	PORT (CIN, A, B: IN STD_LOGIC;
		  COUT, S: OUT STD_LOGIC
	);
END FULL_ADDER;

ARCHITECTURE RCAcomportamento4m28b OF FULL_ADDER IS

SIGNAL fio1, fio2, fio3: STD_LOGIC;
BEGIN
	fio1 <= A XOR B; 
	S <= fio1 XOR CIN;
	fio2 <= A AND B; 
	fio3 <= fio1 AND CIN; 
	COUT <= fio3 OR fio2; 
END RCAcomportamento4m28b;

--============================================================
-- Multiplexador de 2:1 entradas de 1 bit
--============================================================
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

ENTITY mux_1bit IS
	PORT (a, b: IN STD_LOGIC;
		  mux_out: OUT STD_LOGIC;
		  sel: IN STD_LOGIC
		  );
END mux_1bit;

ARCHITECTURE comportamento OF mux_1bit IS
BEGIN
	
	WITH sel SELECT
	   
	   mux_out <=	a WHEN '0',
					b WHEN others;
					
END comportamento;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encoder is
port (A, B, C, D: in std_logic;
      S2, S1, S0: out std_logic
      );
end encoder;

architecture Behavioral of encoder is

SIGNAL i1, i2, i3, i4, i5, i6: STD_LOGIC;

begin
i1 <= A XOR B;
i2 <= C XOR D;
i3 <= A OR B;
i4 <= C OR D;
i5 <= B XOR i4;
i6 <= C NAND D;
S0 <= i1 XOR i2;
S1 <= i5 when (i1 = '0') else i6;
S2 <= i3 OR i4;
end Behavioral;

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE my_components1 IS

COMPONENT mux_1bit IS
	PORT (a, b: IN STD_LOGIC;
		  mux_out: OUT STD_LOGIC;
		  sel: IN STD_LOGIC
		  );
END COMPONENT;

COMPONENT HALF_ADDER is
port (A, B: in std_logic;
      Cout: out std_logic;
      S: out std_logic
      );
END COMPONENT;

COMPONENT FULL_ADDER IS
	PORT (CIN, A, B: IN STD_LOGIC;
		  COUT, S: OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT encoder is
port (A, B, C, D: in std_logic;
      S2, S1, S0: out std_logic
      );
END COMPONENT;

END my_components1;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.my_components1.all;

ENTITY somador3_2 IS
	PORT (A2, A1, A0, B1, B0: IN STD_LOGIC;
		  S2, S1, S0: OUT STD_LOGIC
	);
END somador3_2;

ARCHITECTURE RCAcomportamento4m28b OF somador3_2 IS

SIGNAL COUTa, COUTb: STD_LOGIC;

BEGIN
label_1: HALF_ADDER port map (A0, B0, COUTa, S0); 
label_2: FULL_ADDER port map (COUTa, A1, B1, COUTb, S1);
S2 <= COUTb XOR A2; 

END RCAcomportamento4m28b;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.my_components1.all;

ENTITY compressor_4entradas IS
PORT (A, B, C, D, Cin: IN STD_LOGIC;
	  Cout, Carry, Sum : OUT STD_LOGIC);

END compressor_4entradas;

ARCHITECTURE comportamento OF compressor_4entradas IS

SIGNAL  out_xor1, out_xor2, out_xor3, out_xor4 :  STD_LOGIC;
SIGNAL	out_mux1, out_mux2 : STD_LOGIC;

BEGIN

	out_xor1 <= A XOR B;

	out_xor2 <= C XOR D;

	out_xor3 <= out_xor1 XOR out_xor2;

	out_xor4 <= Cin XOR out_xor3;
				
  s0: mux_1bit
	  PORT MAP (a => A,
				b => C,
				mux_out => out_mux1,	
				sel => out_xor1);
			
  s1: mux_1bit
	  PORT MAP (a => D,
				b => Cin,
				mux_out => out_mux2,
				sel => out_xor3);
	
	  Sum <= out_xor4;
	  Carry <= out_mux2;
	  Cout <= out_mux1;
	 	
END comportamento;

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE my_components2 IS

COMPONENT compressor_4entradas IS
PORT (A, B, C, D, Cin: IN STD_LOGIC;
	  Cout, Carry, Sum : OUT STD_LOGIC);

END COMPONENT;

COMPONENT somador3_2 IS
	PORT (A2, A1, A0, B1, B0: IN STD_LOGIC;
		  S2, S1, S0: OUT STD_LOGIC
	);
END COMPONENT;

END my_components2;

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE work.my_components1.all;
USE work.my_components2.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY compressor_42_16bits IS
PORT (
	  A, B, C, D: IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
	  SOMA: OUT STD_LOGIC_VECTOR (17 DOWNTO 0)
	  );

END compressor_42_16bits;

ARCHITECTURE comportamento OF compressor_42_16bits IS

SIGNAL cout, carry: STD_LOGIC_VECTOR (14 downto 0); 
SIGNAL sum: STD_LOGIC_VECTOR (14 downto 1);
SIGNAL temp: STD_LOGIC_VECTOR (13 downto 0);
SIGNAL Sa2, Sa1, Sa0, sumTa, carryTa: STD_LOGIC;

BEGIN

comp42_num0: compressor_4entradas PORT MAP(A(0), B(0), C(0), D(0), '0', cout(0), carry(0), SOMA(0));			
comp42_num1: compressor_4entradas PORT MAP(A(1), B(1), C(1), D(1), cout(0), cout(1), carry(1), sum(1));
comp42_num2: compressor_4entradas PORT MAP(A(2), B(2), C(2), D(2), cout(1), cout(2), carry(2), sum(2));
comp42_num3: compressor_4entradas PORT MAP(A(3), B(3), C(3), D(3), cout(2), cout(3), carry(3), sum(3));
comp42_num4: compressor_4entradas PORT MAP(A(4), B(4), C(4), D(4), cout(3), cout(4), carry(4), sum(4));
comp42_num5: compressor_4entradas PORT MAP(A(5), B(5), C(5), D(5), cout(4), cout(5), carry(5), sum(5));
comp42_num6: compressor_4entradas PORT MAP(A(6), B(6), C(6), D(6), cout(5), cout(6), carry(6), sum(6));
comp42_num7: compressor_4entradas PORT MAP(A(7), B(7), C(7), D(7), cout(6), cout(7), carry(7), sum(7));
comp42_num8: compressor_4entradas PORT MAP(A(8), B(8), C(8), D(8), cout(7), cout(8), carry(8), sum(8));
comp42_num9: compressor_4entradas PORT MAP(A(9), B(9), C(9), D(9), cout(8), cout(9), carry(9), sum(9));
comp42_num10: compressor_4entradas PORT MAP(A(10), B(10), C(10), D(10), cout(9), cout(10), carry(10), sum(10));
comp42_num11: compressor_4entradas PORT MAP(A(11), B(11), C(11), D(11), cout(10), cout(11), carry(11), sum(11));
comp42_num12: compressor_4entradas PORT MAP(A(12), B(12), C(12), D(12), cout(11), cout(12), carry(12), sum(12));
comp42_num13: compressor_4entradas PORT MAP(A(13), B(13), C(13), D(13), cout(12), cout(13), carry(13), sum(13));
comp42_num14: compressor_4entradas PORT MAP(A(14), B(14), C(14), D(14), cout(13), cout(14), carry(14), sum(14));
			
var0: HALF_ADDER PORT MAP(carry(0), sum(1), temp(0), SOMA(1));
var1: FULL_ADDER PORT MAP(temp(0), carry(1), sum(2), temp(1), SOMA(2));
var2: FULL_ADDER PORT MAP(temp(1), carry(2), sum(3), temp(2), SOMA(3));
var3: FULL_ADDER PORT MAP(temp(2), carry(3), sum(4), temp(3), SOMA(4));
var4: FULL_ADDER PORT MAP(temp(3), carry(4), sum(5), temp(4), SOMA(5));
var5: FULL_ADDER PORT MAP(temp(4), carry(5), sum(6), temp(5), SOMA(6));
var6: FULL_ADDER PORT MAP(temp(5), carry(6), sum(7), temp(6), SOMA(7));
var7: FULL_ADDER PORT MAP(temp(6), carry(7), sum(8), temp(7), SOMA(8));
var8: FULL_ADDER PORT MAP(temp(7), carry(8), sum(9), temp(8), SOMA(9));
var9: FULL_ADDER PORT MAP(temp(8), carry(9), sum(10), temp(9), SOMA(10));
var10: FULL_ADDER PORT MAP(temp(9), carry(10), sum(11), temp(10), SOMA(11));
var11: FULL_ADDER PORT MAP(temp(10), carry(11), sum(12), temp(11), SOMA(12));
var12: FULL_ADDER PORT MAP(temp(11), carry(12), sum(13), temp(12), SOMA(13));
var13: FULL_ADDER PORT MAP(temp(12), carry(13), sum(14), temp(13), SOMA(14));

var14: encoder port map (A(15), B(15), C(15), D(15), Sa2, Sa1, Sa0);
var15: FULL_ADDER PORT MAP(cout(14), temp(13), carry(14), carryTa, sumTa);
var16: somador3_2 PORT MAP(Sa2, Sa1, Sa0, carryTa, sumTa, SOMA(17), SOMA(16), SOMA(15));

END comportamento;