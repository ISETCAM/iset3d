function [assetsPosList,assets] = piAssetPlace(trafficflow,varargin)
%%
% Place assets with the Sumo trafficflow information
% Sumo generates trafficflow with timesteps, we choose one or multiple
% timestamps, find the number and the class of vehicles for this/these
% timestamp(s) on the road. Download assets with respect to the number and
% class.
%
%
%
%
%
%
%  Zhenyi
%%
p = inputParser;

p.addParameter('nScene',1);
p.addParameter('timestamp',[]);
p.addParameter('trafficlight','red');

p.parse(varargin{:});

nScene =p.Results.nScene;
timestamp = p.Results.timestamp;
trafficlight = p.Results.trafficlight;

%% Download asssets with respect to the number and class of Sumo output.
if isfield(trafficflow(timestamp).objects,'car')
    ncars = length(trafficflow(timestamp).objects.car);
else ncars = 0;end

if isfield(trafficflow(timestamp).objects,'pedestrian')
    nped = length(trafficflow(timestamp).objects.pedestrian);
else nped = 0;end

assets = piAssetCreate('ncars',ncars,'nped',nped);

% if isfield(lower(trafficflow(timestamp).objects),'bus')
% nBuses = trafficflow(timestamp).objects.Bus;
% assets_bus = piAssetCreate('nbus',nbuses);end
%% objects positions are classified by class, building/trees might be different.
assets_updated = assets;

if nScene == 1
    assetClassList = fieldnames(assets);
    for hh = 1: length(assetClassList)
        assetClass = assetClassList{hh};
        index = 1;
        for ii = 1: length(assets.(assetClass))
            
            [~,n] = size(assets.(assetClass)(ii).geometry(1).position);
            position=cell(n,1);
            rotation=cell(n,1);
            for gg = 1:n
                position{gg} = trafficflow(timestamp).objects.(assetClass)(index).pos;
                rotation{gg} = trafficflow(timestamp).objects.(assetClass)(index).orientation-90;
                index = index+1;
            end
            assets_updated.(assetClass)(ii).geometry = piAssetTranslate(assets.(assetClass)(ii).geometry,position,'Pos_demention',n);
            assets_updated.(assetClass)(ii).geometry = piAssetRotate(assets_updated.(assetClass)(ii).geometry,rotation,'Pos_demention',n);
        end
    end
    %
    %     if isfield(assets, 'pedestrian')
    %         for ii = 1: length(assets.pedestrian)
    %             [~,n] = size(assets.pedestrian(ii).geometry(1).position);
    %             position=cell(n,1);
    %             rotation=cell(n,1);
    %             for gg = 1:n
    %                 position{gg} = trafficflow(timestamp).objects.pedestrian(ii+gg-1).pos;
    %                 rotation{gg} = -trafficflow(timestamp).objects.pedestrian(ii+gg-1).orientation-90;
    %             end
    %             %             carPos = assets.car(ii).geometry.position(:,n);
    %             assets_updated.pedestrian(ii).geometry = piAssetTranslate(assets.pedestrian(ii).geometry,position,'Pos_demention',n);
    %             assets_updated.pedestrian(ii).geometry = piAssetRotate(assets_updated.pedestrian(ii).geometry,rotation,'Pos_demention',n);
    %         end
    %     end
    assetsPosList{1} = assets_updated;
    % else
    % % Generate random multiple scenes
    % timestampList = randperm(length(trafficflow),nScene);
    % for kk = 1: length(timestampList)
    %     if isfield(assets, 'car')
    %         for ii = 1: length(assets.car)
    %             position = trafficflow(timestampList(kk)).objects.car(ii).pos;
    %             assets_updated.car(ii).geometry = piAssetTranslate(assets.car(ii).geometry,position);
    %             rotation = -trafficflow(timestampList(kk)).objects.car(ii).orientation-90;
    %             assets_updated.car(ii).geometry = piAssetRotate(assets_updated.car(ii).geometry,rotation);
    %         end
    %     end
    %     if isfield(assets, 'pedestrian')
    %         for ii = 1: length(assets.pedestrian)
    %             position = trafficflow(timestampList(kk)).objects.pedestrian(ii).pos;
    %             assets_updated.pedestrian(ii).geometry = piAssetTranslate(assets.pedestrian(ii).geometry,position);
    %             rotation = -trafficflow(timestampList(kk)).objects.pedestrian(ii).orientation-90;
    %             assets_updated.pedestrian(ii).geometry = piAssetRotate(assets_updated.pedestrian(ii).geometry,rotation);
    %         end
    %     end
    % end
    % end
end



