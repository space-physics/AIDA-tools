==========
AIDA-tools
==========

Git fork of original Gustavsson/Brandstrom et al AIDA analysis toolset for ALIS tomography of the aurora

[Authors' SVN repo](https://aniara.irf.se/svn/AIDA_tools/)

.. contents::

Basic Uses
==========
I have made a couple patches to support Octave, but most of the program still requires Matlab::

    git clone https://github.com/scienceopen/AIDA-tools

Computing ionospheric production rates from incident particle flux
-------------------------------------------------------------------
There is `far more efficient Python code <https://github.com/scienceopen/reesaurora>`_ but if you must use Matlab, look in the `tools directory <https://github.com/scienceopen/AIDA-tools/tree/master/tools>`_, specifically ``ionization_profiles_from_flux.m``.

Appendicies 
===========

One-time steps to cutover SVN to Git (discarding SVN history) 
--------------------------------------------------------------

* (reference only, not used by normal users) *

https://www.atlassian.com/git/tutorials/migrating-overview
I already did this so you don't have to. More of an example to those wanting to do this for other SVNs that have enormous histories.
```
cd ~/code
svn co svn co https://aniara.irf.se/svn/AIDA_tools/
cd AIDA_tools
rmdir branches tags
rm -rf .svn
echo ".data" >> .gitignore
git init
git add .
git commit -m "cutover from SVN"
git remote add origin https://github.com/scienceopen/AIDA-tools
git pull
git push origin master
```
