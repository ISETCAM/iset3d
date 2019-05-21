%% Render a cornell box
%
%
% Zhenyi, SCIEN
ieInit;
if ~piDockerExists, piDockerConfig; end
%% Read a cornell box pbrt file
sceneName = 'cornell_box';
filename = fullfile(piRootPath, 'data', 'V3', sceneName, [sceneName, '.pbrt']);
thisR = piRead(filename);
%% Check information of thisR
thisR.summarize;
%% Add an area light at predefined region
% Default light spectrum is D65
thisR = piLightAdd(thisR, 'type', 'area', 'lightspectrum', 'Tungsten');
%%
filmRes = thisR.get('film resolution');
thisR.set('film resolution',filmRes/1.5);
thisR.set('pixel samples',16);
thisR.set('nbounces',5);
thisR.integrator.subtype ='directlighting'; 
%%
piWrite(thisR, 'creatematerials', true);
scene = piRender(thisR, 'rendertype', 'radiance');
sceneWindow(scene);
%% Add another point light
thisR = piLightAdd(thisR, 'type', 'point', 'from',[-0.25,-0.25,1.68]);
piWrite(thisR, 'creatematerials', true);
[scene, result] = piRender(thisR, 'rendertype', 'radiance');
sceneWindow(scene);

%% Change light to D65
lightsource = piLightGet(thisR);
piLightDelete(thisR, lightsource,'all');
thisR = piLightAdd(thisR, 'type', 'area', 'lightspectrum', 'D65');
