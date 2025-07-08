module adder(
  input logic [3:0] a, b,
  output logic [4:0] sum
);

  always_comb begin
    sum = a + b;
  end
endmodule

interface adder_if (input logic clk);
  logic [3:0] a, b;
  logic [4:0] sum;
endinterface