% Minimal test - write directly to file
fid = fopen('test_direct_output.txt', 'w');

fprintf(fid, 'Starting test...\n');

try
    config = design_variables_config();
    fprintf(fid, 'Config loaded\n');
    
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
    
    fprintf(fid, 'Creating design space...\n');
    design_space = DesignSpace(varying_names, varying_ranges, varying_n_points, fixed_names, all_params);
    fprintf(fid, 'Design space created\n');
    
    fprintf(fid, 'Creating objectives...\n');
    objectives = ObjectiveFunctions();
    fprintf(fid, 'Objectives created\n');
    
    fprintf(fid, 'Running evaluation...\n');
    engine = EvaluationEngine(design_space, objectives, false);
    engine = engine.evaluate_all();
    fprintf(fid, 'Evaluation complete, n_solutions=%d\n', size(engine.results.flattened_objectives, 1));
    
    fprintf(fid, 'Finding Pareto front...\n');
    pareto_indices = MOOAnalyzer.find_pareto_front(engine.results.flattened_objectives, objectives.directions);
    fprintf(fid, 'Pareto: %d solutions\n', sum(pareto_indices));
    
    fprintf(fid, 'Computing TOPSIS...\n');
    [~, ~, topsis_scores] = MOOAnalyzer.topsis_analysis(engine.results.flattened_objectives, objectives.directions, objectives.weights);
    fprintf(fid, 'TOPSIS complete, scores=%d values\n', length(topsis_scores));
    
    fprintf(fid, 'Creating visualizations...\n');
    moo_visualize(engine, objectives, topsis_scores, pareto_indices, ...
        size(engine.results.flattened_objectives, 1), ...
        varying_names, varying_ranges, varying_n_points, all_params);
    fprintf(fid, 'Visualizations created\n');
    
    fprintf(fid, 'SUCCESS\n');
catch ME
    fprintf(fid, 'ERROR: %s\n', ME.message);
    fprintf(fid, 'ID: %s\n', ME.identifier);
end

fclose(fid);
