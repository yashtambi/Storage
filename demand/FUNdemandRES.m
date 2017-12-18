function [PDresyR1, PDresR11, PDresR12 ,EDdayWR1, EDdaySR1, EDyearR1] = FUNdemandRES(r)
    
    %% Variables
    % r = region
    
    % Region Data
    %Population 2017
    R = [18481407,129675684,95515922,79507369,129163276];
    %population growth to 2050
    G = [1.26,1.26,1.26,1.26,1.36];
    %Efficiency improvements to 2050
    E = [0.2,0.2,0.2,0.2,0.2];
    %MAX Power use per capita 2016 (Kw)
    P = [0.8,0.8,0.8,0.8,0.4];
    %Time difference (zones)
    T = [7 5 6 5 6];
    
    % Duck curve properties
    D = [0.1 0.6 3 0.15 0.3 1 0.1 0.3;
        0.1 0.6 3 0.15 0.3 1 0.1 0.3;
        0.05 0.5 1 0.1 0.35 3 0.05 0.3;
        0.05 0.5 1 0.1 0.35 3 0.05 0.3;
        0.3 0.6 3 0.15 0.15 1 0.2 0.25];
    
    % aa
    % factor *
    a1 = D(r,1);       %range
    a2 = D(r,2);       %average
    a3 = D(r,3);         %3 is positive 1 is negative
    % factor +
    b1 = D(r,4);      %range
    b2 = D(r,5);      %average
    b3 = D(r,6);         %3 is positive 1 is negative
    % mid-day curve
    c1 = D(r,7);       %range
    c2 = D(r,8);       %average
    
    %% Constants
    
    % time
    tpd = 96;
    td = 365;
    tpy = td*tpd;
    tdy = 1:1:td;
    tsy = 1:1:tpy;
    
    % Duck curve
    FDres2050 = [0.196000000000000,0.162400000000000,0.156800000000000,0.148400000000000,0.142800000000000,0.141400000000000,0.140000000000000,0.138600000000000,0.137200000000000,0.140000000000000,0.148400000000000,0.159600000000000,0.168000000000000,0.196000000000000,0.224000000000000,0.252000000000000,0.280000000000000,0.336000000000000,0.392000000000000,0.448000000000000,0.504000000000000,0.532000000000000,0.588000000000000,0.644000000000000,0.700000000000000,0.686000000000000,0.672000000000000,0.658000000000000,0.644000000000000,0.616000000000000,0.588000000000000,0.532000000000000,0.504000000000000,0.476000000000000,0.448000000000000,0.420000000000000,0.364000000000000,0.336000000000000,0.308000000000000,0.252000000000000,0.224000000000000,0.210000000000000,0.196000000000000,0.168000000000000,0.140000000000000,0.126000000000000,0.112000000000000,0.0840000000000000,0.0560000000000000,0.0560000000000000,0.0420000000000000,0.0280000000000000,0.0280000000000000,0.0280000000000000,0.0420000000000000,0.0420000000000000,0.0560000000000000,0.112000000000000,0.168000000000000,0.224000000000000,0.252000000000000,0.336000000000000,0.448000000000000,0.560000000000000,0.616000000000000,0.672000000000000,0.728000000000000,0.840000000000000,0.868000000000000,0.896000000000000,0.924000000000000,0.938000000000000,0.952000000000000,0.966000000000000,0.952000000000000,0.938000000000000,0.924000000000000,0.910000000000000,0.896000000000000,0.882000000000000,0.868000000000000,0.854000000000000,0.840000000000000,0.826000000000000,0.812000000000000,0.784000000000000,0.728000000000000,0.644000000000000,0.560000000000000,0.504000000000000,0.448000000000000,0.392000000000000,0.364000000000000,0.336000000000000,0.308000000000000,0.252000000000000];
    
    
    %% Difference in Duck curve
    aa = a1*sin((2*pi*(tdy+a3*(365/4)))/365)+a2;
    bb = b1*sin((2*pi*(tdy+b3*(365/4)))/365)+b2;
    cc = c1*sin((2*pi*(tdy+3*(365/4)))/365)+c2;
    
    % showcase midday summer
    vec0 = zeros(1,tpd);
    td0 = 1:1:50;
    fluc0 = -(c2+c1)*sin(2*pi*(td0+(50/4))/(50))+(c2+c1);
    
    for i = 1:50
        vec0(1,(26)+i) = fluc0(i);
    end
    
    % showcase midday winter
    vec1 = zeros(1,tpd);
    fluc1 = -(c2-c1)*sin(2*pi*(td0+(50/4))/(50))+(c2-c1);
    
    for i = 1:50
        vec1(1,(26)+i) = fluc1(i);
    end
    
    % summer
    FDresR11 = ((a2-(2-a3)*(a1)).*(FDres2050+vec0))+(b2-(2-b3)*b1);
    % winter
    FDresR12 = ((a2+(2-a3)*(a1)).*(FDres2050+vec1))+(b2+(2-b3)*b1);
    
    clear vec0 vec1 td0 fluc0 fluc1
    
    %% Differences in duckcurve converted to a year
    FDresyR1 = zeros(1,35040);
    
    for i = 1:365
        % * factor
        aaa = a1*sin((2*pi*(i+a3*(365/4)))/365)+a2;
        % + factor
        bbb = b1*sin((2*pi*(i+b3*(365/4)))/365)+b2;
        % midday factor
        ccc = c1*sin((2*pi*(i+3*(365/4)))/365)+c2;
        
        vec0 = zeros(1,tpd);
        td0 = 1:1:50;
        fluc0 = -(ccc)*sin(2*pi*(td0+(50/4))/(50))+ccc;
        
        for k = 1:50
            vec0(1,(26)+k) = fluc0(k);
        end
        
        
        FDresR13 = (aaa.*(FDres2050+vec0))+bbb;
        
        % Times differences
        dd = T(r)*4;
        FDresR14= zeros(1,96);
        
        for k = 1:96-dd
            FDresR14(1,k) = FDresR13(dd+k);
        end
        
        for k = 1:dd
            FDresR14(1,(96-dd)+k) = FDresR13(k);
        end
        
        % wat was dit ook alweer? oja maak een jaar (make a year)
        
        for j = 1:96
            FDresyR1(96*(i-1)+j) = FDresR14(j);
        end
    end
    
    %% random curves year
    rd = randi([1 30],1,1);
    rdv= zeros(1,tpy);
    
    for j = 1:rd
        
        rd1 = (rand-0.5)/30;
        rd3 = randi([10 5000],1,1);
        rd2 = randi([1 35000-rd3],1,1);
        
        td0 = 1:1:rd3;
        vec1 = zeros(1,tpy);
        fluc1 = -(rd1)*sin(2*pi*(td0+(rd3/4))/(rd3))+(rd1);
        
        for i = 1:rd3
            vec1(1,(rd2)+i) = fluc1(i);
        end
        
        rdv=rdv+vec1;
    end
    
    clear rd rd1 rd2 rd3 td0 vec1 fluc1 i j
    
    %% Year curve + random curve
    
    FDresyR1 = FDresyR1 + rdv;
    
    %% Energy use
    PDresyR1 = (((1+G(r))*R(r))*(1-E(r))*(P(r))*FDresyR1)/1e3;      % Convert kWh/15min to MWh/15min
    
    if nargout > 1
        PDresR11 = ((1+G(r))*R(r))*(1-E(r))*(P(r))*FDresR11;
        PDresR12 = ((1+G(r))*R(r))*(1-E(r))*(P(r))*FDresR12;
        % energy use
        EDdayWR1 = trapz(0.25*PDresR11);               %Residential energy demand day Winter (kWh)
        EDdaySR1 = trapz(0.25*PDresR12);               %Residential energy demand day Summer (kWh)
        EDyearR1 = trapz(0.25*PDresyR1);               %Residential energy demand year       (kWh)
    end
