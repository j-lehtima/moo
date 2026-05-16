%% ======================================================================
% MONITAVOITEOPTIMOINTIKEHIKKO - MOO FRAMEWORK v2.0
% ======================================================================
%
% 🎯 KAIKKI SUUNNITTELUMUUTTUJAT MÄÄRITELLÄÄN YHDESSÄ PAIKASSA:
%    design_variables_config.m
%
% ======================================================================

% Tyhjennä välimuisti jotta uudet objektiivit ladataan oikein
clear all;
close all;

fprintf('\n%s\n', repmat('=', 1, 70));
fprintf('MONITAVOITEOPTIMOINTIKEHIKKO - MOO FRAMEWORK v2.0\n');
fprintf('%s\n', repmat('=', 1, 70));

%% ========== VAIHE 0: Lataa kaikki suunnittelumuuttujat ==========
fprintf('\n[VAIHE 0] Ladataan suunnittelumuuttujat\n');
fprintf('  📝 Lähde: design_variables_config.m\n');
fprintf('  🎯 Kaikki parametrit YHDESSÄ PAIKASSA\n\n');

% Lataa konfiguraatio (KAIKKI parametrit täällä!)
config = design_variables_config();

% Ekstraktoi eri muotoihin - käytä purettuja arvoja
all_params = struct();
all_params.A = config.dynamics.A.min;
all_params.H = config.static.H;
all_params.K = config.static.K;
all_params.F_1 = config.static.F_1;
all_params.Fg_1 = config.static.Fg_1;
all_params.Fg_2 = config.static.Fg_2;
all_params.J = all_params.A + all_params.H;
all_params.g = config.static.g;
all_params.static = config.static;
all_params.frame_mass_per_m = config.static.frame_mass_per_m;
all_params.drawbar_mass_per_m = config.static.drawbar_mass_per_m;
all_params.dynamics = config.dynamics;

% Dynaamiset parametrit
all_params.A = config.dynamics.A.min;
all_params.B = config.dynamics.B.min;
all_params.G = config.dynamics.G.min;

% Määritä mitä vaihtelee
varying_names = {'A', 'B', 'G'};
varying_ranges = {[config.dynamics.A.min, config.dynamics.A.max], ...
                   [config.dynamics.B.min, config.dynamics.B.max], ...
                   [config.dynamics.G.min, config.dynamics.G.max]};
varying_n_points = [config.dynamics.A.n_points, config.dynamics.B.n_points, config.dynamics.G.n_points];

% Määritä mitä on kiinteitä
fixed_names = {'H', 'K', 'F_1', 'g', 'frame_mass_per_m', 'drawbar_mass_per_m', 'Fg_1', 'Fg_2', 'J'};

% Näytä konfiguraatio
fprintf('%s\n', repmat('-', 1, 70));
fprintf('📊 DYNAAMISET PARAMETRIT (optimization variables):\n');
fprintf('%s\n', repmat('-', 1, 70));

for i = 1:length(varying_names)
    param_name = varying_names{i};
    param_data = config.dynamics.(param_name);
    fprintf('  ✓ %s: [%.2f, %.2f] (%d pistettä)\n', ...
        param_name, ...
        varying_ranges{i}(1), ...
        varying_ranges{i}(2), ...
        varying_n_points(i));
    fprintf('    → %s (%s)\n', param_data.description, param_data.unit);
end

fprintf('\n%s\n', repmat('-', 1, 70));
fprintf('🔒 STAATTISET PARAMETRIT (fixed values):\n');
fprintf('%s\n', repmat('-', 1, 70));

for i = 1:length(fixed_names)
    param_name = fixed_names{i};
    desc_field = [param_name '_desc'];
    
    if isfield(config.static, desc_field)
        description = config.static.(desc_field);
    else
        description = '(ei kuvausta)';
    end
    
    fprintf('  ✓ %s = %.2f\n', param_name, config.static.(param_name));
    fprintf('    → %s\n', description);
end

fprintf('\n');

