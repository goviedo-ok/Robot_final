%% FUNCTION: ODOMETRY
%  --Uses RGB color sensors
function odometry(nb)
    % Color Sensing
    %Take a single RGB color sensor reading
    values = nb.colorRead();
    
    %The sensor values are saved as fields in a structure:
    red = values.red;
    green = values.green;
    blue = values.blue;
    fprintf('red: %.2f, green: %.2f, blue: %.2f\n', red, green, blue);
    
    % Encoder Conversion
    
    % Straight-line Odometry
    
    % Angular Odometry
    
    % Motor Speed Capping
    val = nb.encoderRead(1); %substitute 1 with 2 for second encoder
    fprintf('counts since last read: %i, counts per second: %i\n',val.counts,val.countspersec);
end
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