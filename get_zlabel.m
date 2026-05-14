function zlabel_str = get_zlabel(index)
% GET_ZLABEL - Palauttaa formatoidun z-akselin otsikon
% 
% Käyttö: zlabel_str = get_zlabel(1);  % palauttaa "x(1) - F_a [N]"

labels = get_plot_labels();
zlabel_str = sprintf('x(%d) - %s %s', index, labels.force_names{index}, labels.unit);

end
