
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotar(numerador, denominador, indicador_do_desejado)
    % Função que generalizará a plotagem dos gráficos, retirando a
    % necessidade de uma quantidade X de imagens de uma vez.
    % 0 -> Impulso
    % 1 -> Degrau

    sys = tf(numerador, denominador);
    
    % Obtendo Polos e Zeros
    function [polos, zeros] = apresentar_polos_zeros(numerador, denominador)
        % Calculará as raízes dos polinômios numerador e denominador, a
        % partir das quais teremos, respectivamente, zeros e polos.
        
        
        polos = roots(denominador);
    
        % if isempty(polos)
        %     disp("-- Não há s finito tal que G(s) -> inf.");
        % else
        %     disp("-- Os polos estão em: ");
        %     disp(polos');
        % end
    
        zeros = roots(numerador);
    
        % if isempty(zeros)
        %     disp("-- Não há s finito tal que G(s) -> 0.");
        % else
        %     disp("-- Os zeros estão em:");
        %     disp(zeros');
        % end
    
    end
    
    [polos, zeros] = apresentar_polos_zeros(numerador, denominador);
    
    % Apresentando Zeros e Polos
    function apresentar_pontos_especiais(polos, zeros)
        % Apresentaremos os polos e zeros.
    
        % Note que aqui criamos nossa figura.
        figure();

        subplot(1, 2, 1);
        hold on

        scatter(polos - imag(polos) * 1i, imag(polos), "x", LineWidth=2);
    
        scatter(zeros - imag(zeros) * 1i, imag(zeros), "o", LineWidth=2);
    
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
    
    % Plotamos a resposta ao degrau.
    subplot(1, 2, 2);
    tempo = 0:0.1:20;

    if indicador_do_desejado
        resposta = step(sys, tempo);
    else
        resposta = impulse(sys, tempo);
    end

    plot(tempo, resposta, LineWidth=2);
    yline(0, "--", LineWidth=2);
    xline(0, "--", LineWidth=2);
    xlabel("Tempo(s)");
    ylabel("Resposta");
    
    if indicador_do_desejado
        title("Resposta ao Degrau");
    else
        title("Resposta ao Impulso");
    end

    grid;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LISTA_DE_FIGURAS = {
    % Cada linha representa uma figura.
    % Dentro de cada linha, figura, há 3 colunas.
    % Cada coluna representa numerador, denominador e
    % funcao_de_entrada_desejada, respectivamente.
    %
    % O numerador e denominador definem a função de transferência.
    % E a funcao_de_entrada_deseja representa:
    % 0 - Impulso
    % 1 - Degrau
    %
    % As imagens surgirão primeiro pela última linha colocada, afinal ela
    % foi a última a ser executada.

    1, [1, 2, 1], 1 ;
    1, [1, 16, 64], 1;
    [1, -1], [1, 2, 1], 1;
    [-5, -1], [1, 2, 1], 1;
    1, [1, 2, 20], 1;
    1, [1, 2, 100], 1;
    [1, -1], [1, 2, 20], 1;
    1, [1, 0, 2], 1;
    1, [1, 0, 0], 1;
    [1, 1], [1, 0, 2], 1;
    1, [1, 0, -1], 1;
    1, [1, -6, 100], 1;
    
};

for index_de_figura = 1:1:length(LISTA_DE_FIGURAS)

    plotar(LISTA_DE_FIGURAS{index_de_figura, 1}, LISTA_DE_FIGURAS{index_de_figura, 2}, LISTA_DE_FIGURAS{index_de_figura, 3});
 
end


clc 
clear LISTA_DE_FIGURAS;