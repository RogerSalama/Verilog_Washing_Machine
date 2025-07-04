module WashingMachine (
    input clk, powerButton, configu, run,
    input [2:0] mode,
    input [31:0] manualTimer,
    input door_error, water_error,
    output reg [3:0] cs
    // output CycleComplete
);
    reg [3:0] ns; // Next state
    reg [9:0] timer,config_timer, fillTimer, lastManualTimer;// Timer for state transitions
    reg cycleComplete;
    reg internalPower;

    // State definitions
    parameter Idle = 4'b0000,
              Options = 4'b0001,
              Configurations = 4'b0010,
              Ready = 4'b0011,
              Wash = 4'b0100,
              Rinse = 4'b0101,
              Drain = 4'b0110,
              Dry = 4'b0111,
              Completion = 4'b1000,
              Bamla_Mayya = 4'b1001,
             // Pause = 4'b1010,
              CheckForError = 4'b1111,
              WashCycle = 4'd90;
              
    // Mode definitions
    parameter QuickWash = 3'b000,
              Sports = 3'b001,
              GentleCare = 3'b010,
              Denim = 3'b011,
              Wool = 3'b100,
              Synthetics = 3'b101;

    
    
    

    initial 
    begin
        internalPower=0;
        cs <= Idle;
        ns <= Idle;
        timer <= 0;
        config_timer <= 0;
        lastManualTimer = 0;
        cycleComplete <= 0; 
    end

    // State transition
    // always @(posedge clk) 
    // begin
    //     cs = ns;
    // end

    always @(posedge powerButton or negedge powerButton)
    begin
        if (powerButton==0) internalPower=0;
        else internalPower <= ~ internalPower; //manual turn on or off 
    end

    // Next state logic
    always @(posedge clk )
    begin
        cs = ns;
        if (internalPower)
        begin
            case (cs)
                Idle: 
                begin
                    ns = Options;
                end

                // Pause:
                // begin
                //     if (ns == CheckForError)
                //     begin
                //         if (door_error == 0 && water_error == 0)
                //         cs = ns;
                //         else
                //         cs = Pause;
                //     end
                //     else
                //     cs = ns;
                // end

                Options: 
                begin
                    if (!configu) 
                    begin
                        case (mode) 
                            QuickWash: begin timer = 120;    $display("QuickWash mode on!"); end
                            Sports:    begin timer = 190;    $display("Sports mode on!"); end
                            GentleCare:begin timer = 140;    $display("Gentlecare mode on!"); end
                            Denim:     begin timer = 160;    $display("Denim mode on!"); end
                            Wool:      begin timer = 150;    $display("Wool mode on!"); end
                            Synthetics:begin timer = 230;    $display("Synthetics mode on!"); end
                            default:   begin timer = 120;    $display("QuickWash mode on!"); end// set to quickwash timer as a default
                        endcase
                        ns = Ready;
                    end
                    else 
                    begin
                        ns = Configurations;
                        config_timer = 20;
                    end
                end


                Configurations:
                begin
                    if (config_timer == 0) 
                    begin
                        $display("Time limit exceeded!");
                        ns = Idle;
                        internalPower = 0;
                        lastManualTimer = 0;

                    end
                    else if (manualTimer > 0 && manualTimer != lastManualTimer) 
                    begin 
                        if (manualTimer < 120) 
                        begin
                            $display("Error: Manual timer must be at least 120!");
                            lastManualTimer = manualTimer;
                            ns = Configurations;
                            config_timer = config_timer - 1;
                        end
                        else 
                        begin
                            timer = manualTimer;
                            lastManualTimer = 0;
                            ns = Ready;
                        end
                    end
                    else 
                    begin
                        config_timer = config_timer - 1;
                        ns = Configurations;
                    end 
                end


                Ready:
                begin
                    if (run)
                        begin
                            fillTimer = timer - 10;
                            ns = CheckForError;
                        end
                    else
                        ns = Ready;
                end
                CheckForError: 
                begin
                    if (door_error)
                    begin 
                        $display("Error: Door not closed!");
                        ns = CheckForError;
                        // ns = cs;
                        // cs = Pause;
                    end
                    else if (water_error)
                    begin
                        $display("Error: Water level low!");
                        ns = CheckForError;
                        // ns = cs;
                        // cs = Pause;
                    end
                    else 
                    ns = Bamla_Mayya;
                end

                Bamla_Mayya: 
                begin
                    if (!water_error)
                    begin
                        if (timer <=70)
                        begin
                            ns=Rinse;
                        end
                        else if ((timer <= fillTimer) && timer > 90) 
                        begin
                            ns = Wash;     
                        end 
                        else 
                        begin
                            timer = timer - 1;
                            ns = Bamla_Mayya;
                        end
                    end
                    else
                    begin
                        ns=CheckForError;
                    end
                end

                Wash: 
                begin
                    if (timer <= 90) 
                    begin
                        ns = Drain;     
                    end 
                    else                     
                    begin
                        timer = timer - 1;
                        ns = Wash;
                    end
                end

                Drain: 
                begin
                    if (timer <= 30) 
                    begin                   
                        ns = Dry;
                    end
                    else if (timer <=80 && timer > 70) 
                    begin
                        ns = Bamla_Mayya;
                    end
                    else
                    begin
                        timer = timer - 1;
                        ns = Drain;
                    end
                end

                Rinse: 
                begin
                    if (timer <= 40) 
                    begin
                        ns = Drain;
                    end 
                    else                     
                    begin
                        timer = timer - 1;
                        ns = Rinse;
                    end
                end


                Dry: 
                begin
                    if (timer <= 0)
                        ns = Completion;
                    else 
                    begin
                        timer = timer - 1;
                        ns = Dry;
                    end
                end
                
                Completion: 
                begin
                $display("Cycle is completed hooray!");
                cycleComplete = 1'b1;
                ns = Idle;
                internalPower = 0;
                end

                default: ns = Idle;
            endcase
        end
        
        // else if (cs != Idle && internalPower==0) //automatic power outage or timeout
        // begin
        //     $display("Paused!");
        //     ns = Idle;
        //     // ns <= cs;
        //     // cs <= Pause;
        // end
        else
        begin
            ns <= Idle;
            timer <= 0;
            config_timer <= 0;
            cycleComplete <= 0;
        end
    end
    // psl default clock = rose(clk);
    // psl property POWER_NOT_IDLE = always (internalPower) -> eventually! (cs != Idle);
    // psl assert POWER_NOT_IDLE;

    // psl property Configurations_Timeout_Handling = always(internalPower && cs == Configurations && config_timer == 0) -> next (ns == Idle );
    // psl assert Configurations_Timeout_Handling;

    // psl property Manual_Timer_Validation = always (internalPower && cs == Configurations && manualTimer > 0 && manualTimer < 120) -> next (cs == Configurations);
    // If a manual timer is provided and it's invalid (< 120), the system stays in Configurations.
    // psl assert Manual_Timer_Validation;


    // psl property Washing_Without_Water_Error = always (internalPower && cs == Wash) -> (!water_error);
    // While the system is in the Wash state, there should be no water error.
    // psl assert Washing_Without_Water_Error;

    // psl property Sequential_State_Progression = always (internalPower && cs == Ready && run) -> next (cs == CheckForError);
    // The FSM should follow the expected sequence: Ready -> CheckForError -> Bamla_Mayya -> Wash (or subsequent states).
    // psl assert Sequential_State_Progression;

    // psl property Idle_to_options = always (cs == Idle && internalPower) -> eventually! (cs == Options);
    // psl assert Idle_to_options;

    // psl property Options_to_Configurations = always (cs == Options && configu) -> next (cs == Configurations);
    // psl assert Options_to_Configurations;

    // psl property Idle_to_Idle = always (!internalPower) -> next (ns == Idle);
    // psl assert Idle_to_Idle;

    // psl property Options_to_Ready = always (cs == Options && !configu) -> next (cs == Ready);
    // psl assert Options_to_Ready;

    // psl property Synthetics_time = always (cs == Options && mode == 3'b000 && !configu) -> next (timer == 120); 
    // psl assert Synthetics_time;

    // psl property Configurations_to_Configurations = always (internalPower && cs == Configurations && manualTimer > 0 && manualTimer < 120) -> (ns == Configurations);
    // psl assert Configurations_to_Configurations;

    // psl property Config_Valid_Timer = always (cs == Configurations && manualTimer >= 120) -> next (cs == Ready);
    // psl assert Config_Valid_Timer;

    // psl property Ready_to_CheckForError = always (internalPower && cs == Ready && run) -> next (cs == CheckForError);
    // psl assert Ready_to_CheckForError;

    // psl property Ready_Stay_Without_Run = always (internalPower && cs == Ready && !run) -> next (cs == Ready);
    // psl assert Ready_Stay_Without_Run;


    // 3. Reset FSM on Power OFF
    // psl property Power_Off_Reset = always (!internalPower) -> next (ns == Idle);
    // psl assert Power_Off_Reset;

    // Idle State Assertions
    // 4. Idle Timer Reset
    // psl property Idle_Timer_Reset = always (cs == Idle) -> (timer == 0 && config_timer == 0);
    // psl assert Idle_Timer_Reset;


    // Wash State Assertions
    // 13. Transition to Drain after Wash
    // psl property Wash_to_Drain = always (cs == Wash && timer <= 90) -> next (ns == Drain);
    // psl assert Wash_to_Drain;

    // Drain State Assertions
    // 14. Transition to Dry after Drain
    // psl property Drain_to_Dry = always (cs == Drain && timer <= 30) -> next (ns == Dry);
    // psl assert Drain_to_Dry;

    // Completion Assertions
    // 16. CycleComplete Set at Completion
    // psl property Completion_CycleComplete = always (cs == Completion) -> (cycleComplete == 1);
    // psl assert Completion_CycleComplete;

    // Error Handling Assertions
    // 17. Handle Door Error in CheckForError
    // psl property CheckForError_Handle_Door_Error = always (cs == CheckForError && door_error) -> next (cs == CheckForError);
    // psl assert CheckForError_Handle_Door_Error;

    // 18. Handle Water Error in CheckForError
    // psl property CheckForError_Handle_Water_Error = always (cs == CheckForError && water_error) -> next (cs == CheckForError);
    // psl assert CheckForError_Handle_Water_Error;

endmodule //////////////////////////////////////////////////////////////////////////////////////////////