%% SAMPLE PSUEDOCODE: GESTURE CLASSIFICATION
% initialize variable to track whether we’ve given valid input
% define list of possible output values, in the order that the network was trained on
% while we haven’t given valid input
	% perform gesture classification as we had done in labs 4 and 5 (outputs index of classified output according to the output value list)
	% let user know what was gesture was classified as, and ask to verify
	% perform gesture classification again
	% check if the first gesture was verified according to the second gesture.
		% if so, set valid input variable such that we exit the loop on the next iteration
		% if not, proceed to the next iteration of the loop
clear; clc; close all; %initialization
nb = nanobot('/dev/cu.usbmodem1101', 115200, 'serial'); %connect to MKR
nb.ledWrite(0);

filename = "filename_here.mat";  % add the directory before the filename 
                                 % if needed
data = importdata(filename);

gestureCount = height(data); %number of gestures is the number of rows (height)
trialCount = width(data)-1; %number of trials is the number of columns (width)
Features = zeros(gestureCount, trialCount, 3); % 3 because the accelerometer sends 3 axes of data
for a = 1:gestureCount %iterate through all gestures
    for b = 1:trialCount %iterate through all trials
        singleLetter = data{a,b+1}; %get the individual gesture data   
        
        Features(a,b,1) = rand(1,1); % YOU SHOULD MODIFY THIS LINE
        Features(a,b,2) = rand(1,1); % YOU SHOULD MODIFY THIS LINE
        Features(a,b,3) = rand(1,1); % YOU SHOULD MODIFY THIS LINE

    end
end

%% Store Data as at Stack for Input to Neural Network
% Features are stored as a stack in a 4D array (b/c the MATLAB function 
% requries a 4D array as input; we are only using the 1st and 4 dimensions)
% Initialize to zero.
TrainingFeatures = zeros(3,1,1,gestureCount*trialCount); 
%labels are stored as a 1D array, initialize to zero
labels = zeros(1,gestureCount*trialCount); 

k=1; %simple counter
for a = 1:gestureCount %iterate through gestures
    for b = 1:trialCount %iterate through trials
        TrainingFeatures(:,:,:,k) = Features(a,b,:); %put each feature into image stack
        labels(k) = data{a,1}; %put each label into label stack
        k = k + 1; %increment
    end
end
labels = categorical(labels); %convert labels into categorical

[myNeuralNetwork,info] = trainNetwork(xTrain,yTrain,layers,options); %output is the trained NN

%% Run-Time Predictions 
% (copy of lab 1 code with determiation replaced with NN code)

% make sure NN exists
if(~exist('myNeuralNetwork'))
    error("You have not yet created your neural network! Be sure you" + ...
        " run this section AFTER your neural network is created.");
end

% clear the old singleLetter and nb
clear nb singleLetter;

% ADD YOUR PORT BELOW (SAME AS AT THE BEGINNING OF THE CODE)
nb = nanobot('COM5', 115200, 'serial'); 
nb.ledWrite(0); % turn off the LED

numreads = 150; % about 2 seconds (on serial); adjust as needed, but we 
                % will be using a value of 150 for Labs 4 and 5
pause(.5);
countdown("Beginning in", 3);
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

singleLetter = [vals(1,:);vals(2,:);vals(3,:)];

% put accelerometer data into NN input form
xTestLive = zeros(3,1,1,1); %allocate the size

xTestLive(:,:,:,1) = rand(3,1); % YOU SHOULD MODIFY THIS LINE TO MATCH 
                                % THE TYPE OF TRAINING DATA ABOVE

% Prediction based on NN
prediction = classify(myNeuralNetwork,xTestLive);

% Plot with label
figure(); plot(singleLetter', 'LineWidth', 1.5); %plot accelerometer traces
legend('X','Y','Z'); ylabel('Acceleration'); xlabel('Time') %label axes
title("Classification:", string(prediction)); %title plot with the label

function countdown(n)
    % countdown(n) counts down from n to 0 with a 1-second pause
    for i = n:-1:0
        fprintf('%d\n', i);  % Display the countdown number
        pause(1);            % Wait for 1 second
    end
end