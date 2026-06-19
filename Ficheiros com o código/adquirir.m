function adquirir(opcao)

opcao.direct_ant = cd;
colormap('default')

switch opcao.avanco

    case 'series'

    processar_lote(opcao);

    final(opcao);

    case 'imagem'

        [filename,pathname] = uigetfile({'*.bmp;*.tif;*.jpg'},'Choose the picture');

        if filename ~= 0

            fullpath = fullfile(pathname,filename);

IMAGEM_ORG = imread(fullpath);

%% Ler calibração TIFF
opcao.dist = 1;

try

    info = imfinfo(fullpath);

    if isfield(info,'ImageDescription')

        txt = info.ImageDescription;

        expr = 'PhysicalSizeX="([\d\.]+)"';

        valor = regexp(txt,expr,'tokens');

        if ~isempty(valor)

            opcao.dist = str2double(valor{1}{1});

            fprintf('\nEscala encontrada: %.3f um/pixel\n', ...
                opcao.dist);

        end

    end

catch

    opcao.dist = 1;

end

imshow(IMAGEM_ORG)
pause(1)

opcao.nome_temp = filename;

corpo(opcao,IMAGEM_ORG);

            clear IMAGEM_ORG
        else
            final(opcao)
        end
end

cd(opcao.direct_ant)
end

