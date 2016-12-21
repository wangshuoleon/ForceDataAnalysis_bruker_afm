% analysis the adhesion force at droplet/substrate interface
function [AdhesionForce_OilSub]=AnalysisAdhesionAtDroplet_Solid(ForceCurveOnDroplets,Yretrace)
AdhesionForce_OilSub=zeros(length(ForceCurveOnDroplets),1);
for i=1:length(ForceCurveOnDroplets)
    % find the first positive peak and first negative peak
    negative_peak=findpeaks(-Yretrace{ForceCurveOnDroplets(i)});
    positive_peak=findpeaks(Yretrace{ForceCurveOnDroplets(i)});
    AdhesionForce_OilSub(i)=positive_peak(1)+negative_peak(1);
%     % first smooth the retraction curve
%     Smoothed=smooth(Yretrace{ForceCurveOnDroplets(i)}(1:100));
%     % then differential
%     Differential=diff(Smoothed);
%     % return the adhesion(without correction) and the order of the force in the array
%     [AdhesionForce_without,Order]=max(Differential);
%     % polyfit the baseline
%     FitParameter=polyfit(Xretrace{ForceCurveOnDroplets(i)}(Order+35:Order+65),Yretrace{ForceCurveOnDroplets(i)}(Order+35:Order+65),1);
%     % corrected adhesion force
%     AdhesionForce_OilSubstrate(i)=FitParameter(1)*Xretrace{ForceCurveOnDroplets(i)}(Order)+FitParameter(2)-Yretrace{ForceCurveOnDroplets(i)}(Order);
end
figure;
hist(AdhesionForce_OilSub);
