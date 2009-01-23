source proc_force.do
do wave.do
run -all

run 110us

# SEEKFWD key
send_key "74"
# SEEKBKW key
#send_key "6B"

run 100us









# STOP key
#send_key 14

#run 100us

# PLAY key
#send_key 76

#run 600us
