function [params,xMat,obj_hist] = adagrad(func, params, x0, nIter, stepSize, lower_bound, upper_bound)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Implementation of AdaGrad algorithm
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
% Reference : Duchi, John, Elad Hazan, and Yoram Singer. 
%          "Adaptive subgradient methods for online learning and stochastic optimization." 
%           Journal of Machine Learning Research 12.Jul (2011): 2121-2159.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Use machine precision eps for epsilon
epsilon = sqrt(eps);

% Store the number of decision variables
nDecVar = length(x0);

% Allocate output
xMat = zeros(nDecVar, 1);

% Set the initial guess
xMat = x0;

% Initialise historical gradients
sgHist = zeros(nDecVar, 1);

obj_hist = [];
con_hist = [];
lambda_hist = [];
% Run optimisation
for iter = 1 : 1 : nIter
    [params,~,sgCurr,objective,constraint] =feval(func,xMat,params);


    obj_hist = [obj_hist; objective]; %#ok<*AGROW>
    con_hist = [con_hist; constraint];
    lambda_hist = [lambda_hist; params.obj_con_lambda];

    % Update historical gradients
    sgHist = sgHist + sgCurr.^2;

    % Update decision variables
    xMat = xMat - ...
        stepSize.*sgCurr./(sqrt(sgHist) + epsilon);

    xMat = min(xMat,upper_bound);
    xMat = max(xMat,lower_bound);
    disp(sprintf('iter: %3d   objective         : %e',iter,objective)); %#ok<*DSPS>
    disp(sprintf('Constraint Vioaltion         : %e',constraint)); %#ok<*DSPS>
    save(strcat('adagrad_output_',params.fname,'.mat'))
    %    if mod(iter,params.save_mod) == 0
    %        save(strcat('adagrad_output_',params.fname,'.mat'))
    %    end
end

end
                                                                                                                                        1,1           Top
