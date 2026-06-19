function gerar_relatorio_html( ...
    ~, ...
    IM_BRD_PHA, ...
    RESULTADO, ...
    classes)
%% ------------------------------------------------------------
% Guardar imagem segmentada
%% ------------------------------------------------------------
imwrite(IM_BRD_PHA,'segmentacao.png');
%% ------------------------------------------------------------
% Histograma Areas
%% ------------------------------------------------------------
figure('Visible','off')
bw_area = max(0.1, (max(RESULTADO.Area) - min(RESULTADO.Area)) / 10);
h = histogram(RESULTADO.Area, 'BinWidth', bw_area);
title('Distribuicao da Area')
xlabel('Area (\mum^2)')
ylabel('Numero de Particulas')
ylim([0 max(h.Values) + 1])
grid on
saveas(gcf,'histograma_area.png')
close
%% ------------------------------------------------------------
% Histograma Comprimentos
%% ------------------------------------------------------------
figure('Visible','off')
bw_comp = max(0.1, (max(RESULTADO.Comprimento) - min(RESULTADO.Comprimento)) / 10);
h = histogram(RESULTADO.Comprimento, 'BinWidth', bw_comp);
title('Distribuicao do Comprimento')
xlabel('Comprimento (\mum)')
ylabel('Numero de Particulas')
ylim([0 max(h.Values) + 1])
grid on
saveas(gcf,'histograma_comprimento.png')
close
%% ------------------------------------------------------------
% Classes
%% ------------------------------------------------------------
if ~isempty(classes)
    n_fiber    = sum(strcmp(classes,'Fiber'));
    n_fragment = sum(strcmp(classes,'Fragment'));
    n_film     = sum(strcmp(classes,'Film'));
    n_bead     = sum(strcmp(classes,'Bead'));
    n_agregado = sum(strcmp(classes,'Agregado'));
    valores = [n_fiber n_fragment n_film n_bead n_agregado];
    labels  = {'Fiber','Fragment','Film','Bead','Agregado'};
    mask    = valores > 0;
    figure('Visible','off')
    pie(valores(mask), labels(mask))
    title('Classificacao dos Microplasticos')
    saveas(gcf,'grafico_classes.png')
    close
else
    n_fiber    = 0;
    n_fragment = 0;
    n_film     = 0;
    n_bead     = 0;
    n_agregado = 0;
end
%% ------------------------------------------------------------
% Estatisticas
%% ------------------------------------------------------------
n_part = length(RESULTADO.Area);
if n_part > 0
    area_media = mean(RESULTADO.Area);
    comprimento_medio = ...
        mean(RESULTADO.Comprimento);
    largura_media = ...
        mean(RESULTADO.Largura);
    esfericidade_media = ...
        mean(RESULTADO.Esfericidade);
    compacidade_media = ...
        mean(RESULTADO.Compacidade);
else
    area_media = 0;
    comprimento_medio = 0;
    largura_media = 0;
    esfericidade_media = 0;
    compacidade_media = 0;
end
%% ------------------------------------------------------------
% Criar HTML
%% ------------------------------------------------------------
fid = fopen('relatorio.html','w');
fprintf(fid,'<html>');
fprintf(fid,'<head>');
fprintf(fid,'<title>Microplastic Report</title>');
fprintf(fid,'</head>');
fprintf(fid,'<body style="font-family:Arial;">');
fprintf(fid,'<h1>Microplastic Analysis Report</h1>');
fprintf(fid,'<h2>Resumo Geral</h2>');
fprintf(fid,'<ul>');
fprintf(fid,'<li>Numero de Particulas: %d</li>',n_part);
fprintf(fid,'<li>Area Media: %.2f</li>',area_media);
fprintf(fid,'<li>Comprimento Medio: %.2f</li>',comprimento_medio);
fprintf(fid,'<li>Largura Media: %.2f</li>',largura_media);
fprintf(fid,'<li>Esfericidade Media: %.2f</li>',esfericidade_media);
fprintf(fid,'<li>Compacidade Media: %.2f</li>',compacidade_media);
fprintf(fid,'</ul>');
fprintf(fid,'<h2>Classificacao</h2>');
fprintf(fid,'<ul>');
fprintf(fid,'<li>Fibers: %d</li>',n_fiber);
fprintf(fid,'<li>Fragments: %d</li>',n_fragment);
fprintf(fid,'<li>Films: %d</li>',n_film);
fprintf(fid,'<li>Beads: %d</li>',n_bead);
fprintf(fid,'<li>Agregados: %d</li>',n_agregado);
fprintf(fid,'</ul>');
fprintf(fid,'<h2>Segmentacao</h2>');
fprintf(fid,'<img src="segmentacao.png" width="800">');
fprintf(fid,'<h2>Distribuicao da Area</h2>');
fprintf(fid,'<img src="histograma_area.png" width="800">');
fprintf(fid,'<h2>Distribuicao do Comprimento</h2>');
fprintf(fid,'<img src="histograma_comprimento.png" width="800">');
fprintf(fid,'<h2>Classificacao dos Microplasticos</h2>');
fprintf(fid,'<img src="grafico_classes.png" width="800">');
fprintf(fid,'<h2>Tabela de Resultados</h2>');
fprintf(fid,'<table border="1" cellpadding="5">');
fprintf(fid,'<tr>');
fprintf(fid,'<th>ID</th>');
fprintf(fid,'<th>Area (um2)</th>');
fprintf(fid,'<th>Comprimento (um)</th>');
fprintf(fid,'<th>Largura (um)</th>');
fprintf(fid,'<th>Esfericidade</th>');
fprintf(fid,'<th>Compacidade</th>');
fprintf(fid,'<th>Classe</th>');
fprintf(fid,'</tr>');
for i = 1:length(RESULTADO.Area)
    fprintf(fid,'<tr>');
    fprintf(fid,'<td>%d</td>',i);
    fprintf(fid,'<td>%.2f</td>', ...
        RESULTADO.Area(i));
    fprintf(fid,'<td>%.2f</td>', ...
        RESULTADO.Comprimento(i));
    fprintf(fid,'<td>%.2f</td>', ...
        RESULTADO.Largura(i));
    fprintf(fid,'<td>%.2f</td>', ...
        RESULTADO.Esfericidade(i));
    fprintf(fid,'<td>%.2f</td>', ...
        RESULTADO.Compacidade(i));
    fprintf(fid,'<td>%s</td>', ...
        classes{i});
    fprintf(fid,'</tr>');
end
fprintf(fid,'</table>');
fprintf(fid,'</body>');
fprintf(fid,'</html>');
fclose(fid);
web('relatorio.html','-browser');
fprintf('\nRelatorio HTML criado com sucesso.\n');
end