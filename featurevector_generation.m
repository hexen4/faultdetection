%%%% generate feature vector
function [feature_vector,feature_vector_v,max_differential,max_differential2,max_differential3] = featurevector_generation()
feature_vector = zeros(50,18,8,6,11); %current feature vector
feature_vector_v = zeros(50,18,8,6,11);
% 
% %nofeature_vector = zeros(100,18,8,6,11);
for j = 1:3 %number of big folders
    if j ==1 
        type = '0-20[done]';    
    elseif j ==2 
        type = '21-40[done]';
    elseif j ==3 
        type = '41-60[done]';
    elseif j ==4 
        type = '61-80[done]';
    elseif j ==5 
        type = '81-100[done]';
    end
        if j ==1 
            %[nofeature_vector(i,:,:,:,:),feature_vector(i,:,:,:,:)] = dsp_optimised(type,num2str(i));
            for i= 1:20 %number of steps in folder  
            [feature_vector(i,:,:,:,:),feature_vector_v(i,:,:,:,:),max_differential(i,:)] = dsp(type,num2str(i));
            end
        elseif j ==2 
            for i= 1:20 %number of steps in folder
            %[nofeature_vector(i+20,:,:,:,:),feature_vector(i+20,:,:,:,:)] = dsp_optimised(type,num2str(i));
            [feature_vector(i+20,:,:,:,:),feature_vector_v(i+20,:,:,:,:),max_differential2(i,:)] = dsp(type,num2str(i));
            end
        elseif j ==3 
            %[nofeature_vector(i+40,:,:,:,:),feature_vector(i+40,:,:,:,:)] = dsp_optimised(type,num2str(i));
            for i= 1:10
            [ feature_vector(i+40,:,:,:,:),feature_vector_v(i+40,:,:,:,:),max_differential3(i,:)] = dsp(type,num2str(i));
            end
           % elseif j ==4 
           % [feature_vector(i+60,:,:,:,:),feature_vector_v(i+60,:,:,:,:)]= dsp_optimised(type,num2str(i));
       % elseif j ==5 
            %[nofeature_vector(i+80,:,:,:,:),feature_vector(i+80,:,:,:,:)] = dsp_optimised(type,num2str(i));
           % [feature_vector(i+80,:,:,:,:),feature_vector_v(i+80,:,:,:,:)] = dsp_optimised(type,num2str(i));
        end     


end 
