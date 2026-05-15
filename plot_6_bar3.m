function plot_6_bar3(x_vals, y_vals, M_x_all)
% PLOT_6_BAR3 - 3D-palkit (Bar3)
% Näyttää M_x(1) arvot diskreetteina 3D-palkeina

labels = get_plot_labels();

figure(6); clf;

bar3(M_x_all(:, :, 1));
cb = colorbar;
ylabel(cb, get_zlabel(1));
xlabel('G-indeksi');
ylabel('B-indeksi');
zlabel(get_zlabel(1));
title(get_subplot_title(1));
grid on;

end
