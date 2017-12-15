function outstruct=delimread(fpath,delim,outstyle,varargin)
% Function Description
%   This function reads delimited text files. Like xlsread, a range can be
%   specified in Excel A1 format. Ranges can also be row & column boundary
%   pairs. The results are broken out into numerical only, text only, and
%   raw output, in imitation of xlsread.
%   This is generally much faster than xlsread work well across all 
%   operating systems.
%
%   Motivation: in Matlab 2015a, xlsread 'basic' mode does not operate
%   on csv files or any other non-Excel files that can be opened in Excel.
%   On Linux or Mac systems, 'basic' mode is enforced exclusively.
%   Therefore, this is a great replacement for xlsread on non-excel files
%   to enable code to run correctly on all operating systems.
%
%   Copyright Kirby Fears, 2015
%
% DEPENDENCY
%   This function requires convertxlrange.m, which converts A1 excel ranges
%   to row/column boundary pairs.
%
% Function Call
%   outstruct=delimread(fpath,delim,outstyle)
%   Reads document specified by fpath using specified delimiters.
%   delim: should be specified as a string or cell array of strings with
%   one delimiter per string.
%   outstyle: should be a string or cell array of strings. Each string
%   should be a string in {'num', 'text', 'mixed', 'raw'}.
%   All data is initially parsed as strings, creating the 'raw' output.
%   Anything that can be converted using str2double is returned in 'num'
%   output. All raw outputs excluding those convertible to numbers are
%   returned in 'text'. All outputs are returned in 'mixed' with numerical
%   and char data mixed into one cell structure.
%   outstruct: a struct containing each specified outstyle as
%   outstruct.num, outstruct.text, etc.
%
%   outstruct=delimread(fpath,delim,outstyle,xlrange)
%   Reads portion of document specified by xlrange in Excel A1 format.
%
%   outstruct=delimread(fpath,delim,outstyle,rpair,cpair)
%   Reads file specified by     rpair = [minrow maxrow] and
%                               cpair = [mincol maxcol].
%   Both rpair and cpair must be specified if one is specified. You can use
%   blank matrix [] to read all rows or all columns. If a single row or
%   column is to be read, it can be specified as a scalar instead of a
%   min/max pair.
%

%% Settings
% Enhancement: these could be modified with name/value input pairs.
dropmode=3; % row/col dropping: 1 drop trailing, 2 drop leading, 3 both.
strfmt='%[^\n]'; % reads whole line verbatim as char
% You can change keywords, but positions 1:4 have hardcoded meaning.
styles={'num','text','mixed','raw'}; % Do not change.

%% Handling delimiter input
% Include carriage return \r as a mandatory delimiter. Prevents false 1x1
% tokens caused by \r\n line endings.
if ischar(delim),
    delim={delim;'\r'};
elseif iscell(delim),
    delim=[delim(:);{'\r'}];
else
    error('Invalid delimiter input.');
end,

%% Handling outstyle input
if ischar(outstyle),
    makestyle=strcmpi(outstyle,styles);
elseif iscell(outstyle),
    if all(cellfun(@(c)ischar(c),outstyle)),
        makestyle=cellfun(@(c)any(strcmpi(c,outstyle)),styles);
    else
        error('Invalid outstyle input.');
    end,
else
    error('Invalid outstyle input.');
end,
if ~any(makestyle),
    stylestring='';
    for s=1:numel(styles),
        stylestring=[stylestring ' ' styles{s}];
    end,
    error(['No valid output styles specified. Please specify ',...
        'at least one of:',stylestring]);
end,

%% Handling variable argument assignments.
nargs=numel(varargin);
switch nargs
    case 0
        rpair=[];
        cpair=[];
    case 1
        % Validate excel range format and get rows/cols.
        xlrange=convertxlrange(varargin{1});
        if ~xlrange.status,
            error('Invalid Excel range specified.');
        end,
        % Assign the converted rows and columns.
        rpair=xlrange.rows;
        cpair=xlrange.cols;
    case 2
        rpair=varargin{1};
        cpair=varargin{2};
    otherwise
        error('Too many input arguments.');
end

% Validate rpair.
throwerr=false;
if ~isempty(rpair),
    if ~isnumeric(rpair),
        throwerr=true;
    elseif numel(rpair)==1,
        rpair=[rpair rpair];
    elseif numel(rpair)==2,
    else
        throwerr=true;
    end,
