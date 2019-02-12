# TOuU (Topology Optimization under Uncertainty) 

We propose the use of stochastic gradient descent algorithms for Topology optimization under uncertainty (TOuU) in (citation).  To illustrate the approach, we consider a 3D design problem with a structure being subject to uncertain loading and resting on uncertain bedding. The non-design domain is occupied by a material with random stiffness and represents an uncertain bedding. This non-design domain is clamped at the bottom face. At the center of the top face of the design domain, a point load with random  direction is applied. The performance measure of the objective function is the strain energy, and the only constraint is to ensure that the mass-ratio of the structure is no more than 15% of the maximum design mass.

## block_launch.m  
This file sets up the problem, initializes the variables, and calls the Adam optimizer. 
Please change the path variables as necessary, for example, paraview_save_path, code_path, run_path, etc. 
Also, use mkdir if needed to create those directories.

### Variables defined: 
* The param structure contains  
  * paraview_save_path : Indicates the path to save paraview output  
  * code_path : Indicates the path with Matlab codes  
  * run_path : Indicates the path, where FEMDOC run results are saved  
  * n_call_samples : Number of random samples per iteration  
  * n_workers : Number of workers assigned  
  * obj_history : Objective history  
  * con_history : Constraint history  
  * obj_mean_history : History of mean of objective  
  * con_mean_history : History of means of constraints  
  * obj_var_history : History of variance of objective  
  * con_var_history : History of variances of constraints  
  * numcon : Number of constraints  
  * numvar : Number of optimization variables  
  * obj_func : Objective at the current iteration  
  * con_func : Constraints at the current iteration  
  * obj_func_grad : Gradients of the objective with respect to the optimization variables  
  * con_func_grad : Gradients of the constraints with respect to the optimization variables  
  * obj_con_lambda : Penalty to enforce constraints  

* step_size :  learning rate parameter for stochastic gradient descent algorithm  
* optiter : Number of iteration  
* s :  Optimization variables  
* sl : Lower bounds for optimization variables  
* su : Upper bounds for optimization variables  

## Functions used:  
### *adam*, *adagrad* ###   
Adam and AdaGrad optimizers are implemented.  
*Inputs:*   
  * params.eval_name,  
  * params,s,optiter,  
  * step_size,  
  * sl,  
  * su  : defined as above.  

*Outputs:*  
  * params: updated param structure 
  * s: optimization variable
  * obj_hist: objective history

### block_val ###   
Calls two separate functions :  
 *block_call* : to run the forward problem, and to evaluate the gradients  
 *mean_plus_var* : to estimate the robust objective E[f] + λ Var(f), constraints, and their corresponding gradients

*Inputs*:  
  * s, 
  * params

*Outputs*: 
	* params : defined above
	* z : 
	* grad : gradients
	* objective : 
	* constraint : 

### block_call ###  
calls block_write to write FEMDOC input files.  
*Inputs* : 
  * s,  
  * params

*Outputs* :    
  * params : defined above  
  * obj_realizations : n_call_samples number of realizations of the objective  
  * con_realizations : n_call_samples number of realizations of the constraints  
  * obj_grads : corresponding gradients of the objective  
  * con_grads : corresponding gradient of the constraints  

### mean_plus_var ###  
*Inputs*:   
  * params : defined above
  * obj : objective realizations
  * con : constraint realizations
  * obj_grad : objective gradients
  * con_grad : constraint gradients

*Outputs*:
  * params : updated params
  * obj_functional : E[f] + λ Var(f) = R
  * con_functional : E[g] + λ Var(g) = C
  * d_obj_functional :  ∇R
  * d_con_functional : ∇C

### block_write ###   
Writes the FEMDOC input files.  
*Inputs*:  
  * s : optimization variables
  * params : defined above

### design_var_info_read_script ###   
Reads the optimization variables initially.  
*Inputs*: params  
*Outputs*: params  

## Results: ##  

To view the optimized structure go to the paraview_save_path and open the paraview_output.e-s.xx file in Paraview.   

Matlab also saves the params structure with objective and constraint histories in adam_output_block_sg.exo.mat inside the for_simultaneous_runs folder. 

## NOTE: ##
GCMMA codes can be obtained by contacting Prof. K. Svanberg (KTH Royal Institute of Technology).
