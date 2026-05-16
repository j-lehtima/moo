classdef EvaluationEngine
    % EvaluationEngine - N-ulotteisen parametritilan arviointia
    %
    % Käy läpi kaikki parametriyhdistelmät, laskee matriisit ja tavoitefunktiot.
    % Tulokset tallennetaan n-ulotteisiin taulukoihin.
    %
    % Esimerkki:
    %   engine = EvaluationEngine(design_space, objectives);
    %   engine = engine.evaluate_all(@matrix_builder_func, constants_struct);
    %   % engine.results.solutions = [n_points(1) x n_points(2) x ... x 6]
    %   % engine.results.objectives = [n_points(1) x n_points(2) x ... x n_objectives]
    
    properties
        design_space          % DesignSpace-objekti
        objectives            % ObjectiveFunctions-objekti
        results               % struct: solutions, objectives, flattened_*
        verbose               % tulostus debug-tietoja
    end
    
    methods
        function obj = EvaluationEngine(design_space, objectives, verbose)
            % Konstruktori
            % verbose (opt): true/false debug-tulostukselle
            
            obj.design_space = design_space;
            obj.objectives = objectives;
            obj.verbose = false;
            
            if nargin > 2
                obj.verbose = verbose;
            end
            
            obj.results = struct();
        end
        
        function obj = evaluate_all(obj)
            % Arvioi kaikki parametriyhdistelmät
            %
            % Käytö:
            %   design_space - DesignSpace objekti (vaihtelevat + kiinteät parametrit)
            %   objectives - ObjectiveFunctions objekti
            %   Ei tarvitse siirtää matrix_builder:ia - käytetään suoraan
            %
            % Luodut tulokset:
            %   obj.results.solutions - n-ulotteinen array [n1 x n2 x ... x 6]
            %   obj.results.objectives - n-ulotteinen array [n1 x n2 x ... x n_obj]
            %   obj.results.flattened_solutions - 2D: [tuples x 6]
            %   obj.results.flattened_objectives - 2D: [tuples x n_obj]
            
            n_params = obj.design_space.n_varying;
            dims = obj.design_space.n_varying_points;
            n_objectives = obj.objectives.n_objectives;
            
            if obj.verbose
                fprintf('Aloitetaan arviointia...\n');
                fprintf('Parametridimensiot: %s\n', sprintf('%d ', dims));
                fprintf('Tavoitteet: %d\n', n_objectives);
            end
            
            % Alusta n-ulotteiset tulostaulukot
            solution_dims = [dims, 6];
            obj_dims = [dims, n_objectives];
            
            obj.results.solutions = zeros(solution_dims);
            obj.results.objectives = zeros(obj_dims);
            
            % Rekursiivinen arviointisykli
            indices = zeros(n_params, 1);
            total_count = prod(dims);
            processed_count = 0;
            
            [obj.results.solutions, obj.results.objectives, processed_count] = ...
                obj.recursive_evaluate(1, indices, ...
                obj.results.solutions, obj.results.objectives, processed_count, total_count);
            
            % Flatten tulokset 2D-muotoon analyysiä varten
            obj.results.flattened_solutions = reshape(obj.results.solutions, [], 6);
            obj.results.flattened_objectives = reshape(obj.results.objectives, [], n_objectives);
            
            if obj.verbose
                fprintf('Arviointia saatu %d kombinaatiota\n\n', processed_count);
            end
        end
        
        function [solutions, objectives, processed_count] = ...
                recursive_evaluate(obj, param_idx, indices, ...
                solutions, objectives, processed_count, total_count)
            % Rekursiivinen silmukka n-ulotteisen parametritilan läpikäyntiin
            
            n_params = obj.design_space.n_varying;
            
            if param_idx > n_params
                % POHJA-TAPAUS: Laske matriisi ja tavoitteet tälle kombinaatiolle
                processed_count = processed_count + 1;
                
                % Kerää parametri-indeksit
                indices_cell = num2cell(indices(1:n_params));
                
                % Hae kaikki parametrit (vaihtelevat + kiinteät)
                params = obj.design_space.get_parameters(indices(1:n_params));
                
                % Laske matriisi (M_x) tälle parametriyhdistelmälle
                M_x = matrix_builder(params);
                
                % Tallennetaan ratkaisu n-ulotteiseen arrayhin
                solutions(indices_cell{:}, :) = M_x';
                
                % Laske tavoitefunktiot
                obj_values = obj.objectives.evaluate_all(M_x);
                objectives(indices_cell{:}, :) = obj_values';
                
                % Debug-tulostus
                if obj.verbose && mod(processed_count, max(1, floor(total_count/10))) == 0
                    fprintf('  %.1f%% valmis (%d/%d)\n', ...
                        100*processed_count/total_count, processed_count, total_count);
                end
                
            else
                % REKURSIIVINEN TAPAUS
                for i = 1:obj.design_space.n_varying_points(param_idx)
                    indices(param_idx) = i;
                    [solutions, objectives, processed_count] = ...
                        obj.recursive_evaluate(param_idx + 1, indices, ...
                        solutions, objectives, processed_count, total_count);
                end
            end
        end
    end
end
