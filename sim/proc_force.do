proc send_key { scan_code } {
  global now
  force -freeze /sim/key_empty 0             -cancel 30ns
  force -freeze /sim/key_data  16#$scan_code -cancel 60ns
  echo "$now ns SIM_FORCE: Sending 0x$scan_code key..."
  run 60ns
  noforce /sim/key_empty
  noforce /sim/key_data
}

proc play {} {
  send_key 76
  run 2600 ns
}

proc pause {} {
  send_key 11
  run 2600 ns
}

proc stop {} {
  send_key 14
  run 2600 ns
}

proc mute {} {
  send_key 66
  run 2600 ns
}

proc volinc {} {
  send_key 79
  run 2600 ns
}

proc voldec {} {
  send_key 7B
  run 2600 ns
}

proc listnext {} {
  send_key 72
  run 2600 ns
}

proc listprev {} {
  send_key 75
  run 2600 ns
}

proc startup {} {
  send_key 77
  run 2600 ns
}

proc fseek {} {
  send_key 74
  run 2600 ns
}

proc bseek {} {
  send_key 6B
  run 2600 ns
}

