function write_this = block_write(input,params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function writes the input files for FEMDOC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    write_this = zeros(params.size_input,1);
    write_this(params.write_1) = -1;
    write_this(params.write_2) = -1;
    write_this(params.write_3) = -1;
    write_this(params.design_ind) = input;
    fid = fopen('AbsDesVariablesInitial.dat','w');
    fwrite(fid,write_this,'double');
    fclose(fid);
    if params.iter > 200
       dens = 1;
    else
       if params.iter > 10
           dens = 0.05+ (params.iter-10)/190;
       else
           dens = 0.05;
       end
    end
    theta = pi*rand;
    phi = 2*pi*rand;
    xdir = sin(theta)*cos(phi);
    ydir = sin(theta)*sin(phi);
    zdir = cos(theta);   

    write_this_2 = [dens 0.5 xdir ydir zdir rand(1,8)]';   
    
    fid = fopen('block_stochgrad_param.txt','w');
    for k = 1:13    
        fprintf(fid,[num2str(write_this_2(k)),'\n']);
    end
    fclose(fid);
end
  
