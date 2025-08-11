vlib work
vmap work work

vlog +acc +sv wishbone_slave_interface.v NEUROMORPHIC_X1_macro.v NEUROMORPHIC_X1.v ReRAM_Wishbone_Interface.v tb_ReRAM_Wishbone_Interface.v

vsim work.tb_ReRAM_Wishbone_Interface

add wave -position insertpoint sim:/tb_ReRAM_Wishbone_Interface/*
add wave -position insertpoint sim:/tb_ReRAM_Wishbone_Interface/dut/wishbone_if/*
add wave -position insertpoint sim:/tb_ReRAM_Wishbone_Interface/dut/functional/NEUROMORPHIC_X1_inst/*

run -all