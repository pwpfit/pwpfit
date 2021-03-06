function varargout = tomatlab(obj, data_file, var, name)
%TOMATLAB Writes matlab function representation of piece-wise fit.
%
%% Usage and description
%
%   fileID = tomatlab(obj, data_file, var, name)
%
% writes to file |data_file|, where
%
% * |var|   is cell array of variable name strings, default 'x';
% * |name|  is function name, default 'f';
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-07-08
% * Changed:    2017-07-8
%
%%

% number of cases
m = size(obj(1).coeffs,2);

% determine recursion
if ~isstruct(data_file)
% no case selected
j = -1;

% determine free variable
if ~exist('var', 'var') || isempty(var)
    p.var = obj(1).var;
elseif ~iscell(var)
    p.var = {var};
else
    p.var = var;
end

% determine function name
if ~exist('name', 'var') || isempty(name)
    p.name = obj(1).name;
else
    p.name = name;
end



% open file for writing
if ~isempty(data_file)
    p.file = fopen(data_file, 'w', 'n', 'UTF-8');
else
    % write to stdout
    p.file = 1;
end

fprintf(p.file, ...
        '%% THIS FILE HAS BEEN WRITTEN BY pwfitobject#tomatlab.m %%\n\n');
    
    
if ~isempty(obj(1).xi)
    fprintf(p.file, '%s0 = %#.4e;\n\n', p.var{1}, obj(1).xi);
end

tomatlab(obj, p, -1);

if p.file > 2 % other than stdout/stderr
    fclose(p.file);
end

varargout = {p.file};
    
else
% first input is p-struct, second selected case
p = data_file;
j = var;

if length(obj) > 1
    for o = obj(:)'
        fprintf(p.file, '%%%% %s(%s)\n', o.name, parameter(o.var));
        
        tomatlab(o, p, -1);
        
        fprintf(p.file, '\n');
    end    
elseif m > 1 && j < 0
    for j=1:m
        tomatlab(obj, p, j);
    end
else
    fprintf(p.file, '%s', obj.name);
    if j < 0
        j = 1;
    else
        fprintf(p.file, '%u', j);
    end
    
    if ~isempty(obj.var)
        var = obj.var;
    else
        var = p.var;
    end
    
    % print all coefficients (epsilon = NaN)
    tex = totex(obj, var, [], [], [], [], {'.^'}, '.*', NaN, j);
    fprintf(p.file, ' = @(%s) %s;\n', parameter(p.var), tex);
    
    if j < m
    end
end

end

end

function par = parameter(var)
    if isempty(var), var = {}; end

    par = [sprintf('%s,', var{:}), 'varargin'];
end