% Código responsável por analisar filtros e suas propriedades.
clc
clear

function [eixo_x_do_sinal, eixo_y_do_sinal, eixo_y_do_sinal_puro] = funcao_sinal()
    % Função responsável por providenciar o sinal de entrada.

    AMPLITUDE_DO_RUIDO = 0.1;
    eixo_x_do_sinal = linspace(0, 2 * pi, 100);  
    eixo_y_do_sinal_puro = sin(eixo_x_do_sinal);
    eixo_y_do_sinal = eixo_y_do_sinal_puro + AMPLITUDE_DO_RUIDO * randn(size(eixo_y_do_sinal_puro));
end

[valores_temporais, sinal_com_ruido, sinal_puro] = funcao_sinal();

function [sinal_de_saida] = aplicando_filtro(sinal_de_entrada, tamanho_da_janela, funcao_de_tendencia)
    % Função responsável por aplicar o filtro médias móvel, permitindo que
    % o usuário sete o tamanho da janela e a função de tendência central.
    % tamanho_da_janela: Deve ser um inteiro ímpar.
    
        
    tamanho_do_vetor = length(sinal_de_entrada);

    sinal_de_saida = zeros(1, tamanho_do_vetor);

    avanco_ou_recuo_da_janela = round((tamanho_da_janela - 1) / 2);
    
    for index = 1 : tamanho_do_vetor

        inicio_da_janela = index - avanco_ou_recuo_da_janela;
        final_da_janela = index + avanco_ou_recuo_da_janela;
        
        if inicio_da_janela < 1
            inicio_da_janela = 1;
        end 
        if final_da_janela > tamanho_do_vetor
            % Caso seja maior, forçará a diminuição do tamanho da janela.
            final_da_janela = tamanho_do_vetor;
        end
        
        sinal_de_saida(index) = funcao_de_tendencia(sinal_de_entrada(inicio_da_janela : final_da_janela));
    end
    
end

funcoes_de_tendencia_central = {@(vetor) mean(vetor), @(vetor) median(vetor), @(vetor) mode(vetor)};

function [] = apresentacao(valores_temporais, sinal_com_ruido, sinal_puro, funcoes_de_tendencia_central)
    % Função unicamente responsável por plotar as informações.
    
    % Plotando as comparações
    for index = 1:3
        figure();
        i = 1;
        for tamanho_de_janela_teste = 3:2:9
        
            sinal_de_saida = aplicando_filtro(sinal_com_ruido, tamanho_de_janela_teste, funcoes_de_tendencia_central{index});
    
            subplot(2, 2, i);
            
            % Apresentar resultados
            hold on
            grossura_linha = 3;
            plot(valores_temporais, sinal_puro, LineWidth=grossura_linha);
            plot(valores_temporais, sinal_com_ruido, LineWidth=grossura_linha);
            plot(valores_temporais, sinal_de_saida,"k", LineWidth=grossura_linha);
            legend("Puro", "ComRuido", "Filtro");
            ylabel("Intensidade do Sinal");
            xlabel("Instante");
            title("Tamanho de Janela: " + tamanho_de_janela_teste);
            hold off

            i = i + 1;
        end
    end
end

apresentacao(valores_temporais, sinal_com_ruido, sinal_puro, funcoes_de_tendencia_central);

function [] = calcular_error(delta_t, sinal_puro,sinal_com_ruido, funcao_de_tendencia_central)
    % Calcurá o erro.

    function [vetor_dif] = dif(vetor)
        vetor_dif = zeros(1, length(vetor));

        for i = 1:length(vetor)
            if i == length(vetor)
                vetor_dif(i) = vetor(i);
            else
                vetor_dif(i) = vetor(i + 1) - vetor(i);
            end
        end
    end
    
    valores_de_tam_de_janela = 3:2:61;

    met_1 = zeros(1, length(valores_de_tam_de_janela));
    met_2 = zeros(1, length(valores_de_tam_de_janela));
    
    index = 1;
    for tamanho_da_janela = valores_de_tam_de_janela
        
        sinal_de_saida = aplicando_filtro(sinal_com_ruido, tamanho_da_janela, funcao_de_tendencia_central);

        met_1(index) = sum(abs(sinal_puro - sinal_de_saida) * delta_t);
        met_2(index) = sum(abs(dif(sinal_puro) - dif(sinal_de_saida)));

        index = index + 1;
    end
    
    figure();
    hold on
    plot(valores_de_tam_de_janela, met_1, LineWidth=3);
    plot(valores_de_tam_de_janela, met_2, LineWidth=3);
    xlabel("Tamanho da Janela");
    ylabel("Valor")
    title("Influência da Janela no Erro");
    legend("Métrica 1", "Métrica 2");
    hold off
end

% Calculamos o erro unicamente da média.
calcular_error(valores_temporais(2) - valores_temporais(1), sinal_puro, sinal_com_ruido, funcoes_de_tendencia_central{1});
