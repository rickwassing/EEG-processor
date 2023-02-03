function writeHTML(fname, S)

fid = fopen(fname, 'w');

fprintf(fid, '<!DOCTYPE html>\n');
fprintf(fid, '<html lang="en">\n');
fprintf(fid, '<head>\n');
fprintf(fid, '<meta charset="utf-8" />\n');
fprintf(fid, '<meta name="viewport" content="width=device-width, initial-scale=1" />\n');
fprintf(fid, '<title>%s</title>\n', S.title);
fprintf(fid, '<link\n');
fprintf(fid, 'rel="canonical"\n');
fprintf(fid, 'href="https://getbootstrap.com/docs/5.0/examples/grid/"\n');
fprintf(fid, '/>\n');
fprintf(fid, '<!-- jQuery -->\n');
fprintf(fid, '<link href="https://cdn.datatables.net/1.13.1/css/jquery.dataTables.min.css" rel="stylesheet">\n');
fprintf(fid, '<script   src="https://code.jquery.com/jquery-3.6.2.min.js"   integrity="sha256-2krYZKh//PcchRtd+H+VyyQoZ/e3EcrkxhM8ycwASPA="   crossorigin="anonymous"></script>');
fprintf(fid, '<script type="text/javascript" src="https://cdn.datatables.net/1.13.1/js/jquery.dataTables.min.js"></script>');
fprintf(fid, '<!-- Bootstrap core CSS -->\n');
fprintf(fid, '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">\n');
fprintf(fid, '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>\n');
fprintf(fid, '<style>\n');
fprintf(fid, '.container-fluid {\n');
fprintf(fid, 'background-image: linear-gradient(180deg, rgba(248, 249, 250, 0.67), rgba(248, 249, 250, 1) 85%%), radial-gradient(ellipse at top left, rgba(13, 110, 253, 0.25), transparent 50%%), radial-gradient(ellipse at top right, rgba(255, 228, 132, 0.5), transparent 50%%), radial-gradient(ellipse at center right, rgba(113, 44, 249, 0.5), transparent 50%%), radial-gradient(ellipse at center left, rgba(214, 51, 132, 0.5), transparent 50%%);\n');
fprintf(fid, '}\n');
fprintf(fid, '</style>\n');
fprintf(fid, '<!-- Custom styles for this template -->\n');
fprintf(fid, '<link href="grid.css" rel="stylesheet" />\n');
fprintf(fid, '</head>\n');
fprintf(fid, '<body class="bg-light p-0 m-0">\n');
fprintf(fid, '<main>\n');
fprintf(fid, '<div class="container-fluid">\n');
for i = 1:length(S.c)
    html = generateHTML(S.c(i));
    fprintf(fid, '%s\n', html);
end
fprintf(fid, '</div>\n');
fprintf(fid, '</main>\n');
fprintf(fid, '%s\n', html);
fprintf(fid, '</body>\n');
fprintf(fid, '<script>$(document).ready(function () { $("table.table-sortable").DataTable({ paging: false, searching: false }); });</script>');
fprintf(fid, '</html>\n');

fclose(fid);

end