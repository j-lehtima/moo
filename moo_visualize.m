function moo_visualize(engine, objectives, topsis_scores, pareto_indices, top_n)
    % moo_visualize - Visualisoi MOO-tulosten
    %
    % Input:
    %   engine - EvaluationEngine objekti (tuloksineen)
    %   objectives - ObjectiveFunctions objekti
    %   topsis_scores - TOPSIS-pisteen vektori
    %   pareto_indices - looginen vektori (Pareto-optimaaliset)
    %   top_n - montako TOP-ratkaisua näytetään (default 5)
    
    if nargin < 5
        top_n = 5;
    end
    
    n_objectives = objectives.n_objectives;
    n_solutions = size(engine.results.flattened_objectives, 1);
    
    % ===== KUVA 1: TOPSIS-pisteet vs ratkaisut =====
    figure('Name', 'MOO Analysis - TOPSIS Ranking', 'NumberTitle', 'off');
    
    % --- Subkuva 1: TOPSIS-ranking ---
    subplot(2, 2, 1);
    x_vals = 1:min(top_n, n_solutions);
    y_vals = topsis_scores(x_vals);
    
    % Väritä bars: punainen = Pareto, sininen = muu
    colors_idx = ~pareto_indices(x_vals);
    plot(x_vals(colors_idx), y_vals(colors_idx), 'bs', 'LineWidth', 2, 'MarkerSize', 10, ...
        'DisplayName', 'Ei Pareto-optimal');
    hold on;
    plot(x_vals(~colors_idx), y_vals(~colors_idx), 'r^', 'LineWidth', 2, 'MarkerSize', 12, ...
        'DisplayName', 'Pareto-optimal');
    
    xlabel('Ranking (paras = 1)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('TOPSIS-piste', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Kuva 1: TOP %d TOPSIS-ratkaisut', top_n), 'FontSize', 12, 'FontWeight', 'bold');
    legend('show', 'Location', 'best');
    grid on;
    ylim([min(y_vals)-0.02, max(y_vals)+0.02]);
    set(gca, 'FontSize', 10);
    
    % --- Subkuva 2: Tavoite-pareittain scatter ---
    subplot(2, 2, 2);
    if n_objectives >= 2
        non_pareto_idx = find(~pareto_indices);
        pareto_idx = find(pareto_indices);
        
        plot(engine.results.flattened_objectives(non_pareto_idx, 1), ...
             engine.results.flattened_objectives(non_pareto_idx, 2), ...
             'bo', 'MarkerSize', 5, 'DisplayName', 'Muut ratkaisut');
        hold on;
        if length(pareto_idx) > 0
            plot(engine.results.flattened_objectives(pareto_idx, 1), ...
                 engine.results.flattened_objectives(pareto_idx, 2), ...
                 'r*', 'MarkerSize', 15, 'LineWidth', 2, 'DisplayName', 'Pareto-front');
        end
        
        xlabel(sprintf('%s →', objectives.names{1}), 'FontSize', 11, 'FontWeight', 'bold');
        ylabel(sprintf('%s →', objectives.names{2}), 'FontSize', 11, 'FontWeight', 'bold');
        title(sprintf('Kuva 2: Tavoitteiden %d vs %d scatter', 1, 2), 'FontSize', 12, 'FontWeight', 'bold');
        legend('show', 'Location', 'best');
        grid on;
        set(gca, 'FontSize', 10);
    end
    
    % --- Subkuva 3: Tavoite-arvojen vertailu TOP-ratkaisuille ---
    subplot(2, 2, 3);
    top_solutions_indices = 1:min(top_n, n_solutions);
    obj_vals_top = engine.results.flattened_objectives(top_solutions_indices, :);
    
    % Normalisoidaan näyttöä varten
    obj_vals_norm = obj_vals_top ./ (max(abs(obj_vals_top), [], 1) + 1e-10);
    
    % Piirrä kuvaajia Octave-yhteensopiavasti
    hold off;
    x_positions = 1:size(obj_vals_norm, 1);
    colors_map = hsv(objectives.n_objectives);
    
    for obj_idx = 1:objectives.n_objectives
        plot(x_positions, obj_vals_norm(:, obj_idx), 'o-', 'Color', colors_map(obj_idx, :), ...
            'LineWidth', 2.5, 'MarkerSize', 8, 'DisplayName', objectives.names{obj_idx});
        hold on;
    end
    
    xlabel('TOP-ranking (parhain = 1)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Normalisoidut tavoitearvot [0...1]', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Kuva 3: Tavoitteiden vertailu TOP %d -ratkaisuille', top_n), 'FontSize', 12, 'FontWeight', 'bold');
    legend('show', 'Location', 'best');
    grid on;
    set(gca, 'FontSize', 10);
    
    % --- Subkuva 4: Pareto-front tilastot ---
    subplot(2, 2, 4);
    
    stats_text = sprintf(...
        '┌─ ANALYYSIN YHTEENVETO ─────────────────┐\n',...
        'Pareto-optimaaliset: %d / %d (%.1f%% )\n', ...
        sum(pareto_indices), n_solutions, 100*sum(pareto_indices)/n_solutions);
    
    stats_text = [stats_text sprintf('\n├─ TOP 5 TOPSIS-RATKAISUT: ─────────────┤\n')];
    [~, sorted_idx] = sort(topsis_scores, 'descend');
    for i = 1:min(5, n_solutions)
        idx = sorted_idx(i);
        pareto_marker = '  ';
        if pareto_indices(idx)
            pareto_marker = '★ ';  % Tähti = Pareto
        end
        stats_text = [stats_text sprintf('│ %d. Score=%.4f %s\n', i, topsis_scores(idx), pareto_marker)];
    end
    
    stats_text = [stats_text sprintf('├─ SELITYKSET: ─────────────────────────┤\n')];
    stats_text = [stats_text sprintf('│ ★ = Pareto-optimaalinen                │\n')];
    stats_text = [stats_text sprintf('│ Score = TOPSIS-paremmuusindeksi        │\n')];
    stats_text = [stats_text sprintf('└────────────────────────────────────────┘\n')];
    
    % Yksinkertainen teksti-näyttö ilman text-funktiota
    fprintf('%s', stats_text);
    axis off;
    title('Kuva 4: Analyysitilastot', 'FontSize', 12, 'FontWeight', 'bold');
    
end
