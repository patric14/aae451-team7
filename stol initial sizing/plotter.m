function plotter(toPlot)

fontsize = 16;

% Get stuff to plot
plotXs = toPlot.plotXs;
plotYs = toPlot.plotYs;
if isfield(toPlot, 'decidedTrips')
    decidedTrips = toPlot.decidedTrips;
end

% Get number of plots to make, set up subplots
[nPlot, nPerPlot] = size(plotYs);
if nPlot <= 3
    nRows = 2;
else
    nRows = ceil(nPlot / 4);
end
nCol = ceil(nPlot / nRows);

figure
% Loop thru plots
for i = 1:nPlot
    subplot(nRows, nCol, i)
    hold on

    currentX = plotXs{i};

    % Loop thru variables per subplot
    for j = 1:nPerPlot
        currentY = plotYs{i, j};
        plot(currentX, currentY, 'LineWidth',2)
    end

    % Shawn's sweet magic plot marker for decided number of trips
    if exist('decidedTrips', 'var')
        for j = 1:nPerPlot
            currentY = plotYs{i, j};
            plot(currentX(decidedTrips), currentY(decidedTrips), ...
                'r.', 'MarkerSize',20)
            xline(currentX(decidedTrips),'r--')
            yline(currentY(decidedTrips),'r--')
        end
    end

    % Labels and grid
    if isfield(toPlot, 'xlabel')
        xlabel(toPlot.xlabel{i})
    end
    if isfield(toPlot, 'ylabel')
        ylabel(toPlot.ylabel{i})
    end
    grid on

    % Put legends on first subplot if enabled
    if i == 1
        if isfield(toPlot, 'subplotLegend')
            legend(toPlot.subplotLegend, 'Location', 'Best')
        end
    end
    set(gca, 'fontsize', fontsize)
end

% Make plot big
set(gcf, 'Units', 'Normalized', 'OuterPosition', [.25 .33 .5 .66]);

end