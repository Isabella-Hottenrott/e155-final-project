if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/wchan/Documents/GitHub/e155-final-project/fpga/LatticeProject/finalproject"
if {![file exists {C:/Users/wchan/Documents/GitHub/e155-final-project/fpga/LatticeProject/finalproject/top}]} {
  file mkdir {C:/Users/wchan/Documents/GitHub/e155-final-project/fpga/LatticeProject/finalproject/top}
}
cd {C:/Users/wchan/Documents/GitHub/e155-final-project/fpga/LatticeProject/finalproject/top}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- finalproject_top_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "finalproject_top.cprj" "message_writer.cprj" -a "iCE40UP"  -o finalproject_top_cpe.ldc
# synthesize top design
file delete -force -- finalproject_top.vm finalproject_top.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/wchan/Documents/GitHub/e155-final-project/fpga/LatticeProject/finalproject/top/finalproject_top_lattice.synproj" -logfile "finalproject_top_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o finalproject_top_syn.udb finalproject_top.vm] [list finalproject_top.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
