library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package test_util is

    function hstr(slv: std_logic_vector) return string;
    function hstr(sl: std_logic) return character;
    procedure display_msg(str : string);
    procedure display_msg_notime(str : string);

end package test_util;

package body test_util is

    function hstr(sl : std_logic) return character is
        variable c : character;
    begin
        case sl is
            when 'U' => c := 'U';
            when 'X' => c := 'X';
            when '0' => c := '0';
            when '1' => c := '1';
            when 'Z' => c := 'Z';
            when 'W' => c := 'W';
            when 'L' => c := 'L';
            when 'H' => c := 'H';
            when '-' => c := '-';
            when others => null;
        end case;
        return c;
    end hstr;

    -- converts a std_logic_vector into a hex string.
    function hstr(slv: std_logic_vector) return string is
        variable hexlen: integer;
        variable longslv : std_logic_vector(67 downto 0) := (others => '0');
        variable hex : string(1 to 16);
        variable fourbit : std_logic_vector(3 downto 0);
    begin
        hexlen := (slv'left+1)/4;
        if (slv'left+1) mod 4 /= 0 then
            hexlen := hexlen + 1;
        end if;
        longslv(slv'left downto 0) := slv;
        for i in (hexlen -1) downto 0 loop
            fourbit := longslv(((i*4)+3) downto (i*4));
            case fourbit is
                when "0000" => hex(hexlen -I) := '0';
                when "0001" => hex(hexlen -I) := '1';
                when "0010" => hex(hexlen -I) := '2';
                when "0011" => hex(hexlen -I) := '3';
                when "0100" => hex(hexlen -I) := '4';
                when "0101" => hex(hexlen -I) := '5';
                when "0110" => hex(hexlen -I) := '6';
                when "0111" => hex(hexlen -I) := '7';
                when "1000" => hex(hexlen -I) := '8';
                when "1001" => hex(hexlen -I) := '9';
                when "1010" => hex(hexlen -I) := 'A';
                when "1011" => hex(hexlen -I) := 'B';
                when "1100" => hex(hexlen -I) := 'C';
                when "1101" => hex(hexlen -I) := 'D';
                when "1110" => hex(hexlen -I) := 'E';
                when "1111" => hex(hexlen -I) := 'F';
                when "ZZZZ" => hex(hexlen -I) := 'z';
                when "UUUU" => hex(hexlen -I) := 'u';
                when "XXXX" => hex(hexlen -I) := 'x';
                when others => hex(hexlen -I) := '?';
         end case;
       end loop;
       return hex(1 to hexlen);
    end hstr;

    procedure display_msg(str : string) is
        variable my_line : line;
    begin
        write(my_line, now);
        write(my_line, string'(": ") & str);
        writeline(output, my_line);
    end procedure;

    procedure display_msg_notime(str : string) is
        variable my_line : line;
    begin
        write(my_line, str);
        writeline(output, my_line);
    end procedure;

end package body test_util;
