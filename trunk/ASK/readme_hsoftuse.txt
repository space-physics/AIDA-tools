      Setting up hsoft on unix/linux systems


      One modification I (myk) put most recently is to have the
      common block variables in h_setup be set to the system
      variables. This means that each and everyone can set
      up his own environment - and easily change it if needed.
      To set this up one needs to define the variables
      in e.g. .bashrc
      export VIDEODIR=/ask/data1/events/
      export SAOFILE=/ask/data1/auxdata/SAOJ2000
      export HDIR=/home/myk
      export PPSIFDIR=/home/myk
      export PPESRDIR=/home/myk
      or in a corresponding way in respective files if you
      run csh or ksh.

      Another thing should make it easier to compare the routines.
      I have added two routines - split_hsoft and gather_hsoft.
      What they do is to split the file into single routines,
      and gather the routines back in one file.

      (a little parenthesis for those who might not have followed
      the development of hsoft and wonder why keep it in one file
      at all. There are two reasons for it. First, we have had quite
      some interference from routines elsewhere in the PATH domain
      having the same names, but doing something completely different!
      If one gathers the routines in one file, compiling it will
      insure that only the "hsoft" versions of the routines are
      used, not people's own or some library routines from other
      places. The second reason is more subtle. Curve fitting is
      done in a couple of places, and there the parametric function
      must be defined externally to the fitting routine. If a function
      name is first encountered as
      a= function(b)
      IDL does not try to resolve it as function and compile the
      necessary file, but treats it as an undefined variable, and
      crashes).

      So, what I suggest is saving the hsoft.pro in some localized
      directory, compile it (starting IDL in that directory), and
      expand to single files. The same can be done to the current
      Southampton version of hsoft (in a different directory of
      course - one can copy the split_hsoft.pro file there). Then
      the tedious task of comparing and making order begins.

      To bring everything back to one file, one just runs gather_hsoft
      in the appropriate directory.

      The order of the routines is kept in the routine_list.txt file,
      created by the split_hsoft. To add new routines, add the filename
      to the appropriate place in the routine_list.txt. If there is
      filename.pro file in the current directory, it will be merged
      into the hsoft.pro file at the next "gathering".

      Editing or changing an existing routine in its single file will
      of course change only it - and that changed file will be used
      at the next merging.
