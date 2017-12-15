function outrange=convertxlrange(rangestr)
% Function Description
%   This function converts excel A1 range strings such as 'A5:B10' into row
%   and column pairs that convey the same information in Matlab-friendly
%   row and column boundaries. For example, 'A5:B10' is converted to 
%                                           outrange.rows=[5 10]
%                                           outrange.cols=[1 2]
%
%   This allows for simple extraction of the desired region from cell or
%   numerical arrays.
%
%   Copyright Kirby Fears, 2015
%
%
% Function Call
%   function outrange = convertxlrange(rangestr)
%   
%   Input: rangestr should be a character string representing a valid A1
%   Excel range. 
%
%   Output: outrange is a struct with outrange.status = bool
%                                     outrange.rows   = [startrow endrow]
%                                     outrange.cols   = [startcol endcol]
%                                     
%           Empty matrix can be returned for rows or cols independently.
%           The outrange.status is true if a valid A1 range is provided in
%           rangestr and false otherwise.
%           If an invalid Excel range is provided, outrange.rows and
%           outrange.cols are both empty matrices.
%           If the start row (or col) is greater than the end row (or col),
%           the rows and columns are returned as is (not necessarily
%           empty), and the status is returned as false.
%
%   Examples:
%   outrange=convertxlrange('A1:B2');
%     status: 1
%       rows: [1 2]
%       cols: [1 2]
%
%	Using these outputs, the desired parts of an array can be selected as follows:
%	selection=samplearray(outrange.rows(1):outrange.rows(2),...
%				outrange.cols(1):outrange.cols(2));
%
%   outrange=convertxlrange('A:BC');
%     status: 1
%       rows: []
%       cols: [1 55]
%
%   outrange=convertxlrange('5:25');
%     status: 1
%       rows: [5 25]
%       cols: []
%
%   outrange = convertxlrange('Oh:my');
%     status: 0
%       rows: []
%       cols: [398 363]

outrange.status=true;
if ischar(rangestr),
    % Range is a simple char string.
    if numel(rangestr)>=3,
        % Range has at least 3 characters.
        idxcolon=(rangestr==':');
        if (sum(idxcolon)==1) && ~any(idxcolon([1 end])),
            % There is exactly 1 colon, not first or last char.
            leftcell=rangestr(1:find(idxcolon)-1);
            % Test left cell validity
            idxleftletter=isletter(leftcell);
            idxleftnumber=isstrprop(leftcell,'digit');
            if all(idxleftletter|idxleftnumber),
                % All characters are letters or numbers.
                if any(idxleftletter)&&any(idxleftnumber),
                    % If numbers and letters, confirm letters are first.
                    if find(idxleftletter,1,'last')>find(idxleftnumber,1),
                        outrange.status=false;
                    end,
                end,
            else
                outrange.status=false;
            end,
            
            rightcell=rangestr(find(idxcolon)+1:end);
            % Test right cell validity
            idxrightletter=isletter(rightcell);
            idxrightnumber=isstrprop(rightcell,'digit');
            if all(idxrightletter|idxrightnumber)
                % All characters are letters or numbers.
                if any(idxrightletter)&&any(idxrightnumber),
                    % If numbers and letters, confirm letters are first.
                    if find(idxrightletter,1,'last')>find(idxrightnumber,1),
                        outrange.status=false;
                    end,
                end,
            else
                outrange.status=false;
            end,
        else
            outrange.status=false;
        end,
    else
        outrange.status=false;
    end,
else
    outrange.status=false;
end,

% If nothing's invalid yet, do additional rightside/leftside checks.
if outrange.status,
    if any(idxleftletter)~=any(idxrightletter),
        % Letters on one side but not the other.
        outrange.status=false;
    elseif any(idxleftnumber)~=any(idxrightnumber),
        % Numbers on one side but not the other.
        outrange.status=false;
    end,
end,

if ~outrange.status,
    outrange.rows=[];
    outrange.cols=[];
    warning(['Invalid Excel range specified in rangestr.'...
        ' Blank output returned.']);
else
    % Return row and column min/max pairs
    temprange=getxlrange(rangestr);
    outrange.rows=temprange.rows;
    outrange.cols=temprange.cols;
    clear temprange;
    if ~isempty(outrange.rows)&&(outrange.rows(1)>outrange.rows(2)),
        warning('Start row greater than end row. See output.rows.');
        outrange.status=false;
    end,
    if ~isempty(outrange.cols)&&(outrange.cols(1)>outrange.cols(2)),
        warning('Start column greater than end column. See output.cols.');
        outrange.status=false;
    end,
end,
end

function outrange=getxlrange(rangestr)
    rangeparts = regexp(rangestr, ':', 'split');
    
    % Create row range.
    rowparts=cellfun(@(r) r(isstrprop(r,'digit')),rangeparts,...
        'UniformOutput',false);
    if isempty(rowparts{1}),
        outrange.rows=[];
    else
        outrange.rows=[str2double(rowparts{1}) str2double(rowparts{2})];
    end,
    
    % Create column range.
    colparts=cellfun(@(p) p(isletter(p)),rangeparts,'UniformOutput',false);
    if isempty(colparts{1}),
        outrange.cols=[];
    else
        leftpartn=double(upper(colparts{1}))-64;
        rightpartn=double(upper(colparts{2}))-64;
        col1=leftpartn*26.^(numel(leftpartn)-1:-1:0)';
        col2=rightpartn*26.^(numel(rightpartn)-1:-1:0)';
        outrange.cols=[col1 col2];
    end,
end