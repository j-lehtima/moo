% Test visualization script
fprintf('Starting visualization test...\n');

% Load config and setup
config = design_variables_config();
all_params = struct();
all_params.A = config.dynamics.A.min;
all_params.H = config.static.H;
all_params.K = config.static.K;
all_params.F_1 = config.static.F_1;
all_params.Fg_1 = config.static.Fg_1;
all_params.Fg_2 = config.static.Fg_2;
all_params.J = all_params.A + all_params.H;
all_params.g = config.static.g;
all_params.frame_mass_per_m = config.static.frame_mass_per_m;
all_params.drawbar_mass_per_m = config.static.drawbar_mass_per_m;
all_params.B = config.dynamics.B.min;
all_params.G = config.dynamics.G.min;

varying_names = {'A', 'B', 'G'};
varying_ranges = {[config.dynamics.A.min, config.dynamics.A.max], ...
                   [config.dynamics.B.min, config.dynamics.B.max], ...
                   [config.dynamics.G.min, config.dynamics.G.max]};
varying_n_points = [4, 5, 5];

fixed_names = {'H', 'K', 'F_1', 'g', 'frame_mass_per_m', 'drawbar_mass_per_m', 'Fg_1', 'Fg_2', 'J'};

fprintf('Creating design space...\n');
design_space = DesignSpace(varying_names, varying_ranges, varying_n_points, fixed_names, all_params);

fprintf('Creating objectives...\n');
objectives = ObjectiveFunctions();

fprintf('Running evaluation engine...\n');
engine = EvaluationEngine(design_space, objectives, false);
engine = engine.evaluate_all();

fprintf('Finding Pareto front...\n');
pareto_indices = MOOAnalyzer.find_pareto_front(engine.results.flattened_objectives, objectives.directions);

fprintf('Computing TOPSIS scores...\n');
topsis_scores = MOOAnalyzer.topsis_score(engine.results.flattened_objectives, objectives.directions);

fprintf('Creating visualizations...\n');
try
    moo_visualize(engine, objectives, topsis_scores, pareto_indices, ...
        size(engine.results.flattened_objectives, 1), ...
        varying_names, varying_ranges, varying_n_points, all_params);
    fprintf('✓ Visualizations created successfully\n');
catch ME
    fprintf('ERROR in moo_visualize: %s\n', ME.message);
    fprintf('ID: %s\n', ME.identifier);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  File: %s, Line: %d\n', ME.stack(i).file, ME.stack(i).line);
    end
end

fprintf('\nTest complete. Check for 3 figure windows.\n');
