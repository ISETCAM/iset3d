function val = piMaterialMixEEM(nameList, ccList, varargin)
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('nameList', @iscell);
p.addRequired('ccList', @iscell);
p.addParameter('wave', 365:5:705, @isnumeric);
p.addParameter('form', 'vec', @ischar);

p.parse(nameList, ccList, varargin{:});
wave = p.Results.wave;
form = p.Results.form;

%%
if ~isequal(numel(nameList), numel(ccList))
    error('Number of fluorophores %d does not match number of concentrations %d',...
            numel(nameList), numel(ccList));
end

val = zeros(numel(wave));

for ii=1:numel(nameList)
    thisEEM = piMaterialGenerateEEM(nameList{ii}, 'wave', wave,...
                                                  'form', 'mat');
    val = val + thisEEM * ccList{ii};                                          
end

switch form
    case {'vec', 'vector'}
        val = piEEM2Vec(wave, val);
    case {'mat', 'matrix'}
        % Do nothing   
end


end