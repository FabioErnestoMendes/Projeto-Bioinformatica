function [RESULTADO, classes] = corpo(opcao, IMAGEM_ORG)
tic
modo_lote = strcmpi(opcao.avanco,'series');
%% ------------------------------------------------------------------------
% Separação canais RGB
%% ------------------------------------------------------------------------
IM_ORG_R = mat2gray(double(IMAGEM_ORG(:,:,1)), [0 255]);
IM_ORG_G = mat2gray(double(IMAGEM_ORG(:,:,2)), [0 255]);
IM_ORG_B = mat2gray(double(IMAGEM_ORG(:,:,3)), [0 255]);
disp(opcao)
%% ------------------------------------------------------------------------
% Seleção do canal fluorescente
%% ------------------------------------------------------------------------
switch lower(opcao.fluor)
    case 'red'
        IM_CHN = IM_ORG_R - 0.7*IM_ORG_G;
    case 'green'
        IM_CHN = IM_ORG_G - 0.7*IM_ORG_R;
    case 'org'
        IM_CHN = 0.667 .* IM_ORG_G + 0.333 .* IM_ORG_R;
    otherwise
        IM_CHN = IM_ORG_R;
end
%% ------------------------------------------------------------------------
% Remover canto inferior direito
%% ------------------------------------------------------------------------
altura = 120;
largura = 120;
[altura_imagem, largura_imagem] = size(IM_CHN);
if largura_imagem >= largura && altura_imagem >= altura
    IM_CHN(altura_imagem-altura+1:end, largura_imagem-largura+1:end) = 0;
end
if ~modo_lote
    imshow(IM_CHN,'InitialMagnification','fit');
end
%% ------------------------------------------------------------------------
% Pré-tratamento Wiener
%% ------------------------------------------------------------------------
switch lower(opcao.pretrat)
    case 'sim'
        IM_PHA_WNR = wiener2(IM_CHN, [2 2]);
    otherwise
        IM_PHA_WNR = IM_CHN;
end
imwrite(mat2gray(IM_PHA_WNR), 'debug_wiener.png');
%% ------------------------------------------------------------------------
% Realce fluorescência
%% ------------------------------------------------------------------------
SE = strel('disk',10);
IM_TOP = imtophat(IM_PHA_WNR, SE);
IM_BOT = imbothat(IM_PHA_WNR, SE);
IM_PHA_TPG = IM_PHA_WNR + 0.8*IM_TOP - 0.3*IM_BOT;
IM_PHA_TPG = mat2gray(IM_PHA_TPG);
IM_PHA_TPG = imadjust(IM_PHA_TPG);
IM_PHA_TPG = adapthisteq( ...
    IM_PHA_TPG, ...
    'ClipLimit',0.02,...
    'Numtiles',[8 8]);
imwrite(mat2gray(IM_PHA_TPG), 'debug_clahe.png');
if ~modo_lote
    figure
    imshow(IM_PHA_TPG,[])
    title('Realce fluorescencia')
end
%% ------------------------------------------------------------------------
% Threshold iterativo automático
%% ------------------------------------------------------------------------
IM_BIN = bin_itr(IM_PHA_TPG);
%% ------------------------------------------------------------------------
% Reconstrução morfológica
%% ------------------------------------------------------------------------
IM_SEED = imerode(IM_BIN, strel('disk',1));
IM_BIN = imreconstruct(IM_SEED, IM_BIN);
%% ------------------------------------------------------------------------
% Operações morfológicas
%% ------------------------------------------------------------------------
%IM_BIN = imfill(IM_BIN, 'holes');
IM_BIN = imopen(IM_BIN, strel('disk',1));
IM_BIN = imfill(IM_BIN, 'holes');
%% ------------------------------------------------------------------------
% Filtrar tamanho partículas
%% ------------------------------------------------------------------------
IM_PHA = bwareafilt(IM_BIN, [40 Inf]);
%% ------------------------------------------------------------------------
% Separação de agregados (Watershed seletivo)
%% ------------------------------------------------------------------------
stats_tmp = regionprops(IM_PHA,'Area');
if ~isempty(stats_tmp)
    areas_tmp = [stats_tmp.Area];
    area_media = mean(areas_tmp);
    CC_tmp = bwconncomp(IM_PHA);
    IM_SEPARADA = false(size(IM_PHA));
    for k = 1:CC_tmp.NumObjects
        objeto = false(size(IM_PHA));
        objeto(CC_tmp.PixelIdxList{k}) = true;
        area_obj = nnz(objeto);
        fprintf('Area objeto = %.2f\n', area_obj);
        fprintf('Area media = %.2f\n\n', area_media);
        if area_obj > 2.0 * area_media
            D = bwdist(~objeto);
            D = imgaussfilt(D,2);
            M = imregionalmax(D);
            M = bwareaopen(M,20);
            M = imdilate(M,strel('disk',1));
            D2 = imimposemin(-D,M);
            L = watershed(D2);
            objeto(L == 0) = 0;
        end
        IM_SEPARADA = IM_SEPARADA | objeto;
    end
    IM_PHA = IM_SEPARADA;
