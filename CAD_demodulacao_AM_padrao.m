% Trabalho de Comunicações Analógicas
clc
clear

% Alterações na função de espectro
function [eixo_de_frequencia, Espectr] = obter_espectro(frequencia_de_amostragem, sinal)
    % Carrega informações de range de frequências e valor espectral no
    % domínio da frequência.
    
    resultado_fft =fft(sinal);

    N = size(resultado_fft, 1);
    
    Nn = floor(N/2);
    
    EspectrNeg=resultado_fft((Nn+2):N,:);
    
    EspectrPos=resultado_fft(1:(Nn+1),:);  
    
    Espectr=abs([EspectrNeg; EspectrPos]);
        
    Deltaf = frequencia_de_amostragem/N;
    eixo_de_frequencia = (-Deltaf*size(EspectrNeg,1)):Deltaf:(Deltaf*(size(EspectrPos,1)-1));
end

Fs = 44100;  % Frequência de Amostragem
tempo_total_do_sinal = 18;  

% Carregamos o vetor do sinal modulado
load 23054_modulado.mat

vetor_temporal = 0: (1 / Fs) : tempo_total_do_sinal;

% Apresentar o sinal modulado.
hold on 
subplot(2, 2, 1);
plot(vetor_temporal, Sin_pb);
xlabel("Instante(s)");
ylabel("Amplitude");
title("Sinal Modulado no Tempo");
grid;

subplot(2, 2, 2);
[eixo_de_frequencia_do_modulado, espectro_do_modulado] = obter_espectro(Fs, Sin_pb);
semilogy(eixo_de_frequencia_do_modulado, espectro_do_modulado);
title("Espectro no Domínio da Frequência");
xlabel("Frequência");
ylabel("Amplitude");
grid;

% Agora devemos realizar a demodulação

% Antes de passar pelo filtro, devemos multiplicar o sinal por cos(2pift)

f_c = 8400;  % Pelo olhômetro
for i = 1:length(Sin_pb)

    Sin_pb(i, 1) = Sin_pb(i, 1) * cos(2 * pi * f_c * vetor_temporal(i));
end


% Finalmente o filtro.

frequencia_de_corte = 2000;
frequencia_de_corte_normalizada = frequencia_de_corte / (Fs / 2);
ordem_do_filtro = 10;
tipo_de_filtro = "low";  % Passa Baixa

[coef_num, coef_den] = butter(ordem_do_filtro, frequencia_de_corte_normalizada, tipo_de_filtro);
mensagem = filter(coef_num, coef_den, Sin_pb);

% Remover o desnível médio e aumentarmos o som
mensagem = 10 * (mensagem - mean(mensagem));

subplot(2, 2, 3);
plot(vetor_temporal, mensagem);
title("Sinal Mensagem");
xlabel("Instante(t)");
ylabel("Amplitude");
grid;

subplot(2, 2, 4)
[eixo_de_frequencia_da_mensagem, espectro_da_mensagem] = obter_espectro(Fs, mensagem);
semilogy(eixo_de_frequencia_da_mensagem, espectro_da_mensagem);
title("Mensagem no Espectro no Domínio da Frequência");
xlabel("Frequência");
ylabel("Amplitude");
grid;

sound(mensagem, Fs);

save "23054.mat" 'mensagem'
