function exotime(exofile,time)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% write in NETCDF format
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open file
ncid = netcdf.open(exofile,'NC_WRITE');

% edit time
varid = netcdf.inqVarID(ncid,'time_whole');
netcdf.putVar(ncid,varid,0,time);

% close file
netcdf.close(ncid)
