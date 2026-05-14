function plot_2_contour(x_vals, y_vals, M_x_all)
% PLOT_2_CONTOUR - Kontuurikaavio (Contour)
% Näyttää tasokäyrät 2D-tasossa

labels = get_plot_labels();

figure(2); clf;
contourf(x_vals, y_vals, M_x_all(:, :, 1), 20);
cb = colorbar;
ylabel(cb, get_zlabel(1));
xlabel(labels.x_axis);
ylabel(labels.y_axis);
title('2. KONTUURIT (Contour) - M_x(1) tasokäyrät');
grid on;
hold on;

end