%% DEBUG: Tarkista ekstraktoidut muuttujat
fprintf('%s\n', repmat('-', 1, 70));
fprintf('DEBUG: Ekstraktoidut muuttujat\n');
fprintf('%s\n', repmat('-', 1, 70));
fprintf('  varying_names: '); disp(varying_names);
fprintf('  varying_ranges: '); disp(varying_ranges);
fprintf('  varying_n_points: '); disp(varying_n_points);
fprintf('  fixed_names: '); disp(fixed_names);
fprintf('  all_params (struct): '); disp(all_params);

%% ========== VAIHE 1: Määritä suunnittelutila (Design Space) ==========
fprintf('[VAIHE 1] Määritellään suunnittelutila\n\n');

design_space = DesignSpace(varying_names, varying_ranges, varying_n_points, ...
    fixed_names, all_params);
design_space.display();

%% ========== VAIHE 2: Määritä tavoitefunktiot ==========
fprintf('[VAIHE 2] Määritellään tavoitefunktiot\n\n');

objectives = ObjectiveFunctions();
objectives.display();

fprintf('  Painotukset TOPSIS-laskentaan: %s\n\n', mat2str(objectives.weights));

%% ========== VAIHE 3: Evaluoi kaikki parametriyhdistelmät ==========
fprintf('[VAIHE 3] Evaluoidaan kaikki parametriyhdistelmät\n');
fprintf('  Tämä voi kestää hetken riippuen resoluutiosta...\n\n');

engine = EvaluationEngine(design_space, objectives, true);
engine = engine.evaluate_all();

fprintf('\n  ✓ Evaluointi valmis\n');
fprintf('    - Ratkaisut: %d kpl\n', size(engine.results.flattened_solutions, 1));
fprintf('    - Tavoitteet: %d kpl\n', objectives.n_objectives);

%% ========== VAIHE 4: MOO-analyysi ==========
fprintf('\n[VAIHE 4] MOO-analyysi (TOPSIS + Pareto)\n');

% 4a. Pareto-front tunnistaminen
fprintf('  4a. Pareto-frontin tunnistaminen...\n');
pareto_indices = MOOAnalyzer.find_pareto_front(...
    engine.results.flattened_objectives, objectives.directions);

n_pareto = sum(pareto_indices);
fprintf('      ✓ Pareto-optimaaliset: %d / %d (%.1f%%)\n', ...
    n_pareto, size(engine.results.flattened_objectives, 1), ...
    100*n_pareto/size(engine.results.flattened_objectives, 1));

% 4b. TOPSIS-menetelmä
fprintf('  4b. TOPSIS-järjestys lasketaan...\n');
[best_idx, ranking, topsis_scores] = MOOAnalyzer.topsis_analysis(...
    engine.results.flattened_objectives, objectives.directions, objectives.weights);

fprintf('      ✓ TOPSIS-paras ratkaisu: indeksi %d\n', best_idx);
fprintf('      ✓ Top 5 TOPSIS-pisteet:\n');
for i = 1:min(5, length(topsis_scores))
    idx = ranking(i);
    pareto_marker = '';
    if pareto_indices(idx)
        pareto_marker = ' [PARETO]';
    end
    fprintf('         %d. Score=%.4f%s\n', i, topsis_scores(idx), pareto_marker);
end

fprintf('      ✓ Rajoitteet määritelty\n');

%% ========== VAIHE 5: Visualisaatio ==========
fprintf('\n[VAIHE 5] Luodaan visualisaatiot...\n\n');

moo_visualize(engine, objectives, topsis_scores, pareto_indices, ...
    size(engine.results.flattened_objectives, 1), ...
    varying_names, varying_ranges, varying_n_points, all_params);

fprintf('      ✓ Kuvaajat luotu\n');

%% ========== VAIHE 6: Exportaa tulokset CSV:ksi ==========
fprintf('\n[VAIHE 6] Viedään tulokset CSV-tiedostoon\n');
fprintf('  Järjestys: Ranking → Tavoitteet → Dynaamiset → Staattiset\n\n');

