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
    
    % K: Lehtijousen pituus [m]
    % Huomio: Vaihda kommentiksi jos haluat pitää kiinteänä
    % config.dynamics.K.min = 0.5;
    % config.dynamics.K.max = 1.5;
    % config.dynamics.K.n_points = 8;
    % config.dynamics.K.description = 'Lehtijousen pituus';
    % config.dynamics.K.unit = 'm';
    
    % ========================================================================
    % STAATTISET PARAMETRIT (Fixed values / Constant parameters)
    % ========================================================================
    % Nämä pysyvät kiinteinä koko analyysissä
    
    config.static = struct();
    
    % === GEOMETRIA [m] ===
    config.static.A = 7.0;       % Kehikon pituus, mille rakennetaan kuorma
    config.static.A_desc = 'Kehikon pituus, mille rakennetaan kuorma';
    
    config.static.H = 1.5;       % Aisan pituus trailerin etuseinästä vetolaitteelle
    config.static.H_desc = 'Aisan pituus vetolaitteelle';
    
    config.static.K = 0.8;       % Lehtijousen pituus (ellei ole dynaamisesti määritelty)
    config.static.K_desc = 'Lehtijousen pituus';
    
    % === KUORMITUS [N] ===
    config.static.F_1 = 80000;   % Lastin paino
    config.static.F_1_desc = 'Lastin paino';
    
    config.static.Fg_1 = 7000;   % Rungon akseleiden päällä oleva omamassa
    config.static.Fg_1_desc = 'Rungon akseleiden omamassa';
    
    config.static.Fg_2 = 1200;   % Aisan omamassa
    config.static.Fg_2_desc = 'Aisan omamassa';
    
    % === KOKONAISPARAMETRIT (lasketaan) ===
    config.static.J = config.static.A + config.static.H;  % Kokonaispituus
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
