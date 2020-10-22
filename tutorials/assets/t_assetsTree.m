%% init
ieInit;

%% 
t = tree('root');

%% Create a 'node' asset node
node = piAssetCreate('type', 'node');

%% Create an 'object' asset node
object = piAssetCreate('type', 'object');

%% Create a 'light' asset node
light = piAssetCreate('type', 'light');

%% add nodes
[t, nID] = t.addnode(1, node);
% disp(t.tostring)
[t, oID] = t.addnode(nID, object);
[t, lID] = t.addnode(nID, light);
% disp(t.tostring)

%% get nodes
nodeGet = t.get(nID);
objectGet = t.get(oID);
lightGet = t.get(lID);

%% Get the parent of a node
pId = t.getparent(oID);
t.get(pId)

%%
sId = t.getsiblings(lID)
t.get(sId(1))
t.get(sId)

%% Add another node
[t, nID2] = t.addnode(nID, node);
% disp(t.tostring)

%% Get siblings
sIDs = t.getsiblings(nID)
t = t.removenode(5);
disp(t.tostring)

%% 
nodeID = piAssetFind(t, 'name', 'light');