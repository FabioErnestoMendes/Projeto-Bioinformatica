function processar_lote(opcao)

wb = waitbar(0,'A processar imagens...');

pasta_antiga = cd;

cd(opcao.direct);



ficheiros = [ ...
    dir('*.jpg'); ...
    dir('*.png'); ...
    dir('*.tif'); ...
    dir('*.tiff')];

TabelaGlobal = table();
for k = 1:length(ficheiros)
    fullpath = fullfile(opcao.direct, ficheiros(k).name);
    img = imread(fullpath);

    %% Ler escala TIFF
    opcao.dist = 1;
    try
        info = imfinfo(fullpath);
        if isfield(info, 'ImageDescription')
            txt = info.ImageDescription;
            expr = 'PhysicalSizeX="([\d\.]+)"';
            valor = regexp(txt, expr, 'tokens');
            if ~isempty(valor)
                opcao.dist = str2double(valor{1}{1});
                fprintf('Escala: %.3f um/pixel — %s\n', opcao.dist, ficheiros(k).name);
            end
        end
    catch
        opcao.dist = 1;
    end

    [RESULTADO, classes] = corpo(opcao, img);
    if isempty(classes)
        continue
    end

    for i = 1:length(classes)
        linhas = table( ...
            ficheiros(k).name, ...
            i, ...
            opcao.dist, ...
            RESULTADO.Area(i), ...
            RESULTADO.Comprimento(i), ...
            RESULTADO.Largura(i), ...
            classes{i}, ...
            'VariableNames', ...
            {'Imagem', 'ID', 'Escala_um_px', ...
             'Area_um2', 'Comprimento_um', 'Largura_um', 'Classe'});
        TabelaGlobal = [TabelaGlobal; linhas];
    end
end
    
writetable( ...
    TabelaGlobal,...
    'Resultados_Globais.xlsx');
if isempty(TabelaGlobal)

    close(wb);
    cd(pasta_antiga);

    errordlg('Nenhuma particula encontrada.');

    return

end
n_fiber = sum(strcmp(TabelaGlobal.Classe,'Fiber'));
n_fragment = sum(strcmp(TabelaGlobal.Classe,'Fragment'));
n_film = sum(strcmp(TabelaGlobal.Classe,'Film'));
n_bead = sum(strcmp(TabelaGlobal.Classe,'Bead'));
n_agregado = sum(strcmp(TabelaGlobal.Classe,'Agregado'));

area_media = mean(TabelaGlobal.Area);
area_max = max(TabelaGlobal.Area);
area_min = min(TabelaGlobal.Area);

comp_media = mean(TabelaGlobal.Comprimento);
larg_media = mean(TabelaGlobal.Largura);

figure

pie( ...
    [n_fiber n_fragment n_film n_bead n_agregado], ...
    {'Fiber','Fragment','Film','Bead','Agregado'})

saveas(gcf,'resultado_global.png');

figure
histogram(TabelaGlobal.Area)
title('Distribuicao das Areas')
xlabel('Area (\mum^2)')
ylabel('Frequencia')
xlim([0 max(TabelaGlobal.Area)*1.1])
grid on
saveas(gcf,'histograma_areas_global.png')
figure

figure
histogram(TabelaGlobal.Comprimento)
title('Distribuicao dos Comprimentos')
xlabel('Comprimento (\mum)')
ylabel('Frequencia')
xlim([0 max(TabelaGlobal.Comprimento)*1.1])
grid on
saveas(gcf,'histograma_comprimentos_global.png')

fid = fopen('Relatorio_Global.html','w');

fprintf(fid,'<html><body>');
fprintf(fid,'<h1>Microplasticos - Resultado Global</h1>');

fprintf(fid,'<p>Total imagens analisadas: %d</p>', ...
    length(ficheiros));

fprintf(fid,'<p>Total particulas: %d</p>', ...
    height(TabelaGlobal));

total = height(TabelaGlobal);

perc_fiber = 100*n_fiber/total;
perc_fragment = 100*n_fragment/total;
perc_film = 100*n_film/total;
perc_bead = 100*n_bead/total;
perc_agregado = 100*n_agregado/total;

fprintf(fid,'<p>Fibers: %d (%.1f%%)</p>', ...
    n_fiber,perc_fiber);

fprintf(fid,'<p>Fragments: %d (%.1f%%)</p>', ...
    n_fragment,perc_fragment);

fprintf(fid,'<p>Films: %d (%.1f%%)</p>', ...
    n_film,perc_film);

fprintf(fid,'<p>Beads: %d (%.1f%%)</p>', ...
    n_bead,perc_bead);

fprintf(fid,'<p>Agregados: %d (%.1f%%)</p>', ...
    n_agregado,perc_agregado);

fprintf(fid,'<h2>Estatisticas Gerais</h2>');

fprintf(fid,'<p>Area media: %.2f</p>',area_media);
fprintf(fid,'<p>Area minima: %.2f</p>',area_min);
fprintf(fid,'<p>Area maxima: %.2f</p>',area_max);

fprintf(fid,'<p>Comprimento medio: %.2f</p>',comp_media);
fprintf(fid,'<p>Largura media: %.2f</p>',larg_media);

fprintf(fid,'<h2>Classificacao Global</h2>');
fprintf(fid,'<img src="resultado_global.png" width="600">');

fprintf(fid,'<h2>Distribuicao das Areas</h2>');
fprintf(fid,'<img src="histograma_areas_global.png" width="600">');

fprintf(fid,'<h2>Distribuicao dos Comprimentos</h2>');
fprintf(fid,'<img src="histograma_comprimentos_global.png" width="600">');

fprintf(fid,'<h2>Particulas Detetadas</h2>');

fprintf(fid,'<table border="1">');

fprintf(fid, '<tr><th>Imagem</th><th>ID</th><th>Classe</th><th>Area (um2)</th><th>Comprimento (um)</th><th>Largura (um)</th></tr>');

for r = 1:height(TabelaGlobal)

    fprintf(fid,...
        '<tr><td>%s</td><td>%d</td><td>%s</td><td>%.2f</td><td>%.2f</td><td>%.2f</td></tr>',...
        TabelaGlobal.Imagem{r},...
        TabelaGlobal.ID(r),...
        TabelaGlobal.Classe{r},...
        TabelaGlobal.Area(r),...
        TabelaGlobal.Comprimento(r),...
        TabelaGlobal.Largura(r));

end

fprintf(fid,'</table>');

fprintf(fid,'</body></html>');

fclose(fid);

close(wb);

cd(pasta_antiga);

end