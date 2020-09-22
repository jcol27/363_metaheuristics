n = 100;
bestobjdef = zeros(1,n);

xnew = zeros(1,n);

for i=1:n


    fun = @egg;
    x0 = [0 0];
    lb = [-512 -512];
    ub = [512 512];
    
    % Default Function
    options = optimoptions('simulannealbnd','InitialTemperature',10*i);
    [x fval] = simulannealbnd(fun,x0,lb,ub,options)
    xnew(1,i) = i*10;
    bestobjdef(1,i) = fval;
    
    % Fast
    options = optimoptions('simulannealbnd','InitialTemperature',10*i, 'AnnealingFcn', 'annealingfast');
    [x fval] = simulannealbnd(fun,x0,lb,ub,options)
    xnew(1,i) = i*10;
    bestobjfast(1,i) = fval;
    
    % Boltz
    options = optimoptions('simulannealbnd','InitialTemperature',10*i, 'AnnealingFcn', 'annealingboltz');
    [x fval] = simulannealbnd(fun,x0,lb,ub,options)
    xnew(1,i) = i*10;
    bestobjboltz(1,i) = fval;
    
    
end

figure(1);
plot(xnew,bestobjdef,xnew,bestobjfast,xnew,bestobjboltz);
legend('Default', 'Fast', 'Boltz')
xlabel("Initial Temperature");
ylabel("Best Objective Function Value");
title("Graph of Simulated Annealing Algorithm Performance vs Initial Temperature for Different Annealing Functions")

