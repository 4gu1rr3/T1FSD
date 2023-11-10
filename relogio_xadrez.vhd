--------------------------------------------------------------------------------
-- Relogio de xadrez
-- Author - Yasmin Cardozo Aguirre 23111329
--------------------------------------------------------------------------------
library IEEE;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;

entity relogio_xadrez is
    port(clock, reset, load, j1, j2 : in std_logic;
        init_time : in std_logic_vector(7 downto 0);
        winJ1 : out std_logic;
        winJ2 : out std_logic;
        contj1 : out std_logic_vector(15 downto 0);
        contj2 : out std_logic_vector(15 downto 0)
    );
end relogio_xadrez;

architecture relogio_xadrez of relogio_xadrez is
    -- Estados da FSM
    type states is (INIT, LOADING, DEC1, DEC2, GAN1, GAN2);

    -- Sinais que armazenam o estado atual(EA) e o próximo(PE)
    signal EA, PE : states;

    -- Sinais de enable para os contadores;
    signal en1, en2: std_logic;

    -- Sinais que armazeam os valores do contador1 e do contador2
    signal cont1, cont2: std_logic_vector(15 downto 0);
    
begin
    -- Instancia o contador1
    contador1 : entity work.temporizador port map (clock => clock, reset => reset, load => load, en => en1, init_time => init_time, cont => cont1);

    -- Instancia o contador2
    contador2 : entity work.temporizador port map (clock => clock, reset => reset, load => load, en => en2, init_time => init_time, cont => cont2);

    -- Processo de atribuição do estado atual
    process (clock, reset)
    begin
        if reset = '1' then
            EA <= INIT;
        elsif rising_edge(clock) then
            EA <= PE;
        end if; 
    end process;

    -- Processo de troca de estados da FSM
    process (EA, load, j1, j2, cont1, cont2)
    begin
        case EA is 
            -- Estado de reset
            when INIT =>
                if load = '1' then
                    PE <= LOADING;
                elsif load = '0' then
                    PE <= INIT;
                end if;

            -- Estado de load, aguardando início do jogo
            when LOADING =>
                if j1 = '1' then
                    PE <= DEC1;
                elsif j1 = '0' then
                    PE <= LOADING;
                end if;

            -- Estado que decrementa o contador1
            when DEC1 =>
                if j1 = '1' then
                    PE <= DEC2;
                elsif cont1 = "0000000000000000" then
                    PE <= GAN2;
                elsif j1 = '0' then    
                    PE <= DEC1;
                end if;

            -- Estado que decrementa o contador2
            when DEC2 =>
                if j2 = '1' then
                    PE <= DEC1;
                elsif cont2 = "0000000000000000" then
                    PE <= GAN1;
                elsif j2 = '0' then 
                    PE <= DEC2;
                end if;

            -- Estado final jogador1 é o ganhador
            when GAN1 =>
                PE <= INIT;

            -- Estado final jogador2 é o ganhador   
            when GAN2 =>
                PE <= INIT;
        end case;
    end process;

    -- atribuições de acordo com os estados
    winJ1 <= '1' when EA = GAN1 else '0';
    winJ2 <= '1' when EA = GAN2 else '0';
    en1 <= '1' when EA = DEC1 else '0';
    en2 <= '1' when EA = DEC2 else '0';
    contj1 <= "0000000000000000" when EA = INIT else cont1;
    contj2 <= "0000000000000000" when EA = INIT else cont2;
end relogio_xadrez;