function [params,z,grad,objective,constraint]= block_val(input, params)
    [params, obj_realizations, con_realizations, obj_grads, con_grads] = block_call(input,params); % Runs problems
    [params, z, c, z_grad, c_grad] = feval(params.obj_const_func,params,obj_realizations, con_realizations, obj_grads, con_grads); % Mean plus var    
    params.obj_func = z; % objective
    params.con_func = c; % constraints
    params.obj_func_grad = z_grad; % gradients of objectuve
    params.con_func_grad = c_grad; % gradients of constraints
    objective = z;
    constraint = max(0,c);
    if c <= 0
        c_grad = zeros(size(c_grad));
    end
    grad = z_grad + params.obj_con_lambda*c_grad'; % Need to transpose this because GCMMA used it transposed way, if not correct will lead to huge matrix instead of a vector
end
