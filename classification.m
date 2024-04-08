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
%X = [X_current X_voltage];
Y_detection = Y_detection';
Y_lengths = Y_lengths';
Y_faults = categorical(Y_faults'); 
Y_faults_oneHotEncoded = dummyvar(Y_faults);
Y_faults_oneHot = Y_faults_oneHotEncoded(:,2:end);%drop col to avoid multicollinearity

X = X_current;
cv = cvpartition(size(X, 1), 'HoldOut', 0.2); % Hold out 20% of the data for testing
idxTrain = training(cv);
idxTest = test(cv);

XTrain = X(idxTrain, :);
YTrain = Y_faults(idxTrain);
XTest = X(idxTest, :);
YTest = Y_faults(idxTest);

% Train the C-SVC model using a linear kernel
%SVMModel = fitcsvm(XTrain, YTrain, 'KernelFunction', 'linear', 'BoxConstraint', 1);
template = templateSVM('KernelFunction', 'linear', 'BoxConstraint', 1, 'Standardize', true);
Mdl = fitcecoc(XTrain, YTrain, 'Learners', template, 'Coding', 'onevsall');

% Predict the labels of the test set
YPred = predict(Mdl, XTest);

% Assess the model's performance
accuracy2 = sum(YPred == YTest) / length(YTest);         
confMat = confusionmat(YTest, YPred);

fprintf('Accuracy: %.2f%%\n', accuracy2 * 100);
disp('Confusion Matrix:');
disp(confMat);

