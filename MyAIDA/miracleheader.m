function h=miracleheader(filename)
%% h=miracleheader(filename)
%%
%% MIRACLE ASC header of <filename>
%% formatted as struct of text strings
%% with field names corresponding to header field names
%% but with brackets and hyphens stripped, as field names
%% cannot contain Matlab operators.
%%
%% CFE 2010, 2011
%%
%% NB: The fields of h contain text strings!
%% To get numerical values use eval()
%% e.g. 
%% h=miracleheader(some_file);
%% exposure=eval(h.Exposures);

%Get file png metadata
hh=imfinfo(filename);
h1=hh.OtherText; %CHECK: expected format of h ???

%Build struct header.keyword='value' (NB: strings)
%In this way sorting and searching can be avoided.
vals={h1{:,2}};
keywords={h1{:,1}};

%workaround: no "operators" or brackets allowed in struct field names
keywords=strrep(keywords,'(','');
keywords=strrep(keywords,')','');
keywords=strrep(keywords,'-','');

%Header struct
h=cell2struct(vals,keywords,2);

%%%
