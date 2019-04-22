function [materiallib_updated] = piMateriallib
% A library of material properties
%
% Syntax:
%  materiallib = piMaterialib;
%
% Brief description:
%  All of the material definitions that we use in ISET3d are
%  represented in the materiallib.  This function creates the material
%  lib with the specific parameters for each type of material.
%
% Inputs:
%  N/A
%
% Outputs:
%  materiallib:  A structure with the different material definitions
%
% Description:
%
%  The PBRT material properties include the specular and diffuse and
%  transparency material properties.  The parameters to achieve these
%  effects are stored in this library for about a dozen different
%  material types.  The definitions of the slots are defined on the
%  PBRT web-site (https://www.pbrt.org/fileformat-v3.html#materials)
%
%  For the imported Cinema 4D scenes we know the material types of
%  each part, and ISET3d specifies in the recipe for each object an
%  object-specific name and a material type.  The reflectance and
%  other material properties are stored in this material library.
%
%  For example, if we want a particular part to look like, say
%  carpaint, we assign the materiallib.carpaint properties to that
%  object.
%
% Zhenyi Liu Scien Stanford, 2018
%
% See also
%   piMaterial*


% Examples:
%{
  
%}

%% carpaintmix
%
% A mixture of a specular (mirror like) material and a substrate
% material that looks like a car.

materiallib.carpaintmix.paint_mirror.string = 'mirror';
materiallib.carpaintmix.paint_mirror.rgbkr = [.1 .1 .1];
materiallib.carpaintmix.paint_base.string='substrate';
materiallib.carpaintmix.paint_base.colorkd = piColorPick('random');
materiallib.carpaintmix.paint_base.colorks =[.1 .1 .1];
materiallib.carpaintmix.paint_base.floaturoughness=0.01;
materiallib.carpaintmix.paint_base.floatvroughness=0.01;
materiallib.carpaintmix.carpaint.string = 'mix';
materiallib.carpaintmix.carpaint.amount = 0.5;
materiallib.carpaintmix.carpaint.stringnamedmaterial1 = 'paint_mirror';
materiallib.carpaintmix.carpaint.stringnamedmaterial2 = 'paint_base';
%% carpaint
%
% Typical car paint without much specularity.  Some people define it
% this way rather than as carpaintmix.
%

materiallib.carpaint.string='substrate';
materiallib.carpaint.rgbkd = piColorPick('random');
materiallib.carpaint.rgbks =[.15 .15 .15];
materiallib.carpaint.floaturoughness =0.0005;
materiallib.carpaint.floatvroughness=0.00051;

%% chrome_spd
%
% This the chrome metal appearance.
%
materiallib.chrome_spd.string='metal';
materiallib.chrome_spd.floatroughness=0.01;
materiallib.chrome_spd.spectrumk='spds/metals/Ag.k.spd';
materiallib.chrome_spd.spectrumeta='spds/metals/Ag.eta.spd';

%% blackrubber

% Good for tires
materiallib.blackrubber.floatroughness = 0.5;
materiallib.blackrubber.string = 'uber';
materiallib.blackrubber.rgbkd = [ .01 .01 .01 ];
materiallib.blackrubber.rgbks = [ 0.2 .2 .2 ];

%% mirror

materiallib.mirror.string='mirror';
materiallib.mirror.spectrumkr = [400 1 800 1];

%% matte

% Standard matte surface.  Only diffuse.
materiallib.matte.string = 'matte';

%% plastic

% Standard plastic appearance
%
materiallib.plastic.string = 'plastic';
materiallib.plastic.rgbkd = [0.25 0.25 0.25];
materiallib.plastic.rgbks = [0.25 0.25 0.25];
materiallib.plastic.floatroughness = 0.1;

%% glass

% Standard glass appearance
materiallib.glass.string = 'glass';
% materiallib.glass.rgbkr = [0.00415 0.00415 0.00415];
materiallib.glass.spectrumkr = [400 1 800 1];
materiallib.glass.spectrumkt = [400 1 800 1];
materiallib.glass.eta = 1.5;

%% Retroreflective

materiallib.retroreflective.string = 'retroreflective';

%% Uber

materiallib.uber.string = 'uber';

%% translucent

materiallib.translucent.string = 'translucent';
materiallib.translucent.colorreflect = [0.5 0.5 0.5];
materiallib.translucent.colortransmit = [0.5 0.5 0.5];

%% substrate

% Human skin is assigned this material.
materiallib.substrate.string = 'substrate';

%% fourier

materiallib.fourier.string = 'fourier';
materiallib.fourier.bsdffile = 'bsdfs/roughglass_alpha_0.2.bsdf';
%%
materiallib_updated = piMaterialEmptySlot(materiallib);
end

function materiallib = piMaterialEmptySlot(materiallib)
% Empty the unused material slot for certain type of material, for example,
% mirror is only defined by reflectivity, since the default material
% includes values for unused parameters, in this case, we should empty the
% slots except Kr(reflectivity) to avoid errors when rendering.
thisMaterial = fieldnames(materiallib);
for ii = 1: length(thisMaterial)
    if isfield(materiallib.(thisMaterial{ii}), 'string')
    switch materiallib.(thisMaterial{ii}).string
        case 'glass'
            materiallib.(thisMaterial{ii}).floatroughness = [];
            materiallib.(thisMaterial{ii}).rgbkr = [];
            materiallib.(thisMaterial{ii}).rgbks = [];
            materiallib.(thisMaterial{ii}).rgbkd = [];
            materiallib.(thisMaterial{ii}).rgbkt = [];
        case 'metal'
            materiallib.(thisMaterial{ii}).floatroughness = [];
            materiallib.(thisMaterial{ii}).rgbkr = [];
            materiallib.(thisMaterial{ii}).rgbks = [];
            materiallib.(thisMaterial{ii}).rgbkd = [];
            materiallib.(thisMaterial{ii}).rgbkt = [];
        case 'mirror'
            materiallib.(thisMaterial{ii}).floatroughness = [];
            materiallib.(thisMaterial{ii}).rgbkr = [];
            materiallib.(thisMaterial{ii}).rgbks = [];
            materiallib.(thisMaterial{ii}).rgbkd = [];
            materiallib.(thisMaterial{ii}).rgbkt = [];
        case 'substrate'
            materiallib.(thisMaterial{ii}).floatroughness = [];
            materiallib.(thisMaterial{ii}).rgbkr = [];
            materiallib.(thisMaterial{ii}).rgbkt = [];
            materiallib.(thisMaterial{ii}).stringnamedmaterial1 = [];
            materiallib.(thisMaterial{ii}).stringnamedmaterial2 = [];
        case 'fourier'
            materiallib.(thisMaterial{ii}).floatroughness = [];
            materiallib.(thisMaterial{ii}).rgbkr = [];
            materiallib.(thisMaterial{ii}).rgbks = [];
            materiallib.(thisMaterial{ii}).rgbkd = [];
            materiallib.(thisMaterial{ii}).rgbkt = [];
        case 'translucent'
            materiallib.(thisMaterial{ii}).floatroughness = [];
            materiallib.(thisMaterial{ii}).rgbkr = [];
            materiallib.(thisMaterial{ii}).rgbkt = [];
        case 'mix'
            materiallib.(thisMaterial{ii}).floatroughness = [];
            materiallib.(thisMaterial{ii}).rgbkr = [];
            materiallib.(thisMaterial{ii}).rgbks = [];
            materiallib.(thisMaterial{ii}).rgbkd = [];
            materiallib.(thisMaterial{ii}).rgbkt = []; 
    end
    else
        continue
    end
end
end
