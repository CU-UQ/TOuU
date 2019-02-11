function [params, obj_functional, con_functional, d_obj_functional, d_con_functional] = mean_plus_var(params,obj,con,obj_grad,con_grad)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Evaluates R = E[f]+lambda*Var(f)
%  C = E[g]+lambda*Var(g) 
%  nabla R
%  nabla C
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_samples = size(obj,1);
obj_mean = sum(obj)/n_samples; % Mean functional
con_mean = sum(con)/n_samples; % Mean functional
obj_sum_sq = sum(obj.^2);
con_sum_sq = sum(con.^2);
obj_var = abs(obj_sum_sq/n_samples - obj_mean.^2);
obj_var = (n_samples/(n_samples-1))*obj_var; % correction for unbiasedness
con_var = abs(con_sum_sq/n_samples - con_mean.^2);
con_var = (n_samples/(n_samples-1))*con_var; % correction for unbiasednesscd 
obj_functional = obj_mean + params.std_penalty*obj_var; % Full stochastic functional
con_functional = con_mean + params.std_penalty*con_var; % Full stochastic functional

d_obj_sum = sum(obj_grad,2);
d_con_sum = sum(con_grad,2);
d_obj_mean = d_obj_sum/n_samples; % Mean gradient
d_con_mean = d_con_sum/n_samples; % Mean gradient

if params.std_penalty ~= 0 % Adjust d_obj_var and d_con_var to work with variance instead of Standard Deviation
    d_obj_var = obj_grad*obj - obj_mean.*d_obj_sum;
    d_con_var = con_grad*con - con_mean.*d_con_sum;
	if (obj_var > 0) % Sometimes problem is rather degenerate
        d_obj_var = 2*d_obj_var./n_samples; % divide by n/2 for appropriate constant. This completes chain rule
        d_obj_var = (n_samples/(n_samples-1))*d_obj_var; % correction for unbiasedness
	else
	    d_obj_var = zeros(params.numvar,1);
	end

	if (con_var > 0) % Sometimes problem is rather degenerate
        d_con_var = 2*d_con_var./n_samples; % divide by n/2 for appropriate constant. This completes chain rule
        d_con_var = (n_samples/(n_samples-1))*d_con_var; % correction for unbiasedness
	else
	    d_con_var = zeros(params.numvar,1);
	end

	d_obj_functional = d_obj_mean + params.std_penalty.*d_obj_var;
	d_con_functional = d_con_mean + params.std_penalty.*d_con_var;
else
	d_obj_functional = d_obj_mean;
	d_con_functional = d_con_mean;
end
d_con_functional = d_con_functional';
params.obj_history = vertcat(params.obj_history,obj_functional);
params.con_history = vertcat(params.con_history,con_functional);
params.obj_mean_history = vertcat(params.obj_mean_history,obj_mean);
params.con_mean_history = vertcat(params.con_mean_history,con_mean);
params.obj_var_history = vertcat(params.obj_var_history,obj_var);
params.con_var_history = vertcat(params.con_var_history,con_var);
