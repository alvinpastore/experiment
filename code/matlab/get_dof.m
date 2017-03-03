function [ dof ] = get_dof(learning_rules)
%GET_DOF Transforms the list of learning rule configurations into a vector
%each element of the vector is number of parameters 
%(degrees of freedom) for each configuration

    dof = strcmp(learning_rules,'avg_tracking')*2 + strcmp(learning_rules,'q_learning')*3;

end

