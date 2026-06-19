function [RESULTADO, IMG_DIST] = euclidean(RESULTADO, FEAT1, i_calc, i_temp, opcao)

%% ------------------------------------------------------------------------
% Cálculo da área da partícula
%% ------------------------------------------------------------------------

area = bwarea(FEAT1(i_temp).Image);

%% ------------------------------------------------------------------------
% Cálculo do perímetro convexo
%
% Usa o ConvexHull para calcular o perímetro da envolvente convexa.
%% ------------------------------------------------------------------------

perc = diff(FEAT1(i_temp).ConvexHull);

perconvexo = 0;

for i_conv = 1:length(perc)

    perconvexo = perconvexo + ...
        sqrt(perc(i_conv,1)^2 + perc(i_conv,2)^2);

end

%% ------------------------------------------------------------------------
% Cálculo do perímetro real da partícula
%
% Usa regionprops em vez do antigo chain_code.
%% ------------------------------------------------------------------------

PER = regionprops(FEAT1(i_temp).FilledImage, 'Perimeter');

perimetro = PER.Perimeter;

%% ------------------------------------------------------------------------
% Determinação da área de cavidades internas
%
% Mede buracos/concavidades dentro da partícula.
%% ------------------------------------------------------------------------

IM_HOLE_TMP = xor(FEAT1(i_temp).FilledImage, FEAT1(i_temp).Image);

areah = bwarea(IM_HOLE_TMP);

%% ------------------------------------------------------------------------
% Distância euclidiana ao fundo
%
% Usado para robustez e maior concavidade.
%% ------------------------------------------------------------------------

FEAT_IMG_PAD = padarray(~FEAT1(i_temp).Image, [1 1], 1, 'both');

IMG_DIST = bwdist(FEAT_IMG_PAD);

%% ------------------------------------------------------------------------
% Distância às regiões convexas
%% ------------------------------------------------------------------------

FEAT_CONV_PAD = padarray( ...
    ~(FEAT1(i_temp).ConvexImage & ~FEAT1(i_temp).Image), ...
    [1 1], ...
    1, ...
    'both');

IM_CONV_DIST = bwdist(FEAT_CONV_PAD);

%% ------------------------------------------------------------------------
% Parâmetros morfológicos
%% ------------------------------------------------------------------------

robst = 2 * max(max(IMG_DIST)) / sqrt(4 * area / pi);

maiorconc = 2 * max(max(IM_CONV_DIST)) / sqrt(area);

relarea = areah / (areah + area);

%% ------------------------------------------------------------------------
% Guardar parâmetros calculados
%% ------------------------------------------------------------------------

RESULTADO.Area(i_calc) = area * opcao.dist^2;

RESULTADO.Largura(i_calc) = FEAT1(i_temp).MinorAxisLength * opcao.dist;

RESULTADO.Perimetro(i_calc) = perimetro * opcao.dist;

RESULTADO.Comprimento(i_calc) = FEAT1(i_temp).MajorAxisLength * opcao.dist;

RESULTADO.FactorForma(i_calc) = (perimetro^2) / (4 * pi * area);

RESULTADO.Convexidade(i_calc) = perconvexo / perimetro;

RESULTADO.Compacidade(i_calc) = ...
    sqrt((4/pi) * area) / FEAT1(i_temp).MajorAxisLength;

RESULTADO.Esfericidade(i_calc) = ...
    4 * pi * area / (perconvexo^2);

RESULTADO.Solidez(i_calc) = FEAT1(i_temp).Solidity;

RESULTADO.Extent(i_calc) = area / ...
    (FEAT1(i_temp).MajorAxisLength * FEAT1(i_temp).MinorAxisLength);

RESULTADO.Excentricidade(i_calc) = FEAT1(i_temp).Eccentricity;

RESULTADO.Robustez(i_calc) = robst;

RESULTADO.MaiorConcavidade(i_calc) = maiorconc;

RESULTADO.RelArea(i_calc) = relarea;

end