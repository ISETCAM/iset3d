%% Render a blank white scene for calibration purposes
%
% TL SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene

% fname = '/home/wandell/pbrt-v2-spectral/pbrtScenes/yeahright/yeahright.pbrt';
fname = fullfile(piRootPath,'data','yeahright','yeahright.pbrt');
if ~exist(fname,'file')
    piPBRTFetch('yeahright');
    if ~exist(fname,'file'), error('File not downloaded: %s',fname); end
end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%% Add a camera
thisR = recipeSet(thisR,'camera','realistic');
thisR.camera.specfile.value = fullfile(piRootPath,'data','lens','dgauss.22deg.50.0mm.dat');
thisR.camera.filmdistance.value = 50;
thisR.camera.aperture_diameter.value = 8;

% Make the sensor really big so we can see the edge of the lens and the
% vignetting.
% This takes roughly a 90 seconds to render on a 6 core machine.
% Why does this take so long? There seems to be a lot of NaN returns for
% the radiance, maybe tracing the edges of the lens is difficult in some
% way? The weighting of the rays might also be incorrect in PBRTv2. 
thisR.camera.filmdiag.value = 100;

thisR = recipeSet(thisR,'pixelsamples',256);
thisR = recipeSet(thisR,'filmresolution',128);

%% Write out a new pbrt file

% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath,'local');

% We copy the pbrt scene directory to the working directory
[p,n,e] = fileparts(fname); 
copyfile(p,workingDirectory);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
thisR.outputFile = fullfile(workingDirectory,[n,e]);

% oname = fullfile(workingDirectory,'whiteScene.pbrt');
piWrite(thisR, 'overwrite pbrt file', true,'overwrite resources',false);

%% Render with the Docker container

oi = piRender(thisR);

% Show it in ISET
ieAddObject(oi); oiWindow;   