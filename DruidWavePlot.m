function [waveOut]=DruidWavePlot( X ,bNorm)
%figure;
dw=1;

[C,T]=size(X);
t=[dw:dw:dw*T];

X=X-mean(X')'*ones(1,T);
if(bNorm==true)
    
    maxX=max(max(X))*2;
else
    maxX=0.0002;
end
X=X./maxX;
% X(2,:)=X(2,:)+200;
for c=1:C
    X(c,:)=X(c,:)-c+C;
end
plot(t,X');
ylabel('electrode');
% set(gca,'XTick',-pi:pi/2:pi)
celChannelLabel={'','P8','T8','F8','RE','P7','T7','F7','LE',''};
set(gca,'YTickLabel',celChannelLabel);


