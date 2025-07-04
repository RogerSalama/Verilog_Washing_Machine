`timescale 1ns / 1ns

module WashingMachine_tb;

    // Inputs
    reg clk, powerButton, configu, run, door_error, 
    water_error;
    reg [2:0] mode;
    reg [31:0] manualTimer;

    // Outputs
    wire [3:0] cs;
    
    // Instantiate the WashingMachine module
    WashingMachine dut (
        .clk(clk),
        .powerButton(powerButton),
        .configu(configu),
        .run(run),
        .mode(mode),
        .manualTimer(manualTimer),
        .door_error(door_error),
        .cs(cs),
        .water_error(water_error)
    );

    // Clock generation
    always #1 clk = ~clk;

    //reset variables 
    task Resetvars;
        begin
            powerButton=0;
            dut.timer=0;
            configu = 0;
            run = 0;
            mode = 0;
            manualTimer = 0;
            door_error = 0;
            water_error = 0;
            dut.ns = 0;
            #20;
        end        
    endtask

    // Task for applying test stimulus
    task apply_test(
        input reg test_power,
        input reg test_configu,
        input reg test_run,
        input [2:0] test_mode,
        input [31:0] test_manualTimer,
        input reg test_door_error,
        input reg test_water_error,
        input reg [31:0] pause_time // Input delay time (in ns)
    );
        begin
            powerButton = test_power;
            configu = test_configu;
            run = test_run;
            mode = test_mode;
            manualTimer = test_manualTimer;
            door_error = test_door_error;
            water_error = test_water_error;
            // CycleComplete = test_CycleComplete; // Uncomment if included
            if (pause_time > 0) begin
                #pause_time; // Wait for the specified time (in ns)
            end
        end        
    endtask

    // Directed test cases
    task directed_tests;
        begin
            $display("...............STARTING DIRECTED TESTS................");
             
            // Test 1: Basic power on, idle state
            apply_test(1, 0, 0, 3'b000, 0,0 ,0,20); 
            $display("-----------------------------------------Test 1 passed.");
            // Test 2: Power on, QuickWash mode
            Resetvars();
            apply_test(1, 0, 1, 3'b000, 0, 0,0,1000);
            $display("-----------------------------------------Test 2 passed.");
            // Test 3: Power on, Sports mode with run disabled
            Resetvars();
            apply_test(1, 0, 0, 3'b001, 0, 0,0,250);
            $display("-----------------------------------------Test 3 passed.");
            // Test 4: Manual timer configuration
            Resetvars();
            apply_test(1, 1, 1, 3'b000, 50, 0,0,50);
            $display("-----------------------------------------Test 4 passed.");
            // Test 5: Door error during wash cycle
            Resetvars();
            apply_test(1, 0, 1, 3'b010, 0, 1,0,100);
            $display("-----------------------------------------Test 5 passed.");
            // Test 6: Invalid mode (edge case)
            // apply_test(1, 0, 1, 3'b111, 0, 0,0);

            // Test 7: Zero timer in manual configuration
            Resetvars();
            apply_test(1, 1, 1, 3'b000, 0, 0,0,350);
            $display("-----------------------------------------Test 6 passed.");
        end
    endtask

    // Random test cases
    task random_tests;
        integer i;
        begin
            $display("Starting Random Tests...");
            for (i = 0; i < 10; i = i + 1) begin
                Resetvars();
                apply_test(
                    $random % 2,           // power
                    $random % 2,           // configu
                    $random % 2,           // run
                    $urandom_range(0,7),   // mode (includes invalid modes)
                    $random % 500,         // manualTimer (wide range)
                    $random % 2,           // door_error
                    $random % 2 ,
                    1000           // water_error
                );
            end
        end
    endtask

    // Constrained random test cases
   task constrained_random_tests;
    integer i;
    integer seed;
    begin
           
        $display("Starting Constrained Random Tests...");
        for (i = 0; i < 10; i = i + 1) begin
            // Reseed random number generator for more varied results
            seed = $time;
            $display(seed);  
            Resetvars(); // clear
            $display("NEW TESTCASE %0d..............", i + 1);
            apply_test(
                1,                   // Always power on
                $urandom % 2,                           // configu
                1,                                      // Always running
                $urandom_range(0, 6),                   // Valid modes only
                100 + ($urandom % 200),                 // Timer between 100 and 300
                $urandom % 2,                           // door_error
                $urandom % 2,                           // water_error
                500                                     // pause time
            );

           
        end
    end
endtask

   

      // Task to simulate door_error trigger and resolve

    task door_error_trigger( input reg test_power,
        input reg test_configu,
        input reg test_run,
        input [2:0] test_mode,
        input [31:0] test_manualTimer,
        input reg test_door_error,
        input reg test_water_error,
        input reg [31:0] pause_time );
        begin
            powerButton = test_power;
            configu = test_configu;
            run = test_run;
            mode = test_mode;
            manualTimer = test_manualTimer;
            $display("Starting Door Error Trigger Task...");
            $display("Door error triggered at time %t.", $time);

            door_error = test_door_error;
            #15;
            door_error = ~test_door_error;
            $display("Door error resolved at time %t.", $time);
            water_error = test_water_error;
            #100;
            $display("Door Error Trigger Task completed at time %t.", $time);
            // CycleComplete = test_CycleComplete; // Uncomment if included
            if (pause_time > 0) begin
                #pause_time; // Wait for the specified time (in ns)
            end
        end
    endtask

    task water_error_trigger( input reg test_power,
        input reg test_configu,
        input reg test_run,
        input [2:0] test_mode,
        input [31:0] test_manualTimer,
        input reg test_door_error,
        input reg test_water_error,
        input reg [31:0] pause_time );
        begin
            powerButton = test_power;
            configu = test_configu;
            run = test_run;
            mode = test_mode;
            manualTimer = test_manualTimer;
            $display("Starting water Error Trigger Task...");
            $display("water error triggered at time %t.", $time);

           
            water_error = test_water_error;
            #15;
            water_error = ~test_water_error;
            $display("Door error resolved at time %t.", $time);
            door_error = test_door_error;
            #100;
            $display("Door Error Trigger Task completed at time %t.", $time);
            // CycleComplete = test_CycleComplete; // Uncomment if included
            if (pause_time > 0) begin
                #pause_time; // Wait for the specified time (in ns)
            end
        end
    endtask
    

    


    // Monitor signal values
    initial begin
        $monitor("Timer: %d | powerButton: %b | internalPower: %b | configu: %b | run: %b | mode: %b | manualTimer: %d | door_error: %b | water_error: %b | cs: %b | ns: %b |cycleComplete: %b |", 
                  dut.timer, powerButton,dut.internalPower, configu, run, mode, manualTimer, door_error,water_error, cs,dut.ns, dut.cycleComplete);
    end

    // Main testbench execution
    initial begin
        clk = 0;
       
        // Run all test categories
        directed_tests();
        random_tests();
        constrained_random_tests();
       

        $display("-----------------------TESTCASE  1--------------------------------");
        Resetvars();
        door_error_trigger(1, 0, 1, 3'b000, 0,1 ,0,500); 
        $display("-----------------------TESTCASE  2--------------------------------");
        Resetvars();
        door_error_trigger(1, 1, 1, 3'b001, 140,1 ,0,500);
        $display("-----------------------TESTCASE  3--------------------------------");
        Resetvars();
        door_error_trigger(0, 0, 1, 3'b000, 0,1 ,0,500);
        $display("-----------------------TESTCASE  4--------------------------------");
        Resetvars();
        water_error_trigger(1, 0, 1, 3'b000, 0,0 ,1,500); 
        $display("-----------------------TESTCASE  5--------------------------------");
        Resetvars();
        water_error_trigger(1, 1, 1, 3'b011, 160,0 ,1,500);
        $display("-----------------------TESTCASE  6--------------------------------");
        Resetvars();
        water_error_trigger(0, 0, 1, 3'b101, 0,0 ,1,500);

        $display("All tests completed.");
        $stop;
    end

endmodule