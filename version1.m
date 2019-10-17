clearvars

%% get example data

Airs = prep_airs_3d(datenum(2008,1,127),57);
[GWs,Airs] = gwanalyse_airs_3d(Airs);

%% create colourbar
%second dimension will be alpha, with a white background
NColours = 16;

% ColourA = colorGradient([0.2,0.5,1],[1,1,1].*0.7,NColours./2);
% ColourB = colorGradient([1,1,1].*0.7,[1,.5,0],NColours./2);
ColourA = colorGradient([0,0,1],[1,1,1].*0.7,NColours./2);
ColourB = colorGradient([1,1,1].*0.7,[1,0,0],NColours./2);
Colours = cat(1,ColourA,ColourB);
clear ColourA ColourB


%% define ranges of the variables, that will be normalised over

ARange = [0,15];
kRange = [-1,1].*600;

%% setup
clf 
set(gcf,'color','w')

%% plotting

x = 1:1:size(GWs.A,1);
y = 1:1:size(GWs.A,2);
z = 10;

subplot(4,5,[1:4,6:9,11:14,16:19])
cla
axis([0 max(y) 0 max(x)])
hold on
box on; grid off;

for iX=1:1:numel(x);
  for iY = 1:1:numel(y)
   
    %first, get amplitude of this voxel
    A = GWs.A(iX,iY,z);
    
    %and k-wavelength
    k = 1./(GWs.k(iX,iY,z));
    
    
    %now, work out the fractional colour and alpha values
    Alpha  = bound((A - min(ARange))./range(ARange),0,1);
    Colour = bound(NColours.*(k - min(kRange))./range(kRange),0,NColours-1);
    
    %optical alpha perception is nonlinear - skew
    Alpha = sqrt(Alpha.^3);
    
    %work out the limits of the pixel
    x0 = x(iX) - 0.5 .* mean(diff(x)) - mean(diff(x));
    x1 = x(iX) + 0.5 .* mean(diff(x)) - mean(diff(x));
    y0 = y(iY) - 0.5 .* mean(diff(y)) - mean(diff(y));
    y1 = y(iY) + 0.5 .* mean(diff(y)) - mean(diff(y));    
    
    %create patch
    patch([y0,y0,y1,y1,y0],          ...
          [x0,x1,x1,x0,x0],          ...
          Colours(round(Colour)+1,:) , ...
          'facealpha', Alpha,'edgecolor','none');
    hold on

    
  end
  drawnow
end

%% colour map

subplot(4,5,20)
cla
axis([0 NColours 0 1])
box on
set(gca,'xtick',[0,NColours],'xticklabel',kRange,'ytick',[0,1],'yticklabel',ARange)
xlabel('Zonal \lambda [km]')
ylabel('Amplitude [K]')
hold on
axis square
set(gca,'fontsize',12)
for iX=1:1:NColours
  for iY=0:0.1:1;
    
    Colour = Colours(iX,:);

    
    %skew alpha
    Alpha = sqrt(iY.^3);
    
    patch([iX iX+1 iX+1 iX iX]-1, ...
          [iY iY iY+1 iY+1 iY], ...
          Colour, ...
          'facealpha',Alpha, ...
          'edgecolor','none');
  end
end

%% plot original data, for visual comparison
subplot(4,5,5)
pcolor(GWs.A(:,:,z)); caxis(ARange); shading flat; colorbar

h = subplot(4,5,10);
pcolor(1./GWs.k(:,:,z)); caxis(kRange); shading flat; colorbar
colormap(h,Colours)
