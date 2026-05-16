%% ======================================================================
% ARKKITEHTUURIOHJEISTO - MOO Framework
% ======================================================================
%
% KANSIO-RAKENNE:
%
% ┌─ PÄÄOHJELMA
% │  main.m ............................ Pääohjelma (5 vaihetta)
% │
% ├─ DESIGN SPACE (Parametrit)
% │  DesignSpace.m ..................... N-ulotteisen parametritilan hallinta
% │  load_constants.m .................. Vakioiden lataus
% │  matrix_builder.m .................. Ratkaisumatriisin M_x laskenta
% │
% ├─ TAVOITEFUNKTIOT
% │  ObjectiveFunctions.m .............. Tavoitefunktioiden määrittely
% │
% ├─ EVALUOINTI
% │  EvaluationEngine.m ................ N-ulotteisen parametritilan arviointia
% │
% ├─ MOO-MENETELMÄT
% │  MOOAnalyzer.m ..................... TOPSIS ja Pareto-front analyysi
% │
% ├─ VISUALISAATIO
% │  moo_visualize.m ................... MOO-tulosten visualisaatio
% │  plot_*.m .......................... Perinteisiä parametritila-kuvaajia
% │
% └─ LEGACY (Vanha ratkaisu)
%    constants.m ....................... Globaalien vakioiden määrittely (legacy)
%
% ======================================================================
% VAIHE-BY-VAIHE OHJEISTO
% ======================================================================
%
% VAIHE 1: SUUNNITTELUTILA (Design Space)
% ─────────────────────────────────────────
% Määritä mitä parametreja haluat tutkia:
%
%   param_config.names = {'B', 'G', 'L', 'K'};  % Parametrien nimet
%   param_config.ranges = {[1, 3], [1.8, 3], [5, 8], [0.5, 1.5]};
%   param_config.n_points = [10, 10, 8, 6];     % Resoluutio
%
% Nykyinen konfiguraatio: 2 parametria (B, G)
% Kokeile laajentaa: lisää uusia rivejä arrays:iin
%
% DesignSpace-luokka generoi linspan vektorit jokaiselle parametrille.
% Parametrit talllennetaan cell-arrayssa: design_space.param_values{i}
%
% Tuotosta:
% - Käy läpi kaikki kombinaatiot rekursiivisesti
% - Jos parametreja n, tulostaulukon dimensio on [n1 x n2 x ... x n_obj]
%
% Eli parametriyhdistelmä indeksoidaan esim: (i, j, :) tai (i, j, k, :)
%
%
% VAIHE 2: TAVOITEFUNKTIOT (Objectives)
% ──────────────────────────────────────
% Määritä tavoitefunktiot ObjectiveFunctions.m:ssa:
%
% Luokan rakenne:
%   .objectives{i} = @(M_x) ... % Lambda-funktio M_x:lle
%   .names{i} = 'Tavoitteen nimi'
%   .directions(i) = -1 tai 1    % -1=minimointi, 1=maksimointi
%   .weights(i) = 0.0...1.0      % TOPSIS-painotukset
%
% Esimerkki tavoitteita:
%   max(abs(M_x))       - suurin yksittäinen voima
%   sum(abs(M_x))       - kokonaisvoima
%   min(abs(M_x>0))     - minimaalinen positiivinen voima
%   var(M_x)            - voimien varianssi / tasaisuus
%   norm(M_x)           - L2-normi
%   max(M_x) - min(M_x) - voimien leviämä
%
% Muokkaa painotuksia: .weights = [0.4, 0.3, 0.2, 0.1]
% Suurempi paino = tärkempi tavoite TOPSIS-laskennassa
%
%
% VAIHE 3: EVALUOINTI (Evaluation Engine)
% ────────────────────────────────────────
% EvaluationEngine käy läpi kaikki parametriyhdistelmät:
%
%   for i1 = 1:n1
%       for i2 = 1:n2
%           ...
%               param_vals = [B(i1), G(i2), ...]
%               M_x = matrix_builder(param_vals, constants)
%               objectives = obj_func.evaluate_all(M_x)
%               tallennetaan tulostaulukkoon
%
% Rekursiivinen algoritmi mahdollistaa minkä tahansa n:n parametrien
% käsittelyn ilman sisäkkäisiä for-silmukoita.
%
% Tulokset:
%   .solutions = [n1 x n2 x ... x 6]      (matriisien M_x arvot)
%   .objectives = [n1 x n2 x ... x n_obj] (tavoitearvojen arvot)
%   .flattened_solutions = [prod(n) x 6]  (litistetty 2D-muoto)
%   .flattened_objectives = [prod(n) x n_obj]
%
%
% VAIHE 4: MOO-ANALYYSI (MOOAnalyzer)
% ────────────────────────────────────
% Kaksi päämenetelmää:
%
% 4a. TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)
%     - Laskee etäisyydet ideaali- ja pahoin ratkaisuista
%     - Tuottaa ranked järjestyksen kaikkille ratkaisuille
%     - Huomio TOPSIS-painotukset .weights:issa
%
% 4b. Pareto-front
%     - Tunnistaa ratkaisut, joita ei dominoi mikään toinen
%     - Ratkaisu A dominoi B:tä jos:
%       * A on vähintään yhtä hyvä kaikissa tavoitteissa JA
%       * A on parempi ainakin yhdessä tavoitteessa
%     - Pareto-front = kaikki ei-dominoidut ratkaisut
%
% Käyttö:
%   [best_idx, ranking, scores] = MOOAnalyzer.topsis_analysis(...)
%   pareto_idx = MOOAnalyzer.find_pareto_front(...)
%   filtered_idx = MOOAnalyzer.apply_constraints(...) % suodata rajoitteilla
%
%
% VAIHE 5: VISUALISAATIO
% ──────────────────────
% moo_visualize.m näyttää:
%   - TOPSIS-pisteen TOP N ratkaisulle
%   - Tavoitepareja scatter-kuvaajissa
%   - Tavoiteiden vertailu TOP-ratkaisuille
%   - Pareto-front tilastot
%
%
% ======================================================================
% KÄYTÄNNÖN ESIMERKKI
% ======================================================================
%
% 1. Muuta resoluutiota:
%    param_config.n_points = [20, 20];  % Kasvata tarkkuutta
%
% 2. Lisää uusi parametri:
%    param_config.names = {'B', 'G', 'K'};
%    param_config.ranges = {[1, 3], [1.8, 3], [0.5, 1.5]};
%    param_config.n_points = [15, 15, 8];
%    % Päivitä matrix_builder.m ottamaan param_vals(3) = K:ksi
%
% 3. Muuta tavoitteita:
%    % ObjectiveFunctions.m:ssa:
%    obj.objectives{5} = @(M_x) sum(M_x.^2);
%    obj.names{5} = 'Neliösumma';
%    obj.directions(5) = -1;
%    obj.weights = [0.25, 0.25, 0.25, 0.25];
%
% 4. Lisää suunnittelurajoite:
%    constraints{3} = @(params, objs) params(1) > 1.5;  % B > 1.5
%    filtered_idx = MOOAnalyzer.apply_constraints(..., constraints);
%
% ======================================================================
