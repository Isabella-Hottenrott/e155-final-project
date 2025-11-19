if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/ihottenrott/finalproject"
if {![file exists {C:/Users/ihottenrott/finalproject/top}]} {
  file mkdir {C:/Users/ihottenrott/finalproject/top}
}
cd {C:/Users/ihottenrott/finalproject/top}
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- finalproject_top.vm finalproject_top.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/ihottenrott/finalproject/top/finalproject_top_lattice.synproj" -logfile "finalproject_top_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o finalproject_top_syn.udb finalproject_top.vm] [list finalproject_top.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
