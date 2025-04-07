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
        tic
        while(toc<1)
        front = nb.ultrasonicRead1();
        side = nb.ultrasonicRead2();
        %Take a single ultrasonic reading
        fprintf('Front dist = %0.0f   Side dist = %0.0f\n', front, left);
        end
        disp('Wall Following')
        wall_follow(nb)
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
    % Front Face
    nb.initUltrasonic1('D4','D5') % Use any of the digital pins, ex. D8, D7
    % Side Face
    nb.initUltrasonic2('D3','D7')
end