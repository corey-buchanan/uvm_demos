// Sudoku Interview Question - Using System Verilog Constraints
`define N 3
`define M 9

class sudoku;
  int puzzle [`M][`M] = 
  '{
    '{0, 2, 3, 4, 0, 6, 7, 8, 0},
    '{4, 0, 6, 7, 0, 9, 1, 0, 3},
    '{7, 8, 0, 0, 2, 0, 0, 5, 6},
    '{2, 3, 0, 0, 6, 0, 0, 9, 1},
    '{0, 0, 7, 8, 0, 1, 2, 0, 0},
    '{8, 9, 0, 0, 3, 0, 0, 6, 7},
    '{3, 4, 0, 0, 7, 0, 0, 1, 2},
    '{6, 0, 8, 9, 0, 2, 3, 0, 5},
    '{0, 1, 2, 3, 0, 5, 6, 7, 0}};

  rand int box [`M][`M];

  constraint rules {
    foreach (box[i,j]) {
      foreach (box[ii,jj]) {
        // Row
        (ii==i)&&(jj!=j) -> box[i][j] != box[ii][jj];
        // Column
        (ii!=i)&&(jj==j) -> box[i][j] != box[ii][jj];
        // 3x3 Box
        ((3*(ii/3)+(jj/3)) == (3*(i/3)+(j/3))) && (ii!=i || jj!=j) -> box[i][j] != box[ii][jj];
      }
    }
    foreach (box[i,j]) {
      // Assign random value
      box[i][j] inside {[1:9]};

      // If puzzle has space filled, set it to the puzzle space
      puzzle[i][j] != 0 -> box[i][j] == puzzle[i][j];
    }
  }

  function void print();
    string s;
    $display("Printing sudoku");
    foreach (box[i]) begin
      s="";
      foreach (box[i][j]) begin
        s = {s, " ", $sformatf("%0d", box[i][j])};
      end
      $display("%s", s);
    end
  endfunction

endclass
      
module automatic_test;
  function void run;
    sudoku my_sudoku = new;
    my_sudoku.randomize();
    my_sudoku.print();
  endfunction
  
  initial begin
    run();
  end
endmodule
