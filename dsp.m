%clear all
function [energies_current,energies_voltage,max_differential] = dsp(type,step_number)
%[I_out] = saturationapplier(20000); %calculate saturated waveform at 20 kA => most distorted
%saturated_waveform = [I_out I_out I_out]; %3 phase
X_current= cell(8, 6, 11);
differential= cell(8,6,11);
%irms = cell(8,6,11);
vdiff = cell(8,6,11);
X_voltage = cell(8,6,11);
%feature_vector = zeros(18,8,6,11);
energies_current = zeros(18,8,6,11);
energies_voltage = zeros(18,8,6,11);
%feature_vector_v = zeros(18,8,6,11);

%% open results
if strcmp(type, '0-20[done]')
    filePath = sprintf('results/%s/result0_%s.mat', type, step_number);
elseif strcmp(type, '21-40[done]')
    filePath = sprintf('results/%s/result20_%s.mat', type, step_number);
elseif strcmp(type, '41-60[done]')
    filePath = sprintf('results/%s/result40_%s.mat', type, step_number);
elseif strcmp(type, '61-80[done]')
    filePath = sprintf('results/%s/result60_%s.mat', type, step_number);
elseif strcmp(type, '81-100[done]')
    filePath = sprintf('results/%s/result80_%s.mat', type, step_number);
