vlib work
vmap work work

vlog +acc +sv wishbone_slave_interface.sv ReRAM_functional.sv ReRAM_Wishbone_Interface.sv tb_ReRAM_Wishbone_Interface.sv

vsim work.tb_ReRAM_Wishbone_Interface

add wave -position insertpoint sim:/tb_ReRAM_Wishbone_Interface/*
add wave -position insertpoint sim:/tb_ReRAM_Wishbone_Interface/dut/wishbone_if/*
add wave -position insertpoint sim:/tb_ReRAM_Wishbone_Interface/dut/functional/*

run -all