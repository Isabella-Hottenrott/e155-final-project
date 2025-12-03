if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/wchan/Documents/GitHub/e155-final-project/lcd_driver_test"
if {![file exists {C:/Users/wchan/Documents/GitHub/e155-final-project/lcd_driver_test/impl_1}]} {
  file mkdir {C:/Users/wchan/Documents/GitHub/e155-final-project/lcd_driver_test/impl_1}
}
cd {C:/Users/wchan/Documents/GitHub/e155-final-project/lcd_driver_test/impl_1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- lcd_driver_test_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "lcd_driver_test_impl_1.cprj" "mess_writ.cprj" -a "iCE40UP"  -o lcd_driver_test_impl_1_cpe.ldc
# synthesize top design
file delete -force -- lcd_driver_test_impl_1.vm lcd_driver_test_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/wchan/Documents/GitHub/e155-final-project/lcd_driver_test/impl_1/lcd_driver_test_impl_1_lattice.synproj" -logfile "lcd_driver_test_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o lcd_driver_test_impl_1_syn.udb lcd_driver_test_impl_1.vm] [list lcd_driver_test_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
