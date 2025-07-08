`include "uvm_macros.svh"
import uvm_pkg::*;

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
    repeat (16) begin
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

class adder_driver extends uvm_driver #(adder_transaction);
  `uvm_component_utils(adder_driver)
  virtual adder_if vif;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual adder_if)::get(this, "", "adder_if", vif)) begin
      `uvm_fatal("DRV", "Interface not found")
    end
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      adder_transaction tr;
      @(posedge vif.clk);
      seq_item_port.get_next_item(tr);
      `uvm_info("DRV", $sformatf("Driving: a=%0d, b=%0d", tr.a, tr.b), UVM_MEDIUM)
      vif.a = tr.a;
      vif.b = tr.b;
      seq_item_port.item_done();
    end
  endtask
endclass

class adder_monitor extends uvm_monitor;
  `uvm_component_utils(adder_monitor)
  virtual adder_if vif;
  uvm_analysis_port #(adder_transaction) ap;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual adder_if)::get(this, "", "adder_if", vif)) begin
      `uvm_fatal("MON", "Interface not found")
    end
  endfunction
  
  task run_phase(uvm_phase phase);
    adder_transaction tr;
    forever begin
      @(posedge vif.clk);
      tr = adder_transaction::type_id::create("tr");
      tr.a = vif.a;
      tr.b = vif.b;
      tr.sum = vif.sum;
      `uvm_info("MON", $sformatf("Captured: a=%0d, b=%0d, sum=%0d", tr.a, tr.b, tr.sum), UVM_MEDIUM)
      ap.write(tr);
    end
  endtask
endclass

class adder_agent extends uvm_agent;
  `uvm_component_utils(adder_agent);
  adder_sequencer sqr;
  adder_driver drv;
  adder_monitor mon;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    sqr = adder_sequencer::type_id::create("sqr", this);
    drv = adder_driver::type_id::create("drv", this);
    mon = adder_monitor::type_id::create("mon", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
  
endclass

class adder_env extends uvm_env;
  `uvm_component_utils(adder_env);
  adder_agent agt;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = adder_agent::type_id::create("agt", this);
  endfunction
endclass

class adder_test extends uvm_test;
  `uvm_component_utils(adder_test)
  adder_env env;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = adder_env::type_id::create("env", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    adder_sequence seq = adder_sequence::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agt.sqr);
    phase.drop_objection(this);
  endtask
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
  
  initial begin
    uvm_config_db#(virtual adder_if)::set(null, "*", "adder_if", adder_if_inst);
    run_test("adder_test");
  end
endmodule
