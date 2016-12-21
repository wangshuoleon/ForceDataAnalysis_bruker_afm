function [ForceCurveOnDroplets]=FindForceCurveOnDroplets( Xretrace, Yretrace, NumberOfCurves)
%  this script was used to extract the force curve performed on droplet
% this arlgrithm evaluate the slope of the F-Z curve at the end portion,
% and the portion around `90 nm, see the graphic at the root folder
order=1;
for i=1:NumberOfCurves
    FitParameterEnd=polyfit(Xretrace{i}(1:8),Yretrace{i}(1:8),1);
    if FitParameterEnd(1)>.3
        FitParameterMid=polyfit(Xretrace{i}(135:145),Yretrace{i}(135:145),1);
        if FitParameterMid(1)>.04
            ForceCurveOnDroplets(order)=i;
         order=order+1;
        end
    end
end
% first, mapping to the height image
%  [data, scaleUnit, dataTypeDesc] = NSMU.GetForceVolumeImageData(NSMU.METRIC);
%     xLabel = NSMU.GetScanSizeLabel();
%     Height = flipud(data);
%     figure();
%     surface(Height);
%     colormap('hot');
%     colorbar();
%     xlabel(xLabel);
    
% superposition 
% figure;
side=sqrt(double(NumberOfCurves));
scatter(mod(ForceCurveOnDroplets,side),fix(ForceCurveOnDroplets/side),50,[0 0 0],'filled');
