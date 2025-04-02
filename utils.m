%% HELPER FUNCTIONS RECCOMENDATIONS
classdef utils
    methods(Static)
        function [m,s] = stat(x)
            n = length(x);
            m = sum(x)/n;
            s = sqrt(sum((x-m).^2/n));
        end
        
        %turnTillLine(): turns in place (center of mass doesn%t move) until the 
        %reflectance sensor reads a  line detected condition.
        function turnTillLine()
           disp('meow');
        end
        
        %kickMotors(): briefly sets the motors to a high duty cycle before returning 
        %to modify the duty cycle in a function that calls it. Helps to break the 
        %static friction of the gearbox so that the motor can operate at lower duty cycles.
        function kickMotors()
        
        end
        
        %attemptCenter(): once a line is detected under the reflectance array, 
        %kicks the motors before setting them to zero and looping to slowly center 
        % the array on the line.
        function attemptCenter()
        
        end
        
        %initAllSensors(): an all-in-one function to initialize the needed sensors 
        %that you can run once at the start of your program.
        
        %approachWall(): drives in a straight line until the front ultrasonic 
        %sensor reads below a certain value.
        
        %setMotorsToZero(): sets the motors on the robot to 0% duty cycle
        function setMotorsToZero
        
        end
        
        %allDark(): checks the reflectance array values to see if all of the values
        %are above the threshold needed to classify as "dark.” Returns true/false.
        function isDark = allDark()
            isDark=true;
        end
        
        %turnOffLine(): moves the reflectance array off of a line or bar by turning
        %in place by a certain amount or for a certain time.
    end
end
