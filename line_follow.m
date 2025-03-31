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