end
raw_data= open(filePath).newsave;
max_differential = 0;
one_cycle = ceil(0.02*6268/0.084);
%% DSP
for w = 1:size(raw_data, 1)
    for k = 1:size(raw_data, 2)
        fault_startrow = ceil(((0.02+0.004*k)/0.084)*6268);
        for l = 1:size(raw_data, 3)
            %% calc differential current between phases#
            
            differential{w,k,l}(:,1)= raw_data{w,k,l}(:,4) - raw_data{w,k,l}(:,1);
            differential{w,k,l}(:,2)= raw_data{w,k,l}(:,5) - raw_data{w,k,l}(:,2);
            differential{w,k,l}(:,3)= raw_data{w,k,l}(:,6) - raw_data{w,k,l}(:,3);
            if max(max(differential{w,k,l})>max_differential)
                max_differential = max(differential{w,k,l});
            end

            cycle_diff{w,k,l} = 39*diff((831.4e6*sqrt(2) / 400e3*sqrt(3))*differential{w,k,l}, 1, 1);% calc cycle difference converting from p.u to A
            %%39
            % %% %seperate no faults from faults;
            cycle_diff{w,k,l} = cycle_diff{w,k,l}(fault_startrow:fault_startrow+one_cycle,:); %extract 1 cycle. faults waveforms periodic, therefore average of 1 waveform is the average of 3
            %saturated_waveform = [saturationapplier(max(cycle_diff{w,k,l}(:,1))) saturationapplier(max(cycle_diff{w,k,l}(:,2))) saturationapplier(80*max(cycle_diff{w,k,l}(:,3)))];
            saturated_waveform = [saturationapplier(max(cycle_diff{w,k,l}(:,1))) saturationapplier(13999) saturationapplier(7999)];
            %saturated_waveform30 = [saturationapplier(30000) saturationapplier(14000) saturationapplier(8000)];
            % saturated_waveform = saturated_waveform(one_cycle:one_cycle*2,:);
            saturated_waveform = saturated_waveform(1664:3140,:);
            cycle_diff{w,k,l} = [cycle_diff{w,k,l} ; saturated_waveform];
            % if max_differential(1) > 25
            %     figure()
            %     cycle_diff{w,k,l} = [saturated_waveform30; saturated_waveform];
            %     plot(cycle_diff{w,k,l}(:,:) / 10^3, 'linewidth',2)
            %     %hold on
            %     %plot(saturated_waveform / 10^3)
            %     legend("Phase A","Phase B","Phase C")
            %     xlabel("Time Step",'FontSize', 12, 'FontWeight', 'bold')
            %     ylabel("Current (kA)",'FontSize', 12, 'FontWeight', 'bold')
            %     title("")
            %     ax = gca; % Get current axes
            %     ax.FontSize = 12; % Adjust font size
            %     ax.FontWeight = 'bold'; % Bold font for axes numbers
            %     ax.LineWidth = 1.5; % Thicker axes line
            % end 
            %irms{w,k,l}= rmscalc(cycle_diff{w,k,l},6269)
            vdiff{w,k,l} = (5*400e-3/3e3)*cycle_diff{w,k,l}; 
            %% fft
            X_current{w,k,l} = fft(cycle_diff{w,k,l}); %fft
            X_voltage{w,k,l} = fft(vdiff{w,k,l});
            
            %% function to generate subbands
            
            [s1_start_index,s1_end_index,s2_start_index,s2_end_index,s3_start_index,s3_end_index,s4_start_index,s4_end_index,s5_start_index,s5_end_index,s6_start_index,s6_end_index,M1,M2,M3,M4,M5,M6] = nfinder(X_current{w,k,l});
            [s1_start_index_v,s1_end_index_v,s2_start_index_v,s2_end_index_v,s3_start_index_v,s3_end_index_v,s4_start_index_v,s4_end_index_v,s5_start_index_v,s5_end_index_v,s6_start_index_v,s6_end_index_v,M1_v,M2_v,M3_v,M4_v,M5_v,M6_v] = nfinder(X_voltage{w,k,l});

            s1_fault{w,k,l} = X_current{w,k,l}(s1_start_index:s1_end_index,:);
            s2_fault{w,k,l} = X_current{w,k,l}(s2_start_index:s2_end_index,:);
            s3_fault{w,k,l} = X_current{w,k,l}(s3_start_index:s3_end_index,:);
            s4_fault{w,k,l} = X_current{w,k,l}(s4_start_index:s4_end_index,:);
            s5_fault{w,k,l}= X_current{w,k,l}(s5_start_index:s5_end_index,:);
            s6_fault{w,k,l}= X_current{w,k,l}(s6_start_index:s6_end_index,:);
            energies1_fault(:,w,k,l) = sum(abs(s1_fault{w,k,l})) / M1;
            energies2_fault(:,w,k,l) = sum(abs(s2_fault{w,k,l})) / M2;
            energies3_fault(:,w,k,l) = sum(abs(s3_fault{w,k,l})) / M3;
            energies4_fault(:,w,k,l) = sum(abs(s4_fault{w,k,l})) / M4;
            energies5_fault(:,w,k,l) = sum(abs(s5_fault{w,k,l})) / M5;
            energies6_fault(:,w,k,l) = sum(abs(s6_fault{w,k,l})) / M6;

            s1_fault_voltage{w,k,l} = X_voltage{w,k,l}(s1_start_index_v:s1_end_index_v,:);
            s2_fault_voltage{w,k,l} = X_voltage{w,k,l}(s2_start_index_v:s2_end_index_v,:);
            s3_fault_voltage{w,k,l} = X_voltage{w,k,l}(s3_start_index_v:s3_end_index_v,:);
            s4_fault_voltage{w,k,l} = X_voltage{w,k,l}(s4_start_index_v:s4_end_index_v,:);
            s5_fault_voltage{w,k,l}= X_voltage{w,k,l}(s5_start_index_v:s5_end_index_v,:);
            s6_fault_voltage{w,k,l}= X_voltage{w,k,l}(s6_start_index_v:s6_end_index_v,:);

            %% calculate energies 
            energies1_fault_v(:,w,k,l) = sum(abs(s1_fault_voltage{w,k,l})) / M1_v;
            energies2_fault_v(:,w,k,l) = sum(abs(s2_fault_voltage{w,k,l})) / M2_v;
            energies3_fault_v(:,w,k,l) = sum(abs(s3_fault_voltage{w,k,l})) / M3_v;
            energies4_fault_v(:,w,k,l) = sum(abs(s4_fault_voltage{w,k,l})) / M4_v;
            energies5_fault_v(:,w,k,l) = sum(abs(s5_fault_voltage{w,k,l})) / M5_v;
            energies6_fault_v(:,w,k,l) = sum(abs(s6_fault_voltage{w,k,l})) / M6_v;
            %s1_nofault{w,k,l} = X_nofault{w,k,l}(s1_start_noindex:s1_end_noindex-1,:);
            %s2_nofault{w,k,l} = X_nofault{w,k,l}(s2_start_noindex:s2_end_noindex-1,:);
            %s3_nofault{w,k,l} = X_nofault{w,k,l}(s3_start_noindex:s3_end_noindex-1,:);
            %s4_nofault{w,k,l} = X_nofault{w,k,l}(s4_start_noindex:s4_end_noindex-1,:);
            %s5_nofault{w,k,l}= X_nofault{w,k,l}(s5_start_noindex:s5_end_noindex-1,:);
            %s6_nofault{w,k,l}= X_nofault{w,k,l}(s6_start_noindex:s6_end_noindex-1,:);
            
            %energies1_nofault(:,w,k,l) = sum(abs(s1_nofault{w,k,l})) / M1no;
           % energies2_nofault(:,w,k,l) = sum(abs(s2_nofault{w,k,l})) / M2no;
            %energies3_nofault(:,w,k,l) = sum(abs(s3_nofault{w,k,l})) / M3no;
            %energies4_nofault(:,w,k,l) = sum(abs(s4_nofault{w,k,l})) / M4no;
           % energies5_nofault(:,w,k,l) = sum(abs(s5_nofault{w,k,l})) / M5no;
           % energies6_nofault(:,w,k,l) = sum(abs(s6_nofault{w,k,l})) / M6no;
        end
    end
