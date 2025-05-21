clc
clear
% Caso você deseje executar este código:
%   Devido ao conjunto de dados ser vasto, mais de 5 arquivos, além da
%   necessidade de escabilidade, pois posteriores grupos podem adicionar
%   mais arquivos para frequências maiores, criou-se uma lógica de iteração
%   que automatiza as leituras. 
%   
%   Entretanto, isso impede que arquivos que não estejam no padrão sejam
%   lidos. A seguir, o padrão:
%   
%   Dados relativos à senoides: sen_x_y.mat. Onde x.y representa a
%   frequência.
%   
%   Dados relativos à pulsos quadrados: sqr_x_y.mat. 
%   
%   Dados relativos à pulsos triangulares: tr_x_y.mat.       

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
% utilizado no ajuste das senoides.
melhor_senoide = @(params, x) params(1) * sin(2 * pi * params(2) * x + params(3));

function [vetor_de_frequencias, espectro] = aplicar_dft(vetor_de_entrada, numero_de_elementos_da_entrada, frequencia_de_amostragem)
    % A função embutida para FFT necessita de todo um tratamento específico
    % Devido à isso, achou-se melhor construir um algoritmo para obter a real
    % transformada de fourier discreta.

    espectro = fftshift(fft(vetor_de_entrada));
    
    vetor_de_frequencias = ((0 : numero_de_elementos_da_entrada - 1) - floor(numero_de_elementos_da_entrada / 2)) * frequencia_de_amostragem / numero_de_elementos_da_entrada;
    
    [~, idx_min] = min(abs(vetor_de_frequencias - 0));

    espectro = espectro(idx_min : end);
    vetor_de_frequencias = vetor_de_frequencias(idx_min : end);
end

