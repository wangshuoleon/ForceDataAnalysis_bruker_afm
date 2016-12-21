function [Xtrace, Xretrace,Ytrace, Yretrace, xLabel, yLabel,SamplesPerLine,NumberOfLines]=GetForceCurveFromFV(filename,IsZ)
% this script was used to extract the force curve data from a Force Volume
% file
% inputs: filename
%         IsZ 0 for z displacements
%             1 for seperation
NSMU = NSMatlabUtilities();
NSMU.Open(filename);
NumberOfCurves = NSMU.GetNumberOfForceCurves();
Ytrace=cell(1,NumberOfCurves);
Yretrace=cell(1,NumberOfCurves);
Xtrace=cell(1,NumberOfCurves);
Xretrace=cell(1,NumberOfCurves);
for i=1:NumberOfCurves
    % the third input parameter of the following function determine the x axis( Z or
    % saperation)
    if IsZ==0
     [Xtrace{i},Xretrace{i},Ytrace{i}, Yretrace{i}, xLabel, yLabel] =NSMU.CreateForceVolumeForceCurveZplot(i, NSMU.FORCE, 0);
    else 
       [Xtrace{i},Xretrace{i},Ytrace{i}, Yretrace{i}, xLabel, yLabel] =NSMU.CreateForceVolumeForceCurveZplot(i, NSMU.FORCE, 1);
    end 
        
end
% the output force data was stored in the cell Ytrace,Yretrace,note that
% each vector in the cell may not have the same size
% get samples perline, and Number of lines
SamplesPerLine = NSMU.GetSamplesPerLine(1);
NumberOfLines = NSMU.GetNumberOfLines(1);
end


