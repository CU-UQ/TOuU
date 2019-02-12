function [params,xMat,obj_hist] = adam(func, params, x0, nIter, stepSize, lower_bound, upper_bound)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Implementation of Adam algorithm
%
% Inputs: func = function handle to estimate the objective, constraints, and gradients
%         params = structure array containing all the info
%         x0 = Initial guess
%         nIter = total number of iteration
%         stepSize = learning rate
%         lower_bound = lower bound of the optimization variables
%         upper_bound = upper bound of the optimization variables
% Outputs: params = updated 'params' structure
%          xMat = output
%          obj_hist = objective history
% Reference : Adam: A Method for Stochastic Optimization by Kingma and Ba (2014)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Adam algorithm parameters
beta1 = 0.9;
beta2 = 0.999;

% Use machine precision eps
epsilon = sqrt(eps);

% Store the number of decision variables
nDecVar = length(x0);

% Allocate output
xMat = zeros(nDecVar, 1);

% Set the initial guess
xMat = x0;

% Initialise historical gradients
sgHist = zeros(nDecVar, 1);

m = zeros(nDecVar, 1);
v = zeros(nDecVar, 1);



obj_hist = [];
con_hist = [];
lambda_hist = [];
% Run optimisation
for iter = 1 : 1 : nIter
    [params,~,sgCurr,objective,constraint] =feval(func,xMat,params);
    
    
    obj_hist = [obj_hist; objective]; %#ok<*AGROW>
    con_hist = [con_hist; constraint];
    lambda_hist = [lambda_hist; params.obj_con_lambda];
    
    m = beta1*m + (1-beta1)*sgCurr;
    v = beta2*v + (1-beta2)*(sgCurr.^2);
    mHat = m./(1-beta1^iter);
    vHat = v./(1-beta2^iter);
     
    % Update decision variables
    xMat = xMat - ...
        stepSize.*mHat./(sqrt(vHat) + epsilon);
    
    xMat = min(xMat,upper_bound);
    xMat = max(xMat,lower_bound);
    disp(sprintf('iter: %3d   objective         : %e',iter,objective)); %#ok<*DSPS>
    disp(sprintf('Constraint Vioaltion         : %e',constraint)); %#ok<*DSPS>
    save(strcat('adam_output_',params.fname,'.mat'))

end

end
