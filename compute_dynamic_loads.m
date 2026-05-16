function params = compute_dynamic_loads(params)
    % compute_dynamic_loads - Päivitä Fg_1 ja Fg_2 ratkaisukohtaisesti
    %
    % Kaavat:
    %   J    = A + H
    %   Fg_1 = A * frame_mass_per_m * g
    %   Fg_2 = G * drawbar_mass_per_m * g
    %
    % Input:
    %   params - struct, joka sisältää vähintään kentät:
    %            A, H, G, frame_mass_per_m, drawbar_mass_per_m, g
    %
    % Output:
    %   params - sama struct, jossa Fg_1 ja Fg_2 päivitetty

    required_fields = {'A', 'H', 'G', 'frame_mass_per_m', 'drawbar_mass_per_m', 'g'};

    for i = 1:length(required_fields)
        field_name = required_fields{i};
        if ~isfield(params, field_name)
            error('compute_dynamic_loads:MissingField', ...
                'Pakollinen kentta puuttuu: %s', field_name);
        end
    end

    params.J = params.A + params.H;
    params.Fg_1 = params.A * params.frame_mass_per_m * params.g;
    params.Fg_2 = params.G * params.drawbar_mass_per_m * params.g;
end
