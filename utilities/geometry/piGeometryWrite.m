function  piGeometryWrite(thisR,varargin)
% Write out a geometry file that matches the format and labeling objects
%
% Synopsis
%   piGeometryWrite(thisR,varargin)
%
% Input:
%       thisR: a render recipe
%       obj:   Returned by piGeometryRead, contains information about objects.
%
% Optional key/value pairs
%
% Output:
%       None for now.
%
% Description
%   We need a better description of objects and groups here.  Definitions
%   of 'assets'.   
%
% Zhenyi, 2018
%
% See also
%   piGeometryRead
%
%%
p = inputParser;

% varargin =ieParamFormat(varargin);

p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
% default is flase, will turn on for night scene
p.addParameter('lightsFlag',false,@islogical);
p.addParameter('thistrafficflow',[]);

p.parse(thisR,varargin{:});

% These were used but seem to be no longer used
%
% lightsFlag  = p.Results.lightsFlag;
% thistrafficflow = p.Results.thistrafficflow;

%% Create the default file name

[Filepath,scene_fname] = fileparts(thisR.outputFile);
fname = fullfile(Filepath,sprintf('%s_geometry.pbrt',scene_fname));[~,n,e]=fileparts(fname);

% Get the assets from the recipe
obj = thisR.assets;

%% Wrote the geometry file.

fname_obj = fullfile(Filepath,sprintf('%s%s',n,e));

% Open and write out the objects
fid_obj = fopen(fname_obj,'w');
fprintf(fid_obj,'# PBRT geometry file converted from C4D exporter output on %i/%i/%i %i:%i:%f \n  \n',clock);

recursiveWriteObjects(fid_obj, obj, Filepath);
recursiveWriteGroups(fid_obj, obj);

fclose(fid_obj);
fprintf('%s is written out \n', fname_obj);

end

%%
function recursiveWriteObjects(fid, objects, rootPath)
% Print the  shape of each object child into the PBRT geometry file.
%
% The nodes and edges of each of the separate objects are stored in their
% own files within scene/PBRT/pbrt-geometry/ASSETNAME.pbrt.  Here we put
% some metadata about the asset and we Include the file with the nodes and
% edges.
%
% See also
%

if isempty(objects)
    return;
end

for i=1:length(objects.children)
    
    if isempty(objects.children(i).areaLight)
        % Area lights are not supported with object instances.
        
        fprintf(fid, 'ObjectBegin "%s"\n', objects.children(i).name);
        if ~isempty(objects.children(i).mediumInterface)
            fprintf(fid, '%s\n', objects.children(i).mediumInterface);
        end
        if ~isempty(objects.children(i).material)
            fprintf(fid, '%s\n', objects.children(i).material);
        end
        if ~isempty(objects.children(i).areaLight)
            fprintf(fid, '%s\n', objects.children(i).areaLight);
        end
        if ~isempty(objects.children(i).light)
            if ~isempty(objects.children(i).light)
                for ii = 1:numel(objects.children(i).light)
                    fprintf(fid, '%s\n', objects.children(i).light{ii});
                end
            end 
        end        
        if ~isempty(objects.children(i).output)
            % There is an output slot
            [~,output] = fileparts(objects.children(i).output);
            fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', output);
        elseif ~isempty(objects.children(i).shape)
            % output is empty but there is a shape slot we also open the
            % geometry file.
            name = objects.children(i).name;
            geometryFile = fopen(fullfile(rootPath,'scene','PBRT','pbrt-geometry',sprintf('%s.pbrt',name)),'w');
            fprintf(geometryFile,'%s',objects.children(i).shape);
            fclose(geometryFile);
            fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', name);
        else
            % For the camera case we get here.
            % warning('Could not find an output or shape slot for this child.');
        end
        fprintf(fid, 'ObjectEnd\n\n');
    else
        % This is an area light case
        if ~isempty(objects.children(i).shape)
            name = objects.children(i).name;
            geometryFile = fopen(fullfile(rootPath,'scene','PBRT','pbrt-geometry',sprintf('%s.pbrt',name)),'w');
            fprintf(geometryFile,'%s',objects.children(i).shape);
            fclose(geometryFile);
        end
    end
end

%
for j=1:length(objects.groupobjs)
    recursiveWriteObjects(fid,objects.groupobjs(j), rootPath);
