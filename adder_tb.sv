`include "uvm_macros.svh"
`timescale 1ns / 1ps
import uvm_pkg::*;

interface adder_if (input logic clk);
    input logic [3:0] a, b;
    output logic [4:0] sum;
endinterface

class adder_transaction extends uvm_sequence_item;
    rand logic [3:0] a, b;
    logic [4:0] sum;

    constraint a_range { a >= 0 && a <= 15; }
    constraint b_range { b >= 0 && b <= 15; }

    `uvm_object_utils(adder_transaction)

    function new(string name = "adder_transaction");
        super.new(name);
    endfunction
endclass

class adder_sequence extends uvm_sequence #(adder_transaction);
    `uvm_object_utils(adder_sequence)

    function new(string name = "adder_sequence");
        super.new(name);
    endfunction

    virtual task body();
        adder_transaction tr;
        repeat (15) begin
            tr = adder_transaction::type_id::create("tr");
            start_item(tr);
            if (!tr.randomize()) begin
                `uvm_error("ADDER_SEQ", "Randomization failed")
            end
            `uvm_info("ADDER_SEQ", $sformatf("Sending: a=%0d, b=%0d", tr.a, tr.b), UVM_MEDIUM)
            finish_item(tr);
        end
    endtask
endclass

class adder_sequencer extends uvm_sequencer #(adder_transaction);
    `uvm_component_utils(adder_sequencer)

    function new(string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction
endclass

class adder_test extends uvm_test;
    `uvm_component_utils(adder_test)

    function new(string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction
endclass

module adder_top;
    bit clk;
    always #10 clk <= ~clk; // 50 MHz clock

    adder_if adder_if_inst(clk);
    adder dut(
        .a(adder_if_inst.a),
        .b(adder_if_inst.b),
        .sum(adder_if_inst.sum)
    );
endmodule
