%% SAMPLE PSUEDOCODE: PID LOOPS
% Setup gain variables
% Initialize integral, previous error, and previous time terms
% Initialize or perform calculations for targets/values your loop will be working with
% tic
% small delay to prevent toc from blowing up derivative term on first loop
% begin while
	% calculate dt based on toc and previous time
	% update previous time
	% take reading of data
	% Perform conditional checking whether we want to exit the loop (e.g. read all black on reflectance array during line following)
		% exit the loop if so, and perform any needed end behaviors (e.g. setting motors to zero)
	% calculate error term
	% use error to calculate/update integral and derivative terms
	% calculate control signal based on error, integral, and derivative
	% update previous error
	% calculate desired setpoint quantities from control signal
	% apply limits to setpoints if needed
	% apply setpoint to plant (e.g. setting duty cycle for motors)

