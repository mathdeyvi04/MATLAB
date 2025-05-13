% Interpretação dos Arquivos
%   Cada arquivo é composto por 2 variáveis, as quais armazenam 2 arrays
%   cada. 
%
%   Na primeira variável, há dois arrays iguais que representam os instantes
%   de amostragem dos sinais.
%   Na segunda variável, os dois arrays representam respectivas a saída real do
%   sistema e a saída do modelo previsto localmente.
%   Conforme é descrito no classroom, só nos é interessante a saída real.

% Algoritmo a ser seguido
%   Conforme é descrito no classroom, obter a curva de resp_a_frequencia
%   a partir da análise simples da amplitude e da fase. Observe que a
%   amplitude e fase da entrada estão setadas de forma convenientes. Logo,
%   só nos interessa a saída.
%
%   Posteriormente, aplicamos FFT nas curvas de pulso quadrado e de pulso
%   triangular. Finalmente, comparar as curvas obtidas.

clear
caminho_da_pasta = "Gp3";
arquivos_da_pasta = dir(caminho_da_pasta);

% Vamos criar o local em que armazenaremos o gráfico da resposta em
% frequência obtida pelo método de análise dos senos. Observe que há 3
% colunas, frequência, amplitude e fase, e 17 linhas relativas aos pontos.
matriz_de_resp_em_freq_por_senos = zeros(17, 3);
idx = 1;

% Definamos o modelo senoidal: y = A * sin(2*pi*f*x + phi) que será
% utilizado no ajuste.
melhor_senoide = @(params, x) params(1) * sin(2 * pi * params(2) * x + params(3));

for i = 1:length(arquivos_da_pasta)
    
    nome_base = arquivos_da_pasta(i).name;
    caminho_completo = fullfile(caminho_da_pasta, nome_base);
    
    % Os arquivos estão na ordem que estão na pasta.
    % Logo, sabemos que serão usados primeiro os senos, dps pulsos
    % quadrados e finalmente triangulares.
    if startsWith(nome_base, "sen")
        
        % Acessamos um struct que representará as variáveis presentes
        espaco = load(caminho_completo);
        espaco_de_variaveis = fieldnames(espaco);
          
        frequencia_da_entrada = str2double(replace(erase(erase(nome_base, ".mat"), "sen_"), "_", "."));
        % Finalmente elas
        instantes_de_amostragem = double(espaco.(espaco_de_variaveis{1})(:, 1));
        saida_real              = double(espaco.(espaco_de_variaveis{2})(:, 1));

        % Vamos utilizar um modelo de ajuste de curva não linear para obter
        % informações de amplitude e fase.

        % Como desejamos resolver um sistema não linear, não
        % necessariamente apenas uma solução. Por conta disso, chutar um
        % valor distante da solução real nos trará problemas severos.
        amplitude_aproximada = (max(saida_real) - min(saida_real)) / 2;
        valores_de_chute = [ amplitude_aproximada, frequencia_da_entrada, 0 ];

        % Características do modelo
        config_do_ajuste = optimset(...
            'Display', 'off', ...         % Não mostrar progresso a cada iteração
            'TolFun', 1e-5, ...           % Para se a diferença de erro for pequena
            'TolX', 1e-5, ...             % Para se mudança nos parâmetros for pequena
            'MaxIter', 10 ...             % Limita número de iterações
        );
        
        % Em alguns casos, pela natureza não linear, o método de ajuste não
        % obtia os valores reais.
        while true

            [best_params, ~] = lsqcurvefit(melhor_senoide, valores_de_chute, instantes_de_amostragem, saida_real, [], [], config_do_ajuste);

            amplitude  = best_params(1);
            frequencia = best_params(2);
            fase       = best_params(3);
            
            % Os casos em que não obtemos o correto possuem amplitude muito
            % menor, logo devemos consertar isso.
            if amplitude < amplitude_aproximada * 0.95 
                
                % Alterando os valores de chute, conseguimos cortornar o
                % problema, apesar de deixar menos eficiente.
                valores_de_chute(3) = valores_de_chute(3) + 0.3;
            else

                break
            end
        end

        % De posse desses dados obtidos:
        matriz_de_resp_em_freq_por_senos(idx, 1) = frequencia_da_entrada;
        matriz_de_resp_em_freq_por_senos(idx, 2) = amplitude;
        matriz_de_resp_em_freq_por_senos(idx, 3) = fase * 180 / pi;

        % ajuste = amplitude * sin(2 * pi * frequencia_da_entrada * instantes_de_amostragem + fase);
        % figure();
        % hold on 
        % plot(instantes_de_amostragem, ajuste);
        % plot(instantes_de_amostragem, saida_real);
        % title(fase * 180 / pi);
        % grid;
        % hold off

        idx = idx + 1;
    end



    
    
end

hold on
% De posse das tabelas finais, podemos vir a construir os gráficos
% desejados.
% GRÁFICO DE RESP FREQUENCIA POR SENOIDES
subplot(2, 3, 1);
scatter(matriz_de_resp_em_freq_por_senos(:, 1), matriz_de_resp_em_freq_por_senos(:, 2), "LineWidth", 3);
title("Resposta Em Frequência: Amplitude");
xlabel("Frequência (Hz)");
ylabel("Amplitude");
grid;

subplot(2, 3, 4);
scatter(matriz_de_resp_em_freq_por_senos(:, 1), matriz_de_resp_em_freq_por_senos(:, 3), "LineWidth", 3);
title("Resposta Em Frequência: Defasagem");
xlabel("Frequência (Hz)");
ylabel("Fase");
grid;

hold off
