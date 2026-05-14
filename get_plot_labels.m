function labels = get_plot_labels()
% GET_PLOT_LABELS - Keskitetty konfiguraatio plot-otsikille
% Palauttaa struct, jossa on kaikki plot-funktioissa käytettävät nimet

% Voiman nimet indeksin mukaan
labels.force_names = {'F_a', 'F_b', 'F_c', 'F_d', 'F_e', 'F_f'};

% Yksikkö
labels.unit = '[N]';

% ===== AKSELIEN KONFIGURAATIO =====
% Valitse käytettävä versio: aseta joko _short tai _long (jäljempänä)

% Lyhyet versiot
x_axis_short = 'Puomin pituus, G [m]';
y_axis_short = 'Akseliston kehikon perästä, B [m]';

% Pitkät selitykset
x_axis_long = 'G [m] - Puomin kokonaispituus. (vetolaitteelle merkittävä osuus lukittu, nivelen paikka kehikon alla muuttuu)';
y_axis_long = 'B [m] - Akseliston keskipaikka kehikon perästä mitattuna';

% === VALITSE KÄYTETTÄVÄ VERSIO (muuta alla olevia rivejä) ===
labels.x_axis = x_axis_short;   % Vaihda x_axis_short käyttääksesi lyhyttä versiota
labels.y_axis = y_axis_short;   % Vaihda y_axis_short käyttääksesi lyhyttä versiota

end
