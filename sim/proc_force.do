proc send_key { scan_code } {
  global now
  force -freeze /sim/key_empty 0             -cancel 30ns
  force -freeze /sim/key_data  16#$scan_code -cancel 60ns
  echo "$now ns SIM_FORCE: Sending 0x$scan_code key..."
  run 60ns
  noforce /sim/key_empty
  noforce /sim/key_data
}
