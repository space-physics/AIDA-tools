import java.awt.*;
import java.awt.event.*;
import java.io.*;
import ij.*;
import ij.io.*;
import ij.process.*;
import ij.plugin.PlugIn;
import ij.plugin.frame.Editor;


public class Open_SIF implements PlugIn {

	public void run(String arg) {
		OpenDialog od = new OpenDialog("Open SIF...", arg);
		String file = od.getFileName();
		if (file == null) return;
		String directory = od.getDirectory();
		ImagePlus imp = open(directory, file);
		if (imp != null ) {
			imp.show();
		} else {
			IJ.showMessage("Open SIF...", "Failed.");
		}
	}

	public static ImagePlus open(String directory, String file) {
		boolean showInfoMessage = true;
		byte b;
		int MAXBYTES = 1000;
		int i, index, offset=0, mod, keepreading;
		int left = 1, right = 512, bottom = 1, top = 512;
		int height, width, stacksize = 1;
		int Xbin = 1, Ybin = 1;
		String str = "  ", temperature = "", acquisitionMode = "", exposureTime = "", Xbin_s = "", Ybin_s = "", EMGain = "", amplifierGain = "";
	    
		File f = new File(directory, file);
		try {
			byte[] byte_buffer = new byte[MAXBYTES];
			int byteOrMinus1;
			offset = 0;
			FileInputStream in = new FileInputStream(f);
			// skip through the first lines of the header. 
			for (i = 0; i < 2; i++){
				while((keepreading = in.read()) != 10) {
					offset++;
				}
				offset++;
			}

			//line 3
			index = 0;
			for (i = 0; str.length() != 0; i++) {

				// collect until you hit a space or new line
				while((byteOrMinus1 = in.read()) != 32 && byteOrMinus1 != 10) {
					b = (byte) byteOrMinus1;
					offset++;
					byte_buffer[index]=b;
					index++;
				}
				str = new String(byte_buffer, 0, index);

				// digest if needed
				if (i == 5)
				 	temperature = str;
				if (i == 12)
				 	exposureTime = str;
				if (i == 21)
				 	EMGain = str;
				index = 0;
				offset++;
			}

			// skip through the first section of the header. 
			for (i = 0; i < 17; i++) {
				while((keepreading = in.read()) != 10) {
					offset++;
				}
				offset++;
			}
			
			// now read out the size information in the image header
			//line 20
			index = 0;
			for (i = 0; i < 7; i++) {
				// collect until you hit a space or new line
				while((byteOrMinus1 = in.read()) != 32 && byteOrMinus1 != 10){
					b = (byte) byteOrMinus1;
					offset++;
					byte_buffer[index] = b;
					index++;
				}
				// digest if needed
				if (i == 6){
				 	String stacksize_s = new String(byte_buffer, 0, index);
					Integer stacksize_i = new Integer(Integer.parseInt(stacksize_s));
					stacksize = stacksize_i.intValue();
				}				
				index = 0;
				offset++;
			}

			//line 21
			index = 0;
			for (i = 0; i < 11; i++) {
				// collect until you hit a space or new line
				while((byteOrMinus1 = in.read()) != 32 && byteOrMinus1 != 10){
					b = (byte) byteOrMinus1;
					offset++;
					byte_buffer[index]=b;
					index++;
				}
				// digest if needed
				if (i == 4){
					String left_s = new String(byte_buffer, 0, index);
					Integer left_i = new Integer(Integer.parseInt(left_s));
					left = left_i.intValue();
				}
				if (i == 5){
					String top_s = new String(byte_buffer, 0, index);
					Integer top_i = new Integer(Integer.parseInt(top_s));
					top = top_i.intValue();
				}
				if (i == 6){
					String right_s = new String(byte_buffer, 0, index);
					Integer right_i = new Integer(Integer.parseInt(right_s));
					right = right_i.intValue();
				}
				if (i == 7){
					String bottom_s = new String(byte_buffer, 0, index);
					Integer bottom_i = new Integer(Integer.parseInt(bottom_s));
					bottom = bottom_i.intValue();
				}

				if (i == 8){
					Ybin_s = new String(byte_buffer, 0, index);
					Integer Ybin_i = new Integer(Integer.parseInt(Ybin_s));
					Ybin = Ybin_i.intValue();
				}	
				if (i == 9){
					Xbin_s = new String(byte_buffer, 0, index);
					Integer Xbin_i = new Integer(Integer.parseInt(Xbin_s));
					Xbin = Xbin_i.intValue();
				}	
				index = 0;
				offset++;
			}

			width = right-left+1;
			mod = width%Xbin;
			width = (width-mod)/Ybin;
			height = top-bottom+1;
			mod = height%Ybin;
			height = (height-mod)/Xbin;

			/*
			The rest of the file is a time stamp for the frame followed 
			new line. 
			*/
			offset = offset+2*stacksize;	
			if (showInfoMessage){
				IJ.showMessage(file, "Image height is "+height+".\nImage width is "+width+".\nStacksize is "+stacksize+".\nOffset is "+offset+".");	
			}
			
			/* 
			Now that the size and the offset of the image is known
			we can open the image/stack.
			*/

			FileInfo fi = new FileInfo();
			fi.directory = directory;
			fi.fileFormat = fi.RAW;
			fi.fileName = file;
			// GRAY32 is the file type for .SIF's 
			fi.fileType = 4;
			fi.gapBetweenImages = 0;
			fi.height = height;
			fi.width = width;
			fi.nImages = stacksize;
			fi.offset = offset;
			fi.intelByteOrder = true;
			FileOpener fo = new FileOpener(fi);
			ImagePlus imp = fo.open(false);

			// result window
			file = file.substring(0, file.length() - 3) + "txt";
			String text =
				"Temperature (°C):\t"		+ temperature +
				"\nExposure Time (secs):\t"	+ exposureTime +
				"\nHorizontal Binning:\t"	+ Xbin_s +
				"\nVertical Binning:\t"		+ Ybin_s +
				"\nEM Gain level:\t"		+ EMGain;
			Editor ed = new Editor();
			ed.setSize(250, 200);
			ed.create(file, text);

			// flip the picture vertically
			if (imp!=null) {
				ImageStack stack = imp.getStack();
				for (i=1; i<=stack.getSize(); i++) {
					ImageProcessor ip = stack.getProcessor(i);
					ip.flipVertical();
				}
				imp.show();
			}

			IJ.showStatus("");
			return imp;
		} catch (IOException e) {
			IJ.error("An error occured reading the file.\n \n" + e);
			IJ.showStatus("");
			return null;
		}
	}
}
