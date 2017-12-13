function [ losses ] = tlosses ( L, Vl, r, l, S, pf, c)
    
    
    
    S=S*(10^6);
    Vl=Vl*(10^3);
    l=l*(10^-3);
    ind=L*(l);
    R=r*(L);
    
    Vr=Vl/sqrt(3);
    Z=complex(R,2*pi*50*ind);
    j=sqrt(-1);
    if L <= 60
        A=1;
        B=Z;
        C=0;
        D=A;
    elseif L > 60 && L <= 160
        c=c*(10^-6);
        Y=2*pi*50*c*L*j;
        A=(Y/2)*Z+1;
        B=Z*((Y/4)*Z+1);
        C=Y;
        D=A;
    else
        c=c*(10^-6);
        Y=2*pi*50*c*L*j;
        K=sqrt(Y*Z);
        M=sqrt(Y/Z);
        A=cosh(K);
        B=sinh(K)/M;
        C=M*sinh(K);
        D=A;
    end
    
    Ir=S/((sqrt(3)*Vl));
    IR =((Ir))*complex(cos(-acos(Fi)),sin(-acos(Fi)));
    VS=A*Vr+B*IR;
    IS=C*Vr+D*IR;
    Ps=3*real(VS*(conj(IS)));
    VR=abs((((abs(VS)/abs(A))-abs(Vr))/abs(Vr)))*100;
    Pr=S*0.8;
    EF=(Pr/Ps)*100;
    Qs=3*imag(VS*(conj(IS)));
    F=cos(atan(Qs/Ps));
    
    fprintf('\n')
    disp('No load receiving end voltage');
    disp(abs(Vr))
    disp('No load sending end current');
    disp(abs(IS))
    disp('Sending end p.f.');
    disp(F)
    disp('Voltage Regulation of the line');
    disp(VR)
    disp('Transmission Efficiency of the line');
    disp(EF)
end