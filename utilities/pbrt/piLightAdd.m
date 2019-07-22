
function thisR = piLightAdd(thisR, varargin)
%% Add different type of light sources to a scene
%
% Inputs:
%       thisR: render recipe
%       types:
%             Point: Casts the same amount of illumination in all directions.
%             Spot: Specify a cone of directions in which light is emitted.
%             distant: It represents a directional light source "at infinity".
%       other related parameters for each type of light source
% Outputs:
%
% Required: ISETCam
% See also: piSkymapAdd(Add HDR lighting for global illumination)
% Zhenyi, SCIEN, 2019
% Example:
%{
lightSources = piLightGet(thisR);
thisR = piLightDelete(thisR, 2);
thisR = piLightAdd(thisR, 'type', 'point');
thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);

%}
%%
varargin = ieParamFormat(varargin);  % Allow spaces and capitalization

p = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('type', 'point', @ischar);
% Load in a light source saved in ISETCam/data/lights
p.addParameter('lightspectrum', 'D65');
% used for point/spot/distant/laser light
p.addParameter('from', [0 0 0]);
% used for spot light
p.addParameter('to', [0 0 1]);

% The angle that the spotlight's cone makes with its primary axis.
% For directions up to this angle from the main axis, the full radiant
% intensity given by "I" is emitted. After this angle and up to
% "coneangle" + "conedeltaangle", illumination falls off until it is zero.
p.addParameter('coneangle', 30, @isnumeric); % It's 30 by default
% The angle at which the spotlight intensity begins to fall off at the edges.
p.addParameter('conedeltaangle', 5, @isnumeric); % It's 5 by default
% place a lightsource at the camera's position
p.addParameter('cameracoordinate',false);
% scale the spectrum
p.addParameter('spectrumscale', 1);
% update an exist light
p.addParameter('update',[]);
p.parse(thisR, varargin{:});

type = p.Results.type;
lightSpectrum = p.Results.lightspectrum;
spectrumScale = p.Results.spectrumscale;
from = p.Results.from;
to = p.Results.to;
coneAngle = p.Results.coneangle;
conDeltaAngle = p.Results.conedeltaangle;
idxL      = p.Results.update;
%% check whether a light needs to be replaced
if idxL
    lightsource = piLightGet(thisR, 'print', false);
    type = lightsource{idxL}.type;
    
    if find(piContains(varargin, 'lightspectrum')), lightSpectrum = p.Results.lightspectrum;
    else, [~,lightSpectrum] = fileparts(lightsource{idxL}.spectrum); end
    
    if find(piContains(varargin, 'from')), from = p.Results.from;
    else, from = lightsource{idxL}.position; end
    
    if find(piContains(varargin, 'to')), to = p.Results.to;
    else, to = lightsource{idxL}.direction; end
    
    if find(piContains(varargin, 'coneAngle')), coneAngle = p.Results.coneangle;
    else, coneAngle = lightsource{idxL}.coneangle; end
    
    if find(piContains(varargin, 'conDeltaAngle')), conDeltaAngle = p.Results.conedeltaangle;
    else, conDeltaAngle = lightsource{idxL}.conedeltaangle; end
    piLightDelete(thisR, idxL);
end
%% Write out lightspectrum into a light.spd file
% [~,sceneName] = fileparts(thisR.inputFile);
if ischar(lightSpectrum)
    try
        thisLight = load(lightSpectrum);
    catch
        error('%s light is not recognized \n', lightSpectrum);
    end
    outputDir = fileparts(thisR.outputFile);
    lightSpdDir = fullfile(outputDir, 'spds', 'lights');
    thisLightfile = fullfile(lightSpdDir,...
        sprintf('%s.spd', lightSpectrum));
    if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
    fid = fopen(thisLightfile, 'w');
    for ii = 1: length(thisLight.data)
        fprintf(fid, '%d %d \n', thisLight.wavelength(ii), thisLight.data(ii)*spectrumScale);
    end
    fclose(fid);
else
    % to do
    % add customized lightspectrum array [400 1 600 1 800 1]
