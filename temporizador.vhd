--------------------------------------------------------------------------------
-- Temporizador decimal do cronometro de xadrez
-- Author - Yasmin Cardozo Aguirre 23111329
--------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
library work;

entity temporizador is
    port( 
        clock, reset, load, en : in std_logic;
        init_time : in  std_logic_vector(7 downto 0);
        cont : out std_logic_vector(15 downto 0)
      );
end temporizador;

architecture a1 of temporizador is
    --sinais referentes as casas do contador
    signal segL, segH, minL, minH : std_logic_vector(3 downto 0);

    --sinais de enable
    signal en1, en2, en3, en4: std_logic;

    --sinais referentes aos auxiliares que serão utilizados na lógica dos enables
    signal signalSl, signalSh, signalMl, siganlMh: std_logic;

begin
    --atribuições dos sinais auxiliares de acordo com o valor das casas do cronometro
    signalSl <= '1' when segL = "0000" else '0';
    signalSh <= '1' when segH = "0000" else '0';
    signalMl <= '1' when minL = "0000" else '0';
    siganlMh <= '1' when minH = "0000" else '0';

    --atribuição dos sinais de enable de acordo com os valores dos sinais auxiliares
    en1 <= en and not(signalSl  and signalSh and signalMl and siganlMh);
    en2 <= en1 and signalSl; 
    en3 <= en2 and signalSh;
    en4 <= en3 and signalMl;

    --Instancia do SegL
    sL : entity work.dec_counter port map (clock => clock, reset => reset, load => load, en => en1, first_value => x"0", limit => x"9", cont => segL);

    --Instancia do SegH
    sH : entity work.dec_counter port map (clock => clock, reset => reset, load => load, en => en2, first_value => x"0", limit => x"5", cont => segH);

    --Instancia do MinL
    mL : entity work.dec_counter port map (clock => clock, reset => reset, load => load, en => en3, first_value => init_time(3 downto 0), limit => x"9", cont => minL);

    --Instancia do MinH
    mH : entity work.dec_counter port map (clock => clock, reset => reset, load => load, en => en4, first_value => init_time(7 downto 4), limit => x"9", cont => minH);

    --Concatenação das casas do cronometro
    cont <= minH & minL & segH & segL;
end a1;