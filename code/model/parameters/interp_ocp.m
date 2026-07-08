function [Vout, SOCout] = interp_ocp(query, mode)
% interp_ocp - Interpolates average OCP vs. SOC from a CSV file
%
% Usage:
%   V = interp_ocp(SOC, 'soc2v')   % Interpolate voltage from SOC
%   SOC = interp_ocp(V, 'v2soc')   % Interpolate SOC from voltage
%
% Inputs:
%   query - value(s) to interpolate (SOC or Voltage)
%   mode  - 'soc2v' or 'v2soc'
%
% Outputs:
%   Vout   - interpolated voltage (if 'soc2v')
%   SOCout - interpolated SOC (if 'v2soc')

% Load the data from CSV
w=warning('off','MATLAB:table:ModifiedAndSavedVarnames');
dataFolder = fullfile(fileparts(mfilename('fullpath')), 'data');
data = readtable(fullfile(dataFolder, 'ocp_charge.csv'));
warning(w);  
SOC_data = data.soc(1:end);
V_data = data.Ewe_V(1:end);

switch mode
    case 'soc2v'
    Vout = interp1(SOC_data, V_data, query,"linear");
    SOCout = [];
    case 'v2soc'
        SOCout = interp1(V_data, SOC_data, query, 'linear');
        Vout = [];
    otherwise
        error('Invalid mode. Use ''soc2v'' or ''v2soc''.');
end
end