% Para armazenarmos os dados obtidos a partir da análise dos quadrados.
% Frequência - Razão de Amplitude
resp_amplitude_por_freq = [];  
resp_fase_por_freq = [];
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

        max_de_iteracoes = 15;
        iteracoes = 0;
        while iteracoes < max_de_iteracoes

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

            iteracoes = iteracoes + 1;
        end

        % De posse desses dados obtidos:
        matriz_de_resp_em_freq_por_senos(idx, 1) = frequencia_da_entrada * 2 * pi; % Devemos ter rad/s
        matriz_de_resp_em_freq_por_senos(idx, 2) = amplitude;
        matriz_de_resp_em_freq_por_senos(idx, 3) = fase * 180 / pi;

        % CASO DESEJE-SE VISUALIZAR OS RESPECTIVOS GRÁFICOS
        % ajuste = amplitude * sin(2 * pi * frequencia_da_entrada * instantes_de_amostragem + fase);
        % figure();
        % hold on
        % plot(instantes_de_amostragem, ajuste);
        % plot(instantes_de_amostragem, saida_real);
        % title("Frequencia de Entrada" + frequencia_da_entrada)
        % legend("Ajuste Saída", "Saída Real");
        % grid;
        % hold off

        idx = idx + 1;
    end

    
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

        % Teorizando entrada
        pulso_quadrado_de_entrada = sign(sin(2 * pi * frequencia_da_entrada * instantes_de_amostragem));

        % Calculando transformada da entrada
        [~, espec_entrada] = aplicar_dft(pulso_quadrado_de_entrada, length(pulso_quadrado_de_entrada), 100);

        % Calculando transformada da saída
        [vet_freq, espec_saida] = aplicar_dft(saida_real, length(saida_real), 100);

        % Devemos criar um algoritmo para obtenção dos dados a serem
        % plotados.
        %
        % Para amplitude:
        %   
        %   Devido ao ruído, não há a possibilidade de apenas dividirmos as
        %   transformadas da saída pela entrada. Sendo assim, faremos
        %   apenas a análise dos picos. Graças ao matlab, já existe uma função 
        %   que encontra picos de maneira satisfatória.
        %   
        %   Entretanto, há outro problema. Na maioria dos arquivos, um pico
        %   na frequência de entrada f também gerará um pico, atenuado ou
        %   não, na frequência de saída f, mas não necessariamente sempre
        %   ocorrerá isso, há valores de dispersão, acredito que devido ao
        %   erro. Sendo assim, faremos verificações e correções.
        % 
        % % ANALISANDO AMPLITUDES
        % 
        % Este indice refere-se aos vetores de espectros e de frequência.
        [picos_na_entrada, indices_dos_picos_na_entrada] = findpeaks(abs(espec_entrada), 'MinPeakProminence', 15, "MinPeakHeight", 50);
        [picos_na_saida, indices_dos_picos_na_saida]     = findpeaks(abs(espec_saida),   'MinPeakProminence', 15, "MinPeakHeight", 50);  

        fases_da_entrada = angle(espec_entrada);
        fases_da_saida   = angle(espec_saida);

        % Desnecessario, dado que trabalhar com os indices é a mesma coisa.
        % % As respectivas frequencias 
        % frequencias_correspondentes_aos_picos_na_entrada = vet_freq(indices_dos_picos_na_entrada);
        % frequencias_correspondentes_aos_picos_na_saida   = vet_freq(indices_dos_picos_na_saida);

        % Em geral, serão iguais, mas não necessariamente. Principalmente
        % pq o ruído pode vir a ser interpretado como pico. 
        % Vamos iterar sobre os picos da entrada e buscar seus
        % correspondentes na saída. 
        % 
        % Supondo que sejam diferentes, vamos ficar com os valores de
        % frequência da entrada, que está "pura".
        conj_a_ser_adicionado_das_amplitudes = [];
        conj_a_ser_adicionado_das_fases      = [];
        for index_de_indice_de_pico_na_entrada = 1:length(indices_dos_picos_na_entrada)

            % Há a possibilidade de haver menos picos na saída do que na entrada.
            % Isso significa que os picos foram muito atenuados pelo sistema. Podemos 
            % aproximá-los para 0.

            % Verificamos se o indice já existe na lista de indices da saída
            index_de_indice_de_pico_na_saida = find(indices_dos_picos_na_saida == indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada), 1);

            if ~isempty(index_de_indice_de_pico_na_saida)
                % Então o indice existe na lista de indices de picos na saída.
                % Podemos trivialmente então:

               conj_a_ser_adicionado_das_amplitudes = [conj_a_ser_adicionado_das_amplitudes ; [vet_freq(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada)), picos_na_saida(index_de_indice_de_pico_na_saida) / picos_na_entrada(index_de_indice_de_pico_na_entrada)]];
               conj_a_ser_adicionado_das_fases = [conj_a_ser_adicionado_das_fases; [vet_freq(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada)), fases_da_saida(indices_dos_picos_na_saida(index_de_indice_de_pico_na_saida)) - fases_da_entrada(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada))]];
            else
                % Aqui nasce o problema. As frequências não são iguais.
                % Devemos buscar então qual indice na saída é mais próximo do index da entrada.
                % Como temos a garantia de que não há elementos repetidos, é possível:

                [dif_min, index_de_indice_de_pico_na_saida] = min(abs(indices_dos_picos_na_saida - indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada)));

                % Ainda sim, pode ser passível de erro, logo devemos evitar que a diferença de indices seja grande demais.
                if dif_min > 18 

                    if index_de_indice_de_pico_na_entrada > length(indices_dos_picos_na_saida)
                        % Então o elemento que estamos buscando além de ser muito distoante dos elementos presentes
                        % Também já está fora do escopo de quantidade. Isso quer dizer que seu sinal foi muito atenuado

                        conj_a_ser_adicionado_das_amplitudes = [conj_a_ser_adicionado_das_amplitudes ; [ vet_freq(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada)), 0 ]];

                        % Vamos assumir que as fases também são levadas à zero.
                        conj_a_ser_adicionado_das_fases = [conj_a_ser_adicionado_das_fases; [vet_freq(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada)), 0 ]];
                    end

                    continue;
                end

                % Adicionamos o pico de frequência mais próximo.
                conj_a_ser_adicionado_das_amplitudes = [conj_a_ser_adicionado_das_amplitudes ; [vet_freq(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada)), picos_na_saida(index_de_indice_de_pico_na_saida) / picos_na_entrada(index_de_indice_de_pico_na_entrada)]];
                conj_a_ser_adicionado_das_fases = [conj_a_ser_adicionado_das_fases; [vet_freq(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada)), fases_da_saida(indices_dos_picos_na_saida(index_de_indice_de_pico_na_saida)) - fases_da_entrada(indices_dos_picos_na_entrada(index_de_indice_de_pico_na_entrada))]];

            end

        end

        resp_amplitude_por_freq = [resp_amplitude_por_freq; conj_a_ser_adicionado_das_amplitudes];
        resp_fase_por_freq = [resp_fase_por_freq; conj_a_ser_adicionado_das_fases];

        % CASO DESEJE VER AS RESPECTIVAS TRANSFORMADAS
        % figure(); 
        % subplot(2, 3, 1);
        % plot(instantes_de_amostragem, pulso_quadrado_de_entrada);
        % xlabel("Tempo")
        % ylabel("Amplitude")
        % title("Entrada de Frequência: " + frequencia_da_entrada);
        % grid;
        % 
        % subplot(2, 3, 4);
        % plot(vet_freq, abs(espec_entrada));
        % xlabel("Frequencia")
        % ylabel("Amplitude")
        % title("DFT da Entrada");
        % grid;
        % 
        % subplot(2, 3, 2);
        % plot(instantes_de_amostragem, saida_real);
        % xlabel("Tempo")
        % ylabel("Amplitude")
        % title("Saída");
        % grid;
        % 
        % subplot(2, 3, 5);
        % plot(vet_freq, abs(espec_saida));
        % xlabel("Frequencia")
        % ylabel("Amplitude")
        % title("DFT da Saida");
        % grid;
        % 
        % subplot(2, 3, 3);
        % scatter(conj_a_ser_adicionado_das_fases(:, 1), conj_a_ser_adicionado_das_fases(:, 2), "LineWidth", 3);
        % xlabel("Frequência");
        % ylabel("Fase(°)")
        % title("Resposta da Fase à Frequência A Partir Desta Entrada");
        % grid;
        % 
        % subplot(2, 3, 6);
        % scatter(conj_a_ser_adicionado_das_amplitudes(:, 1), conj_a_ser_adicionado_das_amplitudes(:, 2), "LineWidth", 3);
        % xlabel("Frequencia")
        % ylabel("Razão das Amplitudes")
        % title("Resposta da Amplitude à Frequência A Partir Desta Entrada")
        % grid;
    end
