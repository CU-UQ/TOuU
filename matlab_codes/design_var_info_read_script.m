function params = design_var_info_read_script(params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function reads the design variables 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A = csvread([params.code_path,'/Design_var_info.txt']);
params.size_input = size(A,1);
design_ind = find(A(:,5) == 0);
params.design_ind = A(design_ind,4)+1;
write_1 = find(A(:,5) == 1);
params.write_1 = A(write_1,4)+1;
write_2 = find(A(:,5) == 2);
params.write_2 = A(write_2,4)+1;
write_3 = find(A(:,5) == 3);
params.write_3 = A(write_3,4)+1;

end
