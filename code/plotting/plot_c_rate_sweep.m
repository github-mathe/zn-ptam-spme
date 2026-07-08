clear all; close all;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(genpath(fullfile(repoRoot, 'code')));

% User input: choose a single C-rate to plot.
Crate = 10;

% Optional: set this to 'charge' or 'discharge' if you want to force a mode.
% Leave it empty to auto-detect charge.csv first, then discharge.csv.
expMode = '';

resultsRoot = fullfile(repoRoot, 'results');
processedRoot = fullfile(repoRoot, 'data', 'processed');

% Load geometry from the matching simulation folder.
simFolder = fullfile(resultsRoot, sprintf('Crate_%g', Crate));
geometryFile = fullfile(simFolder, 'Geometry_cell.mat');
if ~isfile(geometryFile)
    error('plot_c_rate_sweep:MissingGeometry', 'Missing geometry file: %s', geometryFile);
end
BASE_sim_geometry = load(geometryFile);

xr = BASE_sim_geometry.cathode.sorted_dofs(:) * 1e6;
xe = BASE_sim_geometry.electrolyte.sorted_dofs(:) * 1e6;
xe_sep = xe(1:BASE_sim_geometry.electrolyte.Ns);

clear BASE_sim_geometry;

% Load simulation results for the selected C-rate.
simFile = fullfile(simFolder, sprintf('sim_%g.csv', Crate));
if ~isfile(simFile)
    error('plot_c_rate_sweep:MissingSimulation', 'Missing simulation file: %s', simFile);
end
sim = readtable(simFile);

% Load experimental results from data/processed/<Crate>/{charge,discharge}.csv.
expFolder = fullfile(processedRoot, sprintf('%g', Crate));
if isempty(expMode)
    candidateFiles = { ...
        fullfile(expFolder, sprintf('charge_%gC.csv',Crate)), ...
        fullfile(expFolder, sprintf('discharge_%gC.csv',Crate)) ...
        };
else
    candidateFiles = {fullfile(expFolder, sprintf('%sC.csv', expMode))};
end

exp = table();
expFile = '';
for k = 1:numel(candidateFiles)
    if isfile(candidateFiles{k})
        expFile = candidateFiles{k};
        exp = readtable(expFile);
        break;
    end
end

if isempty(expFile)
    warning('plot_c_rate_sweep:MissingExperiment', ...
        'No experimental file found in %s. Expected charge.csv or discharge.csv.', expFolder);
end

% Plot styling.
lwexp = 3;
lwsim = 3;
lstexp = '-';
lstsim = '--';
num_of_states = 5;
len_sim = size(sim,1);
state_list = round(1:(len_sim-1)/(num_of_states-1):len_sim);
colors = lines(7);
max_cap = 0.0729*1e3; % mAh, keep your published value here if needed
color_list = winter(num_of_states);
color_list(1,:) = [0, 0, 0];


sim_soc = sim.cell_SOC .* 100;
sim_cap = sim.Capacity .* 1e6;
sim_V = sim.Voltage_pos;
sim_css = sim.Css;
sim_cs_avg = sim.AvgCs;
sim_ce_avg = sim.AvgCe;
sim_cs = table2array(sim(:, contains(sim.Properties.VariableNames, 'Cs_')));
sim_ce = table2array(sim(:, contains(sim.Properties.VariableNames, 'Ce_')));

soc_list = sim_soc(state_list);
time_list = sim.Time(state_list);
labels = strcat("t = ", string(num2cell(round(time_list))), "\newlineSOC = ", string(num2cell(round(soc_list))));

hasExperiment = ~isempty(expFile) && ~isempty(exp.Properties.VariableNames);
if hasExperiment
    exp_soc = exp.soc_cell .* 100;
    exp_cap = exp.C_A_h .* 1e6;
    exp_V = exp.Ewe_V;
end

fprintf('Plots for %gC\n', Crate);

% Voltage vs capacity
figure('units', 'centimeters', 'Position', [0 0 12 8], 'Visible', 'on', 'PaperPositionMode', 'auto');
hold on;
if hasExperiment
    plot(exp_cap, exp_V, lstexp, 'Color', colors(1,:), 'LineWidth', lwexp, 'DisplayName', sprintf('Experiment %gC', Crate));
end
plot(sim_cap, sim_V, lstsim, 'Color', colors(1,:), 'LineWidth', lwsim, 'DisplayName', sprintf('SPMe %gC', Crate));
xlabel('Capacity [\muAh]');
ylabel('Voltage [V]');
legend('Location', 'south');
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'TickDir', 'in', 'Box', 'on');
xlim([-1, max_cap]);

% Voltage vs SOC
figure('units', 'centimeters', 'Position', [0 0 12 8], 'Visible', 'on', 'PaperPositionMode', 'auto');
hold on;
if hasExperiment
    plot(exp_soc, exp_V, lstexp, 'Color', colors(1,:), 'LineWidth', lwexp, 'DisplayName', sprintf('Experiment %gC', Crate));
end
plot(sim_soc, sim_V, lstsim, 'Color', colors(1,:), 'LineWidth', lwsim, 'DisplayName', sprintf('SPMe %gC', Crate));
xlabel('SOC [%]');
ylabel('Voltage [V]');
legend('Location', 'south');
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'TickDir', 'in', 'Box', 'on');
xlim([-1, 101]);