end
    
% cos_trans1 = dct(log(energies1_fault));
% cos_trans2 = dct(log(energies2_fault));
% cos_trans3 = dct(log(energies3_fault));
% cos_trans4 = dct(log(energies4_fault));
% cos_trans5 = dct(log(energies5_fault));
% cos_trans6 = dct(log(energies6_fault));
% 
% cos_trans1_v = dct(log(energies1_fault_v));
% cos_trans2_v = dct(log(energies2_fault_v));
% cos_trans3_v = dct(log(energies3_fault_v));
% cos_trans4_v = dct(log(energies4_fault_v));
% cos_trans5_v = dct(log(energies5_fault_v));
% cos_trans6_v = dct(log(energies6_fault_v));    
energies_current(1:3,:,:,:) = energies1_fault; %subband 1, phase A,phase B,phase C
energies_current(4:6,:,:,:) = energies2_fault; %subband 2
energies_current(7:9,:,:,:) = energies3_fault; %subband 3
energies_current(10:12,:,:,:) = energies4_fault; %subband 4
energies_current(13:15,:,:,:) = energies5_fault; %subband 5
energies_current(16:18,:,:,:) = energies6_fault; %subban 6

energies_voltage(1:3,:,:,:) = energies1_fault_v; %subband 1, phase A,phase B,phase C
energies_voltage(4:6,:,:,:) = energies2_fault_v; %subband 2
energies_voltage(7:9,:,:,:) = energies3_fault_v; %subband 3
energies_voltage(10:12,:,:,:) = energies4_fault_v; %subband 4
energies_voltage(13:15,:,:,:) = energies5_fault_v; %subband 5
energies_voltage(16:18,:,:,:) = energies6_fault_v; %subban 6
% feature_vector(1:3,:,:,:) = cos_trans1; %subband 1, phase A,phase B,phase C
% feature_vector(4:6,:,:,:) = cos_trans2; %subband 2
% feature_vector(7:9,:,:,:) = cos_trans3; %subband 3
% feature_vector(10:12,:,:,:) = cos_trans4; %subband 4
% feature_vector(13:15,:,:,:) = cos_trans5; %subband 5
% feature_vector(16:18,:,:,:) = cos_trans6; %subban 6
% 
% feature_vector_v(1:3,:,:,:) = cos_trans1_v; %subband 1, phase A,phase B,phase C
% feature_vector_v(4:6,:,:,:) = cos_trans2_v; %subband 2
% feature_vector_v(7:9,:,:,:) = cos_trans3_v; %subband 3
% feature_vector_v(10:12,:,:,:) = cos_trans4_v; %subband 4
% feature_vector_v(13:15,:,:,:) = cos_trans5_v; %subband 5
% feature_vector_v(16:18,:,:,:) = cos_trans6_v; %subban 6
end