end


% A SEGUIR, APRESENTAÇÃO DOS GRÁFICOS A PARTIR DAS SENOIDES
hold on
subplot(2, 2, 1);
scatter(matriz_de_resp_em_freq_por_senos(:, 1), matriz_de_resp_em_freq_por_senos(:, 2), "LineWidth", 3);
title("Resposta da Amplitude Em Frequência");
xlabel("Frequência Angular (rad / s)");
ylabel("Amplitude(db)");
grid;

subplot(2, 2, 3);
scatter(matriz_de_resp_em_freq_por_senos(:, 1), matriz_de_resp_em_freq_por_senos(:, 3), "LineWidth", 3);
title("Resposta da Defasagem Em Frequência");
xlabel("Frequência Angular (rad / s)");
ylabel("Fase(°)");
grid;

% A SEGUIR, APRESENTAÇÃO DOS GRÁFICOS A PARTIR DAS QUADRADAS.
subplot(2, 2, 2);
scatter(resp_amplitude_por_freq(:, 1) * 2 * pi, 20 * log(resp_amplitude_por_freq(:, 2)), "LineWidth", 3);
title("Resposta da Amplitude Em Frequência");
xlabel("Frequência Angular (rad / s)");
ylabel("Amplitude(db)");
grid;

subplot(2, 2, 4);
scatter(resp_fase_por_freq(:, 1) * 2 * pi, resp_fase_por_freq(:, 2) * 180 / pi, "LineWidth", 3);
title("Resposta da Fase Em Frequência");
xlabel("Frequência Angular (rad / s)");
ylabel("Fase(°)");
grid;
