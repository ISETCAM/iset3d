function assetsPlaced = piBuildingPlace(assetsList,buildingPosList)
%% For building assets, place the assets exactly by names
%
%
%
%
%%
for ii = 1: length(buildingPosList)
    PosList{ii} = buildingPosList(ii).name;
end
PosListCheck = unique(PosList);
for kk = 1:length(PosListCheck)
    count = 1;
    for jj = 1: length(PosList)
        if isequal(PosListCheck(kk),PosList(jj))
            buildingPosList_tmp(kk).name = PosListCheck(kk);
            buildingPosList_tmp(kk).count = count;
            count = count+1;
        end
    end
end
%asset = buildingList.building;
asset = assetsList;
for ii = 1: length(buildingPosList_tmp)
%     gg=1;
    % if ~isequal(buildingPosList_tmp(ii).count,1)
    n = buildingPosList_tmp(ii).count;
    for hh = 1: length(asset(ii).geometry)
        
        for dd = 1: length(asset)
            if isequal(asset(dd).geometry.name,buildingPosList_tmp(ii).name{1})
                assets_updated(ii) = asset(dd);
                pos = asset(dd).geometry(hh).position;
                rot = asset(dd).geometry(hh).rotate;
                asset(dd).geometry(hh).position = repmat(pos,1,uint8(buildingPosList_tmp(ii).count));
                asset(dd).geometry(hh).rotate = repmat(rot,1,uint8(buildingPosList_tmp(ii).count));
                position=cell(n,1);
                rotationY=cell(n,1);
                gg=1;
                for jj = 1:length(buildingPosList)
                    if isequal(buildingPosList_tmp(ii).name{1},buildingPosList(jj).name)
                        position{gg} = buildingPosList(jj).position;
                        rotationY{gg} = buildingPosList(jj).rotate;
                        gg = gg+1;
                    end
                end
                assets_updated(ii).geometry = piAssetTranslate(asset(dd).geometry,position,'Pos_demention',n);
                assets_updated(ii).geometry = piAssetRotate(assets_updated(ii).geometry,'Y',rotationY,'Pos_demention',n);
            end
        end
    end
    % end
end
assetsPlaced = assets_updated;
% the reason why we keep this part seperate is that when we need to check which
% buidling does not look correct in rendered image, we want to know the
% exact asset name, instead of the class name ---zhenyi
% debug --09/30
for jj = 1:length(assetsPlaced)
    if ~isequal(lower(assetsPlaced(jj).geometry.name),'camera') && ...
            ~piContains(lower(assetsPlaced(jj).geometry.name),'light')
        name = assetsPlaced(jj).geometry.name;
        assetsPlaced(jj).geometry.name = sprintf('building_%s',name);
    end
end
end