end

end

%%
function recursiveWriteGroups(fid, objects)
% Parse the geometry object tree and for every group object replace the
% actual geometry with the 'Include' directive.

%{
persistent first;
first = strcat(first, " ");
%}

if isempty(objects)
    return;
end

for n=1:length(objects)
    
    currentObject = objects(n);
    
    fprintf(fid,'AttributeBegin\n');
    fprintf(fid,'#ObjectName %s:Vector(%.3f, %.3f, %.3f)\n',currentObject.name, ...
                                                            currentObject.size.l, ...
                                                            currentObject.size.w, ...
                                                            currentObject.size.h);
    % If a motion exists in the current object, prepare to write it out by
    % having an additional line below.
    if isfield(currentObject, 'motion') &&...
            ~isempty(currentObject.motion)
        fprintf(fid,'ActiveTransform StartTime \n');
    end
    fprintf(fid,'Translate %.3f %.3f %.3f\n',currentObject.position(1), currentObject.position(2), currentObject.position(3));
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,1)); % Z
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,2)); % Y
    fprintf(fid,'Rotate %.3f %.3f %.3f %.3f \n',currentObject.rotate(:,3));   % X 
    fprintf(fid,'Scale %.3f %.3f %.3f \n',currentObject.scale);
    
    % Write out this motion
    if isfield(currentObject, 'motion') &&...
            ~isempty(currentObject.motion)
        for kk = 1:size(currentObject.position, 2)
            fprintf(fid, 'ActiveTransform EndTime \n');
            if isempty(currentObject.motion.position(:,kk))
                fprintf(fid,'Translate 0 0 0 \n');
            else
                pos = currentObject.motion.position(:,kk);
                fprintf(fid,'Translate %f %f %f \n',pos(1),...
                    pos(2),pos(3));
            end
            
            if isfield(currentObject.motion, 'rotate') && ~isempty(currentObject.motion.rotate)
                rot = currentObject.motion.rotate;
                % Write out rotation
                fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-2)); % Z
                fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-1)); % Y
                fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3));   % X
            end
        end
    end
    
    for j=1:length(currentObject.children)
       if isempty(currentObject.children(j).areaLight)
           if ~isempty(currentObject.children(j).mediumInterface)
               fprintf(fid, '%s\n', currentObject.children(j).mediumInterface);
           end
           %{
           if ~isempty(currentObject.children(j).material)
               fprintf(fid, '%s\n', currentObject.children(j).material);
           end
           %}
           
           if ~isempty(currentObject.children(j).areaLight)
               fprintf(fid, '%s\n', currentObject.children(j).areaLight);
           end
           
           %{
           if ~isempty(currentObject.children(j).shape)
               fprintf(fid, 'Include "scene/PBRT/pbrt-geometry/%s.pbrt" \n', currentObject.children(j).name);
           end
           %}
           
           %{
           % Not sure if we need this
           if isfield(currentObject.children(j), 'motion') &&...
                   ~isempty(currentObject.children(j).motion)
               for kk = 1:size(currentObject.children(j).position, 2)
                   fprintf(fid, 'ActiveTransform EndTime \n');
                   if isempty(currentObject.children(j).motion.position(:,kk))
                       fprintf(fid,'Translate 0 0 0 \n');
                   else
                       pos = currentObject.children(j).motion.position(:,kk);
                       fprintf(fid,'Translate %f %f %f \n',pos(1),...
                           pos(2),pos(3));
                   end
                   
                   if ~isempty(currentObject.children(j).motion.rotate)
                       rot = currentObject.children(j).motion.rotate;
                       % Write out rotation
                       fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-2)); % Z
                       fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3-1)); % Y
                       fprintf(fid,'Rotate %f %f %f %f \n',rot(:,kk*3));   % X
                   end
               end
           end
           %}
           fprintf(fid,'ObjectInstance "%s"\n',currentObject.children(j).name);      
   
       else
           fprintf(fid,'ObjectInstance "%s"\n',currentObject.children(j).name);
       end
    end
    
    for j=1:length(currentObject.groupobjs)
        recursiveWriteGroups(fid,currentObject.groupobjs(j));
    end
    fprintf(fid,'AttributeEnd\n');
end
fprintf(fid,'\n');

end


