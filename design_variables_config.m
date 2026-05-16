function config = design_variables_config()
    % design_variables_config - KESKITETTY kaikki suunnittelumuuttujat
    %
    % Tämä funktio määrittelee KAIKKI suunnitteluun liittyvät parametrit:
    % - DYNAAMISET parametrit (jotka optimoidaan - vaihtelevat arvoilla)
    % - STAATTISET parametrit (kiinteät arvot - dynaamiset joissa 1 piste)
    %
    % KAIKKI parametrit yhdessä paikassa → Selkeä, helppo muokata
    %
    % Käyttö:
    %   config = design_variables_config();
    %   % Käytä eri scenario:issa muuttamalla arvoja alle
    
    % ========================================================================
    % DYNAAMISET PARAMETRIT (Optimization variables)
    % ========================================================================
    % Nämä vaihtelevat analyysissä: minusta maksiin, N pisteellä
    
    config.dynamics = struct();

    % A: Kehikon pituus, mille rakennetaan kuorma [m]
    config.dynamics.A.min = 7.0;
    config.dynamics.A.max = 8.0;
    config.dynamics.A.n_points = 10;
    config.dynamics.A.description = 'Kehikon pituus, mille rakennetaan kuorma';
    config.dynamics.A.unit = 'm';
    
    % B: Lehtijousen etäisyys kehikon edusta [m]
    config.dynamics.B.min = 1.0;
    config.dynamics.B.max = 3.0;
    config.dynamics.B.n_points = 15;
    config.dynamics.B.description = 'Lehtijousen etäisyys kehikon edusta';
    config.dynamics.B.unit = 'm';
    
    % G: Aisan pituus vetolaitteelle [m]
    config.dynamics.G.min = 1.8;
    config.dynamics.G.max = 3.0;
    config.dynamics.G.n_points = 15;
    config.dynamics.G.description = 'Aisan pituus vetolaitteelle';
    config.dynamics.G.unit = 'm';
    
    
    % ========================================================================
    % STAATTISET PARAMETRIT (Fixed values / Constant parameters)
    % ========================================================================
    % Nämä pysyvät kiinteinä koko analyysissä
    
    config.static = struct();
    
    % === GEOMETRIA [m] ===
    config.static.H = 1.5;       % Aisan pituus trailerin etuseinästä vetolaitteelle
    config.static.H_desc = 'Aisan pituus vetolaitteelle';
    
    config.static.K = 0.8;       % Lehtijousen pituus (ellei ole dynaamisesti määritelty)
    config.static.K_desc = 'Lehtijousen pituus';
    
    % === KUORMITUS [N] ===
    config.static.F_1 = 80000;   % Lastin paino
    config.static.F_1_desc = 'Lastin paino';

    % === OMAN MASSAN MALLI (ratkaisukohtainen) ===
    % Fg lasketaan evaluoinnissa kaavalla:
    %   Fg = pituus (m) * metripaino (kg/m) * g (m/s^2)
    %
    % Tässä mallissa:
    %   Fg_1 = A * frame_mass_per_m * g
    %   Fg_2 = G * drawbar_mass_per_m * g
    config.static.g = 9.81;
    config.static.g_desc = 'Gravitaatio';

    config.static.frame_mass_per_m = 102;   % Rungon metripaino
    config.static.frame_mass_per_m_desc = 'Rungon metripaino';

    config.static.drawbar_mass_per_m = 51;  % Aisan metripaino
    config.static.drawbar_mass_per_m_desc = 'Aisan metripaino';
    
    % Nämä arvot ovat lähtöarvoja/näkyvyyttä varten,
    % mutta evaluoinnissa ne ylikirjoitetaan ratkaisukohtaisesti
    % yllä olevan massamallin perusteella.
    if isfield(config.dynamics, 'A')
        a_length_default = config.dynamics.A.min;
    elseif isfield(config.static, 'A')
        a_length_default = config.static.A;
    else
        error('A-parametri puuttuu: maarita se joko config.dynamics.A tai config.static.A');
    end

    config.static.Fg_1 = a_length_default * config.static.frame_mass_per_m * config.static.g;
    config.static.Fg_1_desc = 'Rungon omamassa (laskettu: A * frame_mass_per_m * g)';
    
    if isfield(config.dynamics, 'G')
        g_length_default = config.dynamics.G.min;
    elseif isfield(config.static, 'G')
        g_length_default = config.static.G;
    else
        error('G-parametri puuttuu: maarita se joko config.dynamics.G tai config.static.G');
    end

    config.static.Fg_2 = g_length_default * config.static.drawbar_mass_per_m * config.static.g;
    config.static.Fg_2_desc = 'Aisan omamassa (laskettu: G * drawbar_mass_per_m * g)';
    
    % === KOKONAISPARAMETRIT (lasketaan) ===
    config.static.J = a_length_default + config.static.H;  % Kokonaispituus
    config.static.J_desc = 'Kokonaispituus (A + H)';
    
    % ========================================================================
    % METADATA - Kuvaajille ja dokumentaatiolle
    % ========================================================================
    
    config.meta = struct();
    config.meta.title = 'MOO Framework - Suunnittelumuuttujat';
    config.meta.version = '2.0';
    config.meta.date_created = datestr(now);
    config.meta.description = 'Kaikki suunnittelumuuttujat keskitettynä';
    
end