%%%%%%%%%%% Voltage components %%%%%%%%%%%%%
% These components reproduce the stacked voltage decomposition used in the paper.
% The concentration scaling factor below matches the original plotting script.
sim_particle_overpotential = interp_ocp(sim_css / 4637.8, 'soc2v') - interp_ocp(sim_cs_avg / 4637.8, 'soc2v');
sim_OCP_p = interp_ocp(sim_cs_avg / 4637.8, 'soc2v');
sim_etha_pos = sim.Etha_cathode;
sim_etha_neg = sim.Etha_anode;
sim_phie_cathode = sim.delta_Phie - sim_etha_neg;

sim_components = [sim_OCP_p, sim_particle_overpotential, sim_etha_pos, sim_phie_cathode];
V_max = max(sim_V);

figure('Color', 'w', 'Visible', 'on');
clf; hold on;

cum = cumsum(sim_components, 2);
prev = zeros(size(sim_cap));

cols = [ ...
    0.98 0.71 0.38;
    0.55 0.78 0.47;
    0.95 0.52 0.52;
    0.70 0.58 0.82;
    0.75 0.68 0.62];

for k = 1:size(sim_components, 2)
    bot = prev;
    top = cum(:, k);
    fill([sim_cap; flipud(sim_cap)], [top; flipud(bot)], cols(k, :), 'EdgeColor', 'none');
    prev = cum(:, k);
end

plot(sim_cap, sim_V, 'k--', 'LineWidth', 1.5);
plot([sim_cap(1) sim_cap(end)], [V_max V_max], 'k-', 'LineWidth', 1);

ylim([min(sim_V) - 0.02, V_max + 0.02]);
xlim([min(sim_cap) - 0.001, max(sim_cap) + 0.001]);
xlabel('Capacity [\muAh]');
ylabel('Voltage [V]');
box on; set(gca, 'Layer', 'top');

legend({ ...
    'OCP', ...
    'Particle conc. overpotential', ...
    'Reaction overpotential in pos. electrode', ...
    'Overpotential and ohmic loss in electrolyte', ...
    'Voltage'}, ...
    'Location', 'eastoutside');

% Average electrolyte concentration vs SOC
figure('units', 'centimeters', 'Position', [0 0 12 8], 'Visible', 'on', 'PaperPositionMode', 'auto');
scatter(soc_list, sim_ce_avg(state_list), 70, 'b', 'filled', 'MarkerEdgeColor', 'k');
xlabel('SOC [%]');
ylabel('Average Concentration c_{e,avg} [mol/m^3]');
xlim([-1, 101]);
ylim([min(sim_ce_avg) - 10, max(sim_ce_avg) + 10]);
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'TickDir', 'in', 'Box', 'on');

% Electrolyte concentration profiles
figure('units', 'centimeters', 'Position', [0 0 14.3 8], 'Visible', 'on', 'PaperPositionMode', 'auto');
clf;
hold on;
plot(xe, sim_ce(1, :), '-', 'LineWidth', lwsim, 'MarkerSize', 10);
plot(xe, sim_ce(state_list(2:end), :), lstexp, 'LineWidth', lwsim);
x_sep = xline(xe_sep(end), 'LineWidth', 3);
x_sep.Label = 'L_{sep}';
x_sep.LabelHorizontalAlignment = "center";
x_sep.LabelVerticalAlignment = 'middle';
x_sep.LineStyle = '--';
x_sep.HandleVisibility = "off";
xlabel('Thickness [\mum]');
ylabel('Concentration c_e [mol/m^3]');
ylim([min(sim_ce(end, :)), 2010]);
xlim([-1, 216]);
xticks(0:50:200);
colororder(color_list);
colormap(color_list);
legend(labels);
legend show;
legend('Location', 'southoutside', ...
    'Orientation', 'horizontal', ...
    'FontWeight', 'bold', ...
    'IconColumnWidth', 10, ...
    'FontSize', 10, ...
    'Box', 'on');
set(gcf, 'Renderer', 'painters');
set(gca, 'FontName', 'Arial', 'FontSize', 10, ...
     'TickDir', 'in', ...
     'Box', 'on');

% Average solid concentration vs SOC
figure('units', 'centimeters', 'Position', [0 0 12 8], 'Visible', 'on', 'PaperPositionMode', 'auto');
scatter(soc_list, sim_cs_avg(state_list), 70, 'r', 'filled', 'MarkerEdgeColor', 'k');
xlabel('SOC [%]');
ylabel('Average Concentration c_{s,avg} [mol/m^3]');
xlim([-1, 101]);
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'TickDir', 'in', 'Box', 'on');

% Radial solid concentration profiles
figure('PaperUnits', 'centimeters', 'units', 'centimeters', 'Position', [0 0 14.3 8], 'Visible', 'on', 'PaperPositionMode', 'auto');
clf;
plot(xr, sim_cs(1, :), '-', 'LineWidth', lwsim);
hold on;
plot(xr, sim_cs(state_list(2:end), :), lstexp, 'LineWidth', lwsim);

ylim([-400, 5000]);
xlim([-0.1, 10.1]);
xticks(0:1:10);
xlabel('Radius [\mum]');
ylabel({'Concentration c_s [mol/m^3]'});
colororder(color_list);
legend(labels);
legend('Location', 'southoutside', ...
    'Orientation', 'horizontal', ...
    'FontName', 'Arial', ...
    'FontWeight', 'bold', ...
    'FontSize', 10, ...
    'IconColumnWidth', 10, ...
    'Box', 'on');
set(gcf, 'Renderer', 'painters');
set(gca, 'FontName', 'Arial', 'FontSize', 10, ...
     'TickDir', 'in', ...
     'Box', 'on');