end
%% ------------------------------------------------------------------------
% Filtrar propriedades geométricas
%% ------------------------------------------------------------------------
if ~modo_lote
    figure
    imshow(IM_PHA)
    title('Mascara Final')
    figure
    imshow(label2rgb(bwlabel(IM_PHA)))
    title('Objetos Individuais')
end
CC = bwconncomp(IM_PHA);
stats_geo = regionprops(CC,'Solidity');
IM_TMP = false(size(IM_PHA));
for k=1:CC.NumObjects
    if stats_geo(k).Solidity > 0.35
        IM_TMP(CC.PixelIdxList{k}) = true;
    end
end
IM_PHA = IM_TMP;
%% ------------------------------------------------------------------------
% Atualizar componentes ligados após filtro geométrico
%% ------------------------------------------------------------------------
CC = bwconncomp(IM_PHA);
stats = regionprops( ...
    CC,...
    IM_CHN,...
    'Area',...
    'MaxIntensity',...
    'PixelIdxList');
IM_FILTRADA = false(size(IM_PHA));
%% ------------------------------------------------------------------------
% Thresholds automáticos
%% ------------------------------------------------------------------------
media_int = mean([stats.MaxIntensity]);
if isempty(stats)
    RESULTADO = struct;
    classes = {};
    return
end
thr_int = media_int * 0.50;
areas = [stats.Area];
thr_area = max( ...
    5, ...
    mean(areas) * 0.08);
%% ------------------------------------------------------------------------
% Filtragem partículas
%% ------------------------------------------------------------------------
for k = 1:length(stats)
    area_part = stats(k).Area;
    intensidade = stats(k).MaxIntensity;
    mean_red = mean(IM_ORG_R(stats(k).PixelIdxList));
    mean_green = mean(IM_ORG_G(stats(k).PixelIdxList));
    if strcmpi(opcao.fluor,'red')
        criterio_cor = ...
        (mean_red/(mean_green+eps)) > 1.15;
    elseif strcmpi(opcao.fluor,'green')
        criterio_cor = ...
        (mean_green/(mean_red+eps)) > 1.30;
    else
        criterio_cor = true;
    end
    if area_part > thr_area && ...
        intensidade > thr_int && ...
        criterio_cor
        IM_FILTRADA( ...
            CC.PixelIdxList{k}) = true;
    end
end
IM_PHA = IM_FILTRADA;
%% ------------------------------------------------------------------------
% Refinamento final
%% ------------------------------------------------------------------------
IM_PHA = imfill(IM_PHA, 'holes');
IM_PHA = bwmorph(IM_PHA, 'majority');
%% ------------------------------------------------------------------------
% Métricas fluorescência
%% ------------------------------------------------------------------------
pha_area = bwarea(IM_PHA);
if pha_area > 0
    pha_val = sum(IM_CHN(IM_PHA));
    pha_media = pha_val / pha_area;
else
    pha_val = 0;
    pha_media = 0;
