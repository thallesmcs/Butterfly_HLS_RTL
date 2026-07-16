library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity borboleta is
generic ( WIDTH: integer := 16 );
port(
    Ar, Ai, Br, Bi, Wr, Wi : in  std_logic_vector(WIDTH-1 downto 0);
    Cr, Ci, Dr, Di         : out std_logic_vector(WIDTH-1 downto 0)
);
end entity;

architecture radix2 of borboleta is

component compressor_42_16bits is
port (
    A, B, C, D : in  std_logic_vector(15 downto 0);
    SOMA       : out std_logic_vector(17 downto 0)
);
end component;

constant MUL_W : integer := 2*WIDTH;

signal m1, m2, m3, m4 : signed(MUL_W-1 downto 0);

signal op1, op2, op3, op4 : std_logic_vector(MUL_W-1 downto 0);

signal t_op1, t_op2, t_op3, t_op4 : std_logic_vector(WIDTH-1 downto 0);

signal nt_op1, nt_op2, nt_op3, nt_op4 : std_logic_vector(WIDTH-1 downto 0);

signal cr_temp, dr_temp, ci_temp, di_temp : std_logic_vector(17 downto 0);

begin

-- ============================================================
-- Multiplicações complexas
-- ============================================================
-- m1 = Br * Wr
-- m2 = Bi * Wi
-- m3 = Br * Wi
-- m4 = Bi * Wr

m1 <= signed(Br) * signed(Wr);
m2 <= signed(Bi) * signed(Wi);
m3 <= signed(Br) * signed(Wi);
m4 <= signed(Bi) * signed(Wr);

op1 <= std_logic_vector(m1);
op2 <= std_logic_vector(m2);
op3 <= std_logic_vector(m3);
op4 <= std_logic_vector(m4);

-- ============================================================
-- Truncamento / realinhamento para WIDTH bits
-- bit de sinal: MUL_W-1
-- bits úteis  : MUL_W-4 downto 14
--
-- Para WIDTH = 16 e MUL_W = 32:
-- sinal = bit 31
-- dados = bits 28 downto 14
-- ============================================================

t_op1 <= op1(MUL_W-1) & op1(MUL_W-4 downto 14); -- Br*Wr
t_op2 <= op2(MUL_W-1) & op2(MUL_W-4 downto 14); -- Bi*Wi
t_op3 <= op3(MUL_W-1) & op3(MUL_W-4 downto 14); -- Br*Wi
t_op4 <= op4(MUL_W-1) & op4(MUL_W-4 downto 14); -- Bi*Wr

-- ============================================================
-- Versões negativas dos termos truncados
-- ============================================================

nt_op1 <= std_logic_vector(-signed(t_op1)); -- -Br*Wr
nt_op2 <= std_logic_vector(-signed(t_op2)); -- -Bi*Wi
nt_op3 <= std_logic_vector(-signed(t_op3)); -- -Br*Wi
nt_op4 <= std_logic_vector(-signed(t_op4)); -- -Bi*Wr

-- ============================================================
-- Estágios usando compressor 4:2
-- ============================================================
-- Tr = Br*Wr - Bi*Wi = t_op1 - t_op2
-- Ti = Br*Wi + Bi*Wr = t_op3 + t_op4
--
-- Cr = Ar + Tr = Ar + t_op1 - t_op2
-- Dr = Ar - Tr = Ar - t_op1 + t_op2
-- Ci = Ai + Ti = Ai + t_op3 + t_op4
-- Di = Ai - Ti = Ai - t_op3 - t_op4
-- ============================================================

estagio1_Cr : compressor_42_16bits
port map (
    A    => Ar,
    B    => t_op1,
    C    => nt_op2,
    D    => (others => '0'),
    SOMA => cr_temp
);

estagio2_Dr : compressor_42_16bits
port map (
    A    => Ar,
    B    => nt_op1,
    C    => t_op2,
    D    => (others => '0'),
    SOMA => dr_temp
);

estagio3_Ci : compressor_42_16bits
port map (
    A    => Ai,
    B    => t_op3,
    C    => t_op4,
    D    => (others => '0'),
    SOMA => ci_temp
);

estagio4_Di : compressor_42_16bits
port map (
    A    => Ai,
    B    => nt_op3,
    C    => nt_op4,
    D    => (others => '0'),
    SOMA => di_temp
);

-- ============================================================
-- Redução de 18 bits para 16 bits
-- ============================================================

Cr <= cr_temp(17) & cr_temp(WIDTH-2 downto 0);
Ci <= ci_temp(17) & ci_temp(WIDTH-2 downto 0);
Dr <= dr_temp(17) & dr_temp(WIDTH-2 downto 0);
Di <= di_temp(17) & di_temp(WIDTH-2 downto 0);

end architecture;