function param_values = moo_get_param_values(indices_linear, design_space)
    % moo_get_param_values - Muunna lineaariset indeksit parametri-arvoiksi
    %
    % Input:
    %   indices_linear - vektori lineaarisia indeksejä [1, 2, 3, ...]
    %   design_space - DesignSpace objekti
    %
    % Output:
    %   param_values - [n x n_dimensions] matriisi parametrien arvoista
    %
    % Esimerkki:
    %   % Hae TOP 5 ratkaisun parametrit:
    %   top_params = moo_get_param_values([1, 2, 3, 4, 5], design_space);
    %   % Näytä parhaan ratkaisun parametrit:
    %   fprintf('Parhaan ratkaisun parametrit: B=%.2f, G=%.2f\n', top_params(1,1), top_params(1,2));
    
    n_params = design_space.n_dimensions;
    n_indices = length(indices_linear);
    param_values = zeros(n_indices, n_params);
    
    % Dimensioiden järjestys
    dims = design_space.n_points;
    
    for idx_linear = 1:n_indices
        linear_idx = indices_linear(idx_linear);
        
        % Muunna lineaarinen indeksi n-ulotteiseksi indeksiksi
        % sub2ind/ind2sub logiikka
        indices_nd = zeros(n_params, 1);
        remainder = linear_idx - 1;  % 0-indexed
        
        for dim = 1:n_params
            % Laske divisor kaikille seuraavilla dimensioille
            divisor = prod(dims(dim+1:end));
            if isempty(divisor) || divisor == 0
                divisor = 1;
            end
            
            indices_nd(dim) = floor(remainder / divisor) + 1;  % 1-indexed
            remainder = mod(remainder, divisor);
        end
        
        % Hae parametrien arvot näille indekseille
        for dim = 1:n_params
            param_idx = indices_nd(dim);
            param_values(idx_linear, dim) = design_space.param_values{dim}(param_idx);
        end
    end
end
