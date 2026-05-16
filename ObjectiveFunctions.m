classdef ObjectiveFunctions
    % ObjectiveFunctions - Tavoitefunktioiden määrittely ja hallinta
    %
    % Sisältää kaikki tavoitefunktiot, joita käytetään monitavoiteoptimointiin.
    % Tavoitteita voi lisätä tai muokata muuttamalla objectives-cell-arrayta
    % ja vastaavia properties.
    %
    % Esimerkki:
    %   obj_func = ObjectiveFunctions();
    %   value = obj_func.objectives{1}(M_x);  % laske tavoite 1
    
    properties
        objectives      % cell array: function handles (@(M_x) ... tai @(M_x, params) ...)
        names           % tavoitteiden nimet (string array)
        directions      % -1 = minimointi, +1 = maksimointi
        weights         % painotukset TOPSIS-analyysiä varten
        n_objectives    % tavoitteiden lukumäärä
    end
    
    methods
        function obj = ObjectiveFunctions()
            % Konstruktori: Määritä kaikki tavoitefunktiot
            %
            % Tässä konfiguraatiossa 4 tavoitetta:
            % 1. Huippukuorman minimointi (max |M_x|)
            % 2. Kokonaiskuorman minimointi (sum |M_x|)
            % 3. Takajousituksen kuormajaon tasaisuuden minimointi (std)
            % 4. Rakennemassan minimointi (A + G pituuksista)
            
            % Tavoitefunktiot lambda-funktioina
            %
            % Tuettu muoto:
            %   @(M_x) ...
            %   @(M_x, params) ...
            % missä params sisältää sen hetkisen parametriyhdistelmän,
            % esim. params.G, params.B, params.K, jne.
            %
            % Esimerkki (kommentoituna):
            %   obj.objectives{1} = @(M_x, params) M_x(1) * params.G;
            obj.objectives{1} = @(M_x) max(abs(M_x));
            obj.objectives{2} = @(M_x) sum(abs(M_x));
            obj.objectives{3} = @(M_x) std(M_x(4:6));
            obj.objectives{4} = @(M_x, params) ...
                params.A * params.frame_mass_per_m + ...
                params.G * params.drawbar_mass_per_m;

            % Tavoitteiden nimet (käytetään visualisaatioissa)
            obj.names = {
                'Huippukuorma, max|F| (N)';
                'Kokonaiskuorma, sum|F| (N)';
                'Takajousien kuormajaon hajonta, std(F_d..F_f)';
                'Rakennemassa, A*kg/m + G*kg/m (kg)'
            };
            
            % Optimointisuunta: -1 = minimointi, +1 = maksimointi
            obj.directions = [-1, -1, -1, -1];
            
            % Painotukset TOPSIS-algoritmille (summa=1.0)
            % Muokkaa näitä painoarvoja kun haluat korostaa joitain tavoitteita
            obj.weights = [0.35, 0.25, 0.20, 0.20];
            
            % Validaatio
            if abs(sum(obj.weights) - 1.0) > 1e-6
                warning('Painojen summa ei ole 1.0 - normalisoidaan automaattisesti');
                obj.weights = obj.weights / sum(obj.weights);
            end
            
            obj.n_objectives = length(obj.objectives);
        end
        
        function values = evaluate_all(obj, M_x, params)
            % Laske kaikki tavoitefunktiot annetulle ratkaisulle M_x
            % 
            % Input:  M_x - ratkaisuvektori (6x1)
            %         params - (opt) struct: sen hetkiset suunnitteluparametrit
            % Output: values - tavoitearvojen vektori (n_objectives x 1)

            if nargin < 3
                params = struct();
            end
            
            values = zeros(obj.n_objectives, 1);
            for i = 1:obj.n_objectives
                objective_handle = obj.objectives{i};
                n_inputs = nargin(objective_handle);

                if n_inputs == 1
                    values(i) = objective_handle(M_x);
                else
                    values(i) = objective_handle(M_x, params);
                end
            end
        end
        
        function display(obj)
            % Näytä tavoitefunktioiden konfiguraatio
            fprintf('\n=== Tavoitefunktiot ===\n');
            for i = 1:obj.n_objectives
                direction_str = "minimointi";
                if obj.directions(i) > 0
                    direction_str = "maksimointi";
                end
                fprintf('  %d. %s (%s, paino=%.2f)\n', ...
                    i, obj.names{i}, direction_str, obj.weights(i));
            end
            fprintf('\n');
        end
    end
end
