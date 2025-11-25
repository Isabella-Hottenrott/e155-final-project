if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/wchan/Documents/GitHub/disp_fpga/lcd_disp"
if {![file exists {C:/Users/wchan/Documents/GitHub/disp_fpga/lcd_disp/impl_1}]} {
  file mkdir {C:/Users/wchan/Documents/GitHub/disp_fpga/lcd_disp/impl_1}
}
cd {C:/Users/wchan/Documents/GitHub/disp_fpga/lcd_disp/impl_1}
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- lcd_disp_impl_1.vm lcd_disp_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/wchan/Documents/GitHub/disp_fpga/lcd_disp/impl_1/lcd_disp_impl_1_lattice.synproj" -logfile "lcd_disp_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP3K -t UWG30 -sp High-Performance_1.2V -oc Industrial -top -w -o lcd_disp_impl_1_syn.udb lcd_disp_impl_1.vm] [list lcd_disp_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
