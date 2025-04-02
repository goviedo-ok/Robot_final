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

%% CONNECT TO YOUR NANOBOT
clc
clear all
nb = nanobot('COM3', 115200, 'serial');

%% MAIN
n = input('Enter a number: '); %Should be based on magic wand

init_all(nb);

switch n
    case 0
        % Line Follow
        disp('Line Following')
        rotate()
        line_follow(nb)
        wall_follow()
        rotate()
        line_follow()
        line_follow()
        line_follow()
        rotate()
        line_follow()
        rotate()
        odometry()
    case 1
        % Wall Follow
        disp('Wall Following')
        utils.turnTillLine()
        values = [12.7, 45.4, 98.9, 26.6, 53.1];
        [ave,stdev] = utils.stat(values);
    otherwise
        % Panic
        disp('!!!!')
end

%% DISCONNECT
%  Clears the workspace and command window, then
%  disconnects from the nanobot, freeing up the serial port.

clc
delete(nb);
clear('nb');
clear all

%% LOCAL FUNCTIONS
function init_all(nb)
    % Initialize the reflectance array
    nb.initReflectance();
    % Initialize the ultrasonic sensor with TRIGPIN, ECHOPIN
    %nb.initUltrasonic('D2','D3') % Use any of the digital pins, ex. D8, D7
end