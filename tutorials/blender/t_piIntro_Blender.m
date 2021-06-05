%% Render a pbrt image exported from Blender
%
% Description:
%    This tutorial demonstrates how you can use iset3d to render and modify
%    a scene that was created in Blender.
% 
%    This tutorial uses an image that was exported from Blender and which 
%    is included in the iset3d repository, but you can use your own Blender
%    scene by following the instructions found here: 
%    https://github.com/ISET/iset3d/wiki/Blender

%    The wiki page above will show you some Blender basics, how to export
%    your Blender scene as a pbrt file, and how to set up a folder in
%    iset3d that contains your scene. You will then need to follow the
%    comments in the tutorial below to modify this script for your scene.
%
%    For a demonstration of how you can add materials to Blender scenes 
%    exported without materials, see:
%    ~/iset3d/tutorials/introduction/t_factoidImages
%
% History:
%   11/27/20  amn  Wrote it, adapted from t_piIntro_scenefromweb.m.
%   11/29/20  dhb  Edited it.
%   04/01/21  amn  Adapted for general parser and assets/materials updates.
%   04/29/21  amn  Adapted for object naming based on object's .ply file name.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker.
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set the input folder name
%
% This is currently set to a folder included in the iset3d repository
% but you can change the name to the name of your own folder, which you 
% can set up as described at: https://github.com/ISET/iset3d/wiki/Blender
sceneName = 'BlenderScene';

%% Set name of pbrt file exported from Blender
%
% This is currently set to a pbrt file included in the iset3d repository
% but you can change the file name to the name of your own scene.
pbrtName = 'BlenderScene'; 

%% Set pbrt file path
%
% This is currently set to the file included in the iset3d repository
% (which is located in ~/iset3d/data/blender/BlenderScene) but you can
% change it to the file path for your scene.
filePath = fullfile(piRootPath,'data','blender',sceneName);
fname = fullfile(filePath,[pbrtName,'.pbrt']);
if ~exist(fname,'file')
    error('File not found - see tutorial header for instructions'); 
end

%% Read scene
%
% Read and parse the pbrt file exported from Blender, and return a
% rendering recipe with the parsed scene information.
thisR = piRead(fname);

%% Add light
% 
% This scene was exported without a light, so create and add an infinite light.
infiniteLight = piLightCreate('infiniteLight','type','infinite','spd','D65');
thisR.set('light','add',infiniteLight);

%% Change render quality
%
% Decrease the resolution and rays/pixel to decrease rendering time.
raysperpixel = thisR.get('rays per pixel');
filmresolution = thisR.get('film resolution');
thisR.set('rays per pixel', raysperpixel/2);
thisR.set('film resolution',filmresolution/2);

%% Write scene
% 
% Save the recipe information in a pbrt scene file. 
piWrite(thisR);

%% Render and display
%
% Render the scene, specifiying the 'radiance' render type only.
scene = piRender(thisR,'render type','radiance');

% Name this render and display it.
scene = sceneSet(scene,'name','Blender export');
sceneWindow(scene);

% Change the gamma for improved visibility.
sceneSet(scene,'gamma',0.5);

%% Modify the scene
%
% Next, we will demonstrate how you can modify a Blender scene in iset3d by
% performing one simple modification. See the other iset3d tutorials for 
% detailed instructions on making various modifications.

%% See asset tree
%
% Print the asset tree structure in the command window.
thisR.show;

%% Get the names of the objects in the scene
%
% List the object names. You will need to know the names of the objects in
%the scene to modify them.
fprintf('\nThis recipe contains objects:\n');
for ii = 1:length(thisR.assets.Node)
    if isfield(thisR.assets.Node{ii},'name')
        assetName = thisR.assets.Node{ii}.name;
        
        % The object name (from Blender) was assigned to the object's leaf
        % (see the section below for more details on the object's leaf and
        % branch).
        if contains(assetName,'_O')
            fprintf('%s\n',assetName);
        end 
    end
end
fprintf('\n');

%% Select an object to modify
% 
% Each object in this scene was assigned a branch (its position,
% orientation, and size) and a leaf (its shape and material).
% First, select an object leaf name from the list that was just
% printed in the command window. 
% In this example, we select the object leaf named '027ID_Monkey_O'.
leafName = '027ID_Monkey_O';

% The leaf of the object contains its shape and material information.
% We need to get the ID of the branch of the object to manipulate the 
% object's position, orientation, or size.
% The branch node is just above the leaf.
branchID = thisR.get('asset parent id',leafName);

%% Move the Monkey object
%
% Here we translate the Monkey object's position 1 meter in the negative x
% direction.
[~,translateBranch] = thisR.set('asset', branchID, 'translate', [-1, 0, 0]);

%% Write, render, and display
% 
% Write the scene.
piWrite(thisR);

% Render and display.
scene = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name','Translated Monkey');
sceneWindow(scene);

%% End