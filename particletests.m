n = 100;
bestobj = zeros(1,n);
xnew = zeros(1,n);

for i=1:n
    rng(686411634) % for reproducibility
    nvars = 6; % choose any even value for nvars
    fun = @egg;
    lb = -512*ones(1,nvars);
    ub = -lb; % set bounds to (-10, 10)
    options = optimoptions('particleswarm', 'SocialAdjustmentWeight',i/25);
    [x,fval,exitflag,output] = particleswarm(fun,nvars,lb,ub,options);
    xnew(1,i) = i/25;
    bestobj(1,i) = output.funccount;    
end

figure(1);
plot(xnew,bestobj);
xlabel("Social Adjustment Weight");
ylabel("Iteration Count");
title("Graph of Particle Swarm Algorithm Runtime Performance vs Social Adjustment Weight")