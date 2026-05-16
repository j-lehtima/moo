function params = get_params_from_index(multi_idx, varying_names, varying_ranges, ...
        varying_n_points, all_params)
    % Hae kaikki parametrit multi-indeksin perusteella
    %
    % Input:
    %   multi_idx - vektori: [i1, i2, i3, ...] (1-based indeksit dimensioihin)
    %   varying_names - cell array: dynaamisten parametrien nimet
    %   varying_ranges - cell array: dynaamisten välit {[min1, max1], [min2, max2], ...}
    %   varying_n_points - vektori: resoluutiot [n1, n2, n3, ...]
    %   all_params - struct: kaikki parametrit (käytetään baseliksi)
    %
    % Output:
    %   params - struct: kaikki parametrit (dynaamiset laskettuina, staattiset periytettyinä)
    
    params = all_params;
    
    % Laske dynaamiset parametriarvot
    for dim = 1:length(varying_names)
        param_name = varying_names{dim};
        n_points = varying_n_points(dim);
        idx = multi_idx(dim);
        
        % Linspace: muunna indeksi arvoksi
        min_val = varying_ranges{dim}(1);
        max_val = varying_ranges{dim}(2);
        values = linspace(min_val, max_val, n_points);
        
        params.(param_name) = values(idx);
    end
end
