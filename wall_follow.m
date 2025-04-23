%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTION: WALL FOLLOWING
%  --Uses 2 ultrasonic sensors
function wall_follow(nb)
    avgScaleFactor = 62.741;
    resolution = 0.2;
    
    minRange = 90;
    maxRange = 1400;
    
    
    % Set the motor offset factor (use the value you found earlier)
    mOffScale = 0.95;
    
    %Tuning
    kp = 2;
    ki = 0.1;
    kd = -0.026;

    desired_distance = 10;

    % Basic initialization
    vals = 0;
    prevError = 0;
    prevTime = 0;
    integral = 0;
    derivative = 0;

    % The base duty cycle "speed" you wish to travel down the line with
    % (recommended values are 9 or 10)
    motorBaseSpeed = 10;

    disp('approaching wall')
    utils.approachWall(nb)
    disp('Wall seen')

    odometry.rotate(nb,90);
    odometry.rotate(nb,100);



    tic
    utils.kickMotors(nb,mOffScale)
    pause(0.5)
    % Advancing
    while (~utils.allDark(nb))
        % TIME STEP
        dt = toc - prevTime;
        prevTime = toc;

        pulseVal = nb.ultrasonicRead1();
        cmVal = pulseVal / avgScaleFactor;
        fprintf("Last read: %0.1f cm\n",cmVal); 

        
        error = desired_distance - cmVal;
        
        %round(interp1([minRange,maxRange], [0,motorBaseSpeed] , pulseVal)); % linear interpolation based on custom data. HINT: see lab3 or lab4's use of it
        
        % Calculate I and D terms
        integral = integral + error*dt;
    
        derivative = (error-prevError)/dt;
    
        % Set PID
        control = (kp*error+ki*integral+kd*derivative);
        fprintf('Control: %.2f \n', control)

        if (control < -2.5)
            control = -2.5;
        end
        if (control > 2.5)
            control = 2.5;
        end

        m1Duty = (mOffScale * motorBaseSpeed) - control;
        m2Duty = -(motorBaseSpeed+control);

        nb.setMotor(1, m1Duty);
        nb.setMotor(2, m2Duty);
        prevError = error;
    end
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    pause(0.03)
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