function [all_params, varying_names, varying_ranges, varying_n_points, fixed_names] = ...
    extract_design_variables(config)
    % extract_design_variables - Muunnos config:sta käytettäviin muotoihin
    %
    % Input:
    %   config - struct joka luotiin design_variables_config():lla
    %
    % Output:
    %   all_params - struct: kaikki parametrit (dynaamiset + staattiset)
    %   varying_names - cell array: dynaamisten nimien nimet
    %   varying_ranges - cell array: dynaamisten välit [min, max]
    %   varying_n_points - vektori: dynaamisten resoluutiot
    %   fixed_names - cell array: staattisten parametrien nimet
    
    % Kerää staattiset parametrit
    static_fields = fieldnames(config.static);
    
    % Alusta all_params
    all_params = config.static;
    
    % Kerää dynaamiset parametrit
    dynamic_fields = fieldnames(config.dynamics);
    
    varying_names = {};
    varying_ranges = {};
    varying_n_points = [];
    
    for i = 1:length(dynamic_fields)
        param_name = dynamic_fields{i};
        param_data = config.dynamics.(param_name);
        
        % Lisää dynaamisten listaan
        varying_names{i} = param_name;
        varying_ranges{i} = [param_data.min, param_data.max];
        varying_n_points(i) = param_data.n_points;
        
        % Lisää all_params:iin default-arvo (min)
        all_params.(param_name) = param_data.min;
    end
    
    % Kerää staattiset parametrien nimet (ilman _desc kenttiä)
    fixed_names = {};
    for i = 1:length(static_fields)
        field_name = static_fields{i};
        % Jätä pois kuvaukset (_desc)
        if ~endsWith(field_name, '_desc')
            fixed_names{end+1} = field_name;
        end
    end
    
end

function tf = endsWith(str, suffix)
    % Tarkista että string päättyy tiettyyn suffiksiin
    if length(str) < length(suffix)
        tf = false;
        return;
    end
    tf = strcmp(str(end-length(suffix)+1:end), suffix);
end
