clear; clc; close all;

% Aircraft geometry
ac.AR = 6.178;
ac.numEngines = 2;
ac.dragbodies = {'fuse', 'nacelle', 'wing', 'horiz_tail', 'vert_tail'};
wing.sw = 350;
wing.sweep = 0;
wing.t_c = .15;
ac.wing = wing;
fuse.l = 45.12;
fuse.D = 7.52;
fuse.xSection = 'rect';
ac.fuse = fuse;
nacelle.l = 12.5;
nacelle.D = 5.5;
ac.nacelle = nacelle;
horiz_tail.config = 'T';
horiz_tail.sw = 105;
horiz_tail.AR = 3;
horiz_tail.t_c = .12;
ac.horiz_tail = horiz_tail;
vert_tail.config = 'T';
vert_tail.sw = 60;
vert_tail.AR = 1.2;
vert_tail.t_c = .12;
ac.vert_tail = vert_tail;

data = readmatrix("280kts_4kfeet.txt");
%data{2} = readmatrix("280kts_6kfeet.txt");
h = 4000;


CL = data(:, 3);

Sref = ac.wing.sw; % Planform wing area [ft^2]
e0 = 1.78 * (1 - 0.045 * ac.AR ^ 0.68) - 0.64; % Oswald Efficiency Factor

% Induced drag
CDi = CL.^2./(pi*ac.AR*e0) * .7;


% Parasitic drag buildup
ac.CDi = CDi;
ac.CL = CL;
ac = parasiticBuildup(ac, 280, h);

%% Total drag and L/D
CD = ac.CDi + ac.CD0;
ac.CD = CD;
ac.L_D = CL / CD;


plot(CL, CD)
xlabel('C_L')
ylabel('C_D')
%title('Cruise Drag Polar')
grid
set(gca, 'fontsize', 14)