end
%% Read light source struct from world struct
% currentlightSources = piLightGet(thisR, 'print', false);
% %% Construct a lightsource structure
% numLights = length(currentlightSources);
newlight = [];
switch type
    case 'point'
        newlight{1}.type = 'point';
        if p.Results.cameracoordinate
            newlight{1}.line{1} = 'AttributeBegin';
            newlight{1}.line{2,:} = 'CoordSysTransform "camera"';
            newlight{1}.line{3,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd"', lightSpectrum);
            newlight{1}.line{end+1} = 'AttributeEnd';
        else
            newlight{1}.line{1,:} = sprintf('LightSource "point" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d]',...
                lightSpectrum, from);
        end
    case 'spot'
        newlight{1}.type = 'spot';
        newlight{1}.line{1,:} = sprintf('LightSource "spot" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
            lightSpectrum, from, to);
        thisConeAngle = sprintf('float coneangle [%d]', coneAngle);
        thisConeDelta = sprintf('float conedelataangle [%d]', conDeltaAngle);
        newlight{1}.line{2,:} = [newlight{end+1}.line{2}, thisConeAngle, thisConeDelta];
    case 'laser' % not supported for public
        newlight{1}.type = 'laser';
        newlight{1}.line{1,:} = sprintf('LightSource "laser" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
            lightSpectrum, from, to);
        thisConeAngle = sprintf('float coneangle [%d]', coneAngle);
        thisConeDelta = sprintf('float conedelataangle [%d]', conDeltaAngle);
        newlight{1}.line{1,:} = [newlight{end+1}.line{2}, thisConeAngle, thisConeDelta];
    case 'distant'
        newlight{1}.type = 'distant';
        newlight{1}.line{1,:} = sprintf('LightSource "distant" "spectrum I" "spds/lights/%s.spd" "point from" [%d %d %d] "point to" [%d %d %d]',...
            lightSpectrum, from, to);
    case 'area'
        % find area light geometry info
        
        nlight = 1;
        for ii = 1:length(thisR.assets)
            if piContains(lower(thisR.assets(ii).name), 'area') ||...
                    piContains(lower(thisR.assets(ii).name), 'sphere')
                newlight{nlight}.type = 'area';
                newlight{nlight}.line{1} = 'AttributeBegin';
                if ~isempty(idxL)
                    if ~isempty(from)
                        newlight{+nlight}.line{2,:} = sprintf('Translate %f %f %f',from(1),...
                            from(2), from(3));
                    end
                else
                    newlight{nlight}.line{2,:} = sprintf('Translate %f %f %f',thisR.assets(ii).position(1),...
                        thisR.assets(ii).position(2), thisR.assets(ii).position(3));
                end
                newlight{nlight}.line{3,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,1));
                newlight{nlight}.line{4,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,2));
                newlight{nlight}.line{5,:} = sprintf('Rotate %f %f %f %f',thisR.assets(ii).rotate(:,3));
                if piContains(lower(thisR.assets(ii).name), 'area')
                    newlight{nlight}.line{6,:} = sprintf('AreaLightSource "diffuse" "spectrum L" "spds/lights/%s.spd" "bool twosided" "true"', lightSpectrum);
                    newlight{nlight}.line{7,:} = sprintf('Include "%s"', thisR.assets(ii).children.output);
                else
                    newlight{nlight}.line{6,:} = sprintf('AreaLightSource "diffuse" "spectrum L" "spds/lights/%s.spd"', lightSpectrum);
                    newlight{nlight}.line{7,:} = sprintf('Shape "sphere" "float radius" [.1]');
                end
                newlight{nlight}.line{end+1} = 'AttributeEnd';
                nlight = nlight+1;
            end
        end
        if isempty(newlight) % update current lightsource
            newlight{nlight}.type = 'area';
            newlight{nlight}.line{1} = 'AttributeBegin';
            if ~isempty(from)
                newlight{+nlight}.line{2,:} = sprintf('Translate %f %f %f',from(1),...
                    from(2), from(3));
            end
            newlight{nlight}.line{3,:} = sprintf('AreaLightSource "diffuse" "spectrum L" "spds/lights/%s.spd" "bool twosided" "true"', lightSpectrum);
            if find(piContains(lightsource{idxL}.line, 'Shape "trianglemesh"'))
                newlight{nlight}.line{4} = lightsource{idxL}.line{piContains(lightsource{idxL}.line, 'Shape "trianglemesh"')};
            elseif find(piContains(lightsource{idxL}.line, 'Include'))
                newlight{nlight}.line{4,:} = lightsource{idxL}.line{piContains(lightsource{idxL}.line, 'Include')};
            end
            newlight{nlight}.line{end+1} = 'AttributeEnd';
        end
        
        
end
%%
index_m = find(piContains(thisR.world,'_materials.pbrt'));
index_g = find(piContains(thisR.world,'_geometry.pbrt'));
if ~isempty(index_m) || ~isempty(index_g)
    world = thisR.world(1:end-3);
elseif ~isempty(index_m)
    world = thisR.world(1:index_m);
elseif ~isempty(index_g)
    world = thisR.world(1:index_g);
else
    world = thisR.world(1:end-1);
end
for jj = 1: length(newlight)
    numWorld = length(world);
    % infinity light can be added by piSkymap add.
    if ~piContains(newlight{jj}.type, 'infinity')
        ll=1;
        for kk = 1: length(newlight{jj}.line)
            if ~isempty(newlight{jj}.line{kk})
                world{numWorld+ll,:} = newlight{jj}.line{kk};
                ll = ll+1;
            end
        end
    end
end
numWorld = length(world);
if ~isempty(index_m), world{numWorld+1,:} = thisR.world{index_m};end
if ~isempty(index_g), world{numWorld+2,:} = thisR.world{index_g};end
world{end+1,:} = 'WorldEnd';
thisR.world = world;
if idxL
    disp('Light updated.');
else
    disp('Light Added to the Scene.');
end
end


