function clr = standard_colors(varargin)

if nargin < 1
    input = [];
else
    input = varargin{1};
end
% category colors
cat_red         = [0.722, 0.110, 0.153];
cat_pink        = [1.000, 0.318, 0.663];
cat_purple      = [0.553, 0.239, 0.612];
cat_blue        = [0.188, 0.310, 0.792];
cat_turquoise   = [0.110, 0.769, 0.824];
cat_green       = [0.278, 0.561, 0.118];
cat_yellow      = [0.910, 0.761, 0.090];
cat_orange      = [0.850, 0.325, 0.098];
cat_black       = [0, 0, 0];
cat_white       = [1, 1, 1];

tmp = ...
    [cat_red;...
    cat_green;...
    cat_blue;...
    cat_purple;...
    cat_turquoise;...
    cat_yellow;...
    cat_pink;....
    cat_orange];

if isempty(input)
    clr = tmp;
elseif isnumeric(input) && length(input) == 1
    nreps = ceil(input/size(tmp,1));
    if nreps == 1
        tmp1 = tmp;
        clr = tmp1;
        clr = clr(1:input,:);
    elseif nreps == 2
        hue_change = 0.5+120*(1/360);
        tmp1 = tmp;
        tmp2 = rgb2hsv(tmp);
        new_hue = tmp2(:,1)+hue_change;
        new_hue(new_hue > 1) = new_hue(new_hue > 1) - 1;
        tmp2(:,1) = new_hue;
        tmp2 = hsv2rgb(tmp2);
        clr = [tmp1;tmp2];
        clr = clr(1:input,:);
        
    elseif nreps >= 3
        fprintf('\nSorry, too many colors!\n')
        
    end
elseif ischar(input)
    if strcmp(input,'gradient')
        
        % gradient colors
        gra_indigo      = [13 45 164]./255;
        gra_blue        = [43 118 217]./255;
        gra_turquoise   = [134 247 253]./255;
        gra_white       = [255 250 212]./255;
        gra_yellow      = [256 256 96]./255;
        gra_orange      = [237 101 33]./255;
        gra_red         = [209 11 11]./255;
        
        N=21;
        clr = [...
            linspace(gra_indigo(1),gra_blue(1),N)' linspace(gra_indigo(2),gra_blue(2),N)' linspace(gra_indigo(3),gra_blue(3),N)';...
            linspace(gra_blue(1),gra_turquoise(1),N)' linspace(gra_blue(2),gra_turquoise(2),N)' linspace(gra_blue(3),gra_turquoise(3),N)';...
            linspace(gra_turquoise(1),gra_white(1),N)' linspace(gra_turquoise(2),gra_white(2),N)' linspace(gra_turquoise(3),gra_white(3),N)';...
            linspace(gra_white(1),gra_yellow(1),N)' linspace(gra_white(2),gra_yellow(2),N)' linspace(gra_white(3),gra_yellow(3),N)';...
            linspace(gra_yellow(1),gra_orange(1),N)' linspace(gra_yellow(2),gra_orange(2),N)' linspace(gra_yellow(3),gra_orange(3),N)';...
            linspace(gra_orange(1),gra_red(1),N)' linspace(gra_orange(2),gra_red(2),N)' linspace(gra_orange(3),gra_red(3),N)';...
            ];
    else
        clr = eval(sprintf('cat_%s',input));
    end
elseif iscell(input)
    clr=[];
    for c = 1:length(input)
        this_clr = input{1,c};
        clr = [clr; eval(sprintf('cat_%s',this_clr))];
    end
    
end