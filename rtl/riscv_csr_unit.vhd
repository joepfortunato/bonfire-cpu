----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:54:38 10/24/2016 
-- Design Name: 
-- Module Name:    riscv_control_unit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.csr_def.all;


entity riscv_control_unit is
    Port ( op1_i : in  STD_LOGIC_VECTOR (31 downto 0);
           wdata_o : out  STD_LOGIC_VECTOR (31 downto 0);
      
           we_o : out  STD_LOGIC;
           csr_exception : out STD_LOGIC;
           csr_adr : in  STD_LOGIC_VECTOR (11 downto 0);
           ce_i : in STD_LOGIC;
           busy_o : out STD_LOGIC;
           csr_x0_i : in STD_LOGIC; -- should be set when rs field is x0
           csr_op_i : in  STD_LOGIC_VECTOR (1 downto 0);
           -- external registers
           
           
           
           clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC);
end riscv_control_unit;

architecture Behavioral of riscv_control_unit is

signal csr_in, csr_out : STD_LOGIC_VECTOR (31 downto 0); -- Signals for CSR "ALU"
signal csr_offset : std_logic_vector(7 downto 0); -- lower 8 Bits of CSR address

signal busy : std_logic := '0';
signal we : std_logic :='0';
signal exception : std_logic :='0';


-- Local Control registers

signal mtvec : std_logic_vector(31 downto 2) := (others=>'0');
signal mscratch : std_logic_vector(31 downto 0) := (others=>'0');

begin

-- output wiring
we_o <= we;
busy_o<=busy;
csr_exception <= exception;


csr_offset <= csr_adr(7 downto 0);

--csr select mux
with csr_offset select 
   csr_in <= mtvec&"00" when tvec,
             mscratch   when scratch,
             
             (others=>'X') when others;
   

csr_alu: process(op1_i,csr_in,csr_op_i) 
begin
  case csr_op_i is 
    when "01" => csr_out<=op1_i; -- CSRRW
    when "10" => csr_out <= csr_in or op1_i; --CSRRS
    when "11" => csr_out <= csr_in and (not op1_i); -- CSRRC
    when others => csr_out <= (others => 'X');
  end case;     

end process;



process(clk_i) 
variable l_exception : std_logic;
begin
   
   if rising_edge(clk_i) then
     we <= ce_i; -- Pipeline control, latency one cycle
     
     if we='1' or rst_i='1' then
         busy<='0';
         exception  <= '0';
         mtvec <=  (others=>'0');
                
     elsif ce_i='1' then
       busy <= '1'; 
       l_exception:='0'; 
       
       if csr_adr(11 downto 8)=m_stdprefix then
         case csr_adr(7 downto 0) is
           when tvec =>             
              mtvec<=csr_out(31 downto 2);
           when scratch =>                        
              mscratch<=csr_out;   
           when others=> 
             l_exception:='1';            
         end case;         
       else 
         l_exception:='1'; 
       end if;
       if l_exception = '0'  then -- and csr_x0_i='0'
         wdata_o <= csr_in;
       else
         wdata_o <= (others => '0');       
       end if;  
       exception<=l_exception;       
     end if;    
   end if;
end process;



end Behavioral;
