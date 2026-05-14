% Määritä globaalit vakiot
global F_1 Fg_1 Fg_2
global A H K J

% Yksiköt:
% - pituusmitat [m]
% - voimat [N]
% - massa [kg]

% Tasofunktioiden akseleina käytettävät tarkasteluvälit
% (nämä määritellään main.m:ssä silmukoille)

% Pituusmitat
A = 7;        % kehikon pituus, mille rakennetaan kuorma
H = 1.5;        % Aisan pituus trailerin etuseinästä vetolaitteelle
K = 0.8;         % lehtijousen pituus
J = A + H;       % kokonaispituus

% Voimat
F_1 = 80000;     % Lastin paino
Fg_1 = 7000;     % Rungon akseleiden päällä oleva omamassa
Fg_2 = 1200;     % Aisan omamassa