end
%% ------------------------------------------------------------------------
% Extração morfológica avançada
%% ------------------------------------------------------------------------
FEAT1 = regionprops(IM_PHA, 'Area', 'MajorAxisLength', 'MinorAxisLength', ...
    'Perimeter', ...
    'ConvexHull', 'ConvexImage', 'FilledImage', 'Image', ...
    'Solidity', 'Eccentricity');
RESULTADO = struct;
for i = 1:length(FEAT1)
    [RESULTADO, ~] = euclidean(RESULTADO, FEAT1, i, i, opcao);
end
for i = 1:length(FEAT1)
    RESULTADO.Circularidade(i) = ...
        4*pi*FEAT1(i).Area / ...
        (FEAT1(i).Perimeter^2 + eps);
end
%% ------------------------------------------------------------------------
% Mostrar métricas no Command Window
%% ------------------------------------------------------------------------
if ~isempty(FEAT1)
    fprintf('\nNumero de particulas: %d\n\n', length(FEAT1));
    for i = 1:length(FEAT1)
        fprintf('Particula %d\n', i);
        fprintf('Area: %.2f\n', RESULTADO.Area(i));
        fprintf('Comprimento: %.2f\n', RESULTADO.Comprimento(i));
        fprintf('Largura: %.2f\n', RESULTADO.Largura(i));
        fprintf('Esfericidade: %.2f\n', RESULTADO.Esfericidade(i));
        fprintf('Compacidade: %.2f\n\n', RESULTADO.Compacidade(i));
        fprintf('Solidity: %.2f\n', FEAT1(i).Solidity);
    end
end
%% ------------------------------------------------------------------------
% Classificacao automatica microplasticos
%% ------------------------------------------------------------------------
fprintf('\n');
fprintf('CLASSIFICACAO AUTOMATICA\n');
fprintf('------------------------\n\n');
n_fiber = 0;
n_bead = 0;
n_film = 0;
n_fragment = 0;
n_agregado = 0;
classes = cell(length(FEAT1),1);
CC_CLASS = bwconncomp(IM_PHA);
for i = 1:length(FEAT1)
    excentricidade = RESULTADO.Excentricidade(i);
    esfericidade = RESULTADO.Esfericidade(i);
    compacidade = RESULTADO.Compacidade(i);
    comprimento = RESULTADO.Comprimento(i);
    largura = RESULTADO.Largura(i);
    aspect_ratio = comprimento / largura;
    solidez = FEAT1(i).Solidity;
    circularidade = RESULTADO.Circularidade(i);
    objeto = false(size(IM_PHA));
    if i <= CC_CLASS.NumObjects
        objeto(CC_CLASS.PixelIdxList{i}) = true;
    else
        continue
    end
    D = bwdist(~objeto);
    M = imregionalmax(D);
    M = bwareaopen(M,2);
    num_maximos = bwconncomp(M).NumObjects;
    %% ------------------------------------------------------------
    % CLASSIFICACAO
    %% ------------------------------------------------------------
    if num_maximos >= 3 && ...
       solidez < 0.80
        classe = 'Agregado';
        n_agregado = n_agregado + 1;
    elseif excentricidade > 0.95 && ...
        aspect_ratio > 3
        classe = 'Fiber';
        n_fiber = n_fiber + 1;
    elseif esfericidade > 0.85 && ...
           compacidade > 0.75 && ...
           solidez > 0.85 && ...
           circularidade > 0.75
        classe = 'Bead';
        n_bead = n_bead + 1;
    elseif compacidade < 0.45
        classe = 'Film';
        n_film = n_film + 1;
    else
        classe = 'Fragment';
        n_fragment = n_fragment + 1;
    end
    RESULTADO.NumFibers = n_fiber;
    RESULTADO.NumFragments = n_fragment;
    RESULTADO.NumFilms = n_film;
    RESULTADO.NumBeads = n_bead;
    RESULTADO.NumAgregados = n_agregado;
    RESULTADO.NumParticulas = length(FEAT1);
    classes{i} = classe;
    fprintf('Particula %d -> %s\n', i, classe);
