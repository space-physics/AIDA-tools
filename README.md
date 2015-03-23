# AIDA-tools
Git fork of original Gustavsson/Brandstrom et al AIDA analysis toolset for ALIS tomography of the aurora

[Authors' SVN repo](https://aniara.irf.se/svn/AIDA_tools/)

One-time steps to cutover SVN to Git (discarding SVN history): 
-------------------------------------
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
