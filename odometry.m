%% FUNCTION: ODOMETRY
%  --Uses RGB color sensors
classdef odometry
    methods(Static)
        % Reads the RGB color sensor and returns a structure with the values
        function values = readColorSensor(nb)
            values = nb.colorRead();
            red = values.red;
            green = values.green;
            blue = values.blue;
            fprintf('red: %.2f, green: %.2f, blue: %.2f\n', red, green, blue);
        end
        
        % Moves the robot in a straight line for the specified distance
        function moveDistance(nb, distance)
            % Encoder Conversion Constants - based on robot geometry
            wheelDiameter = 7;    % cm
            wheelBase = 13.5;       % cm
            countsPerRotation = 1440; % encoder counts per wheel rotation
            distancePerCount = pi * wheelDiameter / countsPerRotation; % cm per encoder count
            
            % Calculate required encoder counts
            targetCounts = distance / distancePerCount;
            
            % PID constants for straight-line control
            Kp = 0.5;
            Ki = 0.01;
            Kd = -0.1;
            
            % Initialize PID variables
            integral = 0;
            prevError = 0;
            totalCounts1 = 0;
            totalCounts2 = 0;
            motorBaseSpeed = 12;
            
            % Reset encoders
            nb.encoderReset(1);
            nb.encoderReset(2);
            
            % Main control loop
            while (totalCounts1 + totalCounts2)/2 < targetCounts
                % Read encoders
                enc1 = nb.encoderRead(1);
                enc2 = nb.encoderRead(2);
                
                % Update total counts
                totalCounts1 = totalCounts1 + enc1.counts;
                totalCounts2 = totalCounts2 + enc2.counts;
                
                % Calculate error (difference in motor speeds)
                error = enc1.countspersec - enc2.countspersec;
                
                % PID calculation
                integral = integral + error;
                derivative = error - prevError;
                correction = Kp * error + Ki * integral + Kd * derivative;
                prevError = error;
                
                % Apply speeds with correction
                leftSpeed = motorBaseSpeed - correction;
                rightSpeed = motorBaseSpeed + correction;
                
                % Motor Speed Capping to ensure values stay within valid range
                leftSpeed = max(0, min(100, leftSpeed));
                rightSpeed = max(0, min(100, rightSpeed));
                
                % Set motor speeds
                nb.motorPower(1, leftSpeed);
                nb.motorPower(2, rightSpeed);
                
                % Short delay
                pause(0.05);
            end
            
            % Stop motors when target is reached
            nb.motorPower(1, 0);
            nb.motorPower(2, 0);
        end
        
        % Rotates the robot by the specified angle in degrees
        function rotate(nb, angle)
            % Encoder Conversion Constants - based on robot geometry
            wheelDiameter = 9.6;    % cm (adjust to your robot's wheels)
            wheelBase = 14.0;       % cm (distance between wheels)
            countsPerRotation = 1440; % encoder counts per wheel rotation
            distancePerCount = pi * wheelDiameter / countsPerRotation; % cm per encoder count
            
            % Convert angle to radians and calculate arc length
            angleRad = deg2rad(angle);
            arcLength = (wheelBase/2) * angleRad;
            
            % Calculate required encoder counts for rotation
            % For turning, one wheel moves forward, one backward
            targetCounts = abs(arcLength / distancePerCount);
            
            % Initialize variables
            totalCounts1 = 0;
            totalCounts2 = 0;
            rotationSpeed = 10;
            
            % Set direction based on angle sign
            if angle > 0
                leftDir = -1;  % counter-clockwise: left wheel backward
                rightDir = 1;  % right wheel forward
            else
                leftDir = 1;   % clockwise: left wheel forward
                rightDir = -1; % right wheel backward
            end
            
            
            
            % Main rotation loop
            while (abs(totalCounts1) + abs(totalCounts2))/2 < targetCounts
                % Read encoders
                enc1 = nb.encoderRead(1);
                enc2 = nb.encoderRead(2);
                
                % Update total counts
                totalCounts1 = totalCounts1 + enc1.counts;
                totalCounts2 = totalCounts2 + enc2.counts;
                
                % Set motor powers with appropriate directions
                nb.setMotor(1, leftDir * rotationSpeed);
                nb.setMotor(2, -(rightDir * rotationSpeed));
                
                % Short delay
                pause(0.05);
            end
            
            % Stop motors when target is reached
            nb.setMotor(1, 0);
            nb.setMotor(2, 0);
        end
    end
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