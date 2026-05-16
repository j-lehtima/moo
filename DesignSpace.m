classdef DesignSpace
    % DesignSpace - Suunnittelutilan (decision variables) hallinta
    %
    % Laajennettu versio joka mahdollistaa:
    % - Mitä tahansa määrää muuttuvia parametreja (varying_params)
    % - Kiinteitä parametreja joilla on default-arvot (fixed_params)
    %
    % Esimerkki:
    %   all_params = load_default_parameters();
    %   
    %   % Skenario 1: Vaihtele B ja G, pidä muut kiinteinä
    %   ds = DesignSpace(...
    %       {'B', 'G'}, ...           % varying_params nimet
    %       {[1, 3], [1.8, 3]}, ...   % varying_params välit
    %       [15, 15], ...              % varying_params resoluutiot
    %       {'A', 'H', 'K', 'F_1'}, ...% fixed_params nimet
    %       all_params);               % kaikki default-arvot
    %
    %   % Skenario 2: Vaihtele B, G, K (3 parametria), pidä muut kiinteinä
    %   ds = DesignSpace(...
    %       {'B', 'G', 'K'}, ...
    %       {[1, 3], [1.8, 3], [0.5, 1.5]}, ...
    %       [15, 15, 8], ...
    %       {'A', 'H', 'F_1'}, ...
    %       all_params);
    
    properties
        % Vaihtelevat parametrit (design variables)
        varying_names        % cell array: vaihtelevan parametrin nimet
        varying_ranges       % cell array: [min, max] välit kullekin
        varying_values       % cell array: lasketut arvojen vektorit
        n_varying_points     % vektori: kuinka monta pistettä per parametri
        n_varying            % skalaari: vaihtelevan parametrin lukumäärä
        
        % Kiinteät parametrit
        fixed_names          % cell array: kiinteän parametrin nimet
        fixed_values         % struct: kiinteät arvot
        
        % Yhdistetyt
        all_params           % struct: kaikki parametrit (varying + fixed)
    end
    
    methods
        function obj = DesignSpace(varying_names, varying_ranges, varying_n_points, ...
                fixed_names, all_default_params)
            % Konstruktori: Luo laajennettavan DesignSpace:n
            %
            % Input:
            %   varying_names - cell array: {'B', 'G', 'K', ...}
            %   varying_ranges - cell array: {[1,3], [1.8,3], [0.5,1.5], ...}
            %   varying_n_points - vektori: [15, 15, 8, ...]
            %   fixed_names - cell array: {'A', 'H', 'F_1', ...}
            %   all_default_params - struct: kaikki parametrit default-arvoilla
            
            % Tallenna vaihtelevat parametrit
            obj.varying_names = varying_names;
            obj.varying_ranges = varying_ranges;
            obj.n_varying_points = varying_n_points;
            obj.n_varying = length(varying_names);
            
            % Tallenna kiinteät parametrit
            obj.fixed_names = fixed_names;
            
            % Kopioi kaikki default-arvot
            obj.all_params = all_default_params;
            
            % Extraktoi fixed_values structiksi
            for i = 1:length(fixed_names)
                param_name = fixed_names{i};
                if isfield(all_default_params, param_name)
                    obj.fixed_values.(param_name) = all_default_params.(param_name);
                else
                    error(sprintf('Parametria "%s" ei löydy default-arvoista', param_name));
                end
            end
            
            % Validaatio
            if length(obj.varying_names) ~= length(obj.varying_ranges)
                error('varying_names ja varying_ranges tulee olla samapituisia');
            end
            if length(obj.varying_names) ~= length(obj.n_varying_points)
                error('varying_names ja n_varying_points tulee olla samapituisia');
            end
            
            % Generoi vaihtelevien parametrien arvot
            obj = obj.generate_param_vectors();
        end
        
        function obj = generate_param_vectors(obj)
            % Luo lineaariset välit jokaiselle vaihtelevan parametrin arvoille
            obj.varying_values = cell(obj.n_varying, 1);
            
            for i = 1:obj.n_varying
                min_val = obj.varying_ranges{i}(1);
                max_val = obj.varying_ranges{i}(2);
                n_pts = obj.n_varying_points(i);
                
                obj.varying_values{i} = linspace(min_val, max_val, n_pts);
            end
        end
        
        function combined_params = get_parameters(obj, param_indices)
            % Muunna indeksit parametri-arvoiksi yhdistetyssä muodossa
            %
            % Input:
            %   param_indices - vektori indeksejä [i1, i2, i3, ...]
            %                   jokainen indeksi vastaa yhtä vaihtelevan parametrin väliä
            %
            % Output:
            %   combined_params - struct: kaikki parametrit (varying + fixed)
            %                     esim. {B: 2.5, G: 2.2, A: 7, H: 1.5, ...}
            
            % Aloita kopiolla kaikista default-arvoista
            combined_params = obj.all_params;
            
            % Korvaa vaihtelevat parametrit annetulla indeksillä
            for i = 1:obj.n_varying
                param_name = obj.varying_names{i};
                param_idx = param_indices(i);
                combined_params.(param_name) = obj.varying_values{i}(param_idx);
            end
        end
        
        function display(obj)
            % Näytä Design Space parametrit
            fprintf('\n=== DESIGN SPACE ===\n');
            fprintf('Ulottuvuudet: %d + %d kiinteitä\n', obj.n_varying, length(obj.fixed_names));
            
            fprintf('\n--- VAIHTELEVAT PARAMETRIT: ---\n');
            for i = 1:obj.n_varying
                fprintf('  %s: [%.3f, %.3f] - %d pistettä\n', ...
                    obj.varying_names{i}, ...
                    obj.varying_ranges{i}(1), ...
                    obj.varying_ranges{i}(2), ...
                    obj.n_varying_points(i));
            end
            
            fprintf('\n--- KIINTEÄT PARAMETRIT: ---\n');
            for i = 1:length(obj.fixed_names)
                param_name = obj.fixed_names{i};
                fprintf('  %s = %.3f\n', param_name, obj.fixed_values.(param_name));
            end
            
            fprintf('\nKokonais kombinaatiot: %d\n\n', prod(obj.n_varying_points));
        end
        
        function total_combinations = get_total_combinations(obj)
            % Palauttaa kaikkien parametriyhdistelmien lukumäärä
            total_combinations = prod(obj.n_varying_points);
        end
    end
end
