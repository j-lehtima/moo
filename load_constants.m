function constants = load_constants()
    % load_constants - Lataa ja palauttaa constants-structin
    %
    % Tämä funktion avulla pidetään vakiot keskitettynä ja päivitettävissä
    % yhdestä paikasta.
    %
    % Output:
    %   constants - struct joka sisältää kaikki vakiot
    
    % Pituusmitat [m]
    constants.A = 7;        % kehikon pituus, mille rakennetaan kuorma
    constants.H = 1.5;      % Aisan pituus trailerin etuseinästä vetolaitteelle
    constants.K = 0.8;      % lehtijousen pituus
    constants.J = constants.A + constants.H;  % kokonaispituus
    
    % Voimat [N]
    constants.F_1 = 80000;     % Lastin paino
    constants.Fg_1 = 7000;     % Rungon akseleiden päällä oleva omamassa
    constants.Fg_2 = 1200;     % Aisan omamassa
end
