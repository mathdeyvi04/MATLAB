function [f, X] =EspectroLog(Fs,x)
    % Plota o Espectro do Sinal
    % Fs: frequência de amostragem;
    % x: Sinal (vetor coluna).
    
    x=x';
    %tam_x=size(x)
    
    X=fft(x) ;
    N=size(X,1);
    
    Nn=floor(N/2);
    
    EspectrNeg=X((Nn+2):N,:);
    %size(EspectrNeg,1)
    
    EspectrPos=X(1:(Nn+1),:);
    %size(EspectrPos,1)
    
    Espectr=[EspectrNeg; EspectrPos];
    %size(Espectr,1)
    
    Espectr=abs(Espectr);
    Deltaf=Fs/N;
    f=(-Deltaf*size(EspectrNeg,1)):Deltaf:(Deltaf*(size(EspectrPos,1)-1));
    semilogy(f,Espectr);grid
    %plot(f,Espectr);grid
end