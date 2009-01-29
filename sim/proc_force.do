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
  run 5 us
}

proc pause {} {
  send_key 11
  run 5 us
}

proc stop {} {
  send_key 14
  run 5 us
}

proc mute {} {
  send_key 66
  run 5 us
}

proc volinc {} {
  send_key 79
  run 5 us
}

proc voldec {} {
  send_key 7B
  run 5 us
}

proc listnext {} {
  send_key 72
  run 5 us
}

proc listprev {} {
  send_key 75
  run 5 us
}

proc startup {} {
  send_key 5A
  run 5 us
}

proc scrollsw {} {
  send_key 77
  run 5 us
}

proc scrollfast {} {
  send_key 69
  run 5 us
}

proc scrollslow {} {
  send_key 6C
  run 5 us
}

proc fseek {} {
  send_key 74
  run 5 us
}

proc bseek {} {
  send_key 6B
  run 5 us
}

proc voldown {delta} {
  for {set i 1} {$i <= $delta} {incr i} {
    voldec
  }
}

proc volup {delta} {
  for {set i 1} {$i <= $delta} {incr i} {
    volinc
  }
}
