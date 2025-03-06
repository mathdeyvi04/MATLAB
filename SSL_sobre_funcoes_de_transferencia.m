% De fato, os valores de polos influenciam na limitação da resposta
% Entretanto, valores de zeros são significativos para como a resposta se
% comporta.


numerador = [1];

denominador = [1, -6, 100];

function [str_pol] = criar_string_pol(vetor)
    % Cria uma string capaz de representar o polinômio.
    str_pol = "";

    i = length(vetor) - 1;
    for coef = vetor
        if i == 0
            str_pol = str_pol + sprintf("%d", coef);
            continue;
        end

        str_pol = str_pol + sprintf("%d s^%d + ", coef, i);
        
        i = i - 1;
    end

end

% Apresentando Função de Transferência
function [sys] = apresentar_funcao_de_transferencia(ver_ou_nao_ver, numerador, denominador)
    % Função responsável por criar e apresentar, caso desejado, a função de
    % transferência.

    if ver_ou_nao_ver

        sys = tf(numerador, denominador);

    else 
        sys = tf(numerador, denominador);
    
    end

end

sys = apresentar_funcao_de_transferencia(1, numerador, denominador);

% Apresentando Polos e Zeros
function [polos, zeros] = apresentar_polos_zeros(numerador, denominador)
    
    polos = roots(denominador);

    if isempty(polos)
        disp("-- Não há s finito tal que G(s) -> inf.");
    else
        disp("-- Os polos estão em: ");
        disp(polos');
    end

    zeros = roots(numerador);

    if isempty(zeros)
        disp("-- Não há s finito tal que G(s) -> 0.");
    else
        disp("-- Os zeros estão em:");
        disp(zeros');
    end

end

[polos, zeros] = apresentar_polos_zeros(numerador, denominador);

% Apresentando Zeros e Polos
function apresentar_pontos_especiais(polos, zeros)
    figure();
    subplot(1, 2, 1);
    hold on
    % Apresentação dos Polos
    for polo = polos
                    
        scatter(polo - imag(polo) * 1i, imag(polo), "x", LineWidth=2);

    end

    for zero = zeros
                    
        scatter(zero - imag(zeros) * 1i, imag(zero), "o", LineWidth=2);

    end

    yline(0, "--", LineWidth=1);
    xline(0, "--", LineWidth=1);
    legend("Polos", "Zeros");
    xlabel("Eixo Real (\sigma)");
    ylabel("Eixo Imaginário (w)");
    title("Análise da Estabilidade")
    grid;
    hold off
    

end

apresentar_pontos_especiais(polos, zeros);

subplot(1, 2, 2);
tempo = 0:0.1:20;
resposta = step(sys, tempo);
plot(tempo, resposta, LineWidth=2);
yline(0, "--", LineWidth=2);
xline(0, "--", LineWidth=2);
xlabel("Tempo(s)");
ylabel("Resposta");
title("Resposta ao Degrau");
grid;