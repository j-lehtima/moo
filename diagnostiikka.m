%% ======================================================================
% DIAGNOSTIIKKA-SKRIPTI - MOO Framework komponen
%
% Tämä skripti tarkistaa että kaikki komponentit toimivat
% ======================================================================

fprintf('\n%s\n', repmat('=', 1, 70));
fprintf('MOO Framework - DIAGNOSTIIKKA\n');
fprintf('%s\n', repmat('=', 1, 70));

%% Testi 1: Vakioiden lataus
fprintf('\n[TESTI 1] Vakioiden lataus (load_constants)\n');
try
    constants = load_constants();
    fprintf('  ✓ Constants-struct luotu onnistuneesti\n');
    fprintf('    - A (kehikon pituus) = %.1f m\n', constants.A);
    fprintf('    - F_1 (lastin paino) = %.0f N\n', constants.F_1);
catch ME
    fprintf('  ✗ VIRHE: %s\n', ME.message);
end

%% Testi 2: DesignSpace-luokka
fprintf('\n[TESTI 2] DesignSpace-luokka\n');
try
    param_config.names = {'B', 'G'};
    param_config.ranges = {[1, 3], [1.8, 3]};
    param_config.n_points = [5, 5];  % Pieni testi
    
    ds = DesignSpace(param_config);
    fprintf('  ✓ DesignSpace luotu onnistuneesti\n');
    fprintf('    - Dimensiot: %d\n', ds.n_dimensions);
    fprintf('    - Kombinaatiot: %d\n', ds.get_total_combinations());
    fprintf('    - B-arvot (%.2f...%.2f, %d pt)\n', ...
        ds.param_values{1}(1), ds.param_values{1}(end), length(ds.param_values{1}));
catch ME
    fprintf('  ✗ VIRHE: %s\n', ME.message);
end

%% Testi 3: ObjectiveFunctions-luokka
fprintf('\n[TESTI 3] ObjectiveFunctions-luokka\n');
try
    obj = ObjectiveFunctions();
    fprintf('  ✓ ObjectiveFunctions luotu onnistuneesti\n');
    fprintf('    - Tavoitteet: %d\n', obj.n_objectives);
    
    % Testaa tavoitefunktioita
    test_M_x = [50000; 30000; 20000; 10000; -5000; 15000];
    test_vals = obj.evaluate_all(test_M_x);
    fprintf('    - Tavoitearvojen laskenta: ✓\n');
    fprintf('      Test M_x arvolla: [%s]\n', sprintf('%.0f ', test_M_x(1:3)));
    fprintf('      Tavoitearvot: [%s]\n', sprintf('%.1f ', test_vals(1:3)));
catch ME
    fprintf('  ✗ VIRHE: %s\n', ME.message);
end

%% Testi 4: matrix_builder-funktio
fprintf('\n[TESTI 4] matrix_builder-funktio\n');
try
    test_params = [2.0; 2.4];  % B=2.0, G=2.4
    M_x = matrix_builder(test_params, constants);
    fprintf('  ✓ matrix_builder toimii onnistuneesti\n');
    fprintf('    - Syöte: B=%.1f, G=%.1f\n', test_params(1), test_params(2));
    fprintf('    - Tuotto M_x: [%s]\n', sprintf('%.1f ', M_x(1:3)));
    
    % Tarkista että M_x ei ole NaN
    if any(isnan(M_x))
        fprintf('    ⚠ VAROITUS: M_x sisältää NaN-arvoja!\n');
    end
catch ME
    fprintf('  ✗ VIRHE: %s\n', ME.message);
end

%% Testi 5: EvaluationEngine (pieni skaalassa)
fprintf('\n[TESTI 5] EvaluationEngine (pieni testi 3x3 grid)\n');
try
    % Pieni testi-grid
    param_config_small.names = {'B', 'G'};
    param_config_small.ranges = {[1.5, 2.5], [2.0, 2.8]};
    param_config_small.n_points = [3, 3];  % Vain 9 kombinaatiota
    
    ds_small = DesignSpace(param_config_small);
    obj = ObjectiveFunctions();
    
    engine = EvaluationEngine(ds_small, obj, false);  % verbose=false
    engine = engine.evaluate_all(@matrix_builder, constants);
    
    fprintf('  ✓ EvaluationEngine suoritettu onnistuneesti\n');
    fprintf('    - Evaluoitujen kombinaatioiden määrä: %d\n', ...
        size(engine.results.flattened_objectives, 1));
    fprintf('    - Tavoitteiden määrä: %d\n', ...
        size(engine.results.flattened_objectives, 2));
    
    % Tarkista tulokset
    if all(~isnan(engine.results.flattened_objectives(:)))
        fprintf('    - Tavoitearvot: ✓ (ei NaN)\n');
    else
        fprintf('    ⚠ VAROITUS: Tavoitearvoissa NaN-arvoja!\n');
    end
catch ME
    fprintf('  ✗ VIRHE: %s\n', ME.message);
end

%% Testi 6: MOOAnalyzer - TOPSIS
fprintf('\n[TESTI 6] MOOAnalyzer - TOPSIS\n');
try
    obj_fun = ObjectiveFunctions();
    [best_idx, ranking, scores] = MOOAnalyzer.topsis_analysis(...
        engine.results.flattened_objectives, obj_fun.directions, obj_fun.weights);
    
    fprintf('  ✓ TOPSIS-analyysi suoritettu onnistuneesti\n');
    fprintf('    - Parhaan ratkaisun indeksi: %d\n', best_idx);
    fprintf('    - TOPSIS-pisteen paras: %.4f\n', scores(best_idx));
    fprintf('    - TOPSIS-pisteen huonoin: %.4f\n', min(scores));
catch ME
    fprintf('  ✗ VIRHE: %s\n', ME.message);
end

%% Testi 7: MOOAnalyzer - Pareto
fprintf('\n[TESTI 7] MOOAnalyzer - Pareto-front\n');
try
    obj_fun = ObjectiveFunctions();
    pareto_idx = MOOAnalyzer.find_pareto_front(...
        engine.results.flattened_objectives, obj_fun.directions);
    
    n_pareto = sum(pareto_idx);
    fprintf('  ✓ Pareto-front analyysi suoritettu onnistuneesti\n');
    fprintf('    - Pareto-optimaalisia: %d / %d (%.1f%%)\n', ...
        n_pareto, length(pareto_idx), 100*n_pareto/length(pareto_idx));
catch ME
    fprintf('  ✗ VIRHE: %s\n', ME.message);
end

%% Yhteenveto
fprintf('\n%s\n', repmat('=', 1, 70));
fprintf('DIAGNOSTIIKKA VALMIS\n');
fprintf('%s\n\n', repmat('=', 1, 70));

fprintf('Seuraava askel:\n');
fprintf('  1. Tarkista että kaikki testit menivät läpi (✓)\n');
fprintf('  2. Avaa ja suorita main.m täysimittaisella analyysilä\n');
fprintf('  3. Jos virheitä, tarkista error-viestit yllä\n\n');
