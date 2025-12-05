if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/ihottenrott/FINAL/FINAL"
if {![file exists {C:/Users/ihottenrott/FINAL/FINAL/impl_1}]} {
  file mkdir {C:/Users/ihottenrott/FINAL/FINAL/impl_1}
}
cd {C:/Users/ihottenrott/FINAL/FINAL/impl_1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- FINAL_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "FINAL_impl_1.cprj" "mess_writ.cprj" -a "iCE40UP"  -o FINAL_impl_1_cpe.ldc
# synthesize top design
file delete -force -- FINAL_impl_1.vm FINAL_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/ihottenrott/FINAL/FINAL/impl_1/FINAL_impl_1_lattice.synproj" -logfile "FINAL_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o FINAL_impl_1_syn.udb FINAL_impl_1.vm] [list FINAL_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
