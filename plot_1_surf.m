function plot_1_surf(x_vals, y_vals, M_x_all)
% PLOT_1_SURF - Pinta-visualisointi (Surf)
% Näyttää M_x(1) pinnan 3D-muodossa

labels = get_plot_labels();

figure(1); clf;
surf(x_vals, y_vals, M_x_all(:, :, 1));
xlabel(labels.x_axis);
ylabel(labels.y_axis);
zlabel(get_zlabel(1));
title(get_subplot_title(1));
colorbar;
grid on;
rotate3d on;

end