end,
if throwerr,
    error('Invalid rpair input.');
end,
% Last check for valid numerical values.
if ~isempty(rpair),
    if rpair(1)>rpair(2) || rpair(1)<1,
        error('Invalid rpair input.');
    end,
end,

% Validate cpair.
throwerr=false;
if ~isempty(cpair),
    if ~isnumeric(cpair),
        throwerr=true;
    elseif numel(cpair)==1,
        cpair=[cpair cpair];
    elseif numel(cpair)==2,
    else
        throwerr=true;
    end,
end,
if throwerr,
    error('Invalid cpair input.');
end,
% Last check for valid numerical values.
if ~isempty(cpair),
    if cpair(1)>cpair(2) || cpair(1)<1,
        error('Invalid cpair input.');
    end,
end,

%% Main
fid=fopen(fpath);
if fid==-1,
    error(['File could not be opened: ',fpath]);
end,
% On cleanup, close file if open.
cleanup=onCleanup(@()mycleanup(fid));

% Handle each input style differently.
switch nargs,
    case 0
        % File and delimiter are specified. Nothing else.
        outdata=textscan(fid,strfmt);
        % Process by delimiter and drop extra rows/columns.
        outdata=cellfun(@(c)strsplit(c,delim,'CollapseDelimiters',false)',...
            outdata{1},'UniformOutput',false);
        % Pad to make square before stacking.
        maxcols=max(cellfun(@(c)numel(c),outdata));
        outdata=cellfun(@(c)[c;repmat({''},maxcols-numel(c),1)],...
            outdata,'UniformOutput',false);
        % Extract and stack inner cells.
        outdata=[outdata{:}]';
        outdata=dropBlankRows(outdata,dropmode);
        outdata=dropBlankCols(outdata,dropmode);
    otherwise
        if ~isempty(cpair),
            % Column range is specified.
            strfmt=[repmat('%*s ',1,cpair(1)-1),...
                repmat('%s ',1,cpair(2)-cpair(1)+1), '%*[^\n]'];
            if isempty(rpair),
                % Rows not specified.
                outdata=textscan(fid,strfmt,'Delimiter',...
                    delim,'CollectOutput',true);
                outdata=outdata{:};
                outdata=dropBlankRows(outdata,dropmode);
            else
                % Rows specified.
                outdata=textscan(fid,strfmt,rpair(2)-rpair(1)+1,...
                    'Delimiter',delim,'CollectOutput',true,...
                    'HeaderLines',rpair(1)-1);
                outdata=outdata{:};
            end,
        else
            % No columns specified.
            if isempty(rpair),
                % Rows not specified. Degenerates to case 0.
                outdata=textscan(fid,strfmt);
                outdata=cellfun(@(c)strsplit(c,delim,...
                    'CollapseDelimiters',false)',outdata{1},...
                    'UniformOutput',false);
                % Pad to make square before stacking.
                maxcols=max(cellfun(@(c)numel(c),outdata));
                outdata=cellfun(@(c)[c;repmat({''},maxcols-numel(c),1)],...
                    outdata,'UniformOutput',false);
                % Extract and stack inner cells.
                outdata=[outdata{:}]';
                outdata=dropBlankRows(outdata,dropmode);
                outdata=dropBlankCols(outdata,dropmode);
            else
                % Rows specified but not columns.
                outdata=textscan(fid,strfmt,rpair(2)-rpair(1)+1,...
                    'CollectOutput',true,'HeaderLines',rpair(1)-1);
                % Reuse post-read processing from case 0 to parse delims.
                outdata=cellfun(@(c)strsplit(c,delim,...
                    'CollapseDelimiters',false)',outdata{1},...
                    'UniformOutput',false);
                % Pad to make square before stacking.
                maxcols=max(cellfun(@(c)numel(c),outdata));
                outdata=cellfun(@(c)[c;repmat({''},maxcols-numel(c),1)],...
                    outdata,'UniformOutput',false);
                % Extract and stack inner cells.
                outdata=[outdata{:}]';
                outdata=dropBlankCols(outdata,dropmode);
            end,
        end,
end,
fclose(fid);

