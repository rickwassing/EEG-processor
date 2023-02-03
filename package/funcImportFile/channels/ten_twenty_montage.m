function MONT = ten_twenty_montage()

MONT.F3.chan  = 'E36';   MONT.F3.ref  = {'E190'};        % F3 - M2
MONT.Fz.chan  = 'E21';   MONT.Fz.ref  = {'E190', 'E94'}; % Fz - 1/2*(M1+M2)
MONT.F4.chan  = 'E224';  MONT.F4.ref  = {'E94'};         % F4 - M1
MONT.C3.chan  = 'E59';   MONT.C3.ref  = {'E190'};        % C3 - M2
MONT.Cz.chan  = 'Cz';    MONT.Cz.ref  = {'E190', 'E94'}; % Cz - 1/2*(M1+M2)
MONT.C4.chan  = 'E183';  MONT.C4.ref  = {'E94'};         % C4 - M1
MONT.P3.chan  = 'E87';   MONT.P3.ref  = {'E190'};        % P3 - M2
MONT.Pz.chan  = 'E101';  MONT.Pz.ref  = {'E190', 'E94'}; % Pz - 1/2*(M1+M2)
MONT.P4.chan  = 'E153';  MONT.P4.ref  = {'E94'};         % P4 - M1
MONT.O1.chan  = 'E116';  MONT.O1.ref  = {'E190'};        % O1 - M2
MONT.Oz.chan  = 'E126';  MONT.Oz.ref  = {'E190', 'E94'}; % Oz - 1/2*(M1+M2)
MONT.O2.chan  = 'E150';  MONT.O2.ref  = {'E94'};         % O2 - M2
MONT.vEOG.chan = 'E18';  MONT.vEOG.ref = {'E238'};       % vEOG
MONT.hEOG.chan = 'E1';   MONT.hEOG.ref = {'E252'};        % hEOG

end