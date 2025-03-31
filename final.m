%%%%%%%%%%%%%
% ECE 3610
% FINAL PROJECT DRAFT
% Team Members: Guillermo Oviedo, Brian Rassmussen, Kyle 
%%%%%%%%%%%%%

%%%%%%%%%%%%%
% Throughout this project, you will combine feedback from multiple sensors  
% to navigate a game field. This game field will have you perform line
% following, wall following, and odometry. You will be given a start point, from which you must
% complete the three objectives on the track, before returning to the start intersection.
% You will be using a second arduino as a wand for gesture recognition 
% to control which actions the robot takes.
%%%%%%%%%%%%%%

%% 1. CONNECT TO YOUR NANOBOT
clc
clear all
nb = nanobot('COM3', 115200, 'serial');


%% MAIN

n = input('Enter a number: '); %Should be based on magic wand

switch n
    case -1
        % Line Follow
        disp('Line Following')
        linefollow()
    case 0
        % Wall Follow
        disp('Wall Following')
    otherwise
        % Panic
        disp('!!!!')
end



%% FUNCTION: LINE FOLLOWING
%  --Uses IR sensor array
function line_follow()
    % Read reflectance array values
    % First initialize the reflectance array.
    nb.initReflectance();
    % Get a reading
    vals = nb.reflectanceRead();
    
    % Set the motor offset factor (use the value you found earlier)
    mOffScale = 1.13;
    
    % TUNING:
    % Start small (ESPECIALLY with the reflectance values, error can range 
    % from zero to several thousand!).
    % Tip: when tuning kd, it must be the opposite sign of kp to damp
    kp = 1;
    ki = 0.001;
    kd = -0.026;
    
    % Basic initialization
    vals = 0;
    prevError = 0;
    prevTime = 0;
    integral = 0;
    derivative = 0;
    
    % Determine a threshold to detect when white is detected 
    % (will be used as a threshold for all sensors to know if the robot has 
    % lost the line)
    whiteThresh = 260; % Max value detected for all white
    
    % The base duty cycle "speed" you wish to travel down the line with
    % (recommended values are 9 or 10)
    motorBaseSpeed = 11;
    
    tic
    % It can be helpful to initialize your motors to a fixed higher duty cycle
    % for a very brief moment, just to overcome the gearbox force of static
    % friction so that lower duty cycles don't stall out at the start.
    % (recommendation: 10, with mOffScale if needed)
    nb.setMotor(1, mOffScale * 12);
    nb.setMotor(2, -12);
    pause(0.03);
    while (toc < 5)  % Adjust me if you want to stop your line following 
                 % earlier, or let it run longer.
    
    % TIME STEP
    dt = toc - prevTime;
    prevTime = toc;
    
    vals = nb.reflectanceRead();
    vals = [vals.one, vals.two, vals.three, vals.four, vals.five, vals.six];
    
    calibratedVals = zeros(6);
    % Calibrate sensor readings
    for i = 1:6
        calibratedVals(i) = (vals(i) - minVals(i))/(maxVals(i) - minVals(i));
        % overwrite the calculated calibrated values if get a reading 
        % below or above minVals or maxVals, respectively
        if vals(i) < minVals(i)
            calibratedVals(i) = 0;
        end
        if vals(i) > maxVals(i)
            calibratedVals(i) = maxVals(i);
        end
    end
    
    % Designing your error term can sometimes be just as important as the
    % tuning of the feedback loop. In this case, how you define your error
    % term will control how sharp the feedback response is depending on
    % where the line is detected. This is similar to the error term we used
    % in the Sensors Line Detection Milestone. (Use the calibrated values 
    % to determine the error.)
    error = 0.7*calibratedVals(1) + 0.3*calibratedVals(2) + 0.2*calibratedVals(3) - 0.2*calibratedVals(4) - 0.3*calibratedVals(5) - 0.7*calibratedVals(6);
    
    % Calculate I and D terms
    integral = integral + error*dt;
    
    derivative = (error-prevError)/dt;
    
    % Set PID
    control = (kp*error+ki*integral+kd*derivative)/20;
    fprintf('Control - %.2f \n', control)
    
    % STATE CHECKING - stops robot if all sensors read white (lost tracking):
    if (vals(1) < whiteThresh && ...
            vals(2) < whiteThresh && ...
            vals(3) < whiteThresh && ...
            vals(4) < whiteThresh && ...
            vals(5) < whiteThresh && ...
            vals(6) < whiteThresh)
        % Stop the motors and exit the while loop
        nb.setMotor(1, 0);
        nb.setMotor(2, 0);
        break;
    else
        % LINE DETECTED:
        
        % Remember, we want to travel around a fixed speed down the line,
        % and the control should make minor adjustments that allow the
        % robot to stay centered on the line as it moves.
        m1Duty = mOffScale * motorBaseSpeed + control;
        m2Duty = -motorBaseSpeed - control;
       
        % If you're doing something with encoders to derive control, you
        % may want to make sure the duty cycles of the motors don't exceed
        % the maximum speed so that your counts stay accurate.
    
        nb.setMotor(1, m1Duty);
        nb.setMotor(2, m2Duty);
    end
    
    prevError = error;
    end
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
end

