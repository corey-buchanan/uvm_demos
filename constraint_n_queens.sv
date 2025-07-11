`define N 8

class n_queens;
  // Each value is the column index where the queen is placed in each row
  rand int queens[`N];

  constraint rules {
    unique {queens};
    foreach (queens[i]) {
      queens[i] inside {[0:`N-1]};
      foreach (queens[j]) {
        // abs(i-j) != abs(queens[i] - queens[j]) ensures no two queens are on the same diagonal
        i != j -> i-j != queens[i] - queens[j];
        i != j -> i-j != queens[j] - queens[i];
      }
    }
  }

  function void print();
    string s;
    $display("Printing n-queens solution");
    foreach (queens[i]) begin
      s = "";
      for (int j = 0; j < queens[i]; j++) begin
        s = {s, " . "};
      end
      s = {s, " Q "}; // Place a queen
      for (int j = queens[i] + 1; j < `N; j++) begin
        s = {s, " . "};
      end
      $display("%s", s);
    end
  endfunction
endclass

module automatic_test;
  task run;
    n_queens my_n_queens = new;
    my_n_queens.randomize();
    my_n_queens.print();
  endtask

  initial begin
    run();
  end
endmodule