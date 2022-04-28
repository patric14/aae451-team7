function stats = statsCalc(time, dist, galWater, numTrips, ac)

stats.totalDist = dist.mainCruz + dist.waterDescent +...
    numTrips * (dist.waterCruz + dist.waterDrop  + ...
    dist.waterCruz) + dist.mainCruz + dist.descent;

stats.hooverTime = time.takeoff + time.waterPickup * numTrips + ...
    time.landing;

fliteTime = 2 * dist.mainCruz / ac.Vcruz + ...
    dist.waterDescent / 200 + numTrips * ...
    (2 * dist.waterCruz / ac.Vcruz + dist.waterDrop / 150) + dist.descent / 200;

stats.totalTime = fliteTime * 60 + stats.hooverTime + 10;

stats.galPerHr = galWater * numTrips / stats.totalTime;


end