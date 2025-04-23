%%%%%%%%%%%%%
% ECE 3610
% INTEL LAB 5 -- Data Augmentation and Software Engineering 2.0
%%%%%%%%%%%%%
% Today we will crowd source data from everyone in the class and
% augment it to classify all 10 digits with near perfect accuracy 
% (>90% at least).

clear; clc; close all; %initialization

%% Load in Merged Training Sets
% When you run this section, it will ask you to select the file you want to
% load.  A file has been prepared for you that combines all of the data
% from everyone in the class.

[file, path] = uigetfile('CrowdSourceDataSet.mat');
load(fullfile(path,file));

% Figure out how many gestures there are.
[h, w] = size(data);
gestureCount = h;
trialCount = w-1;
digits = [data{:,1}];

%% Store Data for Neural Network
%determine gestureCount and trialCount based on data size
gestureCount = height(data); %number of gestures is the number of rows (height)
trialCount = width(data)-1; %number of trials is the number of columns (width)
%features are stored as a stack of 3D images (4D array), initialize to zero
TrainingFeatures = zeros(3,150,1,gestureCount*trialCount); 
%labels are stored as a 1D array, initialize to zero
labels = zeros(1,gestureCount*trialCount); 

k=1; %simple counter
for a = 1:gestureCount %iterate through gestures
    for b = 1:trialCount %iterate through trials
        TrainingFeatures(:,:,:,k) = data{a,b+1}; %put data into image stack
        labels(k) = data{a,1}; %put each label into label stack
        k = k + 1; %increment
    end
end
labels = categorical(labels); %convert labels into categorical

%% Split Training and Testing Data
%selection is an array that will hold the value of 1 when that data is 
%selected to be training data and a 0 when that data is selected to be 
%testing data
selection = ones(1,gestureCount*trialCount); %allocate logical array
                                             %initialize all to 1 at first
selectionIndices = []; %initialization
for b = 1:gestureCount %save 1/4 of the data for testing
    selectionIndices = [selectionIndices,  round(linspace(1,trialCount,round(trialCount/4))) + (trialCount*(b-1))];
end
selection(selectionIndices) = 0; %set logical to zero

%training data
xTrain = TrainingFeatures(:,:,:,logical(selection)); %get subset (3/4) of features to train on
yTrain = labels(logical(selection)); %get subset (3/4) of labels to train on
%testing data
xTest = TrainingFeatures(:,:,:,~logical(selection)); % get subset (1/4) of features to test on
yTest = labels(~logical(selection)); %get subset (1/4) of labels to test on

%% Define Neural Network

[inputsize1,inputsize2,~] = size(TrainingFeatures); %input size is defined by features
numClasses = length(unique(labels)); %output size (classes) is defined by number of unique labels

%%%%%%%%%%%%%%%%%%%%%% YOUR MODIFICATIONS GO HERE %%%%%%%%%%%%%%%%%%%%%%%%%%

learnRate = 0.005; %how quickly network makes changes and learns
maxEpoch = 500; %how long the network learns

layers= [ ... %NN architecture for a conv net
    imageInputLayer([inputsize1,inputsize2,1])
    convolution2dLayer([1,20],20) % [1,1] is the size of the convolution 
                                 % (e.g., 3x10 means across all x,y,z 
                                 % accelerometers and 10 time steps).  
                                 % Change [1,1] to be your desired size for 
                                 % the convolution.
                                 % The second value (initially 20) is the
                                 % number of filters (i.e. features) you
                                 % want the CNN to use.
    batchNormalizationLayer % normalize the inputs to the next layer
    reluLayer % activation layer
    convolution2dLayer([2,4],20) % [1,1] is the size of the convolution 
                                 % (e.g., 3x10 means across all x,y,z 
                                 % accelerometers and 10 time steps).  
                                 % Change [1,1] to be your desired size for 
                                 % the convolution.
                                 % The second value (initially 20) is the
                                 % number of filters (i.e. features) you
                                 % want the CNN to use.
    batchNormalizationLayer % normalize the inputs to the next layer
    reluLayer % activation layer
    fullyConnectedLayer(10)
    batchNormalizationLayer
    dropoutLayer(.02) % Rate of dropout (e.g., 0.01 = 1%). This value is 
                      % reasonable, but feel free to change it!
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ];

