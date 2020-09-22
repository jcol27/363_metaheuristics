n = 100;
bestobj = zeros(1,n);
xnew = zeros(1,n);

for i=1:n
    
    rng(686411534)
    fun = @egg;
    %options = optimoptions('ga','PlotFcn', {@gaplotbestf, @gaplotscorediversity},'PopulationSize', 4000, 'CrossoverFraction', i/100);
    %options = optimoptions('ga','PopulationSize', 4000, 'CrossoverFraction', i/n);
    options  = optimoptions('ga','PopulationSize', i*100)
    [x fval] = ga(fun,2,[],[],[],[],[],[],[],options)
    xnew(1,i) = i*100;
    bestobj(1,i) = fval;
end
figure(1);
plot(xnew,bestobj);
xlabel("Population Size");
ylabel("Best Objective Function Value");
title("Graph of Genetic Algorithm Performance vs Population Size")


%{
options  = optimoptions('ga','PopulationSize', i*100)
[x fval] = ga(fun,2,[],[],[],[],[],[],[],options)
xnew(1,1) = 1;
bestobj(1,1) = fval;

options  = optimoptions('ga','PopulationSize', i*100)
[x fval] = ga(fun,2,[],[],[],[],[],[],[],options)
xnew(1,1) = 1;
bestobj(1,1) = fval;

options  = optimoptions('ga','PopulationSize', i*100)
[x fval] = ga(fun,2,[],[],[],[],[],[],[],options)
xnew(1,1) = 1;
bestobj(1,1) = fval;

figure(1);
plot(xnew,bestobj);
xlabel("Population Size");
ylabel("Best Objective Function Value");
title("Graph of Genetic Algorithm Performance vs Population Size")

%}


    