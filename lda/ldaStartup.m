% startup script for LDA

homepath = fullfile('..','lda');
libpath = fullfile('..', 'topictoolbox');
addpath(libpath);
cd(libpath);
compilescripts;
cd(homepath);
clear homepath libpath;
set(0, 'DefaultFigureWindowStyle', 'docked');
iptsetpref('ImshowInitialMagnification', 'fit')
