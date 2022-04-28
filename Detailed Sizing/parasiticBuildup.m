function ac = parasiticBuildup(ac, V, h)

[a, mu, rho] = AtmosphereFunction(h);
v = V*1.68781;
mach = v / a;
Sref = ac.wing.sw;

CD0 = 0;

if isfield(ac, 'dragbodies')

    CD0 = 0;
    for i = 1:length(ac.dragbodies)

        bodyName = ac.dragbodies{i};
        body = ac.(bodyName);

        if contains(bodyName, 'fuse') || contains(bodyName, 'nacelle') ...
                || contains(bodyName, 'pod')
            if isfield(body, 'sw')
                Swet = body.sw;
            else
                Swet = -1;
            end

                D = body.D;
                l = body.l;

            if contains(bodyName, 'fuse') 
                
                if Swet == -1
                lambda = l / D;

                Swet = pi * D * l * (1 - 2 / lambda) ^ (2/3) * ...
                    (1 + lambda ^ -2);
                end

                Q = 1;
                FF = 0.9 + 5 / (lambda ^ 1.5) + lambda / 400;

                if isfield(body, 'xSection')
                    if contains(body.xSection, 'rect')
                        FF = 1 + (FF - 1) * 1.3;
                    end
                end

            elseif contains(bodyName, 'nacelle')
                if Swet == -1
                Swet = pi * D * l * ac.numEngines;
                Q = 1;
                FF = 1 + 0.35 / (l / D);
                end
            end
        elseif contains(bodyName, 'wing') || contains(bodyName, 'tail')
            
            Swet = body.sw * 2 * 1.02;
            if isfield(body, 'sweep')
                sweep = body.sweep;
            else
                sweep = 0;
            end
            if contains(bodyName, 'wing')
                Q = 1;
                AR = ac.AR;
                l = sqrt(AR * Swet);
            else
                AR = body.AR;
                l = sqrt(AR * Swet);
                if strcmp(body.config, 'V')
                    Q = 1.04;
                elseif strcmp(body.config, 'H')
                    Q = 1.08;
                    l = sqrt(AR * Swet / 2);
                else
                    Q = 1.05;
                end
            end

            Z = (2 - mach ^ 2) * cosd(sweep) / ...
                sqrt(1 - mach ^ 2 * cos(sweep) ^ 2);
            FF = 1 + Z * body.t_c + 100 * body.t_c ^ 4;

        end
        Re = rho * V * l / mu;
        Cf = 0.455 / (log10(Re) ^ 2.58);
        CD0 = FF * Q * Cf * Swet / Sref + CD0;
        clear Swet;
    end

else
    %Cd0 = Cfe*ac.GeometryOutput.Swet/inputs.GeometryOutput.Sw;
end

ac.CD0 = CD0 * 1.1;

end

