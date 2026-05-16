function results_summary = moo_extract_results(engine, objectives, topsis_scores, ...
    pareto_indices, design_space, top_n)
    % moo_extract_results - Poimi ja järjestele MOO-analyysin tulokset
    %
    % Input:
    %   engine - EvaluationEngine objekti
    %   objectives - ObjectiveFunctions objekti
    %   topsis_scores - TOPSIS-pisteen vektori
    %   pareto_indices - looginen vektori Pareto-optimaaleille
    %   design_space - DesignSpace objekti
    %   top_n - montako top-ratkaisua palautetaan (default 5)
    %
    % Output:
    %   results_summary - struct: .best_topsis, .pareto_solutions, jne.
    %
    % Esimerkki:
    %   results = moo_extract_results(engine, objectives, scores, pareto_idx, ds, 5);
    %   % Näytä parhaat TOPSIS-ratkaisut:
    %   disp(results.best_topsis_table);
    %   % Vie CSV:ksi:
    %   writetable(results.best_topsis_table, 'top_solutions.csv');
    
    if nargin < 6
        top_n = 5;
    end
    
    n_solutions = size(engine.results.flattened_objectives, 1);
    n_objectives = objectives.n_objectives;
    n_params = design_space.n_dimensions;
    
    %% TOPSIS-ranking
    [~, topsis_ranking] = sort(topsis_scores, 'descend');
    top_topsis_idx = topsis_ranking(1:min(top_n, n_solutions));
    
    %% Pareto-optimaaliset
    pareto_idx_list = find(pareto_indices);
    [~, pareto_topsis_ranking] = sort(topsis_scores(pareto_idx_list), 'descend');
    top_pareto_idx = pareto_idx_list(pareto_topsis_ranking(1:min(top_n, length(pareto_idx_list))));
    
    %% Rakenna tulostaulukot
    
    % TOP TOPSIS-ratkaisut
    results_summary.best_topsis_idx = top_topsis_idx;
    results_summary.best_topsis_scores = topsis_scores(top_topsis_idx);
    results_summary.best_topsis_objectives = engine.results.flattened_objectives(top_topsis_idx, :);
    results_summary.best_topsis_solutions = engine.results.flattened_solutions(top_topsis_idx, :);
    
    % TOP Pareto-ratkaisut
    results_summary.top_pareto_idx = top_pareto_idx;
    results_summary.top_pareto_scores = topsis_scores(top_pareto_idx);
    results_summary.top_pareto_objectives = engine.results.flattened_objectives(top_pareto_idx, :);
    results_summary.top_pareto_solutions = engine.results.flattened_solutions(top_pareto_idx, :);
    
    % Yhteenveto-tilastot
    results_summary.n_total_solutions = n_solutions;
    results_summary.n_pareto = sum(pareto_indices);
    results_summary.pareto_percentage = 100 * sum(pareto_indices) / n_solutions;
    results_summary.best_overall_idx = topsis_ranking(1);
    results_summary.best_overall_score = topsis_scores(topsis_ranking(1));
    
    % Luo taulukot visualisaatiota / export-käyttöä varten
    results_summary.best_topsis_table = ...
        create_results_table(top_topsis_idx, topsis_scores, ...
        engine.results.flattened_objectives, objectives, 'TOPSIS TOP');
    
    results_summary.top_pareto_table = ...
        create_results_table(top_pareto_idx, topsis_scores, ...
        engine.results.flattened_objectives, objectives, 'PARETO TOP');
    
end

function table_out = create_results_table(indices, scores, objectives, objectives_config, name_prefix)
    % Aputoiminto: Luo taulukko tuloksista
    
    n_objectives = size(objectives, 2);
    n_rows = length(indices);
    
    % Alusta cell-array
    data = cell(n_rows, 2 + n_objectives);
    
    % Ranking
    for i = 1:n_rows
        data{i, 1} = i;
    end
    
    % Indeksit
    for i = 1:n_rows
        data{i, 2} = indices(i);
    end
    
    % Tavoitearvot
    for i = 1:n_rows
        for j = 1:n_objectives
            data{i, 2+j} = objectives(indices(i), j);
        end
    end
    
    % Luo taulukko
    var_names = [{'Ranking', 'Index'}, ...
        objectives_config.names'];
    
    table_out = cell2table(data, 'VariableNames', var_names);
end
