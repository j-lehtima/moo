%% ======================================================================
% QUICK START - MOO Framework
% ======================================================================
%
% PIKA-OPAS: Miten käytän tätä kehikkoa?
%
% ======================================================================
%
% ASKEL 1: Avaa main.m ja suorita
% ────────────────────────────────
%   Komennolla: octave --no-gui --eval "main"
%   tai: F5 Octave GUI:ssa
%
% Mitä tapahtuu:
%   1. Ladataan vakiot
%   2. Määritellään parametritila (Design Space)
%   3. Määritellään tavoitefunktiot (4 kpl)
%   4. Evaluoidaan 15x15 = 225 kombinaatiota
%   5. Lasketaan TOPSIS-ranking ja Pareto-front
%   6. Piirretään kuvaajat
%
%
% ASKEL 2: Kokeile parametrien laajentamista
% ────────────────────────────────────────────
%
% Avaa main.m ja muuta rivi ~20:
%
% ENNEN:
%   param_config.names = {'B', 'G'};
%   param_config.ranges = {[1, 3], [1.8, 3]};
%   param_config.n_points = [15, 15];
%
% JÄLKEEN (kolme parametria):
%   param_config.names = {'B', 'G', 'K'};
%   param_config.ranges = {[1, 3], [1.8, 3], [0.5, 1.5]};
%   param_config.n_points = [12, 12, 8];  % Vähennä koska 3D on isompi
%
% Sitten PÄIVITÄ matrix_builder.m:
% Vanha (rivi ~18):
%   B = param_vals(1);
%   G = param_vals(2);
%
% Uusi:
%   B = param_vals(1);
%   G = param_vals(2);
%   K = param_vals(3);  % Lisää tämä
%   % Käytä K:ta laskennassa...
%
%
% ASKEL 3: Muuta tavoitefunktioita
% ─────────────────────────────────
%
% Avaa ObjectiveFunctions.m konstruktori ja muuta:
%
% Lisää uusi tavoite:
%   obj.objectives{5} = @(M_x) max(M_x) - min(M_x);  % Voimien leviämä
%   obj.names{5} = 'Leviämä (N)';
%   obj.directions(5) = -1;  % Minimointi
%
% Päivitä n_objectives:
%   obj.n_objectives = length(obj.objectives);  % Automaattinen
%
% Muuta painotukset (jos 5 tavoitetta):
%   obj.weights = [0.25, 0.2, 0.2, 0.2, 0.15];  % Summa = 1.0
%
%
% ASKEL 4: Sovella suunnittelurajoitteita
% ────────────────────────────────────────
%
% Avaa main.m ja muuta constraints-osio (~viivarit 75-80):
%
% Nykyiset rajoitteet:
%   constraints{1} = @(params, objs) params(1) >= 1.2 && params(1) <= 2.8;  % B
%   constraints{2} = @(params, objs) params(2) >= 2.0 && params(2) <= 2.9;  % G
%
% Lisää tavoite-rajoite:
%   constraints{3} = @(params, objs) objs(1) < 100000;  % Maksimi voima
%
% Lisää uusi parametri-rajoite:
%   constraints{4} = @(params, objs) params(1) + params(2) > 3.5;  % Summa
%
%
% ASKEL 5: Muuta resoluutiota (tarkkuus vs nopeus)
% ─────────────────────────────────────────────────
%
% NOPEA analyysi (< 1 sekunnissa):
%   param_config.n_points = [8, 8];
%
% NORMAALI analyysi (muutama sekunti):
%   param_config.n_points = [15, 15];
%
% TARKKA analyysi (10+ sekuntia, riippuen koneesta):
%   param_config.n_points = [30, 30];
%
%
% ASKEL 6: Tulkitse tuloksia
% ──────────────────────────
%
% TOPSIS-ranking:
%   Numero 1 = paras ratkaisu ottaen huomioon KAIKKI tavoitteet ja painotukset
%   Numero 2 = toiseksi paras, jne.
%
% Pareto-front [P]:
%   Merkityt ratkaisut ovat Pareto-optimaalisia
%   Niitä ei voi parantaa yhdessä tavoitteessa
%   heikentämättä toista tavoitetta
%
% Tavoite-pareittain scatter:
%   Punainen = Pareto-optimaalinen
%   Sininen = muut ratkaisut
%
%
% ASKEL 7: Tallenna tulokset
% ──────────────────────────
% Tulokset ovat muistissa:
%   engine.results.flattened_objectives
%   engine.results.flattened_solutions
%   topsis_scores
%   pareto_indices
%
% Tallenna CSV:ksi:
%   results_table = table(...
%       (1:size(engine.results.flattened_objectives,1))', ...
%       engine.results.flattened_objectives, ...
%       topsis_scores, ...
%       pareto_indices);
%   writetable(results_table, 'MOO_results.csv');
%
%
% ======================================================================
% TROUBLESHOOTING
% ======================================================================
%
% Q: "Error: matrix is singular" matrix_builder.m:ssa
% A: Tarkista että vakiot ovat oikeita load_constants.m:ssa
%    Tarkista että parametrien välit ovat järkeviä
%    (esim. B > A tekee mahdottomaksi matriisin)
%
% Q: "Not enough input arguments" ObjectiveFunctions:ssa
% A: Muista että @(M_x) funktiot ottavat M_x:n parametriksi
%    M_x on ratkaisuvektori (6x1)
%
% Q: Kuvaajat eivät näy
% A: Tarkista että figure-kutsut eivät ole kommentoituja
%    moo_visualize.m:ssa tai muissa plot-funktioissa
%
% Q: Haluan näyttää vain Pareto-optimaalijset ratkaisut
% A: Suodata tulokset ennen visualisaatiota:
%    pareto_objs = engine.results.flattened_objectives(pareto_indices, :);
%    pareto_sols = engine.results.flattened_solutions(pareto_indices, :);
%
% ======================================================================
