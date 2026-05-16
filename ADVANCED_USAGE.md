%% ======================================================================
% ADVANCED USAGE - MOO Framework
% ======================================================================
%
% Tämä tiedosto näyttää edistyneet käyttötapaukset ja helper-funktiot
%
% ======================================================================
%
% KÄYTTÖTAPAUS 1: Tulosten poimiminen ja tarkastelu
% ──────────────────────────────────────────────────
%
% Suorita ensin main.m:
%   run main.m
%
% Sitten poimi tulokset:
%   results = moo_extract_results(engine, objectives, topsis_scores, ...
%       pareto_indices, design_space, 10);  % TOP 10
%
% Näytä TOP TOPSIS-ratkaisut:
%   disp(results.best_topsis_table);
%
% Näytä TOP Pareto-ratkaisut:
%   disp(results.top_pareto_table);
%
% Tilastot:
%   fprintf('Pareto-optimaaliset: %d / %d (%.1f%%)\n', ...
%       results.n_pareto, results.n_total_solutions, ...
%       results.pareto_percentage);
%
%
% KÄYTTÖTAPAUS 2: Parhaan ratkaisun parametrien tunnistaminen
% ────────────────────────────────────────────────────────────
%
% Hae parhaan TOPSIS-ratkaisun parametrit:
%   best_idx = results.best_overall_idx;
%   best_params = moo_get_param_values(best_idx, design_space);
%   fprintf('Paras ratkaisu:\n');
%   for i = 1:design_space.n_dimensions
%       fprintf('  %s = %.3f\n', design_space.param_names{i}, best_params(i));
%   end
%
% Hae TOP 5 parametrit:
%   top_5_idx = results.best_topsis_idx(1:5);
%   top_5_params = moo_get_param_values(top_5_idx, design_space);
%   % Näytä taulukossa:
%   for i = 1:5
%       fprintf('Top %d: ', i);
%       for j = 1:design_space.n_dimensions
%           fprintf('%s=%.2f ', design_space.param_names{j}, top_5_params(i,j));
%       end
%       fprintf('→ Score=%.4f\n', results.best_topsis_scores(i));
%   end
%
%
% KÄYTTÖTAPAUS 3: Tulosten vienti CSV-tiedostoon
% ───────────────────────────────────────────────
%
% Vie TOP 10 TOPSIS-ratkaisut:
%   results = moo_extract_results(engine, objectives, topsis_scores, ...
%       pareto_indices, design_space, 10);
%   writetable(results.best_topsis_table, 'top_10_topsis.csv');
%
% Vie TOP Pareto-ratkaisut:
%   writetable(results.top_pareto_table, 'top_pareto.csv');
%
% Vie KAIKKI ratkaisut yhteen suureen taulukkoon:
%   all_results = table(...
%       (1:size(engine.results.flattened_objectives, 1))', ...
%       topsis_scores, ...
%       pareto_indices, ...
%       engine.results.flattened_objectives);
%   writetable(all_results, 'all_solutions.csv');
%
%
% KÄYTTÖTAPAUS 4: Suunnittelurajoitteiden soveltaminen
% ──────────────────────────────────────────────────────
%
% Määritä rajoitteet:
%   constraints = {};
%   constraints{1} = @(params, objs) params(1) > 1.5 && params(1) < 2.5;
%   constraints{2} = @(params, objs) params(2) > 2.0 && params(2) < 2.9;
%   constraints{3} = @(params, objs) objs(1) < 100000;  % Max voima
%
% Sovella rajoitteet:
%   param_values_all = moo_get_param_values(...
%       (1:size(engine.results.flattened_objectives, 1))', design_space);
%   
%   filtered_idx = MOOAnalyzer.apply_constraints(...
%       engine.results.flattened_objectives, param_values_all, constraints);
%
%   % Näytä vain rajoitteita täyttävät ratkaisut:
%   fprintf('Rajoitteita täyttävät: %d / %d\n', sum(filtered_idx), length(filtered_idx));
%
%   % Hae paras rajoitteita täyttävä ratkaisu:
%   filtered_scores = topsis_scores;
%   filtered_scores(~filtered_idx) = -inf;
%   [~, best_filtered_idx] = max(filtered_scores);
%   best_filtered_params = moo_get_param_values(best_filtered_idx, design_space);
%
%
% KÄYTTÖTAPAUS 5: Tavoitepainotuksien herkkyysvaikutus
% ──────────────────────────────────────────────────────
%
% Tutki kuinka TOPSIS-painotuksien muutos vaikuttaa rankingiin:
%
% % Skenario 1: Painota maksimi voimaa
%   obj_func_1 = ObjectiveFunctions();
%   obj_func_1.weights = [0.7, 0.1, 0.1, 0.1];  % Maksimi voima hallitsee
%   [best_1, ~, scores_1] = MOOAnalyzer.topsis_analysis(...
%       engine.results.flattened_objectives, obj_func_1.directions, ...
%       obj_func_1.weights);
%
% % Skenario 2: Tasapainotetut painotukset
%   obj_func_2 = ObjectiveFunctions();
%   obj_func_2.weights = [0.25, 0.25, 0.25, 0.25];
%   [best_2, ~, scores_2] = MOOAnalyzer.topsis_analysis(...
%       engine.results.flattened_objectives, obj_func_2.directions, ...
%       obj_func_2.weights);
%
% % Vertaile tuloksia:
%   fprintf('Skenario 1 paras: idx=%d, score=%.4f\n', best_1, scores_1(best_1));\n   fprintf('Skenario 2 paras: idx=%d, score=%.4f\n', best_2, scores_2(best_2));
%   % Jos eri - painotuksilla on vaikutusta!
%
%
% KÄYTTÖTAPAUS 6: Pareto-frontin yksityiskohtainen analyysi
% ──────────────────────────────────────────────────────────
%
% Hae kaikki Pareto-optimaaliset ratkaisut:
%   pareto_objs = engine.results.flattened_objectives(pareto_indices, :);
%   pareto_sols = engine.results.flattened_solutions(pareto_indices, :);
%   pareto_idx_list = find(pareto_indices);
%
% Näytä Pareto-frontin koko eri tavoitepareille:
%   figure('Name', 'Pareto Front Analysis');
%   for pair = 1:3
%       subplot(1, 3, pair);
%       scatter(pareto_objs(:, pair), pareto_objs(:, pair+1), 50, 'r', 'filled');
%       xlabel(objectives.names{pair});
%       ylabel(objectives.names{pair+1});
%       title('Pareto-front');
%       grid on;
%   end
%
%
% KÄYTTÖTAPAUS 7: Parametri-herkkyysvaikutus analyysi
% ────────────────────────────────────────────────────
%
% Tutki kuinka parametrin muutos vaikuttaa tavoitteisiin:
%   % Fiksoi parametri 1 (B) ja vaihtele parametri 2 (G)
%   B_fixed = 2.0;
%   mask = false(size(engine.results.flattened_objectives, 1), 1);
%   
%   for i = 1:size(engine.results.flattened_objectives, 1)
%       param_vals = moo_get_param_values(i, design_space);
%       if abs(param_vals(1) - B_fixed) < 0.05  % Lähellä B=2.0?
%           mask(i) = true;
%       end
%   end
%   
%   G_vals = moo_get_param_values(find(mask), design_space);
%   objs_for_fixed_B = engine.results.flattened_objectives(mask, :);
%   
%   % Piirrä miten G:n muutos vaikuttaa tavoitteisiin:
%   figure;
%   for obj_idx = 1:objectives.n_objectives
%       subplot(2, 2, obj_idx);
%       plot(G_vals, objs_for_fixed_B(:, obj_idx), 'o-');
%       xlabel('G');
%       ylabel(objectives.names{obj_idx});
%       title(sprintf('%s (B=%.1f)', objectives.names{obj_idx}, B_fixed));
%       grid on;
%   end
%
%
% KÄYTTÖTAPAUS 8: Riskivalikointi Pareton ratkaisuista
% ────────────────────────────────────────────────────
%
% Ei ole yhtä "oikeaa" ratkaisua - valitse erilaisten kriteereiden mukaan:
%
% % Konservatiivinen (pienin maksimi-voima):
%   [~, conservative_idx] = min(engine.results.flattened_objectives(pareto_indices, 1));
%   conservative_idx = find(pareto_indices)(conservative_idx);
%
% % Aggressiivinen (suurin pienin voima):
%   [~, aggressive_idx] = max(engine.results.flattened_objectives(pareto_indices, 3));
%   aggressive_idx = find(pareto_indices)(aggressive_idx);
%
% % Tasapainotettu (paras TOPSIS-score):
%   [~, balanced_idx] = max(topsis_scores(pareto_indices));
%   balanced_idx = find(pareto_indices)(balanced_idx);
%
% % Vertaile:
%   fprintf('Konservatiivinen: idx=%d\n', conservative_idx);
%   fprintf('Aggressiivinen: idx=%d\n', aggressive_idx);
%   fprintf('Tasapainotettu: idx=%d\n', balanced_idx);
%
%
% ======================================================================
