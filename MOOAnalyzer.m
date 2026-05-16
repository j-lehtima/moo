classdef MOOAnalyzer
    % MOOAnalyzer - Monitavoiteoptimointimenetelmät
    %
    % Sisältää:
    % - TOPSIS: Technique for Order Preference by Similarity to Ideal Solution
    % - Pareto-front: Dominoimattomat ratkaisut
    %
    % Esimerkki:
    %   [best_idx, ranking] = MOOAnalyzer.topsis_analysis(obj_values, directions, weights);
    %   pareto_idx = MOOAnalyzer.find_pareto_front(obj_values, directions);
    
    properties (Constant)
        EPSILON = 1e-10  % Numeerinen tarkkuus
    end
    
    methods (Static)
        
        function [best_idx, ranking, scores] = topsis_analysis(obj_values, directions, weights)
            % TOPSIS-menetelmä monitavoiteoptimointiin
            %
            % Input:
            %   obj_values - tavoitearvojen matriisi [n_solutions x n_objectives]
            %   directions - optimointisuunnat [-1=min, +1=max] [1 x n_objectives]
            %   weights - painotukset [1 x n_objectives], summa=1
            %
            % Output:
            %   best_idx - parhaan ratkaisun indeksi
            %   ranking - järjestetty indeksi (paras ensin)
            %   scores - TOPSIS-pisteen jokaista ratkaisua (0...1)
            
            % Validaatio
            [n_solutions, n_objectives] = size(obj_values);
            if length(weights) ~= n_objectives
                error('weights ja objektiivit eivät täsmää');
            end
            if abs(sum(weights) - 1.0) > 1e-6
                warning('Painojen summa ei ole 1.0 - normalisoidaan');
                weights = weights / sum(weights);
            end
            
            % Vaihe 1: Normalisointi (0-1 väli)
            % Jokainen sarake normalisoidaan omaan suuruusluokkaansa
            norm_values = obj_values ./ (sqrt(sum(obj_values.^2, 1)) + MOOAnalyzer.EPSILON);
            
            % Vaihe 2: Painotettu normalisointi
            weighted_norm = norm_values .* weights;
            
            % Vaihe 3: Ihanteellisen ratkaisun määritys
            % Ihanteellinen = parhaaksi suunta jokaiselle tavoitteelle
            ideal_solution = zeros(1, n_objectives);
            worst_solution = zeros(1, n_objectives);
            
            for j = 1:n_objectives
                if directions(j) > 0  % maksimointi
                    ideal_solution(j) = max(weighted_norm(:, j));
                    worst_solution(j) = min(weighted_norm(:, j));
                else  % minimointi
                    ideal_solution(j) = min(weighted_norm(:, j));
                    worst_solution(j) = max(weighted_norm(:, j));
                end
            end
            
            % Vaihe 4: Etäisyyksien laskeminen ihanteesta ja pahimmasta
            separation_from_ideal = sqrt(sum((weighted_norm - ideal_solution).^2, 2));
            separation_from_worst = sqrt(sum((weighted_norm - worst_solution).^2, 2));
            
            % Vaihe 5: TOPSIS-skore
            scores = separation_from_worst ./ ...
                (separation_from_ideal + separation_from_worst + MOOAnalyzer.EPSILON);
            
            % Järjestys (paras = korkein score)
            [~, ranking] = sort(scores, 'descend');
            best_idx = ranking(1);
        end
        
        function pareto_indices = find_pareto_front(obj_values, directions)
            % Etsi Pareto-optimaaliset ratkaisut
            % Ratkaisu on Pareto-optimaalinen jos sitä ei dominoi mikään toinen ratkaisu
            %
            % Input:
            %   obj_values - tavoitearvojen matriisi [n_solutions x n_objectives]
            %   directions - optimointisuunnat [-1=min, +1=max]
            %
            % Output:
            %   pareto_indices - looginen vektori, true = Pareto-optimal
            %
            % Määritelmä: Ratkaisu A dominoi ratkaisua B jos:
            % - A on vähintään yhtä hyvä kaikissa tavoitteissa AND
            % - A on parempi ainakin yhdessä tavoitteessa
            
            n_solutions = size(obj_values, 1);
            pareto_indices = true(n_solutions, 1);

            % Muunna kaikki tavoitteet minimointimuotoon:
            % maksimointitavoitteet kerrotaan -1:llä.
            comparable_values = obj_values;
            maximize_mask = directions > 0;
            comparable_values(:, maximize_mask) = -comparable_values(:, maximize_mask);

            for i = 1:n_solutions
                if ~pareto_indices(i)
                    continue;
                end

                active_indices = find(pareto_indices);
                active_values = comparable_values(active_indices, :);
                current_value = comparable_values(i, :);

                % Onko jokin aktiivinen ratkaisu vähintään yhtä hyvä kaikissa
                % tavoitteissa ja parempi ainakin yhdessä?
                dominates_current = all(bsxfun(@le, active_values, ...
                    current_value + MOOAnalyzer.EPSILON), 2) & ...
                    any(bsxfun(@lt, active_values, ...
                    current_value - MOOAnalyzer.EPSILON), 2);

                if any(dominates_current)
                    pareto_indices(i) = false;
                    continue;
                end

                % Karsi pois ratkaisut, jotka nykyinen ratkaisu dominoi.
                dominated_by_current = all(bsxfun(@ge, active_values, ...
                    current_value - MOOAnalyzer.EPSILON), 2) & ...
                    any(bsxfun(@gt, active_values, ...
                    current_value + MOOAnalyzer.EPSILON), 2);

                pareto_indices(active_indices(dominated_by_current)) = false;
                pareto_indices(i) = true;
            end
        end
        
        function filtered_indices = apply_constraints(obj_values, param_values_flat, ...
                constraint_functions)
            % Suodata Pareto-front suunnittelurajoitteiden perusteella
            %
            % Input:
            %   obj_values - tavoitearvojen matriisi [n_solutions x n_objectives]
            %   param_values_flat - parametrien arvot [n_solutions x n_params]
            %   constraint_functions - cell-array function handles
            %                         jokainen @(params, obj_vals) -> true/false
            %
            % Output:
            %   filtered_indices - looginen vektori, true = täyttää kaikki rajoitteet
            %
            % Esimerkki:
            %   constraints{1} = @(params, objs) params(1) < 2.5;  % B < 2.5
            %   constraints{2} = @(params, objs) objs(1) < 100000;  % Max voima < 100kN
            %   filtered = MOOAnalyzer.apply_constraints(objs, params, constraints);
            
            n_solutions = size(obj_values, 1);
            filtered_indices = true(n_solutions, 1);
            
            for i = 1:n_solutions
                for c_idx = 1:length(constraint_functions)
                    % Tarkista rajoite
                    satisfied = constraint_functions{c_idx}(...
                        param_values_flat(i, :)', obj_values(i, :)');
                    
                    if ~satisfied
                        filtered_indices(i) = false;
                        break;
                    end
                end
            end
        end
        
    end
end
