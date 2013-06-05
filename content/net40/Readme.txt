MonoGame XNB Default Action Sample

The install.ps1 file in this nuget package will prompt to install a pkgdef which changes 
the default build action of XNB files to "Content". If the pkgdef is already installed
then no action is taken.

The same script could be added to the installer / vsix for the main MonoGame installer if
necessary.

Supports VS2010 and VS2012.