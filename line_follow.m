%% FUNCTION: LINE FOLLOWING
%  --Uses IR sensor array
function line_follow(nb)
    % Read reflectance array values
    % Get a reading
    vals = nb.reflectanceRead();
    
    % Set the motor offset factor (use the value you found earlier)
    mOffScale = 0.95;
    
    %min and max values
    maxVals = [1.421200000000000e+03,9.771000000000000e+02,9.549000000000000e+02,7.308000000000000e+02,8.351000000000000e+02,9.916000000000000e+02];
    minVals = [1.902000000000000e+02,1.418000000000000e+02,1.255000000000000e+02,1.267000000000000e+02,1.406000000000000e+02,1.625000000000000e+02];


    % TUNING:
    % Start small (ESPECIALLY with the reflectance values, error can range 
    % from zero to several thousand!).
    % Tip: when tuning kd, it must be the opposite sign of kp to damp
    kp = 1;
    ki = 0.1;
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
    blackThresh = 850;
    
    % The base duty cycle "speed" you wish to travel down the line with
    % (recommended values are 9 or 10)
    motorBaseSpeed = 10;
    maxEncoderDuty = 3;
    
    tic
    % It can be helpful to initialize your motors to a fixed higher duty cycle
    % for a very brief moment, just to overcome the gearbox force of static
    % friction so that lower duty cycles don't stall out at the start.
    % (recommendation: 10, with mOffScale if needed)
    utils.kickMotors(nb, mOffScale)
    pause(0.03);
    running = true;
    while (running == true)  % Adjust me if you want to stop your line following 
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
    error = 1*calibratedVals(1) + 0.6*calibratedVals(2) + 0.2*calibratedVals(3) - 0.2*calibratedVals(4) - 0.6*calibratedVals(5) - 1*calibratedVals(6);
    
    % Calculate I and D terms
    integral = integral + error*dt;
    
    derivative = (error-prevError)/dt;
    
    % Set PID
    control = (kp*error+ki*integral+kd*derivative);
    if control > maxEncoderDuty
        control = maxEncoderDuty;
    end 
    if control < -maxEncoderDuty
        control = -maxEncoderDuty;
    end
    fprintf('Control: %.2f \n', control)
    
    % STATE CHECKING - stops robot if all sensors read white (lost tracking):
    if (vals(1) < whiteThresh && ...
            vals(2) < whiteThresh && ...
            vals(3) < whiteThresh && ...
            vals(4) < whiteThresh && ...
            vals(5) < whiteThresh && ...
            vals(6) < whiteThresh)
        % Stop the motors and exit the while loop
        disp('all white')
        %while(control > 1)
        nb.setMotor(1, -(mOffScale * 13));
        nb.setMotor(2, 13);
        %end
    elseif(vals(1) > blackThresh && ...
            vals(2) > blackThresh && ...
            vals(3) > blackThresh && ...
            vals(4) > blackThresh && ...
            vals(5) > blackThresh && ...
            vals(6) > blackThresh)  
        running = false;
        disp('line follow stopped')
    else
        % LINE DETECTED:
        
        % Remember, we want to travel around a fixed speed down the line,
        % and the control should make minor adjustments that allow the
        % robot to stay centered on the line as it moves.
        m1Duty = (mOffScale * motorBaseSpeed) + control;
        m2Duty = -(motorBaseSpeed - control);
       
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
    pause(2);
end

%% SAMPLE PSUEDOCODE: LINE FOLLOWING
% Define a motor speed compensation factor if needed
% Set up PID loop
	% After reading data from the necessary sensors, you should check important states for the robot (e.g. reading all black, meaning a stop was encountered, or all white, meaning you lost the line) and handle them appropriately.
	% Error should be calculated such that the robot seeks to center the reflectance array on the line
	% The robot should move at a specified speed forward, and use the control signal adjust the speed to each motor to turn and keep itself on the line