% Järjestä TOPSIS scoresit parhailta huonoimmille
[~, ranked_indices] = sort(topsis_scores, 'descend');

n_results = length(ranked_indices);
n_objectives = size(engine.results.flattened_objectives, 2);

% Luo CSV-sarakkeiden otsikot
csv_headers = {'Ranking', 'TOPSIS_Score'};

% Tavoitefunktioiden nimet
for i = 1:n_objectives
    csv_headers{end+1} = objectives.names{i};
end

% Dynaamiset parametrit
for i = 1:length(varying_names)
    csv_headers{end+1} = varying_names{i};
end

% Staattiset parametrit
for i = 1:length(fixed_names)
    csv_headers{end+1} = fixed_names{i};
end

% Kerää kaikki tulokset taulukkoon
data_table = [];

for rank = 1:n_results
    flat_idx = ranked_indices(rank);
    
    % Aloita ranking-numerolla ja TOPSIS-pisteen
    row = [rank, topsis_scores(flat_idx)];
    
    % Lisää tavoitefunktioiden arvot
    row = [row, engine.results.flattened_objectives(flat_idx, :)];
    
    % Muunna flat-indeksi multi-indeksiksi (parametriyhdistelmä)
    multi_idx = ind2sub_custom(varying_n_points, flat_idx);
    
    % Hae kyseisen kombinaation parametrit
    params = get_params_from_index(multi_idx, varying_names, varying_ranges, ...
        varying_n_points, all_params);
    
    % Lisää dynaamiset parametrit
    for i = 1:length(varying_names)
        row = [row, params.(varying_names{i})];
    end
    
    % Lisää staattiset parametrit
    for i = 1:length(fixed_names)
        row = [row, params.(fixed_names{i})];
    end
    
    data_table = [data_table; row];
end

% Kirjoita CSV-tiedosto
csv_filename = 'moo_results_ranked.csv';
fid = fopen(csv_filename, 'w');

% Kirjoita otsikkorivi
for i = 1:length(csv_headers)
    if i < length(csv_headers)
        fprintf(fid, '%s,', csv_headers{i});
    else
        fprintf(fid, '%s\n', csv_headers{i});
    end
end

% Kirjoita datarivi
for i = 1:size(data_table, 1)
    for j = 1:size(data_table, 2)
        if j < size(data_table, 2)
            fprintf(fid, '%.8f,', data_table(i, j));
        else
            fprintf(fid, '%.8f\n', data_table(i, j));
        end
    end
end

fclose(fid);

fprintf('      ✓ CSV exportattu: %s\n', csv_filename);
fprintf('      ✓ Rivejä: %d (ranking 1 = paras)\n', size(data_table, 1));
fprintf('      ✓ Sarakkeita: %d\n', size(data_table, 2));
fprintf('        - Ranking, TOPSIS_Score, Tavoitteet (%d), Dynaamiset (%d), Staattiset (%d)\n\n', ...
    n_objectives, length(varying_names), length(fixed_names));

%% ========== YHTEENVETO ==========
fprintf('\n%s\n', repmat('=', 1, 70));
fprintf('✓ ANALYYSI VALMIS\n');
fprintf('%s\n\n', repmat('=', 1, 70));

fprintf('📝 MUOKKAUSOHJEET:\n\n');
fprintf('1️⃣  Muuta suunnittelumuuttujia:\n');
fprintf('    → Avaa: design_variables_config.m\n');
fprintf('    → Muuta: min, max, n_points\n');
fprintf('    → Suorita: main\n\n');

fprintf('2️⃣  Lisää uusia parametreja:\n');
fprintf('    → design_variables_config.m (dynamics osio)\n');
fprintf('    → config.dynamics.L = {...}\n\n');

fprintf('3️⃣  Muuta tavoitefunktioita:\n');
fprintf('    → ObjectiveFunctions.m\n\n');



waitfor(gcf);  % Odottaa Enter-painallusta ennen sulkeutumista

% Prevent Octave from closing figures immediately after execution
pause;
