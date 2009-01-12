library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity list_ctrl is
  port(
    clk         : in  std_logic;
    reset       : in  std_logic;
    listnext    : in  std_logic;
    listprev    : in  std_logic;
    file_info_ready  : in  std_logic;
    fio_busy        : in  std_logic;
    fio_gnt         : in  std_logic;
    fio_req         : out std_logic;
    fio_busi        : out std_logic_vector(7 downto 0);
    fio_busiv       : out std_logic;
    fio_ctrl        : out std_logic;
    file_info_start  : out std_logic
  );
end entity;

architecture arch of list_ctrl is
  type state_type is (IDLE, WRDY, WINFO);
  signal state, next_state: state_type;
  signal fio_busi_le : std_logic;
begin

  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= IDLE;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  next_state_comb_logic: process (state, listnext, listprev, fio_gnt, fio_busy, file_info_ready)
  begin
    case state is
      when IDLE =>
        if (listnext = '1' or listprev = '1') then
          next_state <= WRDY;
        else
          next_state <= IDLE;
        end if;
      when WRDY =>
        if (fio_gnt = '1' and fio_busy = '0') then
          next_state <= WINFO;
        else
          next_state <= WRDY;
        end if;
      when WINFO =>
        if (file_info_ready = '1') then
          next_state <= IDLE;
        else
          next_state <= WINFO;
        end if;
      when others =>
          next_state <= IDLE;
    end case;
  end process;

  output_comb_logic: process (state, listnext, listprev, fio_gnt, fio_busy, file_info_ready)
  begin
    fio_req <= '0';
    fio_busi_le <= '0';
    fio_busiv <= '0';
    fio_ctrl <= '0';
    file_info_start <= '0';
    case state is
      when IDLE =>
        if (listnext = '1' or listprev = '1') then
          fio_busi_le <= '1';
          fio_req <= '1';
        end if;
      when WRDY =>
        fio_req <= '1';
        if (fio_gnt = '1' and fio_busy = '0') then
          fio_busiv <= '1';
          fio_ctrl <= '1';
          file_info_start <= '1';
        end if;
      when WINFO =>
        if (file_info_ready = '1') then
        else
          fio_req <= '1';
        end if;
    end case;
  end process;

  busi_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_busi <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (fio_busi_le = '1') then
        if (listnext = '1') then
          fio_busi <= FIO_FILENEXT;
        elsif (listprev = '1') then
          fio_busi <= FIO_FILEPREV;
        end if;
      end if;
    end if;
  end process;

end architecture;