%% FUNCTION: WALL FOLLOWING
%  --Uses 2 ultrasonic sensors

% Advancing

% Wall follwing and Stop Condition


%% FUNCTION: ODOMETRY
%  --Uses RGB color sensors

% Encoder Conversion

% Straight-line Odometry

% Angular Odometry

% Motor Speed Capping

% Color Sensing
val = nb.encoderRead(1); %substitute 1 with 2 for second encoder
fprintf('counts since last read: %i, counts per second: %i\n',val.counts,val.countspersec);


%% 5. DISCONNECT
%  Clears the workspace and command window, then
%  disconnects from the nanobot, freeing up the serial port.

clc
delete(nb);
clear('nb');
clear all

%% EXAMPLE: SWITCH STATEMENT
n = input('Enter a number: ');

switch n
    case -1
        disp('negative one')
    case 0
        disp('zero')
    case 1
        disp('positive one')
    otherwise
        disp('other value')
end

%% EXAMPLE: FUNCTION
values = [12.7, 45.4, 98.9, 26.6, 53.1];
[ave,stdev] = stat(values)

function [m,s] = stat(x)
    n = length(x);
    m = sum(x)/n;
    s = sqrt(sum((x-m).^2/n));
end

%% SAMPLE PSUEDOCODE: PID LOOPS
% Setup gain variables
% Initialize integral, previous error, and previous time terms
% Initialize or perform calculations for targets/values your loop will be working with
% tic
% small delay to prevent toc from blowing up derivative term on first loop
% begin while
	% calculate dt based on toc and previous time
	% update previous time
	% take reading of data
	% Perform conditional checking whether we want to exit the loop (e.g. read all black on reflectance array during line following)
		% exit the loop if so, and perform any needed end behaviors (e.g. setting motors to zero)
	% calculate error term
	% use error to calculate/update integral and derivative terms
	% calculate control signal based on error, integral, and derivative
	% update previous error
	% calculate desired setpoint quantities from control signal
	% apply limits to setpoints if needed
	% apply setpoint to plant (e.g. setting duty cycle for motors)


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
%% SAMPLE PSUEDOCODE: LINE FOLLOWING
% Define a motor speed compensation factor if needed
% Set up PID loop
	% After reading data from the necessary sensors, you should check important states for the robot (e.g. reading all black, meaning a stop was encountered, or all white, meaning you lost the line) and handle them appropriately.
	% Error should be calculated such that the robot seeks to center the reflectance array on the line
	% The robot should move at a specified speed forward, and use the control signal adjust the speed to each motor to turn and keep itself on the line
%% SAMPLE PSUEDOCODE: WALL FOLLOWING
%(True distance-maintaining)
% Set up PID loop
	% Check for all black condition (made a complete circle)
	% Calculate error as the difference between the distance you intend to follow and the measured ultrasonic distance
	% Use prior values of error and/or motor setpoints/encoder rates to determine if the robot is reading a point in front of or behind it, and correct the control signal/motor setpoints accordingly to stabilize.

%OR

%(Hacky solution)
% Move forward while reading sensors
	% If reflectance is all black, exit loop
	% if the side ultrasonic reading exceeds a certain value
		% turn by a specified amount (or turn slowly, reading the ultrasonic until you read a new value greater than or equal to the current exceeded value), then proceed
%% SAMPLE PSUEDOCODE: ODOMETRY
%(Straight-line)
% Set up PID loop
	% Using measurements of wheel geometry, calculate the needed encoder counts that each motor needs to go
	% Define a default speed for the robot to move at
	% Calculate the error as being the difference between the motor encoder rates (either countspersec or counts divided by a measured dt)
	% Keep track of the total number of encoder counts for one or both motors and exit the loop and stop the motors once you reach the number of encoder counts needed to travel a certain distance.
		% Alternatively, you could just drive and continue until another condition is met (e.g. the RGB sensor reads red)

%(Angular)
% Set up PID loop
	% Using measurements of wheel geometry, calculate the needed encoder counts that each motor needs to go
	% Similarly to the straight line case, we can monitor the encoder counts/rates until we match the needed value, or come within a certain threshold of it.
%% HELPER FUNCTIONS RECCOMENDATIONS

%turnTillLine(): turns in place (center of mass doesn%t move) until the reflectance sensor reads a  line detected condition.
function turnTillLine()

end

%kickMotors(): briefly sets the motors to a high duty cycle before returning to modify the duty cycle in a function that calls it. Helps to break the static friction of the gearbox so that the motor can operate at lower duty cycles.
function kickMotors()

end

%attemptCenter(): once a line is detected under the reflectance array, kicks the motors before setting them to zero and looping to slowly center the array on the line.

%initAllSensors(): an all-in-one function to initialize the needed sensors that you can run once at the start of your program.

%approachWall(): drives in a straight line until the front ultrasonic sensor reads below a certain value.

%setMotorsToZero(): sets the motors on the robot to 0% duty cycle
function setMotorsToZero

end

%allDark(): checks the reflectance array values to see if all of the values are above the threshold needed to classify as "dark.” Returns true/false.
function isDark = allDark()
    isDark=true;
end

%turnOffLine(): moves the reflectance array off of a line or bar by turning in place by a certain amount or for a certain time.

