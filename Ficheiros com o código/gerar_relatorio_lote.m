function gerar_relatorio_lote(TODOS)

n = length(TODOS);

fibers = sum([TODOS.fiber]);
fragments = sum([TODOS.fragment]);
films = sum([TODOS.film]);
beads = sum([TODOS.bead]);
agregados = sum([TODOS.agregado]);

figure

pie( ...
    [fibers fragments films beads agregados], ...
    {'Fiber','Fragment','Film','Bead','Agregado'})

title('Resultado Global')

saveas(gcf,'resultado_global.png')

fid = fopen('relatorio_global.html','w');

fprintf(fid,'<html><body>');

fprintf(fid,'<h1>Relatorio Global</h1>');

fprintf(fid,'<p>Total imagens: %d</p>',n);

fprintf(fid,'<img src="resultado_global.png">');

fprintf(fid,'</body></html>');

fclose(fid);

end