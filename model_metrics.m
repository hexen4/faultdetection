fault_inception_time = linspace(0.004, 0.024, 6) + 0.02;
fault_inception_time_row = ceil(6269 * fault_inception_time / 0.084); 
fault_detection_label = ones(6269,1);
fault_types = ["AG", "BG", "CG", "AB", "AC", "BC", "ABG", "ACG", "BCG", "ABCG", "NOFAULT"];
 fault_length = linspace(20 * 0.01, 20 * 0.99, 100);
X_current = zeros(50*8*6*11, 18); % Assuming 18 features per vector
X_voltage = zeros(50*8*6*11, 18);
X_nodetection = zeros(50*8*6*11, 18); % Assuming 18 features per vector
detectionIndex = 1; % Initialize a unique index for X_detection
Y_faults = [];
Y_lengths = [];
counter = 0;
for i1 = 1:size(feature_vector, 1)
    counter = counter + 1; %counter for fault length
    for i3 = 1:size(feature_vector, 3)
        for i4 = 1:size(feature_vector, 4)
            Y_faults = [Y_faults fault_types]; 
            for i5 = 1:size(feature_vector, 5)            
            %%unpack featutres
               X_current(detectionIndex, :) = feature_vector(i1, :, i3, i4, i5); 
              % X_voltage(detectionIndex, :) = feature_vector_v (i1, :, i3, i4, i5);
              % X_nodetection(detectionIndex,:) = nofeature_vector(i1,:,i3,i4,i5); 
              %Y_faults = [Y_faults fault_types]; 
                Y_lengths(detectionIndex) = fault_length(counter);
                if mod(detectionIndex,11) == 0
                    Y_detection(detectionIndex) = 0;
                else
                    Y_detection(detectionIndex) = 1;
                end
                detectionIndex = detectionIndex + 1; % Increment the index for each entry
            end
        end
    end
end

% for i= 1:(48000-26400)/11
%     Y_faults = [Y_faults fault_types]; 
% end 
X = [X_current X_voltage];
Y_detection = Y_detection';
Y_lengths = Y_lengths';
Y_faults = categorical(Y_faults'); 
Y_faults_oneHotEncoded = dummyvar(Y_faults);
Y_faults_oneHot = Y_faults_oneHotEncoded(:,2:end);%drop col to avoid multicollinearity
keepIdx = true(size(X,1),1);
keepIdx(11:11:end) = false;
X = X(keepIdx,:);
Y = Y_lengths(keepIdx);

% selectedColumns = X(:, [3, 6, 9, 12, 15, 18]);
% averageOfSelectedColumns = mean(selectedColumns, 2); % 2 indicates that you are taking the mean across the rows. 
% meansVector = [];

% Loop through averageOfSelectedColumns in steps of 528
% for i = 1:480:length(averageOfSelectedColumns)
%     endIndex = min(i+479, length(averageOfSelectedColumns)); % Ensure not going past the end
%     currentMean = mean(averageOfSelectedColumns(i:endIndex)); % Calculate mean for the current segment
%     meansVector(end+1) = currentMean; % Append to the result vector
% end
% % plot(meansVector); 
%X = X(:,1:36);
load('Y_10km.mat')
%load('X_10km.mat')
X = X(:,1:36);
yfit = trainedModel1.predictFcn(X);
numChunks = 50;% Calculate the number of complete chunks
averages = zeros(numChunks, 1); % Preallocate the averages array


for i=1:numChunks
    averages(i) = mean(yfit(1+480*(i-1):480*i));    
end 

errors = averages - fault_length(1:50)';    

%% better error function

error = (1000*abs(yfit - Y_lengths));
stf = std(1000*abs(error));
fault_length2= linspace(10 * 0.01, 10 * 0.99, 50);
plot(fault_length(1:50), abs(errors),'linewidth',2)
%stf = std(1000*abs(error));
ylabel("Average Absolute Error (m)",'FontSize', 12, 'FontWeight', 'bold')
xlabel("Fault Distance (km)",'FontSize', 12, 'FontWeight', 'bold')
ax = gca; % Get current axes
ax.FontSize = 12; % Adjust font size
ax.FontWeight = 'bold'; % Bold font for axes numbers
ax.LineWidth = 1.5; % Thicker axes line
% % %% x setting up
% %X = [X_nodetection;X_detection]; 
% openExample('simscapeelectricalsps/IEEE13NodeTestFeederExample')

%% probability of bad result
A = [errors]; % Replace [your_array] with your actual array
count = sum(A > 300);