% Construct all outputs that have been requested in outdata struct.
outstruct=struct;
if makestyle(4),
    % Raw output.
    outstruct=setfield(outstruct,styles{4},outdata);
end
if any(makestyle(1:3)),
    outnum=cellfun(@(c)numconv(c),outdata);
    idxnum=~isnan(outnum);
    if makestyle(2),
        % Text only output.
        tempout=outdata;
        tempout(idxnum)={''};
        tempout=dropBlankRows(tempout,dropmode);
        tempout=dropBlankCols(tempout,dropmode);
        outstruct=setfield(outstruct,styles{2},tempout);
        clear tempout;
    end,
    if makestyle(3),
        % Mixed cell output.
        tempout=outdata;
        tempout(idxnum)=num2cell(outnum(idxnum));
        % Convert blank strings to NaN to comply with xlsread "raw".
        tempidx=cellfun(@(c)isempty(c),tempout);
        tempout(tempidx)={NaN};
        % Store output.
        outstruct=setfield(outstruct,styles{3},tempout);
        clear tempout;
    end,
    if makestyle(1),
        outnum=dropBlankRows(outnum,dropmode);
        outnum=dropBlankCols(outnum,dropmode);
        outstruct=setfield(outstruct,styles{1},outnum);
        clear outnum;
    end,
end,
end
%% Auxilliary functions
function outdata=dropBlankRows(outdata,dropmode)
% Outdata should be a cell array of strings or a numerical array.
% Use dropmode=1 to remove only trailing blank rows.
% Use dropmode=2 to remove only leading blank rows.
% Use dropmode=3 to remove both trailing and leading blank rows.

if isempty(outdata),
    return;
end,
inputclass=class(outdata);
if iscell(outdata),
    % for cell arrays of strings
    if any(dropmode==[1 3]),
        while size(outdata,1)>0,
            if all(strcmp(outdata(end,:),'')),
                outdata(end,:)=[];
            else
                break;
            end,
        end,
    end,
    if any(dropmode==[2 3]),
        while size(outdata,1)>0,
            if all(strcmp(outdata(1,:),'')),
                outdata(1,:)=[];
            else
                break;
            end,
        end,
    end,
elseif isnumeric(outdata),
    % for numerical arrays
    if any(dropmode==[1 3]),
        while size(outdata,1)>0,
            if all(isnan(outdata(end,:))),
                outdata(end,:)=[];
            else
                break;
            end,
        end,
    end,
    if any(dropmode==[2 3]),
        while size(outdata,1)>0,
            if all(isnan(outdata(1,:))),
                outdata(1,:)=[];
            else
                break;
            end,
        end,
    end,
else
    error(['Unexpected input type: ',inputclass]);
end,
end

function outdata=dropBlankCols(outdata,dropmode)
% Outdata should be a cell array of strings or a numerical array.
% Use dropmode=1 to remove only trailing blank cols.
% Use dropmode=2 to remove only leading blank cols.
% Use dropmode=3 to remove both trailing and leading blank cols.

if isempty(outdata),
    return;
end,
inputclass=class(outdata);
if iscell(outdata),
    % for cell arrays of strings
    if any(dropmode==[1 3]),
        while size(outdata,2)>0,
            if all(strcmp(outdata(:,end),'')),
                outdata(:,end)=[];
            else
                break;
            end,
        end,
    end,
    if any(dropmode==[2,3]),
        while size(outdata,2)>0,
            if all(strcmp(outdata(:,1),'')),
                outdata(:,1)=[];
            else
                break;
            end,
        end,
    end,
elseif isnumeric(outdata),
    % for numerical arrays
    if any(dropmode==[1 3]),
        while size(outdata,2)>0,
            if all(isnan(outdata(:,end))),
                outdata(:,end)=[];
            else
                break;
            end,
        end,
    end,
    if any(dropmode==[2 3]),
        while size(outdata,2)>0,
            if all(isnan(outdata(:,1))),
                outdata(:,1)=[];
            else
                break;
            end,
        end,
    end,
else
    error(['Unexpected input type: ',inputclass]);
end,

end

function mycleanup(fid)
try
    fclose(fid);
catch err1
end
end

function numpart=numconv(cellpart)
try
    numpart=str2double(cellpart);
    if isempty(numpart),
        numpart=NaN;
    end,
catch err2
    numpart=NaN;
end,
end