%%%%%%%%%%%%%%%%%%%%%%%%% END OF YOUR MODIFICATIONS %%%%%%%%%%%%%%%%%%%%%

options = trainingOptions('sgdm','InitialLearnRate', learnRate, 'MaxEpochs', maxEpoch,...
    'Shuffle','every-epoch','Plots','training-progress', 'ValidationData',{xTest,yTest}); %options for NN

%% Train Neural Network

[myNeuralNetwork, info] = trainNetwork(xTrain,yTrain,layers,options); %output is the trained NN
save("trainedGestureNet.mat", "myNeuralNetwork");

%% Test Neural Network

t = 1:length(info.TrainingAccuracy);
figure();
subplot(2,2,1);
plot(info.TrainingAccuracy,'LineWidth',2,'Color',"#0072BD");
hold on;
plot(t(~isnan(info.ValidationAccuracy)),info.ValidationAccuracy(~isnan(info.ValidationAccuracy)),'--k','LineWidth',2,'Marker','o');
title("Training Accuracy")
legend("Training Accuracy","Validation Accuracy");
xlabel("Iterations");
ylabel("Accuracy (%)");

subplot(2,2,3);
plot(info.TrainingLoss,'LineWidth',2,'Color',"#D95319");
hold on;
plot(t(~isnan(info.ValidationLoss)),info.ValidationLoss(~isnan(info.ValidationLoss)),'--k','LineWidth',2,'Marker','o');
title("Training Loss")
legend("Training Loss","Validation Loss");
xlabel("Iterations");
ylabel("RMSE");

predictions = classify(myNeuralNetwork, xTest)'; %classify testing data using NN
disp("The Neural Network Predicted:"); disp(predictions); %display predictions
disp("Correct Answers"); disp(yTest); % display correct answers
subplot(2,2,[2,4]); confusionchart(yTest,predictions); % plot a confusion matrix
title("Confusion Matrix")

%% View Neural Network

figure(); plot(myNeuralNetwork); % visualize network connections

%% Run-Time Predictions 
% (copy of lab 1 code with determiation replaced with NN code)

% make sure NN exists
if(~exist('myNeuralNetwork'))
    error("You have not yet created your neural network! Be sure you run this section AFTER your neural network is created.");
end

% collect gesture
% ADD YOUR PORT BELOW 
nb = nanobot('/dev/cu.usbmodem101', 115200, 'serial'); 
nb.ledWrite(0); % turn off the LED

numreads = 150; % about 2 seconds (on serial); adjust as needed, but we 
                % will be using a value of 150 for Labs 4 and 5
pause(.5);
countdown(3);
disp("Make A Gesture!");
nb.ledWrite(1);  % Turn on the LED to signify the start of recording data

% Gesture is performed during the segement below
for i = 1:numreads
    val = nb.accelRead();
    vals(1,i) = val.x;
    vals(2,i) = val.y;
    vals(3,i) = val.z;
end

nb.ledWrite(0); % Turn the LED off to signify end of recording data

rtdata = [vals(1,:);vals(2,:);vals(3,:)];

% put accelerometer data into NN input form
xTestLive = zeros(3,150,1,1);
xTestLive(:,:,1,1) = rtdata;

% Prediction based on NN
prediction = classify(myNeuralNetwork,xTestLive);

% Plot with label
figure(); plot(rtdata', 'LineWidth', 1.5); %plot accelerometer traces
legend('X','Y','Z'); ylabel('Acceleration'); xlabel('Time') %label axes
title("Classification:", string(prediction)); %title plot with the label

function countdown(n)
    % countdown(n) counts down from n to 0 with a 1-second pause
    for i = n:-1:0
        fprintf('%d\n', i);  % Display the countdown number
        pause(1);            % Wait for 1 second
    end
end