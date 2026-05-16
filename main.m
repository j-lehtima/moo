%% ======================================================================
% MONITAVOITEOPTIMOINTIKEHIKKO - MOO FRAMEWORK v2.0
% ======================================================================
%
% 🎯 KAIKKI SUUNNITTELUMUUTTUJAT MÄÄRITELLÄÄN YHDESSÄ PAIKASSA:
%    design_variables_config.m
%
% ======================================================================

fprintf('\n%s\n', repmat('=', 1, 70));
fprintf('MONITAVOITEOPTIMOINTIKEHIKKO - MOO FRAMEWORK v2.0\n');
fprintf('%s\n', repmat('=', 1, 70));

%% ========== VAIHE 0: Lataa kaikki suunnittelumuuttujat ==========
fprintf('\n[VAIHE 0] Ladataan suunnittelumuuttujat\n');
fprintf('  📝 Lähde: design_variables_config.m\n');
fprintf('  🎯 Kaikki parametrit YHDESSÄ PAIKASSA\n\n');

% Lataa konfiguraatio (KAIKKI parametrit täällä!)
config = design_variables_config();

% Ekstraktoi eri muotoihin
[all_params, varying_names, varying_ranges, varying_n_points, fixed_names] = ...
    extract_design_variables(config);

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

moo_visualize(engine, objectives, topsis_scores, pareto_indices, 5);

fprintf('      ✓ Kuvaajat luotu\n');

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


