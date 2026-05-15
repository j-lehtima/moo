function plot_4_subplots(x_vals, y_vals, M_x_all)
% PLOT_4_SUBPLOTS - Kaikki 6 M_x alkiota 2x3 ruudukossa
% Näyttää kaikkien 6 yhtälön tulokset rinnakkain

labels = get_plot_labels();

figure(4); clf;

% Suurenna ikkunaa niin että tekstit mahtuvat
set(gcf, 'Position', [100, 100, 1600, 1000]);

for k = 1:6
    subplot(2, 3, k);
    surf(x_vals, y_vals, M_x_all(:, :, k));

    % X-akselin label (kierretty ja keskitetty)
    xh = xlabel(labels.x_axis);
    set(xh, 'Rotation', 22, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

    % Y-akselin label (kierretty ja keskitetty)
    yh = ylabel(labels.y_axis);
    set(yh, 'Rotation', -39, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

    % Z-akselin label
    zh = zlabel(get_zlabel(k));
    set(zh, 'Rotation', 90, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

    title(get_subplot_title(k));
    colorbar;
end

sgtitle('4. KAIKKI 6 ALKIOTA (Subplots) - Vertailunäkymä');

end
