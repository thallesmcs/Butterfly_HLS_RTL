library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level_compressor_42_16bits is
    port (
        clk    : in  std_logic;
        ap_rst : in  std_logic;
        A      : in  std_logic_vector(15 downto 0);
        B      : in  std_logic_vector(15 downto 0);
        C      : in  std_logic_vector(15 downto 0);
        D      : in  std_logic_vector(15 downto 0);
        SOMA   : out std_logic_vector(17 downto 0)
    );
end entity;

architecture Behavioral of top_level_compressor_42_16bits is

    component compressor_42_16bits is
        port (
            A    : in  std_logic_vector(15 downto 0);
            B    : in  std_logic_vector(15 downto 0);
            C    : in  std_logic_vector(15 downto 0);
            D    : in  std_logic_vector(15 downto 0);
            SOMA : out std_logic_vector(17 downto 0)
        );
    end component;

    component FF_D16 is
        port (
            clk   : in  std_logic;
            rst_n : in  std_logic;
            d     : in  std_logic_vector(15 downto 0);
            q     : out std_logic_vector(15 downto 0)
        );
    end component;

    component FF_D18 is
        port (
            clk   : in  std_logic;
            rst_n : in  std_logic;
            d     : in  std_logic_vector(17 downto 0);
            q     : out std_logic_vector(17 downto 0)
        );
    end component;

    signal rst_n    : std_logic;
    signal a_reg    : std_logic_vector(15 downto 0);
    signal b_reg    : std_logic_vector(15 downto 0);
    signal c_reg    : std_logic_vector(15 downto 0);
    signal d_reg    : std_logic_vector(15 downto 0);
    signal soma_raw : std_logic_vector(17 downto 0);
    signal soma_reg : std_logic_vector(17 downto 0);

begin

    rst_n <= not ap_rst;

    ff_a : FF_D16
        port map (clk => clk, rst_n => rst_n, d => A, q => a_reg);

    ff_b : FF_D16
        port map (clk => clk, rst_n => rst_n, d => B, q => b_reg);

    ff_c : FF_D16
        port map (clk => clk, rst_n => rst_n, d => C, q => c_reg);

    ff_d : FF_D16
        port map (clk => clk, rst_n => rst_n, d => D, q => d_reg);

    u_compressor : compressor_42_16bits
        port map (
            A    => a_reg,
            B    => b_reg,
            C    => c_reg,
            D    => d_reg,
            SOMA => soma_raw
        );

    ff_soma : FF_D18
        port map (clk => clk, rst_n => rst_n, d => soma_raw, q => soma_reg);

    SOMA <= soma_reg;

end Behavioral;
