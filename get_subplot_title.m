function title_str = get_subplot_title(index)
% GET_SUBPLOT_TITLE - Palauttaa kuvaajien otsikon indeksin perusteella
% 
% Käyttö: title_str = get_subplot_title(1);  % palauttaa "Voima A"

labels = get_plot_labels();
title_str = labels.subplot_titles{index};

end
