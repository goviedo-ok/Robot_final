%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTION: WALL FOLLOWING
%  --Uses 2 ultrasonic sensors
avgScaleFactor = 62.741;
resolution = 0.2;

minRange = 90;
maxRange = 1400;

% Advancing
while (true)
    pulseVal = nb.ultrasonicRead();
    cmVal = pulseVal / avgScaleFactor;
    fprintf("Last read: %0.1f cm\n",cmVal);
    relBright = round(interp1([minRange,maxRange], [0,225] , pulseVal)); % linear interpolation based on custom data. HINT: see lab3 or lab4's use of it
    if (relBright > 255)
        relBright = 255;
    elseif (relBright < 0)
        relBright = 0;
    end
    nb.setRGB(255-relBright, 0, 0); % So that LED intensity decreases at further distance
    pause(0.05); % Don't gotta go too fast
end


% Wall follwing and Stop Condition

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