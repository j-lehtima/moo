function plot_5_slices(x_vals, y_vals, M_x_all)
% PLOT_5_SLICES - Yksittäisen parametrin viipaleet
% Näyttää M_x(1):n riippuvuuden G:stä eri B-arvoilla

labels = get_plot_labels();

figure(5); clf;
hold on;

num_slices = 4;
slice_indices = round(linspace(1, length(y_vals), num_slices));

colors = lines(num_slices);

for idx = 1:num_slices
    j = slice_indices(idx);
    plot(x_vals, M_x_all(j, :, 1), '-o', 'Color', colors(idx, :), ...
        'DisplayName', sprintf('B=%.2f', y_vals(j)), 'LineWidth', 2);
end

xlabel(labels.x_axis);
ylabel(get_zlabel(1));
title('5. VIIPALEET (Slices) - M_x(1) herkkyyden analyysi');
legend;
grid on;
hold off;

end
