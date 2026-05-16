function multi_idx = ind2sub_custom(n_points, linear_idx)
    % Muunna linear index (1-indexed) multi-dimensional index
    % 
    % Input:
    %   n_points - vektori: koko joka dimension osalta [n1, n2, n3, ...]
    %   linear_idx - skalaari: 1-based linear index
    %
    % Output:
    %   multi_idx - vektori: [i1, i2, i3, ...] (1-based)
    %
    % Esimerkki:
    %   n_points = [15, 15]
    %   linear_idx = 100
    %   multi_idx = ind2sub_custom(n_points, 100)  → [1, 7] (approx)
    
    n_dims = length(n_points);
    multi_idx = zeros(n_dims, 1);
    
    % Muunna 0-indeksoinnille
    remainder = linear_idx - 1;
    
    % Käy läpi dimensiot vasemmalta oikealle
    for dim = 1:n_dims
        multi_idx(dim) = mod(remainder, n_points(dim)) + 1;
        remainder = floor(remainder / n_points(dim));
    end
end
