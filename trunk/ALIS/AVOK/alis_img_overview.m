function [scrhndl] = alis_img_overview(ov_filename,f_filename,PO,print_or_what)
% ALIS_IMG_OVERVIEW - make ALIS data overview-plots by scanning OVERVIEW-files and INDEX-files
%   Works for file structure that I have on my PC -
%   sorry. Esentially superceeded by Peter Rydesaters data-base.
% 
% Calling:
% [scrhndl] = alis_img_overview(ov_filename,f_filename,PO,print_or_what)
% 
% OV_FILENAME - string with OVERVIEW file name to scan,
% F_FILENAME - string with INDEX file name that hold the
%              correspondning image file names.
% PO - PRE_PROC_OPS struct see TYPICAL_PRE_PROC_OPS
% PRINT_OR_WHAT - 1 for feeding the plot directly to printer, 0
%                 just pauses - then printin/saving is possible by
%                 the graphical interface.
%
% See also ALIS_OVERVIEW for a more current version

% Copyright Bjorn Gustavsson 20050112



PREPROC_OPS = PO;

get_time = 0;
colormap(bone)
orient tall

ovfid=fopen(ov_filename,'r');
fvfid=fopen(f_filename,'r')
indx = 0;
iii = 1;
ovline = fgetl(ovfid);
pline_indx = 1;
while ( 1 )
  
  ovline = fgetl(ovfid);
  if ~isstr(ovline),
    return,
  end
  
  if ( strncmp(ovline(1:5),'-----',5) )
    get_time = 1;
    skip_rest = 1;
    if ( indx ~= 0 )
      pline_indx = pline_indx + 1;
      if 7*(pline_indx-1)-6 == 1
        ops.datetitle = 1;
      else
        ops.datetitle = 0;
      end
      mysubplot(5,7,7*(pline_indx-1)-6)
      overviewplot(STN,AZ,ZE,FRG,tidstr,ops);
      set(gca,'yticklabel','')
      set(gca,'xticklabel','')
      clear STN AZ ZE FRG
      iii = 1;
      if ( pline_indx == 6 )
        mysubplot(5,7,2)
        set(gca,'yticklabel','')
        set(gca,'xticklabel','')
        title('S01','fontsize',18,'fontweight','bold')
        axis off
        mysubplot(5,7,3)
        set(gca,'yticklabel','')
        set(gca,'xticklabel','')
        title('S02','fontsize',18,'fontweight','bold')
        axis off
        mysubplot(5,7,4)
        set(gca,'yticklabel','')
        set(gca,'xticklabel','')
        title('S03','fontsize',18,'fontweight','bold')
        axis off
        mysubplot(5,7,5)
        set(gca,'yticklabel','')
        set(gca,'xticklabel','')
        title('S04','fontsize',18,'fontweight','bold')
        axis off
        mysubplot(5,7,6)
        set(gca,'yticklabel','')
        set(gca,'xticklabel','')
        title('S05','fontsize',18,'fontweight','bold')
        axis off
        mysubplot(5,7,7)
        set(gca,'yticklabel','')
        set(gca,'xticklabel','')
        title('S06','fontsize',18,'fontweight','bold')
        axis off
        drawnow
        if print_or_what
          print -dpsc2
        else
          disp('Press any key to continue')
          pause
        end
        pline_indx = 1;
        clf
      end
    end
  end
  disp(ovline)
  if ( get_time == 1 & skip_rest == 0 )
    subplot
    [datestr,ovline] = strtok(ovline);
    [timestr,ovline] = strtok(ovline);
    get_time = 0;
    tidstr = [datestr,' ',timestr];
    indx = indx+1;
  end
  if ( skip_rest == 0 )
    [stn,ovline] = strtok(ovline);
    [str,ovline] = strtok(ovline);
    [frgstr,ovline] = strtok(ovline);
    [azstr,ovline] =  strtok(ovline);
    [zestr,ovline] =  strtok(ovline);
    STN(iii) = str2num(stn);
    Az = str2num(azstr);
    if isempty(Az)
      AZ(iii) = 0;
    else
      AZ(iii) = Az;
    end
    Ze = str2num(zestr);
    if isempty(Ze)
      ZE(iii) = 0;
    else
      ZE(iii) = Ze;
    end
    % read image filename from the index.txt file
    fline = fgetl(fvfid);
    if ~isstr(fline),
      return,
    end
    if strcmp(fline(1),'*')
      fline = fgetl(fvfid);
    end
    [q,fline] = strtok(fline,' '); %read away the timestring
    filename = [strtok(fline,' '),'.raf'];
    if strncmp(filename,'9',1)
      filename = ['19',filename];
    end
    %load the image and do som preprocessing
    [img_in,head] = inimg(lower(filename),PREPROC_OPS);
    %have to read stn directly from, image header hrmph
    obs = try_to_be_smart(head,1);
    if min(size(img_in))>257
      img_in = img_in(1:2:end,1:2:end)+...
               img_in(1:2:end,2:2:end)+...
               img_in(2:2:end,1:2:end)+...
               img_in(2:2:end,2:2:end);
    end
    if min(size(img_in))>257
      img_in = img_in(1:2:end,1:2:end)+...
               img_in(1:2:end,2:2:end)+...
               img_in(2:2:end,1:2:end)+...
               img_in(2:2:end,2:2:end);
    end
    img_in = img_in-min(img_in(:));
    clear img_out
    if (strcmp(frgstr,'5577')|strcmp(frgstr,'5590'))
      FRG{iii} = [0 1 0];
    elseif (strcmp(frgstr,'4278') | strcmp(frgstr,'4285'))
	FRG{iii} = [0 .3 1];
    elseif (strcmp(frgstr,'6300') | strcmp(frgstr,'6310'))
      FRG{iii} = [1 0 0];
    elseif (strcmp(frgstr,'8446') | strcmp(frgstr,'8455'))
      FRG{iii} = [.7 0 0];
    else
      FRG{iii} = [0 0 0];
      img_out = img_in;
    end
    
    if ( abs(obs.filter - 5577 ) <100 )
      img_out(:,:,2) = img_in/max(img_in(:));
      img_out(:,:,3) = 0*img_out(:,:,1);
    elseif ( abs( obs.filter - 4278 ) < 100 )
      img_out(:,:,3) = img_in/max(img_in(:));
    elseif ( abs( obs.filter - 6300 ) < 50 )
      img_out(:,:,1) = img_in/max(img_in(:));
      img_out(:,:,2) = 0*img_in/max(img_in(:));
      img_out(:,:,3) = 0*img_out(:,:,1);
    elseif ( abs( obs.filter - 8446 ) < 50 )
      img_out(:,:,1) = 0.7*img_in/max(img_in(:));
      img_out(:,:,2) = 0*img_in/max(img_in(:));
      img_out(:,:,3) = 0.1*img_out(:,:,1);
    else
      img_out = img_in;
    end
    
    mysubplot(5,7,1+obs.station+7*(pline_indx-1))
    imagesc(img_out),axis xy,
    set(gca,'yticklabel','')
    set(gca,'xticklabel','')
    iii = iii + 1;
    
  end % if ( skip_rest == 0 )
  
  skip_rest = 0;
  
end % while ( 1 )


fclose(ovfid);
fclose(fvfid);
OK = 1;
scrhndl = uicontrol('style','slider','position',[225 90 15 780]);
set(scrhndl,'position',[225 90 15 780])
set(scrhndl,'Max',0,'min',-indx,'value',0)
set(scrhndl,'sliderstep',[1/abs(indx),15/(abs(indx))])
set(scrhndl,'callback','axis([-2 1 get(scrhndl,''value'')-15 get(scrhndl,''value'')])')
