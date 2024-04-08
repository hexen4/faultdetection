clc;
clear all;
%mdl = 'x4Nodes.slx';
%open(mdl)
%sim(mdl);
%fault in zone 4

%%differential stuff
%fournodes_fault_at_four = [ans.Iabc, ans.Iabc2, ans.Iabc3, ans.Iabc4, ans.Iabc5];
load("fournodes_fault_at_four.mat");
Iabc = big_matrix(1);
Iabc2 = big_matrix(2);
Iabc3 = big_matrix(3);
Iabc4 = big_matrix(4);
Iabc5 = big_matrix(5);

zone1 = Iabc2 - Iabc;
zone2 = Iabc3 - Iabc2;
zone3 = Iabc4 - Iabc3;
zone4 = Iabc5 - Iabc4;

zone1_data = [min(zone1) max(zone1)];
zone2_data = [min(zone2) max(zone2)];
zone3_data = [min(zone3) max(zone3)];
zone4_data = [min(zone4) max(zone4)];

big_matrix_fault = [zone1_data; zone2_data; zone3_data; zone4_data];

%%no faults
%mdl = 'x4Nodes.slx';
%open(mdl)
%sim(mdl);

%fournodes_no_fault = [ans.Iabc, ans.Iabc2, ans.Iabc3, ans.Iabc4, ans.Iabc5];
load("fournodes_no_fault.mat");
Iabc = fournodes_no_fault(1);
Iabc2 = fournodes_no_fault(2);
Iabc3 = fournodes_no_fault(3);
Iabc4 = fournodes_no_fault(4);
Iabc5 = fournodes_no_fault(5);

zone1_no = Iabc2 - Iabc;
zone2_no = Iabc3 - Iabc2;
zone3_no = Iabc4 - Iabc3;
zone4_no = Iabc5 - Iabc4;

zone1_data_no = [min(zone1_no) max(zone1_no)];
zone2_data_no = [min(zone2_no) max(zone2_no)];
zone3_data_no = [min(zone3_no) max(zone3_no)];
zone4_data_no = [min(zone4_no) max(zone4_no)];

%big_matrix_no = [zone1_data_no; zone2_data_no; zone3_data_no; zone4_data_no];
%bar(big_matrix_no)
%xlabel("Zones")
%ylabel("Differential Current")
plot(zone4_no)
hold on
plot(zone4)