function [obj,results] = piWRS(thisR,varargin)
% Write, render, show radiance image
%
% Write, Render, Show a scene specified by a recipe
%
% Synopsis
%   [isetObj, results] = piWRS(thisR)
% 
% See also
%   piRender, sceneWindow, oiWindow

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisR',@(x)(isa(x,'recipe')));
p.addParameter('dockerimagename','vistalab/pbrt-v3-spectral:latest',@ischar);

p.parse(thisR,varargin{:});
thisDocker = p.Results.dockerimagename;

%%
piWrite(thisR);

[obj,results] = piRender(thisR,...
    'docker image name',thisDocker, ...
    'render type','radiance');

switch obj.type
    case 'scene'
        sceneWindow(obj);
    case 'opticalimage'
        oiWindow(obj);
end

end