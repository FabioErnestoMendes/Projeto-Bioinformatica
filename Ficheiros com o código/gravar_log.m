function gravar_log( ...
    gravacao, ...
    opcao, ...
    RESULTADO)

%% ------------------------------------------------------------------------
% Nome ficheiro
%% ------------------------------------------------------------------------

if gravacao.filename ~= 0

    if endsWith(gravacao.filename, '.tif')

        nome = gravacao.filename(1:end-4);

    else

        nome = gravacao.filename;

    end

    filename_log = fullfile( ...
        gravacao.pathname, ...
        [nome '_log.txt']);

else

    return

end

%% ------------------------------------------------------------------------
% Abrir ficheiro
%% ------------------------------------------------------------------------

fid = fopen(filename_log, 'w');

%% ------------------------------------------------------------------------
% Cabeçalho
%% ------------------------------------------------------------------------

fprintf(fid, '=============================================\n');
fprintf(fid, '         MICROPLASTIC ANALYSIS LOG\n');
fprintf(fid, '=============================================\n\n');

fprintf(fid, 'Imagem analisada : %s\n\n', nome);

%% ------------------------------------------------------------------------
% Parametros utilizados
%% ------------------------------------------------------------------------

fprintf(fid, 'PARAMETROS UTILIZADOS\n');
fprintf(fid, '---------------------------------------------\n');

fprintf(fid, '%-20s : %s\n', ...
    'Fluorescencia', opcao.fluor);

fprintf(fid, '%-20s : %s\n', ...
    'Pre-tratamento', opcao.pretrat);

%fprintf(fid, '%-20s : %s\n', ...
    %'Desconvolucao', opcao.deconv);

fprintf(fid, '\n');

%% ------------------------------------------------------------------------
% Estatisticas gerais
%% ------------------------------------------------------------------------

n_part = length(RESULTADO.Area);

fprintf(fid, 'ESTATISTICAS GERAIS\n');
fprintf(fid, '---------------------------------------------\n');

fprintf(fid, 'Numero total particulas : %d\n', ...
    n_part);

fprintf(fid, 'Area media              : %.2f\n', ...
    mean(RESULTADO.Area));

fprintf(fid, 'Comprimento medio       : %.2f\n', ...
    mean(RESULTADO.Comprimento));

fprintf(fid, 'Largura media           : %.2f\n', ...
    mean(RESULTADO.Largura));

fprintf(fid, '\n');

%% ------------------------------------------------------------------------
% Classificacao automatica
%% ------------------------------------------------------------------------

fprintf(fid, 'CLASSIFICACAO AUTOMATICA\n');
fprintf(fid, '---------------------------------------------\n');

n_fiber = 0;
n_bead = 0;
n_film = 0;
n_fragment = 0;

for i = 1:n_part

    excentricidade = RESULTADO.Excentricidade(i);

    esfericidade = RESULTADO.Esfericidade(i);

    compacidade = RESULTADO.Compacidade(i);

    comprimento = RESULTADO.Comprimento(i);

    largura = RESULTADO.Largura(i);

    aspect_ratio = comprimento / largura;

    %% ------------------------------------------------------------
    % Classificacao
    %% ------------------------------------------------------------

    if excentricidade > 0.95 && ...
       aspect_ratio > 3

        classe = 'Fiber';

        n_fiber = n_fiber + 1;

    elseif esfericidade > 0.75 && ...
           compacidade > 0.60

        classe = 'Bead';

        n_bead = n_bead + 1;

    elseif compacidade < 0.45

        classe = 'Film';

        n_film = n_film + 1;

    else

        classe = 'Fragment';

        n_fragment = n_fragment + 1;

    end

    fprintf(fid, ...
        'Particula %-3d -> %-10s\n', ...
        i, classe);

end

fprintf(fid, '\n');

%% ------------------------------------------------------------------------
% Resumo classificacao
%% ------------------------------------------------------------------------

fprintf(fid, 'RESUMO CLASSIFICACAO\n');
fprintf(fid, '---------------------------------------------\n');

fprintf(fid, 'Fibers    : %d\n', n_fiber);

fprintf(fid, 'Beads     : %d\n', n_bead);

fprintf(fid, 'Films     : %d\n', n_film);

fprintf(fid, 'Fragments : %d\n', n_fragment);

fprintf(fid, '\n');

%% ------------------------------------------------------------------------
% Rodape
%% ------------------------------------------------------------------------

fprintf(fid, '=============================================\n');

fclose(fid);

end