
create_project prj prj -part xczu3eg-sbva484-1-i -force
set_property board_part avnet.com:ultra96v2:part0:1.1 [current_project]
add_files -norecurse {
    ../../common/axi2stream.v 
    ../../common/ydff.v 
    ../../common/asynchronizer.v
    ../../common/design_1_wrapper.v
    ../rtl/async_fifo_wrapper.v
}
update_compile_order -fileset sources_1
source ../script/design_1.tcl
set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1