end
%% ------------------------------------------------------------------------
% Graficos automaticos
%% ------------------------------------------------------------------------
if ~isempty(FEAT1) && ~modo_lote
    %% ------------------------------------------------------------
    % Histograma Areas
    %% ------------------------------------------------------------
    figure
    bw_area = max(0.1, (max(RESULTADO.Area) - min(RESULTADO.Area)) / 10);
    h = histogram(RESULTADO.Area, 'BinWidth', bw_area);
    title('Distribuicao da Area')
    xlabel('Area (\mum^2)')
    ylabel('Numero de Particulas')
    ylim([0 max(h.Values) + 1])
    grid on
    saveas(gcf,'histograma_area.png')
    %% ------------------------------------------------------------
    % Histograma Comprimentos
    %% ------------------------------------------------------------
    figure
    bw_comp = max(0.1, (max(RESULTADO.Comprimento) - min(RESULTADO.Comprimento)) / 10);
    h = histogram(RESULTADO.Comprimento, 'BinWidth', bw_comp);
    title('Distribuicao do Comprimento')
    xlabel('Comprimento (\mum)')
    ylabel('Numero de Particulas')
    ylim([0 max(h.Values) + 1])
    grid on
    saveas(gcf,'histograma_comprimento.png')
    %% ------------------------------------------------------------
    % Grafico Classes
    %% ------------------------------------------------------------
    figure
    valores = [n_fiber n_fragment n_film n_bead n_agregado];
    labels  = {'Fiber','Fragment','Film','Bead','Agregado'};
    mask    = valores > 0;
    pie(valores(mask), labels(mask))
    title('Classificacao dos Microplasticos')
    saveas(gcf,'grafico_classes.png')
    %% ------------------------------------------------------------
    % Resumo estatistico
    %% ------------------------------------------------------------
    fprintf('\n');
    fprintf('RESUMO ESTATISTICO\n');
    fprintf('------------------------\n');
    fprintf('Fibers: %d\n', n_fiber);
    fprintf('Fragments: %d\n', n_fragment);
    fprintf('Films: %d\n', n_film);
    fprintf('Beads: %d\n', n_bead);
    fprintf('Agregados: %d\n', n_agregado);
    fprintf('\n');
    fprintf('Area media: %.2f\n', mean(RESULTADO.Area));
    fprintf('Comprimento medio: %.2f\n', mean(RESULTADO.Comprimento));
    fprintf('Largura media: %.2f\n', mean(RESULTADO.Largura));
    fprintf('Esfericidade media: %.2f\n', mean(RESULTADO.Esfericidade));
    fprintf('Compacidade media: %.2f\n', mean(RESULTADO.Compacidade));
    fprintf('\n');
end
%% ------------------------------------------------------------------------
% Criar contorno fluorescente mais espesso
%% ------------------------------------------------------------------------
IM_EDG_PHA = bwperim(IM_PHA);
IM_EDG_PHA = imdilate(IM_EDG_PHA, strel('disk',1));
IM_BRD_PHA = mat2gray(double(IMAGEM_ORG), [0 255]);
IM_BRD_PHA(:,:,1) = IM_ORG_R .* ~IM_EDG_PHA;
IM_BRD_PHA(:,:,2) = IM_ORG_G + IM_EDG_PHA;
IM_BRD_PHA(:,:,3) = IM_ORG_B .* ~IM_EDG_PHA;
IM_BRD_PHA(IM_BRD_PHA > 1) = 1;
%% ------------------------------------------------------------------------
% Guardar resultados
%% ------------------------------------------------------------------------
if ~modo_lote
    gravacao = gravar(opcao, IM_PHA, IM_BRD_PHA);
    gravar_param( ...
        gravacao, ...
        opcao, ...
        pha_area, ...
        pha_val, ...
        pha_media, ...
        RESULTADO, ...
        FEAT1, ...
        classes);
    gravar_log( ...
        gravacao, ...
        opcao, ...
        RESULTADO);
    gerar_relatorio_html( ...
        IMAGEM_ORG, ...
        IM_BRD_PHA, ...
        RESULTADO, ...
        classes);
end
toc
%% ------------------------------------------------------------------------
% Finalizar
%% ------------------------------------------------------------------------
if strcmp(opcao.avanco, 'imagem')
    final(opcao)
end
end