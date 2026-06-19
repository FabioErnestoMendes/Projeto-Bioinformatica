%%
% 
% <<FILENAME.PNG>>
% 
function [IM_BIN] = bin_itr(IM_GRAY)

%% ------------------------------------------------------------------------
% Threshold híbrido
%
% Combina:
% - Otsu global
% - threshold adaptativo local
%
% Melhor para:
% - microplásticos muito brilhantes
% - fluorescência irregular
% - partículas parcialmente iluminadas
%% ------------------------------------------------------------------------

%% ------------------------------------------------------------------------
% Threshold global Otsu
%% ------------------------------------------------------------------------

thrs = graythresh(IM_GRAY);

media_img = mean(IM_GRAY(:));

fator = 0.80 + 0.10 * media_img;

IM_BIN_OTSU = imbinarize( ...
    IM_GRAY, ...
    thrs * fator);
%% ------------------------------------------------------------------------
% Threshold adaptativo local
%% ------------------------------------------------------------------------

T = adaptthresh( ...
    IM_GRAY, ...
    0.70);

IM_BIN_ADAPT = imbinarize( ...
    IM_GRAY, ...
    T);


%% ------------------------------------------------------------------------
% Combinar os dois resultados
%% ------------------------------------------------------------------------

IM_BIN = IM_BIN_OTSU & IM_BIN_ADAPT;

figure
imshow(IM_BIN_OTSU)
title('Threshold Otsu')

imwrite(IM_BIN_OTSU,'debug_otsu.png');
imwrite(IM_BIN_ADAPT,'debug_adapt.png');
imwrite(IM_BIN,'debug_final.png');
%% ------------------------------------------------------------------------
% Remover ruído pequeno
%% ------------------------------------------------------------------------

IM_BIN = bwareaopen( ...
    IM_BIN, ...
    30);

%% ------------------------------------------------------------------------
% Unir regiões fluorescentes
%% ------------------------------------------------------------------------

% IM_BIN = imclose( ...
%     IM_BIN, ...
%     strel('disk',1));

IM_BIN = imerode( ...
    IM_BIN, ...
    strel('disk',1));


%% ------------------------------------------------------------------------
% Preencher interior
%% ------------------------------------------------------------------------

%IM_BIN = imfill( ...
 %IM_BIN, ...
  %  'holes');

end