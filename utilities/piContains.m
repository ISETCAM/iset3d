function tf = piContains(str,pattern)
% Returns 1 (true) if str contains pattern, and returns 0 (false) otherwise.
%
% Synopsis:
%    tf = piContains(str,pattern)
%
% Description:
%    Work around for the Matlab contains function. Written so that it
%    will work with Matlab versions prior to those with contains().
%
% Inputs
%   str -  A cell array of strings (or a string)
%   pattern -  A string
%
% Returns
%   tf    A logical array for each entry in the cell array, according
%         to whether it contains the pattern
%
% DHB/ZL ISETBIO Team
%
% See also: contains, strfind
%   

% Examples
%{
   piContains('help','he')
   piContains('help','m')
   piContains({'help','he','lp'},'he')
%}

if(iscell(str))
    tf = zeros(1,length(str));
    
    % If cell loop through all entries.
    for ii = 1:length(str)
        currStr = str{ii};
        if (~isempty(strfind(currStr,pattern))) %#ok<*STREMP>
            tf(ii) = 1;
        else
            tf(ii) = 0;
        end
    end
else
    
    if (~isempty(strfind(str,pattern)))
        tf = 1;
    else
        tf = 0;
    end
    
end

tf = logical(tf);

end

