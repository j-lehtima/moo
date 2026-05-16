function M_x = matrix_builder(parameters)
    % matrix_builder - Rakenna ratkaisumatriisi M_x parametreista
    %
    % Input:
    %   parameters - struct: sisältää KAIKKI parametrit (sekä varying että fixed)
    %               esim: parameters.B, parameters.G, parameters.A, parameters.H, jne.
    %
    % Output:
    %   M_x - ratkaisuvektori (6x1)
    %
    % Esimerkki käytöstä:
    %   params.B = 2.0;
    %   params.G = 2.4;
    %   params.A = 7.0;
    %   params.H = 1.5;
    %   params.K = 0.8;
    %   params.F_1 = 80000;
    %   params.Fg_1 = 7000;
    %   params.Fg_2 = 1200;
    %   M_x = matrix_builder(params);
    
    % Purkaa parametrit structista
    B = parameters.B;
    G = parameters.G;
    A = parameters.A;
    H = parameters.H;
    K = parameters.K;
    F_1 = parameters.F_1;
    Fg_1 = parameters.Fg_1;
    Fg_2 = parameters.Fg_2;
    
    % Riippuvaiset vakiot/parametrit
    C = A - B;
    E = G - H;
    D = A - E;
    
    % Matriisiyhtälö M_A * M_x = M_b
    M_A = [
        0,    1,      -1,       1,          1,      1;
        1,    -1,     1,        0,          0,      0;
        0,    0,      0,        -1,         0,      1;
        0,    0,      0,        0,          1,      -2;
        0,    0,      E,        -(C-K),     -C,     -(C+K);
        0,    H,      -G,       0,          0,      0;
    ];
    
    M_b = [
        F_1 + Fg_2;
        Fg_2;
        0;
        0;
        -(A/2)*(F_1 + Fg_1);
        -(G/2) * Fg_2
    ];
    
    % Ratkaise matriisiyhtälö
    M_x = M_A \ M_b;
end
