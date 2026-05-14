function plot_3_imagesc(x_vals, y_vals, M_x_all)
% PLOT_3_IMAGESC - Värikartta (Imagesc)
% Näyttää arvot värikarttana, "lämpökartta"-tyyliin

labels = get_plot_labels();

figure(3); clf;
imagesc(x_vals, y_vals, M_x_all(:, :, 1));
cb = colorbar;
ylabel(cb, get_zlabel(1));
xlabel(labels.x_axis);
ylabel(labels.y_axis);
title('3. VÄRIKARTTA (Imagesc) - M_x(1) lämpökartta');
axis xy;
grid on;

end
