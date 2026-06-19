function [gravacao] = gravar(opcao, IM_PHA, IM_BRD_PHA)

gravacao.filename = 0;
gravacao.pathname = '';

switch opcao.avanco
    case 'imagem'
        [filename, pathname] = uiputfile('*.tif', 'Save as');
        gravacao.filename = filename;
        gravacao.pathname = pathname;

        if gravacao.filename ~= 0
            if endsWith(gravacao.filename, '.tif')
                base = gravacao.filename(1:end-4);
            else
                base = gravacao.filename;
            end

            filename_PHA = fullfile(pathname, [base '_PHA.tif']);
            filename_BRD = fullfile(pathname, [base '_BRD.tif']);
        end
end

if gravacao.filename ~= 0
    imwrite(IM_PHA, filename_PHA, 'tif');
    imwrite(IM_BRD_PHA, filename_BRD, 'tif');
else
    return
end
