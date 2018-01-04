function[x,fval]=Without_storage(PVoutput,wpower,hydropower,region, demand)
data=xlsread('cost analysis.xlsx');
cost=data(1:3,7);%LCOEs
maxarea=data(1:5,9);%Areas of each region
%%shows how much of the land can be apportioned depending on resource availability in the region
PVland=data(1:5,3);
Windland=data(1:5,4);
Hydroland=data(1:5,5);

%%area already occupied per region by pv,wind and solar
pvmin=data(1:5,10);
windmin=data(1:5,11);
hydromin=data(1:5,12);
%%Objective Fn.
f=[cost(1) cost(2) cost(3)];%minimize cost per quarter hour
%%MAX limits for power MWh/quarter
PVmax=PVoutput*PVland(region)*maxarea(region);%MWh per quarter per m2 X area m2
Windmax=wpower*Windland(region)*maxarea(region);%so that total land requirement does not exceed total land area of that region
Hydromax=hydropower*Hydroland(region)*maxarea(region);%PVland+Windland+Hydroland=1;
ub=[PVmax, Windmax, Hydromax];
%%MIN limits for power MWh/quarter
PVmin=PVoutput*pvmin(region);%MWh per quarter per m2 X area m2
Windmin=wpower*windmin(region);
Hydromin=hydropower*hydromin(region);
lb=[PVmin, Windmin, Hydromin];

%%Demand supply constraint
demandfactor=data(1:5,2);
Aeq=[1 1 1];
beq=demandfactor(region)*demand;

%%
A=[];
b=[];

[x,fval] = linprog(f,A,b,Aeq,beq,lb,ub);


