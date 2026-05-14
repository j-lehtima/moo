% Import vakio globaalit
run('constants.m');

global F_1 Fg_1 Fg_2
global A H K J

% Parametrien vektorit
x_G_plot_values = linspace(1, 3, 20);
y_B_plot_values = linspace(1, 3, 20);

% Alusta tulostaulukko (M_x:n ensimmäinen alkio eri G ja B arvoilla)
M_x_results = zeros(length(y_B_plot_values), length(x_G_plot_values));

% Laskenta silmukassa
for i = 1:length(x_G_plot_values)
    for j = 1:length(y_B_plot_values)
        G_val = x_G_plot_values(i);
        B_val = y_B_plot_values(j);
        
        % Lasketaan riippuvaiset vakiot
        C_val = A - B_val;
        E_val = G_val - H;
        D_val = A - E_val;
        
        M_A = [
            0,    1,      -1,       1,          1,      1;
            1,    -1,     1,        0,          0,      0;
            0,    0,      0,        -1,         0,      1;
            0,    0,      0,        0,          1,      -2;
            0,    0,      E_val,    -(C_val-K), -C_val, -(C_val+K);
            0,    H,      -G_val,   0,          0,      0;
        ];
        
        M_b = [
            -2;
            -1;
            0;
            0;
            F_1;
            G_val/2
        ];
        
        M_x = M_A \ M_b;
        M_x_results(j, i) = M_x(1);  % Tallennetaan ensimmäinen alkio
    end
end

% Piirretään pinta
figure(1);
surf(x_G_plot_values, y_B_plot_values, M_x_results);
xlabel('G (mm)');
ylabel('B (mm)');
zlabel('M_x(1)');
title('M_x ensimmäisen alkion pinta G ja B funktiona');
colorbar;
grid on;


