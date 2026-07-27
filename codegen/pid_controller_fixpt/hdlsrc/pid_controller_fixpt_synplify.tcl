project -new pid_controller_fixpt.prj
add_file pid_controller_fixpt.v
set_option -technology VIRTEX4
set_option -part XC4VSX35
set_option -synthesis_onoff_pragma 0
set_option -frequency auto
project -run synthesis
