mdl = 'simulation.slx';
blockName = 'simulation/Three-Phase Fault';
%open(mdl)
fault_length = linspace(20 * 0.01, 20 * 0.99, 100);

fault_length1 = fault_length(1:20); %DONE, PRUNE
fault_length1 = fault_length1([5:9, 12:20]);
fault_length2 = fault_length(21:40); %ALI PC, DONE 21:30
fault_length3 = fault_length(41:60); %JOHN PC, DONE 41:50
fault_length4 = fault_length(61:80); %NATHAN PC, DONE 61:70
fault_length5 = fault_length(81:100); %SENNE PC, need 81,90,89,88
%ALSO PRUNE TOMORROW AND MAKE SURE STARTING FROM CORRECT I   

fault_resistance = [5, 10, 15, 20, 25, 30, 40, 50];
fault_inception_time = linspace(0.004, 0.024, 6) + 0.02 ;
%fault_inception_time_end = fault_inception_time + 1/50;
Rburden = 100;
fault_types = ["AG", "BG", "CG", "AB", "AC", "BC", "ABG", "ACG", "BCG", "ABCG", "NOFAULT"];

len_fault_length = length(fault_length1);
len_fault_resistance = length(fault_resistance);
len_fault_inception_time = length(fault_inception_time);
len_fault_types = length(fault_types);

simulationResults = cell(len_fault_resistance, len_fault_inception_time, len_fault_types);

%open_system('simulation.slx');
%sim('simulation.slx'); % To get timestamps (if needed)
% t_in = ans.tout; 
%get_param('simulation/Three-Phase Fault1','DialogParameters')
%get_param('simulation/Three-Phase Fault','SwitchTimes')
%tic
for i = 1:len_fault_length
    fault_length_val = fault_length1(i);
    set_param('simulation/Line','Length', num2str(fault_length_val));
    set_param('simulation/Line 2','Length', num2str(20 - fault_length_val));
    for j = 1:len_fault_resistance
        fault_resistance_val = fault_resistance(j);
        set_param('simulation/Three-Phase Fault', 'FaultResistance', num2str(fault_resistance_val));
        for z = 1:len_fault_inception_time
            
            fault_time_val = fault_inception_time(z); %start fault after 5 cycles 
            %fault_time_end = fault_inception_time_end(z);
            start = num2str(fault_time_val);
           % stop = num2str(fault_time_end);
            formatted_string = ['[', start, ']'];
            set_param('simulation/Three-Phase Fault' ,'SwitchTimes', formatted_string);
            for y = 1:len_fault_types
                %tic
                fault_type_val = fault_types(y);
            
                % Set fault parameters in Simulink model
                % Check the current fault type and set parameters accordingly
                if strcmp(fault_type_val, 'AG')
                    % Set the checkbox on/off
                    set_param(blockName, 'FaultA', 'on', 'FaultB', 'off', 'FaultC', 'off', 'GroundFault', 'on');
                elseif strcmp(fault_type_val, 'BG')
                    set_param(blockName, 'FaultA', 'off', 'FaultB', 'on', 'FaultC', 'off', 'GroundFault', 'on');
                elseif strcmp(fault_type_val, 'CG')
                    set_param(blockName, 'FaultA', 'off', 'FaultB', 'off', 'FaultC', 'on', 'GroundFault', 'on');
                elseif strcmp(fault_type_val, 'AB')
                    set_param(blockName, 'FaultA', 'on', 'FaultB', 'on', 'FaultC', 'off', 'GroundFault', 'off');
                elseif strcmp(fault_type_val, 'AC')
                    set_param(blockName, 'FaultA', 'on', 'FaultB', 'off', 'FaultC', 'on', 'GroundFault', 'off');
                elseif strcmp(fault_type_val, 'BC')
                    set_param(blockName, 'FaultA', 'off', 'FaultB', 'on', 'FaultC', 'on', 'GroundFault', 'off');
                elseif strcmp(fault_type_val, 'ABG')
                    set_param(blockName, 'FaultA', 'on', 'FaultB', 'on', 'FaultC', 'off', 'GroundFault', 'on');
                elseif strcmp(fault_type_val, 'ACG')
                    set_param(blockName, 'FaultA', 'on', 'FaultB', 'off', 'FaultC', 'on', 'GroundFault', 'on');
                elseif strcmp(fault_type_val, 'BCG')
                    set_param(blockName, 'FaultA', 'off', 'FaultB', 'on', 'FaultC', 'on', 'GroundFault', 'on');
                elseif strcmp(fault_type_val, 'ABCG')
                    set_param(blockName, 'FaultA', 'on', 'FaultB', 'on', 'FaultC', 'on', 'GroundFault', 'on');
                elseif strcmp(fault_type_val, 'NOFAULT')
                    set_param(blockName, 'FaultA', 'off', 'FaultB', 'off', 'FaultC', 'off', 'GroundFault', 'off');
                end
                

                % Run simulation
                sim('simulation.slx');
                
                %Simulate voltage waveform calculation using measurement CT
                %Vabc = (5/1.2e3)*ans.Iabc.Data*Rburden+1.65; %including DC offset
                %Vabc2 = (5/1.2e3)*ans.Iabc2.Data*Rburden+1.65; 

                % Save simulation results
                simulationResults{j, z, y} = [ans.Iabc.Data , ans.Iabc2.Data];

                %results(i,j,z,y,:) = [ans.Iabc.Data , ans.Iabc2.Data];
               % w = simulationResults{1,1,1,1};
               %toc
               if y == 11 && z == 6 && j == 8
                   varName = num2str(i);
                   filename = sprintf('result0_%d.mat', i);
                  % filename = simulationResults{i,:,:,:};
                  newsave = pruner(simulationResults);
                   save(filename,"newsave"','-v7.3')
                   simulationResults = cell(len_fault_resistance, len_fault_inception_time, len_fault_types);
                    
               end
            end
        end
    end
end

