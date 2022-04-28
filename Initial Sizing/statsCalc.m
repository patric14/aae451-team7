function stats = statsCalc(time, dist, galWater, numTrips, Vcruz)

stats.totalDist = dist.climb + dist.mainCruz + ...
    numTrips * (dist.waterDescent + dist.waterClimb + dist.waterCruz + ...
    dist.waterDescent + dist.waterDrop + dist.waterClimb + ...
    dist.waterCruz) + dist.mainCruz + dist.descent;

stats.hooverTime = time.takeoff + time.waterPickup * numTrips + ...
    time.landing;

stats.totalTime = stats.totalDist / Vcruz + stats.hooverTime / 60;

stats.galPerHr = galWater * numTrips / stats.totalTime;


end