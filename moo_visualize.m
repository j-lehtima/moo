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
        top_n = [];
    end
    n_objectives = objectives.n_objectives;
    n_solutions = size(engine.results.flattened_objectives, 1);

    [~, ranking] = sort(topsis_scores, 'descend');

    % Käytä oletuksena kaikkia ratkaisuja.
    n_show = n_solutions;
    if ~isempty(top_n)
        n_show = min(top_n, n_solutions);
    end
    ranked_idx = ranking(1:n_show);

    ranked_objectives = engine.results.flattened_objectives(ranked_idx, :);
    ranked_solutions = engine.results.flattened_solutions(ranked_idx, :);
    ranked_pareto = pareto_indices(ranked_idx);
    ranks = (1:n_show)';

    % ===== IKKUNA 1: TOPSIS-RANK VS TAVOITTEET =====
    fig1 = figure(1); clf;
    set(fig1, 'Name', 'TOPSIS-Rankattu Tavoitevertailu', 'NumberTitle', 'off', ...
        'Color', [1 1 1], 'Position', [80 40 1350 900]);

    colors_map = lines(n_objectives);

    % Subplot 1: TOPSIS-score rankin mukaan
    subplot(n_objectives + 1, 1, 1);
    plot(ranks, topsis_scores(ranked_idx), '-', 'Color', [0.15 0.15 0.15], ...
        'LineWidth', 1.8, 'DisplayName', 'TOPSIS score');
    hold on;
    pareto_ranks = ranks(ranked_pareto);
    if ~isempty(pareto_ranks)
        plot(pareto_ranks, topsis_scores(ranked_idx(ranked_pareto)), 'o', ...
            'MarkerSize', 5, 'Color', [0.85 0.2 0.2], ...
            'DisplayName', 'Pareto-ratkaisu');
    end
    hold off;
    grid on;
    xlabel('Rank (1 = paras TOPSIS)', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('TOPSIS', 'FontSize', 10, 'FontWeight', 'bold');
    title(sprintf('TOPSIS-järjestys (n = %d)', n_show), 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9, 'Box', 'on');
    set(gca, 'FontSize', 9, 'XLim', [1 n_show]);

    % Subplot 2..N: jokaiselle tavoitteelle oma y-akseli / oma paneeli
    for obj_idx = 1:n_objectives
        subplot(n_objectives + 1, 1, obj_idx + 1);
        plot(ranks, ranked_objectives(:, obj_idx), '-', ...
            'Color', colors_map(obj_idx, :), ...
            'LineWidth', 1.8, ...
            'DisplayName', objectives.names{obj_idx});
        grid on;
        xlabel('Rank (1 = paras TOPSIS)', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Arvo', 'FontSize', 10, 'FontWeight', 'bold');
        title(sprintf('Tavoite %d: %s', obj_idx, objectives.names{obj_idx}), ...
            'FontSize', 11, 'FontWeight', 'bold');
        legend('Location', 'best', 'FontSize', 9, 'Box', 'on');
        set(gca, 'FontSize', 9, 'XLim', [1 n_show]);
    end

    sgtitle(sprintf('TOPSIS-rankattu tavoitenakyma, kaikki ratkaisut (n = %d)', n_show), ...
        'FontSize', 14, 'FontWeight', 'bold');

    % ===== IKKUNA 2: M_x-KOMPONENTIT RANKIN MUKAAN =====
    fig2 = figure(2); clf;
    set(fig2, 'Name', 'M_x-elementit rankin mukaan', 'NumberTitle', 'off', ...
        'Color', [1 1 1], 'Position', [100 100 1400 850]);

    component_labels = {
        'M_x(1) = F_a',
        'M_x(2) = F_b',
        'M_x(3) = F_c',
        'M_x(4) = F_d',
        'M_x(5) = F_e',
        'M_x(6) = F_f'
    };

    for k = 1:6
        subplot(2, 3, k);
        plot(ranks, ranked_solutions(:, k), 'o-', ...
            'LineWidth', 2.0, ...
            'MarkerSize', 6, ...
            'Color', [0.1 0.35 0.75], ...
            'DisplayName', component_labels{k});
        grid on;
        xlabel('Rank (1 = paras TOPSIS)', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Arvo', 'FontSize', 10, 'FontWeight', 'bold');
        title(sprintf('%s rankin mukaan', component_labels{k}), ...
            'FontSize', 11, 'FontWeight', 'bold');
        legend('Location', 'best', 'FontSize', 9, 'Box', 'on');
        set(gca, 'FontSize', 9, 'XLim', [1 n_show]);
    end

    sgtitle(sprintf('M_x-elementtien rankattu jakauma (n = %d)', n_show), ...
        'FontSize', 14, 'FontWeight', 'bold');
end
