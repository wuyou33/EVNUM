%This script visualizes the grid
clear all
%% VAriables
ForPaper = 1; % (1) plots for paper (0) plots not for paper




%% Define files to read
linesFile='../European_LV_CSV/Lines.csv';
lineCodeFile= '../European_LV_CSV/LineCodes.csv';
BuscoordsFile='../European_LV_CSV/Buscoords.csv';

LoadsFile= '../European_LV_CSV/Loads.csv';
LoadShapesFile= '../European_LV_CSV/LoadShapes.csv';
%% Get data
Lines = readtable(linesFile,'HeaderLines',1,'Format','%s%f%f%s%f%s%s');
LineCodes = readtable (lineCodeFile, 'HeaderLines',1,'Format','%s%u%f%f%f%f%f%f%s');
Buscoords = readtable(BuscoordsFile, 'HeaderLines',1,'Format', '%f%f%f');
Loads = readtable(LoadsFile, 'HeaderLines',2, 'Format', '%s%f%f%s%f%f%s%f%f%s');
LoadShapes= readtable(LoadShapesFile, 'HeaderLines',1, 'Format', '%s%f%f%s%s');

% put information of lines together
LineCodes.Properties.VariableNames{'Name'} = 'LineCode';
T = table([1:size(LineCodes,1)]','VariableNames',{'LineCodeIndex'});
LineCodes = [LineCodes T];
Lines = join(Lines, LineCodes,'key','LineCode');

% Deifine information of loads
Loads.Properties.VariableNames{'Bus'}='Busname';
Loads = join( Loads, Buscoords,'key', 'Busname' ) ;

%% Graph construction

%Edges start and terminal
s = Lines{:,2};
t = Lines{:,3};

%node labels
nLabels = Buscoords{:,'Busname'}';
eLabels = Lines{:,'Name'};
weigths = Lines{:,'Length'} .* complex(Lines{:,'R1'}, Lines{:,'X1'});

weigthsAbs= abs(weigths);


%% Plot IEEE European LV Test Feeder
% Contruct graph
EdgeTable = table([s t], weigths , eLabels, 'VariableNames', {'EndNodes' 'Admittance' 'Name'} );
NodeTable = Buscoords;
G1=graph(EdgeTable,NodeTable)


% Plot
figure
%Full plot
%p=plot(G1,'LineWidth',1,'NodeLabel',G1.Nodes.Busname,'EdgeLabel',G1.Edges.Name);
% simple
p=plot(G1,'LineWidth',2)
title('Original IEEE European LV Test Feeder')
axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10])
p.XData=Buscoords{:,'x'}'; 
p.YData=Buscoords{:,'y'}';
p.Marker = 'none'; % no marker on connection nodes
highlight(p,Loads{:,'Busname'},'MarkerSize',5 ,'NodeColor','k', 'Marker','v') % highlight Loads
highlight(p,1,'MarkerSize',8 ,'NodeColor','r', 'Marker','s')
labelnode(p,1,'Transformer')
labelnode(p,Loads{:,'Busname'}, Loads{:,'Name'} )
if ForPaper== 1
axis off
set(gca,'position',[0 0 1 1],'units','normalized')
end

%% Plot Simplified IEEE European LV Test Feeder

% Contruct graph
tree = shortestpathtree(G1,Loads{:,'Busname'},1); % paths to load
G2= graph(tree.Edges, tree.Nodes); 

% Plot
figure
p2=plot(G2,'LineWidth',2)
title('Modified IEEE European LV Test Feeder')
axis([min(Buscoords{:,'x'})-10 max(Buscoords{:,'x'})+10 min(Buscoords{:,'y'}')-10 max(Buscoords{:,'y'}')+10])
p2.XData=Buscoords{G2.Nodes.Busname ,'x'}';
p2.YData=Buscoords{G2.Nodes.Busname ,'y'}';
p2.Marker = 'none'; % no marker on connection nodes
highlight(p2,Loads{:,'Busname'},'MarkerSize',5 ,'NodeColor','k', 'Marker','v') % highlight Loads
highlight(p2,1,'MarkerSize',8 ,'NodeColor','r', 'Marker','s')
labelnode(p2,1,'Transformer')
labelnode(p2,Loads{:,'Busname'}, Loads{:,'Name'} )
if ForPaper== 1
axis off
set(gca,'position',[0 0 1 1],'units','normalized')
end

%% Clean up nodes without connection
%G2 = rmnode(G2,find(degree(G2)==0)) ;




