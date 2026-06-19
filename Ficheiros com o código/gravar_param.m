function gravar_param(gravacao, opcao, ~, ~, ~, RESULTADO, ~, classes)
%% ------------------------------------------------------------------------
% Nome ficheiro
%% ------------------------------------------------------------------------
switch opcao.avanco
    case 'imagem'
        if gravacao.filename ~= 0
            if endsWith(gravacao.filename, '.tif')
                nome = gravacao.filename(1:end-4);
            else
                nome = gravacao.filename;
            end
            filename_csv = fullfile( ...
                gravacao.pathname, ...
                [nome '_dataset.csv']);
        end
end
%% ------------------------------------------------------------------------
% Criar dataset
%% ------------------------------------------------------------------------
if gravacao.filename ~= 0
    fid = fopen(filename_csv, 'w');
    %% ------------------------------------------------------------
    % Cabeçalho CSV
    %% ------------------------------------------------------------
    fprintf(fid, ...
    'ID;Area_um2;Comprimento_um;Largura_um;Esfericidade;Compacidade;Excentricidade;Escala_um_px;Classe\n');
    %% ------------------------------------------------------------
    % Guardar partículas
    %% ------------------------------------------------------------
    for i = 1:length(RESULTADO.Area)
        fprintf(fid, ...
            '%d;%.2f;%.2f;%.2f;%.3f;%.3f;%.3f;%.4f;%s\n', ...
                i, ...
                RESULTADO.Area(i), ...
                RESULTADO.Comprimento(i), ...
                RESULTADO.Largura(i), ...
                RESULTADO.Esfericidade(i), ...
                RESULTADO.Compacidade(i), ...
                RESULTADO.Excentricidade(i), ...
                opcao.dist, ...
                classes{i});
    end
    fclose(fid);
else
    final(opcao)
end
end