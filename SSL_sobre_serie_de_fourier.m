%   Criado por:
%   
%   Al Deyvisson - 05/03/2025
%
limpa
%%%%%%%%%%%%%%%%%%%%%%% Parâmetros Manipuláveis %%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = main_(input)
    % Crie uma função que estará centrada no meio.
    % A parte mínima se estenderá de - periodo / 2 até periodo / 2.

    output = input * input;
end

% Período Desejado para nossa função
PERIODO_DA_FUNCAO = 2 * pi;

% Quantos termos desejamos 
QUANTIDADE_DESEJADA = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%% Código %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saida = funcao_periodica(funcao, periodo, valor)
    % Devemos criar uma forma de transformar a função dada em periódica do 
    % período especificado.
    
    if valor >= 0
        sinal = 1;
    else
        sinal = -1;
    end

    quoc_inteiro = floor(valor / (sinal * 0.5 * periodo));

    if quoc_inteiro < 1
        fator = 0;
    else 
        if mod(quoc_inteiro, 2) == 0
            % É par
            fator = quoc_inteiro / 2;
        else
            % É ímpar
            fator = (quoc_inteiro + 1) / 2;
        end
    end

    valor = valor - sinal * fator * periodo;

    saida = funcao(valor);

end

% Precisamos dessa forma para utilizar vetores 
main_vetorial = @(vetor_de_entrada) arrayfun(@(escalar) funcao_periodica(@(x) main_(x), PERIODO_DA_FUNCAO, escalar), vetor_de_entrada);

% Obter Coeficientes de Fourier
function [coef_indep, coef_cos, coef_sin] = obter_coef_fourier(funcao, periodo, quant_desejada)
    % Retornará os coeficientes padrões. Atente-se ao a_0.
    
    precisao = 5;

    % Obtendo o independente
    coef_indep = 2 * (1 / periodo) * integral(funcao, 0, periodo);
    coef_indep = round(coef_indep, precisao);
    
    coef_cos = zeros(1, quant_desejada);
    coef_sin = zeros(1, quant_desejada);

    for index = 1:1:quant_desejada
        % Obtendo coef dos cossenos.
        coef_cos(index) = 2 * (1 / periodo) * integral(@(vetor) funcao(vetor) .* cos((2 * index * pi / periodo) * vetor), 0, periodo);
        
        % Obtendo coef dos senos.
        coef_sin(index) = 2 * (1 / periodo) * integral(@(vetor) funcao(vetor) .* sin((2 * index * pi / periodo) * vetor), 0, periodo);
    end
    
    coef_cos = round(coef_cos, precisao);
    coef_sin = round(coef_sin, precisao);

    clear precisao;
end

[coef_indep, coef_cos, coef_sin] = obter_coef_fourier(main_vetorial, PERIODO_DA_FUNCAO, QUANTIDADE_DESEJADA);

% Obter função de aproximação da série
function saida = calcular_funcao_aproximada_no_ponto(coef_indep, coef_cos, coef_sin, periodo, valor)
    
    saida = coef_indep / 2;

    for index = 1:1:length(coef_cos)
        saida = saida + coef_cos(index) * cos((2 * index * pi / periodo) * valor);
        saida = saida + coef_sin(index) * sin((2 * index * pi / periodo) * valor);
    end

end

serie_de_fourier_completa = @(vetor, quant) arrayfun(@(escalar) calcular_funcao_aproximada_no_ponto(coef_indep, coef_cos(1:quant), coef_sin(1:quant), PERIODO_DA_FUNCAO, escalar), vetor);

% Obter Coeficientes de Complexo
function [coef_complexos, val_n] = obter_coef_complexos(funcao, periodo)
    % Vamos calcular os elementos complexos.
    
    val_n = -10:1:10;

    coef_complexos = zeros(1, length(val_n));
    
    for index = 1:1:length(val_n)
        coef_complexos(index) = (1 / periodo) * integral(@(vetor) funcao(vetor) .* exp( - 1i * val_n(index) * (2 * pi / periodo) * vetor), - periodo / 2, periodo / 2);
    end

    coef_complexos = round(coef_complexos, 2);

end

[coef_complexos, val_n] = obter_coef_complexos(main_vetorial, PERIODO_DA_FUNCAO);

% Extraindo Módulo e Argumento
function [mod_coef_complexo, arg_coef_complexo] = tratar_coef_complexos(coef_complexos)
    
    mod_coef_complexo = abs(coef_complexos);

    arg_coef_complexo = zeros(1, length(coef_complexos));
    
    for index = 1:1:length(coef_complexos)
        if coef_complexos(index) == imag(coef_complexos(index)) * 1i
            arg_coef_complexo(index) = pi / 2;
        else
            arg_coef_complexo(index) = atan(imag(coef_complexos(index)) ./ (coef_complexos(index) - imag(coef_complexos(index)) * 1i));
        end
    end

end

[mod_coef_complexo, arg_coef_complexo] = tratar_coef_complexos(coef_complexos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apenas Visualizaremos a Aproximação %%%%%%%%%

interv = -10:0.01:10;

resp1 = main_vetorial(interv);

resp2 = serie_de_fourier_completa(interv, QUANTIDADE_DESEJADA);

% Apresentando a Aproximação da Série
subplot(1, 3, 1)
hold on
plot(interv, resp1, "LineWidth", 2);
plot(interv, resp2, "LineWidth", 2);
xlabel("Eixo X");
ylabel("Eixo Y");
title("Série de Fourier");
grid;
legend("Real", "Série Aproximada")
hold off

% Apresentando o Módulo de C_n
subplot(1, 3, 2)
plot(val_n, mod_coef_complexo, "LineWidth", 2)
xlabel("Valor de n")
ylabel("Módulo de C_n")
title("Intensidade de C_n")
grid;

% Apresentando a Phase de C_n
subplot(1, 3, 3)
plot(val_n, arg_coef_complexo, "LineWidth", 2)
xlabel("Valor de n")
ylabel("Argumento de C_n")
title("Fase de C_n")
grid;

% Apagando Variáveis Inúteis, pois o que importa são os coeficientes.
clear resp1 resp2 interv QUANTIDADE_DESEJADA main_vetorial serie_de_fourier_completa  val_n;
