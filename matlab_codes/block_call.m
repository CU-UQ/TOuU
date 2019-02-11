function [params, obj_realizations, const_realizations, obj_grads, const_grads] = block_call(input,params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The params structure should contain the following variables, for example:
% params.paraview_save_path = '/home/maute/primitives_code/paraview_save';
% params.run_path = '/home/maute/primitives_code';
% params.code_path = '/home/maute/primitives_code/reference';
% params.fem_bin_exec = '/home/maute/codes/femdoc/bin/femdoc-gcc-serial-acml.opt';
% params.n_call_samples = 40;
% params.batch_size = 10; % Batch size governed by harddrive/filesystem.
% params.num_params = 60; % Total number of parameters
% params.iteration_time = 0; % Should increase with each iteration so paraview can be viewed appropriately Good to start from zero
% input  size is  params.num_params by params.n_call_samples;
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Core of function
obj_realizations = zeros(params.n_call_samples,1);
const_realizations = zeros(params.n_call_samples,1);
obj_grads = zeros(params.num_params,params.n_call_samples);
const_grads = zeros(params.num_params,params.n_call_samples);

for kk = 1:params.batch_size:params.n_call_samples
	% Identify size of batch (can be smaller if final batch necessarily smaller
	current_batch = min(params.n_call_samples-kk+1,params.batch_size);

	% Contains core info for this batch
	current_obj_realizations = zeros(current_batch,1);
	current_const_realizations = zeros(current_batch,1);
	current_obj_grads = zeros(params.num_params,current_batch);
	current_const_grads = zeros(params.num_params,current_batch);

	% Run batch loop in parallel
   for k = 1:current_batch
		folder_string = strcat('folder_',num2str(k));
		unix(sprintf(['cp -R ', params.code_path, ' ', params.run_path, '/', folder_string])); %#ok<*PFBNS>
		cd([params.run_path, '/', folder_string]); % We always explicitly define a full path for saving

		% Write Sample to relevant file
   	        block_write(input,params);       

		% Run Code
		unix(sprintf('sh Run_block_stochgrad.sh &'));

   end
		%Read Output

   for k = 1:current_batch
  	folder_string = strcat('folder_',num2str(k));
	cd([params.run_path, '/', folder_string]);
	while true
		pause(0.1)
		fid = fopen('OptimizationResults_0000.data');
		if fid > -1
		    fclose(fid);
		    break
		end		
	end
	while true
		pause(0.1)
		results = importdata('OptimizationResults_0000.data',',');
		if( size(results,1) > params.num_params)
		    pause(0.1)
		    results = importdata('OptimizationResults_0000.data',',');	
	 	    break
		end
	end	
	current_obj_realizations(k) = results(1,1);
	current_const_realizations(k) = results(1,2);
	temp_obj_grads = results(2:end,1);
        current_obj_grads(:,k) = temp_obj_grads(params.design_ind);
	temp_const_grads = results(2:end,2);
        current_const_grads(:,k) = temp_const_grads(params.design_ind);
	cd([params.run_path]); 
    end

	% Add batch data to collective data
	obj_realizations(kk:kk+current_batch-1) = current_obj_realizations/params.zini;
	const_realizations(kk:kk+current_batch-1) = current_const_realizations/params.gini;
	obj_grads(:,kk:kk+current_batch-1) = current_obj_grads/params.zini;
	const_grads(:,kk:kk+current_batch-1) = current_const_grads/params.gini;

	% Take one of the examples for paraview use
	if (kk == 1) % This /paraview_save folder needs to be made before hand
		cd([params.run_path, '/folder_1']); % Used to be block.e-s.0000, but numbering changed in block prims
		exotime('block.e-s.0000',params.iteration_time); % sets time in exo file
		cd([params.run_path]);
		unix(sprintf(['mv ', params.run_path, '/folder_1/block.e-s.0000 ', params.paraview_save_path, '/paraview_output.e-s.',num2str(params.iteration_time)]));
		params.iteration_time = params.iteration_time+1;
	end
	% Removes Folders
    for k = 1:current_batch
	folder_string = strcat('folder_',num2str(k));
	unix(sprintf(['rm -R' ,' ',params.run_path,'/',folder_string]));
    end
end
