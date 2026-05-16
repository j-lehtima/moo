function all_params = load_default_parameters()
    % load_default_parameters - Lataa kaikki DEFAULT-parametrit
    %
    % Kaikki mahdolliset parametrit joita voidaan vaihdella tai pitää kiinteinä.
    % Tämä korvaa vanhan constants.m:n.
    %
    % Output:
    %   all_params - struct: kaikki parametrit default-arvoilla
    %
    % Esimerkki käytöstä:
    %   params = load_default_parameters();
    %   % Muuta halutessasi:
    %   params.A = 7.5;  % Muuta kehikon pituus
    %   params.F_1 = 100000;  % Muuta lastin paino
    
    % ========== GEOMETRISET PARAMETRIT [m] ==========
    all_params.A = 7;        % Kehikon pituus, mille rakennetaan kuorma
    all_params.H = 1.5;      % Aisan pituus trailerin etuseinästä vetolaitteelle
    all_params.K = 0.8;      % Lehtijousen pituus
    all_params.J = all_params.A + all_params.H;  % Kokonaispituus (lasketaan A:sta ja H:sta)
    
    % ========== KUORMITUSPARAMETRIT [N] ==========
    all_params.F_1 = 80000;     % Lastin paino
    all_params.Fg_1 = 7000;     % Rungon akseleiden päällä oleva omamassa
    all_params.Fg_2 = 1200;     % Aisan omamassa
end
