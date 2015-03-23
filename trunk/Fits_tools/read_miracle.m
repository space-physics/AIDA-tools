function [d,h,o] = read_miracle(filename)
% READ_miracle - reads MIRACLE ASC jpg or png images
% Calling:
%   [d,h,o] = read_miracle(filename)
% Input:
%   filename - filename either a string with name of file (either
%              relative of full path to file) or a struct from the
%              'dir' command (then care have to be taken that the
%              filename.name points to the file i.e. give the full path)
% Output:
%   d - data, [NxN] sized double array
%   o - observation details (time, filter, station position,
%       exposure time, camera and station number)
%       structure
%   h - header containing the metadata for png files 
%
%% CFE 20100326, 2012


if isstruct(filename) 
  filename=filename.name; 
end 

fi=imfinfo(filename);
d=imread(filename);
d=double(d);

switch fi.Format
  case 'png'
    %Only EMCCD for now, add colour camera routines
 
    h=fi.OtherText;
    o=miracle_emccd_obs(h); 
    
  case 'jpg'
 
    h=[]; %JPG files have no headers
    o=miracle_iccd_obs(filename);
 
    %Remove the text field, it is of no use for starcal
    wd=size(d,2);
    if size(d,1)>wd

        %text field
        ho=22; %remove grayscale bar
        vc=420; %cut "compass"
        textfield=d(wd+ho:end,1:vc);
        
        %image area
        d=d(1:wd,:); %assumes height should be equal to width
    
    end
        
    % Try character recognition on text field
    [ex,ocrcmd]=system('which gocr');
    if(ex==0) % GOCR is installed
 
        %Write to PGM file with black text on white
        imwrite(255-uint8(textfield),'tmp_txt.pgm'); 
        
        %Extract the text
        %Cheating: gocr sees the colons in UT time as = signs
        [ex,htxt]=system('gocr tmp_txt.pgm -s 10 | sed s/=/:/g'); 
        %Cut out time, date, filter and exposure time
        ht=regexp(htxt,'(.* UTC)','match','once');
        hd=regexp(htxt,'(\d\d \w+ \d\d\d\d)','match','once');
        hf=regexp(htxt,'(Filter: .* nm)','match','once');
        he=regexp(htxt,'(Exposure: .* ms)','match','once');
        
        h=sprintf('Date: %s\nTime: %s\n%s\n%s\n',hd,ht,hf,he);
        delete('tmp_txt.pgm')

        %Uncomment to use these instead of metadata from filename
        %It is not reliable at this stage
        % o.exptime=str2num(regexp(he,'(\d+)','match','once'));
        % o.filter=str2num(regexp(hf,'(\d+)','match','once'));
        % dd=datenum([hd,' ',ht]);
        % o.date=datevec(dd);
    end
    
  otherwise
    error('File not in MIRACLE format')
end

%%%EOF