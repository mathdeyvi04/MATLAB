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

function [vetor_de_frequencias, espectro] = aplicar_dft(vetor_de_entrada, numero_de_elementos_da_entrada, frequencia_de_amostragem)
    % A função embutida para FFT necessita de todo um tratamento específico
    % Devido à isso, fez-se melhor construir um algoritmo para obter a real
    % transformada de fourier discreta.
    
    espectro = zeros(1, numero_de_elementos_da_entrada);  % Alocação primária

    for k = 0:numero_de_elementos_da_entrada-1
        for n = 0:numero_de_elementos_da_entrada-1
            % Observe que há o j dentro da exponencial. Logo, deve ser
            % complexo mesmo!
            espectro(k+1) = espectro(k+1) + vetor_de_entrada(n+1) * exp(-1j * 2 * pi * k * n / numero_de_elementos_da_entrada);
        end
    end
    
    % Note que pegamos apenas metade dos elementos
    % Observe também que é complexo.
    espectro = 2 * espectro( 1: floor(numero_de_elementos_da_entrada / 2) ) / numero_de_elementos_da_entrada;

    vetor_de_frequencias = (0 : numero_de_elementos_da_entrada - 1) * frequencia_de_amostragem / numero_de_elementos_da_entrada;
    vetor_de_frequencias = vetor_de_frequencias( 1 : floor(numero_de_elementos_da_entrada / 2) );
end


