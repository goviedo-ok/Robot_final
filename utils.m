%% HELPER FUNCTIONS RECCOMENDATIONS
classdef utils
    methods(Static)
        function [m,s] = stat(x)
            n = length(x);
            m = sum(x)/n;
            s = sqrt(sum((x-m).^2/n));
        end
        
        function rotate(nb, moffScale, direction)
           %Right
           if (direction == 1)
               nb.setMotor(1, moffScale * 12)
           %Left
           elseif (direction == -1)
               nb.setMotor(2, moffScale * 12)
           end
        end
        
        %kickMotors(): briefly sets the motors to a high duty cycle before returning 
        %to modify the duty cycle in a function that calls it. Helps to break the 
        %static friction of the gearbox so that the motor can operate at lower duty cycles.
        function kickMotors(nb, mOffScale)
            nb.setMotor(1, mOffScale * 13);
            nb.setMotor(2, -13);
            pause(0.5)
        end
        
        %attemptCenter(): once a line is detected under the reflectance array, 
        %kicks the motors before setting them to zero and looping to slowly center 
        % the array on the line.
        function attemptCenter()
        
        end
        
        %approachWall(): drives in a straight line until the front ultrasonic 
        %sensor reads below a certain value.
        function approachWall(nb)
            mOffScale = 1.16; % Start with 1 so both motors have same duty cycle.

            motorBaseSpeed = 11;
            
            % Set the duty cycle of each motor
            m1Duty = mOffScale * motorBaseSpeed;
            m2Duty = -motorBaseSpeed;
            
            tic
            nb.setMotor(1, mOffScale * 12);
            nb.setMotor(2, -12);
            pause(0.03);
            while (nb.ultrasonicRead1 > 1200) % adjust the time to test if robot goes in straight line
                            % (shorter time saves battery; or longer tests longer path)
                nb.setMotor(1, m1Duty);
                nb.setMotor(2, m2Duty);
            end
            % Turn off the motors
            nb.setMotor(1, 0);
            nb.setMotor(2, 0);
            pause(1);
        end
        
        %setMotorsToZero(): sets the motors on the robot to 0% duty cycle
        function setMotorsToZero
        
        end
        
        %allDark(): checks the reflectance array values to see if all of the values
        %are above the threshold needed to classify as "dark.” Returns true/false.
        function isDark = allDark(nb)
            vals = nb.reflectanceRead();
            vals = [vals.one, vals.two, vals.three, vals.four, vals.five, vals.six];
            blackThresh = 850;
            if(vals(1) > blackThresh && ...
            vals(2) > blackThresh && ...
            vals(3) > blackThresh && ...
            vals(4) > blackThresh && ...
            vals(5) > blackThresh && ...
            vals(6) > blackThresh)  
            isDark = true;
            else
            isDark=false;
            end
        end
        
        %turnOffLine(): moves the reflectance array off of a line or bar by turning
        %in place by a certain amount or for a certain time.
    end
end
