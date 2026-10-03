
`ifndef AFIFO_PKG
  `define AFIFO_PKG
  package afifo_pkg;
    `define _MAX(a, b) (((a) > (b)) ? (a) : (b))
    `define _MIN(a, b) (((a) < (b)) ? (a) : (b))

        
    function automatic int as_div_ceil_pow2 (input int numerator, input int denominator);
      return ((numerator + denominator - 1) >> $clog2(denominator));
    endfunction

    function automatic int find_min2 (int a, int b);
      return (a < b) ? a : b;
    endfunction

    class afifo_item;
      bit          push;
      bit          pop;
      bit [7:0]    data;
    endclass

    class afifo_scoreboard;
      bit [7:0] exp_q[$];
      int errors;

      function new();
        errors = 0;
      endfunction

      function void push_expected(bit [7:0] d);
        exp_q.push_back(d);
      endfunction

      function void push_actual(bit [7:0] d);
        bit [7:0] exp;
        if (exp_q.size() == 0) begin
          errors++;
          $error("AFIFO-SB: unexpected read data=0x%0h", d);
          return;
        end
        exp = exp_q.pop_front();
        if (exp !== d) begin
          errors++;
          $error("AFIFO-SB: mismatch exp=0x%0h act=0x%0h", exp, d);
        end
      endfunction

      function int pending();
        return exp_q.size();
      endfunction
    endclass

    class afifo_generator;
      mailbox #(afifo_item) w_mb;
      mailbox #(afifo_item) r_mb;
      int                   num_items;
      int                   total_steps;
      int                   drain_steps;
      int                   seed;

      function new(mailbox #(afifo_item) w_mb,
                  mailbox #(afifo_item) r_mb,
                  int num_items,
                  int total_steps,
                  int drain_steps,
                  int unsigned seed);
        this.w_mb = w_mb;
        this.r_mb = r_mb;
        this.num_items = num_items;
        this.total_steps = total_steps;
        this.drain_steps = drain_steps;
        this.seed = seed[31:0];
      endfunction

      function int rand_u32();
        return $random(seed);
      endfunction

      function int rand_range(int min_v, int max_v);
        int lo;
        int hi;
        int span;
        int r;

        lo = (min_v < max_v) ? min_v : max_v;
        hi = (min_v < max_v) ? max_v : min_v;
        span = hi - lo + 1;
        r = rand_u32();
        if (r < 0) r = -r;
        return lo + (r % span);
      endfunction

      task run();
        afifo_item w_it, r_it;
        int pushed;
        int level_model;
        int rand_sel;

        pushed = 0;
        level_model = 0;

        for (int step = 0; step < total_steps; step++) begin
          w_it = new();
          r_it = new();

          if (step < (total_steps - drain_steps)) begin
            w_it.push = (pushed < num_items) && (rand_range(0, 99) < 60);
            w_it.data = rand_range(0, 255);

            rand_sel = rand_range(0, 99);
            r_it.pop = (level_model > 0) && (rand_sel < 55);
          end else begin
            // drain phase: stop writes and keep requesting reads
            w_it.push = 1'b0;
            w_it.data = '0;
            r_it.pop = 1'b1;
          end

          if (w_it.push) begin
            pushed++;
          end
          if (w_it.push && !r_it.pop) begin
            level_model++;
          end else if (!w_it.push && r_it.pop && (level_model > 0)) begin
            level_model--;
          end

          w_mb.put(w_it);
          r_mb.put(r_it);
        end
      endtask
    endclass

    class afifo_write_driver;
      virtual afifo_if #(8) vif;
      mailbox #(afifo_item)  mb;

      function new(virtual afifo_if #(8) vif, mailbox #(afifo_item) mb);
        this.vif = vif;
        this.mb  = mb;
      endfunction

      task run(int total_steps);
        afifo_item it;
        wait (vif.w_rst_n === 1'b1);
        for (int i = 0; i < total_steps; i++) begin
          mb.get(it);
          @(vif.wdrv_cb);
          vif.wdrv_cb.wrreq_drv <= it.push;
          vif.wdrv_cb.w_data_in <= it.data;
        end
        @(vif.wdrv_cb);
        vif.wdrv_cb.wrreq_drv <= 1'b0;
        vif.wdrv_cb.w_data_in <= '0;
      endtask
    endclass

    class afifo_read_driver;
      virtual afifo_if #(8) vif;
      mailbox #(afifo_item)  mb;

      function new(virtual afifo_if #(8) vif, mailbox #(afifo_item) mb);
        this.vif = vif;
        this.mb  = mb;
      endfunction

      task run(int total_steps);
        afifo_item it;
        wait (vif.r_rst_n === 1'b1);
        for (int i = 0; i < total_steps; i++) begin
          mb.get(it);
          @(vif.rdrv_cb);
          vif.rdrv_cb.rdreq_drv <= it.pop;
        end
        @(vif.rdrv_cb);
        vif.rdrv_cb.rdreq_drv <= 1'b0;
      endtask
    endclass

    class afifo_write_monitor;
      virtual afifo_if #(8) vif;
      afifo_scoreboard      sb;

      function new(virtual afifo_if #(8) vif, afifo_scoreboard sb);
        this.vif = vif;
        this.sb  = sb;
      endfunction

      task run(int cycles);
        int wr_pkt_no;
        wait (vif.w_rst_n === 1'b1);
        wr_pkt_no = 0;
        repeat (cycles) begin
          @(posedge vif.w_clk);
          if (vif.w_wrreq_in && !vif.w_full_out) begin
            sb.push_expected(vif.w_data_in);
            wr_pkt_no++;
            if ($test$plusargs("AFIFO_TRACE")) begin
              $display("AFIFO-WR: wr_pkt[%0d] @ %0.3f ns, wr_data=0x%0h", wr_pkt_no, ($realtime/1ns), vif.w_data_in);
            end
          end
        end
      endtask
    endclass

    class afifo_read_monitor;
      virtual afifo_if #(8) vif;
      afifo_scoreboard      sb;

      function new(virtual afifo_if #(8) vif, afifo_scoreboard sb);
        this.vif = vif;
        this.sb  = sb;
      endfunction

      task run(int cycles);
        bit [7:0] sampled;
        bit       pop_s;
        bit       empty_s;
        int       rd_pkt_no;

        wait (vif.r_rst_n === 1'b1);
        rd_pkt_no = 0;
        repeat (cycles) begin
          @(negedge vif.r_clk);
          #1step;
          sampled = vif.r_q_out;
          pop_s   = vif.r_rdreq_in;
          empty_s = vif.r_empty_out;
          @(posedge vif.r_clk);
          if (pop_s && !empty_s) begin
            sb.push_actual(sampled);
            rd_pkt_no++;
            if ($test$plusargs("AFIFO_TRACE")) begin
              $display("AFIFO-RD: rd_pkt[%0d] @ %0.3f ns, rd_data=0x%0h", rd_pkt_no, ($realtime/1ns), sampled);
            end
          end
        end
      endtask
    endclass

  
endpackage: afifo_pkg

`endif //AFIFO_PKG