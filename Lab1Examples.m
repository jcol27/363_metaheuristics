%{
fun = @dejong5fcn;
x0 = [0 0];
lb = [-64 -64];
ub = [64 64];
options = optimoptions('simulannealbnd', 'PlotFcn',{@saplotbestf,@saplotf,@saplottemperature});
[x fval] = simulannealbnd(fun,x0,lb,ub,options)

rng default % For reproducibility
fun = @ps_example;
options = optimoptions('ga','PlotFcn', {@gaplotbestf, @gaplotscorediversity});
[x fval] = ga(fun,2,[],[],[],[],[],[],[],options)
%}
rng default % for reproducibility
nvars = 6; % choose any even value for nvars
fun = @multirosenbrock;
lb = -10*ones(1,nvars);
ub = -lb; % set bounds to (-10, 10)
options = optimoptions('particleswarm', 'PlotFcn', @pswplotbestf);
[x,fval] = particleswarm(fun,nvars,lb,ub,options)


