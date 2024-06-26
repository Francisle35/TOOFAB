%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Parameters of the model presented in [2] with some changes presented in
% [1]
%
% This file is a part of the TOOlbox for FAst Battery simulation (TOOFAB)
% Github: https://github.com/Zuan-Khalik/TOOFAB
%
% Author: Zuan Khalik (z.khalik@tue.nl)
%
% TOOFAB is licensed under the BSD 3-Clause License
%
% References
% [1] Khalik et al., Model Simplifications and Their Impact on Computational 
% Complexity for an Electrochemistry-Based Battery Modeling Toolbox, 
% Journal of Power Sources, 2021
% [2] Torchio et al., A matlab framework based on a finite novolume model
% suitable for Li-ion battery design, simulation, and control, Journal of
% the Electrochemical Society, 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function p = parameters_LS(gridsize)
%-------------------------------------------------------------------------%
%--- Configuration parameters --------------------------------------------%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
%- Grid Parameters -------------------------------------------------------%
%-------------------------------------------------------------------------%
% Number of nodes (spatial discretization)
if nargin <1
    p.grid.nn = 8;
    p.grid.ns = 8;
    p.grid.np = 12;
    p.grid.nrn = 3;
    p.grid.nrp = 5;
else
    p.grid.nn = gridsize(1);                                                                  %In negative electrode
    p.grid.ns = gridsize(2);                                                                   %In separator
    p.grid.np = gridsize(3);                                                                   %In positive electrode
    p.grid.nrn = gridsize(4);
    p.grid.nrp = gridsize(5);
end

%-------------------------------------------------------------------------%
%- Simulation parameters -------------------------------------------------%
%-------------------------------------------------------------------------%
p.dt = 1; 
p.tol = 1e-2;                                                     %Tolerance for convergence                                                                     
p.iter_max = 1e2;                                                          %Maximum iterations for the inner loop
p.gamma = 1;                                                                %Damping coefficient for update of states
p.Vmin = 2; p.Vmax = 4.5; 
p.verbose = 1;
% Temperature defined to be constant for now. 
p.T_amb = 298.15;
p.thermal_dynamics = 0; 

p.fvm_method = 1; 
p.set_simp = [2 2 2 2 1 0]; 
%-------------------------------------------------------------------------%
%- Material-specific parameters ------------------------------------------%
%- Default parameters are taken from Xia et al. (2017). ------------------%
%-------------------------------------------------------------------------%
% Physical constants
p.F = 96487;                                                                %Faraday's constant [C/mol]
p.R = 8.314;                                                                %Ideal gas constant [J/mol/K]

%Lengths
p.delta_neg = 8.8e-5;                                                        %Neg. electrode thickness [m]
p.delta_pos = 8e-5;                                                       %Pos. electrode thickness [m]
p.delta_sep = 2.5e-5;            
p.R_neg = 2e-6;                                                               %particle radius (for both pos. and neg. electrode) [m]
p.R_pos = 2e-6;
p.R_s = p.R_neg; 

% Porosity
p.epse_neg = 0.485;                                                         %Electrolyte volume fraction at the neg. electrode [-]
p.epse_pos = 0.385;                                                          %Electrolyte volume fraction at the pos. electrode [-]
p.epse_sep = 0.724;                                                          %Electrolyte volume fraction in the seperator [-]
p.epss_neg = 0.4824;                                                            %Active material volume fraction at the neg. electrode [-]
p.epss_pos = 0.59;               
p.p_neg = 4; 
p.p_pos = 4;
p.p_sep = 4;    

% Diffusion coefficients
p.Ds_neg = 3.9e-14;                                                           %Solid-phase Li diffusion coefficient at the neg. electrode [m^2/s]

p.Rf0_neg = 0;
p.Rf0_pos = 0; 
p.Rf_neg = p.Rf0_neg;
p.Rf_pos = p.Rf0_pos; 
% Transport properties
p.t_plus = 0.364;                                                            %Li+ transference number [-]

% Electrode plate area
p.A_surf = 1;                                                            %Electrode plate area [m^2]
p.R_cc = 0; 

% Transfer coefficient of surface reaction
p.alpha_a = 0.5;                                                            %Charge transfer coefficent (anodic) [-]
p.alpha_c = (1-p.alpha_a);                                                            %Charge transfer coefficient (cathodic) [-]

% Maximum concentration of Li-ion on surface of pticles
p.cs_max_neg = 30555;                                                      %Maximum solid-phase concentration at the neg. electrode [mol/m^3]
p.cs_max_pos = 51554;                                                      %Maximum solid-phase concentration at the pos. electrode [mol/m^3]

% Reaction rate constants
p.k0_neg = 5.031e-11*p.F;                                                          %Kinetic constant in the neg. electrode [mol^(-3/2)*m^(-1/2)*s^(-1)]
p.k0_pos =  2.334e-11*p.F;                                                       %Kinetic constant in the pos. electrode [mol^(-3/2)*m^(-1/2)*s^(-1)]

% Solid-phase conductivity 
p.sigma_neg = 100; 
p.sigma_pos = 100;

%Stoichiometries
p.s100_neg = 0.85510;                                                   %Stoichiometry at 100% SoC at the neg. electrode [-]
p.s100_pos = 0.49550;                                                     %Stoichiometry at 100% SoC at the pos. electrode [-]
p.s0_neg = 0.01429;                                                      %Stoichiometry at 0% SoC at the neg. electrode [-]
p.s0_pos = 0.99174;                                                      %Stoichiometry at 0% So

p.ce0 = 1000; 

p.Cbat = -(p.s100_pos-p.s0_pos)*p.epss_pos*p.delta_pos*p.A_surf*p.F*p.cs_max_pos;
p.kappa = @(c,T)(4.1253*1e-2 + 5.007*1e-4*c - 4.7212*1e-7*c.^2 +1.5094*1e-10*c.^3 -1.6018*1e-14*c.^4); 
p.dlnfdx = @(c,T) (0.601-0.24*(c/1000).^0.5+0.983.*(1-0.0052*(T-294))*(c/1000).^1.5)*(1-p.t_plus)^-1-1; 
p.De = @(c,T) (1/3.222722528605264)*7.5e-1*10e-4*10.^(-4.43-54./(T-229-5*(c/1000))-0.22*(c/1000));
p.Ds_pos = @(stoich,T) 1315383.19875943*10.^(-20.26+534.9*(stoich-0.5).^8+2.263*(stoich-0.5).^2); 

% Negative and positive electrode potentials and their derivatives with
% respect to cs_bar

p.U_pos = @(theta_p) (-4.656+88.669*theta_p.^2 - 401.119*theta_p.^4 + 342.909*theta_p.^6 - 462.471*theta_p.^8 + 433.434*theta_p.^10)./...
               (-1+18.933*theta_p.^2-79.532*theta_p.^4+37.311*theta_p.^6-73.083*theta_p.^8+95.96*theta_p.^10);

p.U_neg = @(theta_n) 0.7222 + 0.1387*theta_n + 0.029*theta_n.^0.5 - 0.0172./theta_n + 0.0019./...
                        theta_n.^1.5 + 0.2808*exp(0.9-15*theta_n)-0.7984*exp(0.4465*theta_n - 0.4108);
end