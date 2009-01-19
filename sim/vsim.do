source proc_force.do
do wave.do

run 110us

# STOP key
send_key 14

run 100us

# PLAY key
send_key 76

run 600us
