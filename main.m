% Import vakio globaalit
run('constants.m');

global F_1 Fg_1 Fg_2
global A H K J

% Parametrien vektorit
x_G_plot_values = linspace(1, 3, 20);
y_B_plot_values = linspace(1, 3, 20);

% Alusta tulostaulukko (kaikki 6 M_x alkiota eri G ja B arvoilla)
M_x_all = zeros(length(y_B_plot_values), length(x_G_plot_values), 6);

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
            F_1 + Fg_2;
            Fg_2;
            0;
            0;
            -(A/2)*(F_1 + Fg_1);
            -(G_val/2) * Fg_2
        ];

        M_x = M_A \ M_b;
        M_x_all(j, i, :) = M_x;  % Tallennetaan kaikki 6 alkiota
    end
end

% ========== VISUALISOINTITAVAT ==========
% Kommentoi pois / päälle tarpeen mukaan

%plot_1_surf(x_G_plot_values, y_B_plot_values, M_x_all);
%plot_2_contour(x_G_plot_values, y_B_plot_values, M_x_all);
%plot_3_imagesc(x_G_plot_values, y_B_plot_values, M_x_all);
plot_4_subplots(x_G_plot_values, y_B_plot_values, M_x_all);
% plot_5_slices(x_G_plot_values, y_B_plot_values, M_x_all);
% plot_6_bar3(x_G_plot_values, y_B_plot_values, M_x_all);


