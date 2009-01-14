library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.system_constants_pkg.all;

entity monitor_fsm is
  port(
    clk         : in  std_logic;
    reset       : in  std_logic;

    play_en     : in  std_logic;

    dbuf_afull  : in  std_logic;
    sbuf_full   : in  std_logic;
    sbuf_empty  : in  std_logic;
    dec_status  : in  std_logic;
    dbuf_wdata  : out std_logic_vector(31 downto 0);
    dbuf_wr     : out std_logic;

    fio_buso        : in  std_logic_vector(31 downto 0);
    fio_busov       : in  std_logic;
    fio_busy        : in  std_logic;
    fio_gnt         : in  std_logic;
    fio_req         : out std_logic;
    fio_busi        : out std_logic_vector(7 downto 0);
    fio_busiv       : out std_logic;
    fio_ctrl        : out std_logic;

    file_size_byte : in  std_logic_vector(31 downto 0);
    file_finished   : out std_logic
  );
end entity;

architecture arch of monitor_fsm is
  type state_type is (IDLE, FETCH);
  signal state, next_state: state_type;
  signal dword_cnt  : std_logic_vector(31 downto 0);
  signal file_size_dword : std_logic_vector(31 downto 0);
  signal fetch_num_dword_32bit : std_logic_vector(31 downto 0);
  signal fetch_num_dword    : std_logic_vector(7 downto 0);
  signal fetch_en     : std_logic;
  signal fetch_en_r   : std_logic;
  signal fetch_start  : std_logic;
  signal fetch_ring   : std_logic_vector(2 downto 0);

begin

  fetch_start <= fetch_en and not fetch_en_r;   -- rising edge one shot
--   fetch_start <= fetch_en and fetch_ring = "000";   -- rising edge one shot
  fetch_en <= play_en and not dbuf_afull;
  process (clk, reset) begin
    if (reset = reset_state) then
      fetch_en_r <= '0';
    elsif (clk'event and clk = clk_polarity) then
      fetch_en_r <= fetch_en;
    end if;
  end process;

  process (clk, reset) begin
    if (reset = reset_state) then
      fetch_ring <= "000";
    elsif (clk'event and clk = clk_polarity) then
      if (fetch_start = '1') then
        fetch_ring <= fetch_ring(1 downto 0) & '1';
      elsif (not (fio_gnt = '1' and fio_busy = '0')) then -- wait until bus becomes available
        fetch_ring <= fetch_ring;
      else
        fetch_ring <= fetch_ring(1 downto 0) & fetch_start;
      end if;
    end if;
  end process;

  fio_req <= fetch_ring(0) or fetch_ring(1) or fetch_ring(2);
  fio_busiv <= '1' when ((fio_gnt = '1' and fio_busy = '0') and (fetch_ring(1)='1' or fetch_ring(2)='1')) else '0';
  fio_ctrl <= '1' when (fetch_ring(2)='1') else '0';
  fio_busi <= fetch_num_dword when (fetch_ring(1)='1') else FIO_READ;




  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= IDLE;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  next_state_comb_logic: process (state, play_en, fio_gnt, fio_busy)
  begin
    case state is
      when IDLE =>
        if (play_en = '1' and dbuf_afull = '0') then
          next_state <= FETCH;
        else
          next_state <= IDLE;
        end if;
      when FETCH =>
        if (play_en = '0') then
          next_state <= IDLE;
        else
          next_state <= FETCH;
        end if;
      when others =>
          next_state <= IDLE;
    end case;
  end process;

-- File D-Words counter
  file_size_dword <= "00" & file_size_byte(31 downto 2);
  fetch_num_dword_32bit <= (file_size_dword - dword_cnt - 1) when ((file_size_dword - dword_cnt) < 256) else
                           x"000000FF";
  fetch_num_dword <= fetch_num_dword_32bit(7 downto 0);

  process (clk, reset)
  begin
    if (reset = reset_state) then
      dword_cnt <= x"00000000";
    elsif (clk'event and clk = clk_polarity) then
      if (fetch_start = '1') then
        if ((file_size_dword - dword_cnt) < 256) then
          dword_cnt <= file_size_dword;
        else
          dword_cnt <= dword_cnt + 256;
        end if;
      end if;
    end if;
  end process;



end architecture;
