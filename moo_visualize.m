function moo_visualize(engine, objectives, topsis_scores, pareto_indices, top_n, varying_names, varying_ranges, varying_n_points, all_params)
    % moo_visualize - Visualisoi MOO-tulosten
    %
    % Input:
    %   engine - EvaluationEngine objekti (tuloksineen)
    %   objectives - ObjectiveFunctions objekti
    %   topsis_scores - TOPSIS-pisteen vektori
    %   pareto_indices - looginen vektori (Pareto-optimaaliset)
    %   top_n - montako TOP-ratkaisua näytetään (default kaikki)
    %   varying_names - cell array: dynaamisten parametrien nimet (opt)
    %   varying_ranges - cell array: dynaamisten välit (opt)
    %   varying_n_points - vektori: dynaamisten resoluutiot (opt)
    %   all_params - struct: kaikki parametrit (opt)
    
    if nargin < 5
        top_n = [];
    end
    if nargin < 6
        varying_names = {};
        varying_ranges = {};
        varying_n_points = [];
        all_params = struct();
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
        'LineWidth', 0.6, 'DisplayName', 'TOPSIS score');
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
    legend('Location', 'northeast', 'FontSize', 9, 'Box', 'on');
    set(gca, 'FontSize', 9, 'XLim', [1 n_show]);

    % Subplot 2..N: jokaiselle tavoitteelle oma y-akseli / oma paneeli
    for obj_idx = 1:n_objectives
        subplot(n_objectives + 1, 1, obj_idx + 1);
        plot(ranks, ranked_objectives(:, obj_idx), '-', ...
            'Color', colors_map(obj_idx, :), ...
            'LineWidth', 0.6, ...
            'DisplayName', objectives.names{obj_idx});
        grid on;
        xlabel('Rank (1 = paras TOPSIS)', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Arvo', 'FontSize', 10, 'FontWeight', 'bold');
        title(sprintf('Tavoite %d: %s', obj_idx, objectives.names{obj_idx}), ...
            'FontSize', 11, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 9, 'Box', 'on');
        set(gca, 'FontSize', 9, 'XLim', [1 n_show]);
    end

    % Figure 1 title can be viewed from window name
    % Lisätään figure-titel käyttäen annotation (Octave-yhteensopiva)
    drawnow;

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
        plot(ranks, ranked_solutions(:, k), '-', ...
            'LineWidth', 0.6, ...
            'MarkerSize', 2, ...
            'Color', [0.1 0.35 0.75], ...
            'DisplayName', component_labels{k});
        grid on;
        xlabel('Rank (1 = paras TOPSIS)', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Arvo', 'FontSize', 10, 'FontWeight', 'bold');
        title(sprintf('%s rankin mukaan', component_labels{k}), ...
            'FontSize', 11, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 9, 'Box', 'on');
        set(gca, 'FontSize', 9, 'XLim', [1 n_show]);
    end

    % Figure 2 title can be viewed from window name
    % Lisätään figure-titel käyttäen annotation (Octave-yhteensopiva)
    drawnow;

    % ===== IKKUNA 3: DESIGN PARAMETRIT RANKIN MUKAAN =====
    if ~isempty(varying_names) && ~isempty(varying_ranges) && ~isempty(varying_n_points)
        fig3 = figure(3); clf;
        set(fig3, 'Name', 'Suunnitteluparametrit rankin mukaan', 'NumberTitle', 'off', ...
            'Color', [1 1 1], 'Position', [120 80 1400 950]);

        n_varying = length(varying_names);
        param_colors = lines(n_varying);

        for p_idx = 1:n_varying
            subplot(3, 2, p_idx);

            % Calculate parameter values for each ranked point
            param_vals = zeros(n_show, 1);
            for r = 1:n_show
                flat_idx = ranked_idx(r);
                multi_idx = ind2sub_custom(varying_n_points, flat_idx);
                params = get_params_from_index(multi_idx, varying_names, varying_ranges, ...
                    varying_n_points, all_params);
                param_vals(r) = params.(varying_names{p_idx});
            end

            % Fetch description from all_params
            param_desc = all_params.dynamics.(varying_names{p_idx}).description;
            param_unit = all_params.dynamics.(varying_names{p_idx}).unit;

            plot(ranks, param_vals, '-', ...
                'Color', param_colors(p_idx, :), ...
                'LineWidth', 0.6, ...
                'DisplayName', sprintf('%s (%s)', param_desc, param_unit));
            grid on;
            xlabel('Rank (1 = paras TOPSIS)', 'FontSize', 10, 'FontWeight', 'bold');
            ylabel('Arvo', 'FontSize', 10, 'FontWeight', 'bold');
            title(sprintf('Parametri: %s (%s)', varying_names{p_idx}, param_desc), ...
                'FontSize', 11, 'FontWeight', 'bold');
            legend('Location', 'northeast', 'FontSize', 9, 'Box', 'on');
            set(gca, 'FontSize', 9, 'XLim', [1 n_show]);
        end

        % Fg_1 ja Fg_2 ovat ratkaisukohtaisesti muuttuvia -> piirretään ne käyrinä.
        subplot(3, 2, 4);
        fg1_vals = zeros(n_show, 1);
        fg2_vals = zeros(n_show, 1);

        for r = 1:n_show
            flat_idx = ranked_idx(r);
            multi_idx = ind2sub_custom(varying_n_points, flat_idx);
            params = get_params_from_index(multi_idx, varying_names, varying_ranges, ...
                varying_n_points, all_params);

            fg1_vals(r) = params.A * all_params.frame_mass_per_m * all_params.g;
            fg2_vals(r) = params.G * all_params.drawbar_mass_per_m * all_params.g;
        end

        plot(ranks, fg1_vals, '-', 'LineWidth', 0.6, 'Color', [0.85 0.33 0.10], ...
            'DisplayName', 'Fg_1 = A * frame_mass_per_m * g');
        hold on;
        plot(ranks, fg2_vals, '-', 'LineWidth', 0.6, 'Color', [0.00 0.45 0.74], ...
            'DisplayName', 'Fg_2 = G * drawbar_mass_per_m * g');
        hold off;
        grid on;
        xlabel('Rank (1 = paras TOPSIS)', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Voima [N]', 'FontSize', 10, 'FontWeight', 'bold');
        title('Muuttuvat omamassat: Fg_1 ja Fg_2', 'FontSize', 11, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 9, 'Box', 'on');
        set(gca, 'FontSize', 9, 'XLim', [1 n_show]);

        % Staattisille parametreille oma paneeli (ei overlayta kuvaajien paalle).
        subplot(3, 2, [5 6]);
        axis off;
        if isfield(all_params, 'static')
            static_names = fieldnames(all_params.static);
            static_lines = {'Staattiset parametrit:'};

            for s_idx = 1:length(static_names)
                s_name = static_names{s_idx};

                if endsWith(s_name, '_desc')
                    continue;
                end
                if strcmp(s_name, 'Fg_1') || strcmp(s_name, 'Fg_2')
                    continue;
                end

                s_value = all_params.static.(s_name);
                desc_name = [s_name '_desc'];
                if isfield(all_params.static, desc_name)
                    s_desc = all_params.static.(desc_name);
                    static_lines{end + 1} = sprintf('%s = %.3g (%s)', s_name, s_value, s_desc);
                else
                    static_lines{end + 1} = sprintf('%s = %.3g', s_name, s_value);
                end
            end

            static_lines{end + 1} = 'Fg_1/Fg_2: katso kuvaaja ylaoikealla';
            text(0.01, 0.98, strjoin(static_lines, '\n'), ...
                'Units', 'normalized', ...
                'VerticalAlignment', 'top', ...
                'Interpreter', 'none', ...
                'FontSize', 10);
        end

        % Varmista, että viimeinen ikkuna renderoituu ilman konsolin klikkausta.
        drawnow;
        pause(0.01);
        drawnow;
    end
end
