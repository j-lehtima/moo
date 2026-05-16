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
        objectives      % cell array: function handles (@(M_x) ...)
        names           % tavoitteiden nimet (string array)
        directions      % -1 = minimointi, +1 = maksimointi
        weights         % painotukset TOPSIS-analyysiä varten
        n_objectives    % tavoitteiden lukumäärä
    end
    
    methods
        function obj = ObjectiveFunctions()
            % Konstruktori: Määritä kaikki tavoitefunktiot
            %
            % Tässä esimerkissä 4 tavoitetta:
            % 1. Maksimaalisen yksittäisen voiman minimointi
            % 2. Kokonaisvoiman (L1-normi) minimointi
            % 3. Minimaalisen (positiivisen) voiman maksimoiminen (stabiilisuus)
            % 4. Voimien tasaisuus (varianssin minimointi)
            
            % Tavoitefunktiot lambda-funktioina
            obj.objectives{1} = @(M_x) max(abs(M_x));           % Maksimi |voima|
            obj.objectives{2} = @(M_x) sum(abs(M_x));           % Kokonaisvoiman summa
            obj.objectives{3} = @(M_x) min(abs(M_x(M_x>0)));   % Minimaalinen positiivinen voima
            obj.objectives{4} = @(M_x) var(M_x);               % Voimien varianssi
            
            % Tavoitteiden nimet (käytetään visualisaatioissa)
            obj.names = {
                'Max. voima (N)'
                'Kokonaisvoima (N)'
                'Min. voima (N)'
                'Varianssi'
            };
            
            % Optimointisuunta: -1 = minimointi, +1 = maksimointi
            obj.directions = [-1, -1, 1, -1];
            
            % Painotukset TOPSIS-algoritmille (summa=1.0)
            % Muokkaa näitä painoarvoja kun haluat korostaa joitain tavoitteita
            obj.weights = [0.3, 0.2, 0.3, 0.2];
            
            % Validaatio
            if abs(sum(obj.weights) - 1.0) > 1e-6
                warning('Painojen summa ei ole 1.0 - normalisoidaan automaattisesti');
                obj.weights = obj.weights / sum(obj.weights);
            end
            
            obj.n_objectives = length(obj.objectives);
        end
        
        function values = evaluate_all(obj, M_x)
            % Laske kaikki tavoitefunktiot annetulle ratkaisulle M_x
            % 
            % Input:  M_x - ratkaisuvektori (6x1)
            % Output: values - tavoitearvojen vektori (n_objectives x 1)
            
            values = zeros(obj.n_objectives, 1);
            for i = 1:obj.n_objectives
                values(i) = obj.objectives{i}(M_x);
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