resp_amplitude_por_freq = [0, 0];  % Para armazenarmos os dados obtidos a partir da análise dos quadrados.
for i = 1:length(arquivos_da_pasta)
    
    nome_base = arquivos_da_pasta(i).name;
    caminho_completo = fullfile(caminho_da_pasta, nome_base);
    
    % Os arquivos estão na ordem que estão na pasta.
    % Logo, sabemos que serão usados primeiro os senos, dps pulsos
    % quadrados e finalmente triangulares.
    % if startsWith(nome_base, "sen")
    % 
    %     % Acessamos um struct que representará as variáveis presentes
    %     espaco = load(caminho_completo);
    %     espaco_de_variaveis = fieldnames(espaco);
    % 
    %     frequencia_da_entrada = str2double(replace(erase(erase(nome_base, ".mat"), "sen_"), "_", "."));
    %     % Finalmente elas
    %     instantes_de_amostragem = double(espaco.(espaco_de_variaveis{1})(:, 1));
    %     saida_real              = double(espaco.(espaco_de_variaveis{2})(:, 1));
    % 
    %     % Vamos utilizar um modelo de ajuste de curva não linear para obter
    %     % informações de amplitude e fase.
    % 
    %     % Como desejamos resolver um sistema não linear, não
    %     % necessariamente apenas uma solução. Por conta disso, chutar um
    %     % valor distante da solução real nos trará problemas severos.
    %     amplitude_aproximada = (max(saida_real) - min(saida_real)) / 2;
    %     valores_de_chute = [ amplitude_aproximada, frequencia_da_entrada, 0 ];
    % 
    %     % Características do modelo
    %     config_do_ajuste = optimset(...
    %         'Display', 'off', ...         % Não mostrar progresso a cada iteração
    %         'TolFun', 1e-5, ...           % Para se a diferença de erro for pequena
    %         'TolX', 1e-5, ...             % Para se mudança nos parâmetros for pequena
    %         'MaxIter', 10 ...             % Limita número de iterações
    %     );
    % 
    %     % Em alguns casos, pela natureza não linear, o método de ajuste não
    %     % obtia os valores reais.
    %     while true
    % 
    %         [best_params, ~] = lsqcurvefit(melhor_senoide, valores_de_chute, instantes_de_amostragem, saida_real, [], [], config_do_ajuste);
    % 
    %         amplitude  = best_params(1);
    %         frequencia = best_params(2);
    %         fase       = best_params(3);
    % 
    %         % Os casos em que não obtemos o correto possuem amplitude muito
    %         % menor, logo devemos consertar isso.
    %         if amplitude < amplitude_aproximada * 0.95 
    % 
    %             % Alterando os valores de chute, conseguimos cortornar o
    %             % problema, apesar de deixar menos eficiente.
    %             valores_de_chute(3) = valores_de_chute(3) + 0.3;
    %         else
    % 
    %             break
    %         end
    %     end
    % 
    %     % De posse desses dados obtidos:
    %     matriz_de_resp_em_freq_por_senos(idx, 1) = frequencia_da_entrada;
    %     matriz_de_resp_em_freq_por_senos(idx, 2) = amplitude;
    %     matriz_de_resp_em_freq_por_senos(idx, 3) = fase * 180 / pi;
    % 
    %     % ajuste = amplitude * sin(2 * pi * frequencia_da_entrada * instantes_de_amostragem + fase);
    %     % figure();
    %     % hold on 
    %     % plot(instantes_de_amostragem, ajuste);
    %     % plot(instantes_de_amostragem, saida_real);
    %     % title(fase * 180 / pi);
    %     % grid;
    %     % hold off
    % 
    %     idx = idx + 1;
    % end

    
    if startsWith(nome_base, "sqr")
        % Vamos utilizar os pulsos quadrados, os quais alternam entre 2
        % patamares em uma determinada frequência. Vamos considerar que a
        % entrada está com patarmares de 1 e -1.

        % Vamos aplicar apenas FFT
        % Acessamos um struct que representará as variáveis presentes
        espaco = load(caminho_completo);
        espaco_de_variaveis = fieldnames(espaco);

        frequencia_da_entrada = str2double(replace(erase(erase(nome_base, ".mat"), "sqr_"), "_", "."));
        instantes_de_amostragem = double(espaco.(espaco_de_variaveis{1})(:, 1));
        saida_real              = double(espaco.(espaco_de_variaveis{2})(:, 1));
        
        % Calculando transformada da saída
        [vet_freq, espec_saida] = aplicar_dft(saida_real, length(saida_real), 100);
        
        % Teorizando entrada
        pulso_quadrado_de_entrada = sign(sin(2 * pi * frequencia_da_entrada * instantes_de_amostragem));
        
        % Calculando transformada da entrada
        [~, espec_entrada] = aplicar_dft(pulso_quadrado_de_entrada, length(pulso_quadrado_de_entrada), 100);
        
        % Calculando a resposta
        % resp_em_frequencia = espec_saida ./ espec_entrada;

        % Vamos obter os pontos de máximo em frequência da entrada e
        % analisá-los na saída. Obtendo uma razão.
        [max_locais_na_entrada, indices_dos_max] = findpeaks(abs(espec_entrada), 'MinPeakProminence', 0.05);
        vetor_de_frequencias_de_pico = vet_freq(indices_dos_max);
        
        max_locais_na_saida = abs(espec_saida(indices_dos_max));
        
        % Enfim, temos a coleção de pontos desejados.
        razao = max_locais_na_saida ./ max_locais_na_entrada;

        conj_a_ser_adicionado = [vetor_de_frequencias_de_pico(:) , razao(:)];

        resp_amplitude_por_freq = [resp_amplitude_por_freq; conj_a_ser_adicionado];
        
        figure(); 
        subplot(2, 3, 1);
        plot(instantes_de_amostragem, pulso_quadrado_de_entrada);
        title("Entrada de Frequência: " + frequencia_da_entrada);
        grid;

        subplot(2, 3, 4);
        plot(vet_freq, abs(espec_entrada));
        title("DFT da Entrada");
        grid;

        subplot(2, 3, 2);
        plot(instantes_de_amostragem, saida_real);
        title("Saída");
        grid;

        subplot(2, 3, 5);
        plot(vet_freq, abs(espec_saida));
        title("DFT da Saida");
        grid;

        subplot(2, 3, 6);
        scatter(conj_a_ser_adicionado(:, 1), conj_a_ser_adicionado(:, 2));
        title("Resposta da Amplitude por Frequência");
        grid;
    end

    

    
    
end


% A SEGUIR, APRESENTAÇÃO DOS GRÁFICOS A PARTIR DAS SENOIDES
% hold on
% subplot(2, 3, 1);
% scatter(matriz_de_resp_em_freq_por_senos(:, 1), matriz_de_resp_em_freq_por_senos(:, 2), "LineWidth", 3);
% title("Resposta Em Frequência: Amplitude");
% xlabel("Frequência (Hz)");
% ylabel("Amplitude");
% grid;
% 
% subplot(2, 3, 4);
% scatter(matriz_de_resp_em_freq_por_senos(:, 1), matriz_de_resp_em_freq_por_senos(:, 3), "LineWidth", 3);
% title("Resposta Em Frequência: Defasagem");
% xlabel("Frequência (Hz)");
% ylabel("Fase");
% grid;
% 
% hold off

% A SEGUIR, APRESENTAÇÃO DOS GRÁFICOS A PARTIR DAS QUADRADAS.
% scatter(resp_amplitude_por_freq(:, 1), resp_amplitude_por_freq(:, 2));
% grid;
