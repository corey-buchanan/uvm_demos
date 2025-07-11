module multiplier(
  input logic clk, rst,
  input logic [3:0] a, b,
  output logic [7:0] product
);

  always_ff begin
    if (rst) begin
      product <= 8'h00; // Reset product to zero
    end else begin
      // Inject error when a == 15
      if (a == 4'hF) begin
        product <= a * b + 1; // Intentional error for testing
      end
      product <= a * b;
    end
    
  end

endmodule