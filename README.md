# AIDA-tools
Git fork of original Gustavsson/Brandstrom et al AIDA analysis toolset for ALIS tomography of the aurora

[Authors' SVN repo](https://aniara.irf.se/svn/AIDA_tools/)

One-time steps to migrate SVN to Git: 
-------------------------------------
https://www.atlassian.com/git/tutorials/migrating-overview
I already did this so you don't have to. More of an example to those wanting to do this for other SVNs
```
cd ~/code
sudo apt-get install git-svn
wget https://bitbucket.org/atlassian/svn-migration-scripts/downloads/svn-migration-scripts.jar
java -jar svn-migration-scripts.jar verify
java -jar svn-migration-scripts.jar authors https://aniara.irf.se/svn/AIDA_tools/ > authors.txt
git svn clone --stdlayout --authors-file=authors.txt https://aniara.irf.se/svn/AIDA_tools/ AIDA-tools
cd AIDA-tools
java -Dfile.encoding=utf-8 -jar ../svn-migration-scripts.jar clean-git
java -Dfile.encoding=utf-8 -jar ../svn-migration-scripts.jar clean-git --force
```

Periodic resync from SVN to git:
--------------------------------
https://www.atlassian.com/git/tutorials/migrating-synchronize
