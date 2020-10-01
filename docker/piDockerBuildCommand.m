function cmd = piDockerBuildCommand(outFile, inputFile, outputFolder,...
                                             dockerImageName, varargin)
% Generate docker command to run the docker container. 
% TODO: Fix the problem for Windows system.
%
% Synopsis:
%   cmd = piDockerBuildCommand(outFile, currFile, outputFolder,...
%                                              dockerImageName, varargin)
% 
% Inputs:
%   outFile         - path of the rendered output .dat file
%   inputFile       - path to the input .pbrt file to the docker image
%   outputFolder    - path to the directory folder which stores output file
%   dockerImageName - which docker to use
%
% Optional:
%   None
% 
% Outputs:
%   cmd             - generated command ready to run in
%                     terminal/commandwindow
%
%% Parse Inputs
p = inputParser;

p.addRequired('outFile', @ischar);
p.addRequired('inputFile', @ischar);
p.addRequired('outputFolder', @ischar);
p.addRequired('dockerImageName', @ischar);

p.parse(outFile, inputFile, outputFolder, dockerImageName, varargin{:});
outFile = p.Results.outFile;
inputFile = p.Results.inputFile;
outputFolder = p.Results.outputFolder;
dockerImageName = p.Results.dockerImageName;

%% Initialize the command base
dockerCommand   = 'docker run -ti --rm';

%%
if ispc  % Windows
    outF = strcat('renderings/',currName,'.dat');
    renderCommand = sprintf('pbrt --outfile %s %s', outF, strcat(currName, '.pbrt'));

    folderBreak = split(outputFolder, '\');
    shortOut = strcat('/', char(folderBreak(end)));

    if ~isempty(outputFolder)
        if ~exist(outputFolder,'dir'), error('Need full path to %s\n',outputFolder); end
        dockerCommand = sprintf('%s -w %s', dockerCommand, shortOut);
    end

    linuxOut = strcat('/c', strrep(erase(outputFolder, 'C:'), '\', '/'));

    dockerCommand = sprintf('%s -v %s:%s', dockerCommand, linuxOut, shortOut);

    cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, renderCommand);
else  % Linux & Mac
    renderCommand = sprintf('pbrt --outfile %s %s', outFile, inputFile);

    if ~isempty(outputFolder)
        if ~exist(outputFolder,'dir'), error('Need full path to %s\n',outputFolder); end
        dockerCommand = sprintf('%s --workdir="%s"', dockerCommand, outputFolder);
    end

    dockerCommand = sprintf('%s --volume="%s":"%s"', dockerCommand, outputFolder, outputFolder);

    cmd = sprintf('%s %s %s', dockerCommand, dockerImageName, renderCommand);
end
end