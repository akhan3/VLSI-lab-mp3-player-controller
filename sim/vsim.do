do wave.do
run -all

# run 110us
#
# # Send STOP key
# force -freeze sim:/playcontrol_tb/key_empty   0       -cancel 30ns
# force -freeze sim:/playcontrol_tb/key_data    16#14   -cancel 100ns
# run 10us
#
# # Send PLAY key
# force -freeze sim:/playcontrol_tb/key_empty   0       -cancel 30ns
# force -freeze sim:/playcontrol_tb/key_data    16#76   -cancel 100ns
# run 10us
