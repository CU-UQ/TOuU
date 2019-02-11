%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This file sets up the problem,
% initializes the variables, and 
% calls the Adam optimizer.
%
% NOTE: change paths in the following as necessary.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modify MATLAB library paths
setenv LD_LIBRARY_PATH /opt/apps/intel18/boost/1.64/lib:/opt/apps/intel18/python2/2.7.15/lib:/opt/cray/udreg/default/lib64:/opt/cray/ugni/default/lib64:/opt/cray/pe/pmi/default/lib64:/opt/cray/dmapp/default/lib64:/opt/cray/xpmem/default/lib64:/opt/cray/pe/mpt/7.7.3/gni/mpich-intel/16.0/lib:/opt/intel/debugger_2018/libipt/intel64/lib:/opt/intel/debugger_2018/iga/lib:/opt/intel/compilers_and_libraries_2018.2.199/linux/daal/../tbb/lib/intel64_lin/gcc4.4:/opt/intel/compilers_and_libraries_2018.2.199/linux/daal/lib/intel64_lin:/opt/intel/compilers_and_libraries_2018.2.199/linux/tbb/lib/intel64/gcc4.7:/opt/intel/compilers_and_libraries_2018.2.199/linux/mkl/lib/intel64_lin:/opt/intel/compilers_and_libraries_2018.2.199/linux/ipp/lib/intel64:/opt/intel/compilers_and_libraries_2018.2.199/linux/compiler/lib/intel64_lin:/opt/intel/compilers_and_libraries_2018.2.199/linux/compiler/lib/intel64:/opt/apps/gcc/6.3.0/lib64:/opt/apps/gcc/6.3.0/lib:/opt/apps/matlab/2017b/bin/glnxa64:/opt/apps/matlab/2017b/runtime/glnxa64:/opt/apps/matlab/2017b/sys/java/jre/glnxa64/jre/lib/amd64/server/:/opt/intel/compilers_and_libraries_2018.2.199/linux/mkl/lib/intel64
% Add matlab code path as necessary
addpath(genpath('/corral-repl/projects/TRADES_colorado/work_subhayan/ready_to_ship_codes/touu_example_II/matlab_codes'));
warning('off', 'MATLAB:illConditionedMatrix') % This will typically pop up a lot if not turned off.

% ParaView save path
params.paraview_save_path = '/corral-repl/projects/TRADES_colorado/work_subhayan/ready_to_ship_codes/touu_example_II/paraview_save';

% If you need to make the paraview save directory
%unix(['mkdir ', params.paraview_save_path]);

% The following directory is used for simultaneous runs of the forward model
params.run_path = '/corral-repl/projects/TRADES_colorado/work_subhayan/ready_to_ship_codes/touu_example_II/for_simultaneous_runs';
%unix(sprintf(['mkdir ' params.this_path]));
unix(sprintf(['cd ' params.run_path]));
unix(sprintf(['rm -R' ,' ',params.run_path,'/fold*'])); % remove any preexisting folders
unix(sprintf(['rm ',params.run_path,'/adam_output*'])); % remove results from previous runs
% Path to the FEMDOC files
params.code_path = '/corral-repl/projects/TRADES_colorado/work_subhayan/ready_to_ship_codes/touu_example_II/block_femdoc';
% params.fem_bin_exec = '/corral-repl/projects/TRADES_colorado/codes/femdoc_DARPA/bin/femdoc-icc-serial-mkl.opt';

% Saving information
params.save_mod = 1; % Save one in every params.save_mod iterations
% Configure the forward runs
params.n_call_samples = 4; % Number of random samples used per iteration
params.batch_size = 4; % 
params.n_workers = 4; % Number of workers assigned

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure the optimizer
step_size = 0.35; % learning rate parameter
params.eval_name = 'block_val'; % This is the parallel implementation of forward model solve
params.obj_const_func = 'mean_plus_var'; % The function that evaluates the robust objective
base_file_name = 'block_sg'; % used for paraview output filename
params.obj_con_lambda = 1000; % penalty for constraints
params.std_penalty = 0.0;% controls importance of variance in the robust objective
% other suggested values: 0.01

params.iteration_time = 0; % This is increased at every plotting

% Initialize histories for objective, constraints, etc.
params.reference_output_obj = [];
params.reference_output_cons = [];
params.reference_output_dobj = [];
params.reference_output_dcons = [];
params.obj_history = []; 
params.con_history = []; 
params.obj_mean_history = []; 
params.con_mean_history = []; 
params.obj_var_history = []; 
params.con_var_history = []; 

params = design_var_info_read_script(params);

params.numcon=1; % Number of constraints
params.numvar=size(params.design_ind,1); % Number of design variables
params.num_params=params.numvar; % Number of design variables (different name for some compatibility)

optiter = 400; % Total number of optimization iteration
sample_size_per_iter = params.n_call_samples; % Different sample sizes per iteration to do.
n_iter_sizes = size(sample_size_per_iter,2);
params.fname=strcat(base_file_name,'.exo'); % Creates filenames with .exo and .mat that will be saved to params.run_path

params.iter = 0;
s = zeros(params.size_input,1);
s = s(params.design_ind);
s = 0.5+0.0125*ones(size(s));

% Set lower and upper bounds
sl = zeros(params.numvar,1);
su = ones(params.numvar,1);

% Normalize the objective and constraint (if needed)
params.zini = 1;
params.gini = 1;

% stochastic gradient descent algorithm
[params,s,obj_hist] = adam(params.eval_name, params,s,optiter,step_size,sl,su);
