classdef NSMatlabUtilities < handle
   % A class that implements NanoScope file I/O utilities
    properties (SetAccess = 'private')
		FileName = '';
        IsOpen = 0;
        METRIC = 1;
		VOLTS = 2;
		FORCE = 3;
		RAW = 4;
    end
	
	methods 
		function this = NSMatlabUtilities()
		end
   	
		function Open(this, FileName)
            try
                if ~libisloaded('DataSourceDLL')
                    if exist('DataSourceDLL.h', 'file')
                        try
                            if (isdeployed)
                                loadlibrary('DataSourceDLL.dll',@mdatasourcehdr);
                            else
                                loadlibrary('DataSourceDLL.dll','DataSourceDLL.h');
                            end
                        catch
                            errMsg = sprintf('Unable to load DataSourceDll.dll. Please install Microsoft Windows SDK 7.1 from http://www.microsoft.com/en-us/download/details.aspx?id=8279');
                            error(errMsg);
                        end
                    else
                        errMsg = sprintf('Unable to locate DataSourceDLL.h. Please change the current folder to where DataSourceDLL.h is located.');
                        error(errMsg);
                    end
                end
            catch exc
                error(exc.message);
            end
            this.FileName = FileName;
            this.IsOpen = calllib('DataSourceDLL', 'DataSourceDllOpen', FileName);
            if this.IsOpen ~= 1
                errMsg = sprintf('Could not open %s.\n\nVerify that it is a valid Nanoscope File.',FileName);
                error(errMsg);
            end
		end
		
		function Close(this)
           	if libisloaded('DataSourceDLL')
                calllib('DataSourceDLL', 'DataSourceDllClose')
				unloadlibrary DataSourceDLL
			end
		end
		
		function [trace, retrace, scaleUnit, dataTypeDesc] = GetForceCurveData(this, ChannelNumber, UnitType)
			%Returns force curve data
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file.
			%UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW
            trace = [];
            retrace = [];
            dataTypeDesc = '';
            scaleUnit = '';
			if this.IsOpen
                if ChannelNumber ~= 0
                    ChannelNumber = ChannelNumber - 1;
                end
				%get number of retrace points
				NumRetrace = 0;
				NumRetrace = this.GetNumberOfRetracePoints(ChannelNumber);
				%get number of trace points
				NumTrace = 0;
				NumTrace = this.GetNumberOfTracePoints(ChannelNumber);
				doubleTrace = double(zeros(NumTrace, 1)); 
				doubleRetrace = double(zeros(NumRetrace, 1)); 
				pTrace = libpointer('doublePtr',doubleTrace);
				pRetrace = libpointer('doublePtr',doubleRetrace);
				scaleUnit = '';
                dataTypeDesc = calllib('DataSourceDLL','DataSourceDllGetDataTypeDesc', ChannelNumber);
				switch UnitType
					case this.RAW
						calllib('DataSourceDLL','DataSourceDllGetForceCurveData', ChannelNumber, pTrace, pRetrace);
						scaleUnit = 'LSB';
					case this.METRIC
						calllib('DataSourceDLL','DataSourceDllGetForceCurveMetricData', ChannelNumber, pTrace, pRetrace);
						scaleUnit = calllib('DataSourceDLL','DataSourceDllGetMetricDataScaleUnits', ChannelNumber);
					case this.FORCE
						calllib('DataSourceDLL','DataSourceDllGetForceCurveForceData', ChannelNumber, pTrace, pRetrace);
						scaleUnit = calllib('DataSourceDLL','DataSourceDllGetForceDataScaleUnits', ChannelNumber);
                        dataTypeDesc = 'Force';
                    case this.VOLTS
						calllib('DataSourceDLL','DataSourceDllGetForceCurveVoltsData', ChannelNumber, pTrace, pRetrace);
						scaleUnit = calllib('DataSourceDLL','DataSourceDllGetVoltsDataScaleUnits', ChannelNumber);
					otherwise
						error('Wrong UnitType parameter.')
				end		
				trace = pTrace.Value;
				retrace = pRetrace.Value;
		    end
    	end
		
		function [data, scaleUnit, dataTypeDesc] = GetHSDCData(this, ChannelNumber, UnitType)
			%Returns HSDC data
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file.
			%UnitType: this.METRIC, this.VOLTS, this.RAW 
			data = [];
			dataTypeDesc = '';
            scaleUnit = '';
            if this.IsOpen
				if ChannelNumber ~= 0
                    ChannelNumber = ChannelNumber - 1;
                end
				MaxDataSize = 0;
				[ret, MaxDataSize] = calllib('DataSourceDLL','DataSourceDllGetNumberOfPointsPerCurve', ChannelNumber, MaxDataSize);
				ActualDataSize = 0;
				DoubleBuffer = double(zeros(1, MaxDataSize));
				pBuffer = libpointer('doublePtr',DoubleBuffer);
			    switch UnitType
					case this.RAW
						calllib('DataSourceDLL','DataSourceDllGetHSDCForceCurveData', ChannelNumber, pBuffer, MaxDataSize, ActualDataSize);
						scaleUnit = 'LSB'
					case this.METRIC
						calllib('DataSourceDLL','DataSourceDllGetHSDCMetricForceCurveData', ChannelNumber, pBuffer, MaxDataSize, ActualDataSize);
						scaleUnit = calllib('DataSourceDLL','DataSourceDllGetMetricDataScaleUnits', ChannelNumber);
					case this.VOLTS
						calllib('DataSourceDLL','DataSourceDllGetHSDCVoltsForceCurveData', ChannelNumber, pBuffer, MaxDataSize, ActualDataSize);
						scaleUnit = calllib('DataSourceDLL','DataSourceDllGetVoltsDataScaleUnits', ChannelNumber);
					otherwise
						error('Wrong UnitType parameter.')
				end	
                dataTypeDesc = calllib('DataSourceDLL','DataSourceDllGetDataTypeDesc', ChannelNumber);
				data = pBuffer.Value;
            end
		end
		
		function [data, scaleUnit, dataTypeDesc] = GetForceVolumeImageData(this, UnitType)
			%Returns force volume image
            %Input: 
			%UnitType: this.METRIC, this.VOLTS, this.RAW 
            data = [];
			dataTypeDesc = '';
            scaleUnit = '';
			if this.IsOpen
				%FV image ChannelNumber is always 0
				SamplesPerLine = 0;
				[ret, SamplesPerLine] = calllib('DataSourceDLL','DataSourceDllGetSamplesPerLine', 0, SamplesPerLine);
				NumberOfLines = 0;
				[ret, NumberOfLines] = calllib('DataSourceDLL','DataSourceDllGetNumberOfLines', 0, NumberOfLines);
				MaxDataSize = SamplesPerLine * NumberOfLines;
				ActualDataSize = 0;
				DoubleBuffer = double(zeros(NumberOfLines, SamplesPerLine));
				pBuffer = libpointer('doublePtr',DoubleBuffer);
                switch UnitType
					case this.RAW
						calllib('DataSourceDLL','DataSourceDllGetForceVolumeImageData', pBuffer, MaxDataSize, ActualDataSize);
                        scaleUnit = 'LSB';
					case this.METRIC
						calllib('DataSourceDLL','DataSourceDllGetForceVolumeMetricImageData', pBuffer, MaxDataSize, ActualDataSize);
                    	scaleUnit = calllib('DataSourceDLL','DataSourceDllGetMetricDataScaleUnits', 0);
					case this.VOLTS
						calllib('DataSourceDLL','DataSourceDllGetForceVolumeVoltsImageData', pBuffer, MaxDataSize, ActualDataSize);
                        scaleUnit = calllib('DataSourceDLL','DataSourceDllGetVoltsDataScaleUnits', 0);
					otherwise
						error('Wrong UnitType parameter.')
				end	
            	dataTypeDesc = calllib('DataSourceDLL','DataSourceDllGetDataTypeDesc', 0);
				data = rot90(pBuffer.Value);
            end
        end
		
        function [data, scaleUnit, dataTypeDesc] = GetPeakForceCaptureImageData(this, UnitType)
            [data, scaleUnit, dataTypeDesc] = this.GetForceVolumeImageData(UnitType);
        end
        
        function [imagePixel, forVolPixel] = GetForceVolumeScanLinePixels(this)
            %Return image pixels and number of force curves
            %in each scan line of the specific force volume/peak force
            %capture file.
            imagePixel = 0;
            forVolPixel = 0;
            if this.IsOpen
                [ret, forVolPixel] = calllib('DataSourceDLL', 'DataSourceDllGetForcesPerLine', forVolPixel);
                %FV image ChannelNumber is always 0
                [ret, imagePixel] = calllib('DataSourceDLL','DataSourceDllGetSamplesPerLine', 0, imagePixel);
            end
        end
        
		function [trace, retrace, scaleUnit, dataTypeDesc] = GetForceVolumeForceCurveData(this, CurveNumber, UnitType)
			%Returns force volume force curve data
			%Input: 
			%CurveNumber ranges from 1 to Number of Curves in the file.
            %UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW 
            trace = [];
            retrace = [];
			dataTypeDesc = '';
            scaleUnit = '';
			if this.IsOpen
				if CurveNumber ~= 0
                    CurveNumber = CurveNumber - 1;
                end
				MaxDataSize = 0;
				[ret, MaxDataSize] = calllib('DataSourceDLL','DataSourceDllGetNumberOfPointsPerCurve', 1, MaxDataSize);
				tracePts = 0;
                retracePts = 0;
				doubleTrace = double(zeros(MaxDataSize, 1)); 
				doubleRetrace = double(zeros(MaxDataSize, 1)); 
				pTrace = libpointer('doublePtr',doubleTrace);
				pRetrace = libpointer('doublePtr',doubleRetrace);

                switch UnitType
					case this.RAW
                        [~, ~, ~, tracePts, retracePts] = calllib('DataSourceDLL','DataSourceDllGetForceVolumeForceCurveData', CurveNumber, pTrace, pRetrace, tracePts, retracePts, MaxDataSize);
                        scaleUnit = 'LSB';
					case this.METRIC
						[~, ~, ~, tracePts, retracePts] = calllib('DataSourceDLL','DataSourceDllGetForceVolumeMetricForceCurveData', CurveNumber, pTrace, pRetrace, tracePts, retracePts, MaxDataSize);
                        scaleUnit = calllib('DataSourceDLL','DataSourceDllGetMetricDataScaleUnits', 1);
					case this.VOLTS
						[~, ~, ~, tracePts, retracePts] = calllib('DataSourceDLL','DataSourceDllGetForceVolumeVoltsForceCurveData', CurveNumber, pTrace, pRetrace, tracePts, retracePts ,MaxDataSize);
                        scaleUnit = calllib('DataSourceDLL','DataSourceDllGetVoltsDataScaleUnits', 1);
                    case this.FORCE
						[~, ~, ~, tracePts, retracePts] = calllib('DataSourceDLL','DataSourceDllGetForceVolumeForceForceCurveData', CurveNumber, pTrace, pRetrace, tracePts, retracePts, MaxDataSize);
                        scaleUnit = calllib('DataSourceDLL','DataSourceDllGetForceDataScaleUnits', 1);
					otherwise
						error('Wrong UnitType parameter.')
				end	
            	dataTypeDesc = calllib('DataSourceDLL','DataSourceDllGetDataTypeDesc', 1);
				trace = pTrace.Value(1:tracePts, 1);
				retrace = pRetrace.Value(1:retracePts, 1);
			end
        end
        
        function [xTrace, xRetrace, scaleUnit] = GetPeakForceCaptureZData(this, TracePts, RetracePts)
            %Returns peak force z data
            %Input: TracePts & RetracePts
            
            xTrace = [];
            xRetrace = [];
            scaleUnit = '';
            if this.IsOpen
                doublexTrace = double(zeros(TracePts, 1));
                doublexRetrace = double(zeros(RetracePts, 1));
                pxTrace = libpointer('doublePtr', doublexTrace);
                pxRetrace = libpointer('doublePtr', doublexRetrace);
                
                calllib('DataSourceDLL', 'DataSourceDllGetPeakForceCaptureZData', pxTrace, pxRetrace, TracePts, RetracePts);
                scaleUnit = 'nm';
                xTrace = pxTrace.Value;
                xRetrace = pxRetrace.Value;
            end
        end
        
        function [data, scaleUnit, dataTypeDesc] = GetImageData(this, ChannelNumber, UnitType)
			%Returns image channel data
            %Input: 
            %ChannelNumber ranges from 1 to Number of Channels in the file.
          	%UnitType: this.METRIC, this.VOLTS, this.RAW 
            data = [];
			dataTypeDesc = '';
            scaleUnit = '';
			if this.IsOpen
				SamplesPerLine = 0;
                if ChannelNumber ~= 0
                    ChannelNumber = ChannelNumber - 1;
                end
				[ret, SamplesPerLine] = calllib('DataSourceDLL','DataSourceDllGetSamplesPerLine', 0, SamplesPerLine);
				NumberOfLines = 0;
				[ret, NumberOfLines] = calllib('DataSourceDLL','DataSourceDllGetNumberOfLines', 0, NumberOfLines);
				MaxDataSize = SamplesPerLine * NumberOfLines;
				ActualDataSize = 0;
				DoubleBuffer = double(zeros(SamplesPerLine, NumberOfLines));
				pBuffer = libpointer('doublePtr',DoubleBuffer);
                switch UnitType
					case this.RAW
						calllib('DataSourceDLL','DataSourceDllGetImageData', ChannelNumber, pBuffer, MaxDataSize, ActualDataSize);
                        scaleUnit = 'LSB';
					case this.METRIC
						calllib('DataSourceDLL','DataSourceDllGetImageMetricData', ChannelNumber, pBuffer, MaxDataSize, ActualDataSize);
                    	scaleUnit = calllib('DataSourceDLL','DataSourceDllGetMetricDataScaleUnits', 0);
					case this.VOLTS
						calllib('DataSourceDLL','DataSourceDllGetImageVoltsData', ChannelNumber, pBuffer, MaxDataSize, ActualDataSize);
                        scaleUnit = calllib('DataSourceDLL','DataSourceDllGetVoltsDataScaleUnits', 0);
					otherwise
						error('Wrong UnitType parameter.')
				end	
            	dataTypeDesc = calllib('DataSourceDLL','DataSourceDllGetDataTypeDesc', ChannelNumber);
				data = rot90(pBuffer.Value);
            end
		end
		
		function [unit] = GetZSensitivityUnits(this, ChannelNumber)
			%Returns Z Sensitivity unit for specific ChannelNumber
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			pstr = char(zeros(1, 256));
			if this.IsOpen
				[ret, pstr] = calllib('DataSourceDLL','DataSourceDllGetZSensitivityUnits', ChannelNumber, pstr);
			end
			unit = pstr;
		end
		
		function [factor] = GetScalingFactor(this, ChannelNumber, isMetric)
			%Returns the Scaling factor for specific ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file.
			%If IsMetric is 1, the function returns the scaling factor to convert the LSB data to metric unit.
			%If IsMetric is 0, the function returns the scaling factor to conver the LSB data to volts unit.
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			ScalingFactor = 1.0;
			if this.IsOpen
				[ret, ScalingFactor] = calllib('DataSourceDLL','DataSourceDllGetScalingFactor', ChannelNumber, ScalingFactor, isMetric);
			end
			factor = ScalingFactor; 
		end
		
		function [size] = GetBufferSize(this, ChannelNumber)
			%Returns the buffer size for specific ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			BufferSize = 0;
			if this.IsOpen
				[ret, BufferSize] = calllib('DataSourceDLL','DataSourceDllGetDataBufferSize', ChannelNumber, BufferSize);
			end
			size = BufferSize; 
		end
		
		function [samps] = GetSamplesPerLine(this, ChannelNumber)
			%Returns the samples per line for specific ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			SamplesPerLine = 0;
			if this.IsOpen
				[ret, SamplesPerLine] = calllib('DataSourceDLL','DataSourceDllGetSamplesPerLine', ChannelNumber, SamplesPerLine);
			end
			samps = SamplesPerLine; 
		end
		
		function [lines] = GetNumberOfLines(this, ChannelNumber)
			%Returns the number of lines for specific ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			NumberOfLines = 0;
			if this.IsOpen
				[ret, NumberOfLines] = calllib('DataSourceDLL','DataSourceDllGetNumberOfLines', ChannelNumber, NumberOfLines);
			end
			lines = NumberOfLines; 
        end
        
        function [AspectRatio] = GetImageAspectRatio(this, ChannelNumber)
			%Returns the Aspect Ratio for specific ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			AspectRatio = 1;
			if this.IsOpen
				[ret, AspectRatio] = calllib('DataSourceDLL','DataSourceDllGetImageAspectRatio', ChannelNumber, AspectRatio);
			end
		end
		
		function [number] = GetNumberOfForceCurves(this)
			%Returns the number of force curves in the file
			NumberOfForceCurves = 0;
			if this.IsOpen
				[ret, NumberOfForceCurves] = calllib('DataSourceDLL','DataSourceDllGetNumberOfForceCurves', NumberOfForceCurves);
			end
			number = NumberOfForceCurves; 
		end
		
		function [number] = GetNumberOfPointsPerCurve(this, ChannelNumber)
			%Returns the number of points for specific force curve ChannelNumber ex)Samps/line
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			NumberOfPoints = 0;
			if this.IsOpen
				[ret, NumberOfPoints] = calllib('DataSourceDLL','DataSourceDllGetNumberOfPointsPerCurve', ChannelNumber, NumberOfPoints);
			end
			number = NumberOfPoints; 
		end
		
		function [RampSize, RampUnits] = GetRampSize(this, ChannelNumber, isMetric)
			%Returns the ramp size of specific force curve ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
            %If IsMetric is 1, the function returns the RampSize to metric unit
			%If IsMetric is 0, the function returns the RampSize to volts unit.
			%Output:
			%Ramp size and unit
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			size = 0;
            units = '';
			if this.IsOpen
				[ret, size] = calllib('DataSourceDLL','DataSourceDllGetRampSize', ChannelNumber, size, isMetric);
				units = calllib('DataSourceDLL','DataSourceDllGetRampUnits', ChannelNumber, isMetric);
            end
            RampSize = size; 
            RampUnits = units;
		end
		
		function [ZScale] = GetZScaleInSwUnits(this, ChannelNumber)
			%Returns the ZScale of specific force curve ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%Output:
			%Z scale in sw unit
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
            end
            ZScale = 1;
			if this.IsOpen
				[ret, ZScale] = calllib('DataSourceDLL','DataSourceDllGetZScaleInSwUnits', ChannelNumber, ZScale);
			end
		end
	
		function [ZScale] = GetZScaleInHwUnits(this, ChannelNumber)
			%Returns the ZScale of specific force curve ChannelNumber
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%Output:
			%Z scale in sw unit
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
            end
            ZScale = 1;
			if this.IsOpen
            	[ret, ZScale] = calllib('DataSourceDLL','DataSourceDllGetZScaleInHwUnits', ChannelNumber, ZScale);
			end
		end
		
		function [NumTrace] = GetNumberOfTracePoints(this, ChannelNumber)
			%Returns the number of points in trace
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%Output:
			%the number of points in trace
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			NumTrace = 0;
			%get number of trace points
			[ret, NumTrace] = calllib('DataSourceDLL','DataSourceDllGetNumberOfTracePoints', ChannelNumber, NumTrace);
		end
		
		function [NumRetrace] = GetNumberOfRetracePoints(this, ChannelNumber)
			%Returns the number of points in retrace
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%Output:
			%the number of points in retrace
			if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			NumRetrace = 0;
			%get number of retrace points
			[ret, NumRetrace] = calllib('DataSourceDLL','DataSourceDllGetForceSamplesPerLine', ChannelNumber, NumRetrace);
		end
		
		function [Ratio] = GetPoissonRatio(this)
			%Returns the Poisson ratio from header file
			%
			%Output:
			%Poisson ratio
			Ratio = 0;
			[ret, Ratio] = calllib('DataSourceDLL','DataSourceDllGetPoissonRatio', Ratio);
		end
		
		function [Radius] = GetTipRadius(this)
			%Returns the Tip radius from the header file
			%Output:
			%Tip Radius
			Radius = 0;
			%get number of retrace points
			[ret, Radius] = calllib('DataSourceDLL','DataSourceDllGetTipRadius', Radius);
        end
        
        function [Velocity] = GetForwardRampVelocity(this, ChannelNumber, isMetric)
			%Returns the Forward ramp velocity from the header file
            %Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%IsMetric is 1 or 0
			%Output:
			%Forward ramp velocity
            if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			Velocity = 0;
			[ret, Velocity] = calllib('DataSourceDLL','DataSourceDllGetForwardRampVelocity', ChannelNumber, Velocity, isMetric);
        end
        
        function [Velocity] = GetReverseRampVelocity(this, ChannelNumber,  isMetric)
			%Returns the Reverse ramp velocity from the header file
			%Input: 
            %IsMetric is 1 or 0
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%Output:
			%Reverse ramp velocity
            if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			Velocity = 0;
			[ret, Velocity] = calllib('DataSourceDLL','DataSourceDllGetReverseRampVelocity', ChannelNumber, Velocity,  isMetric);
        end
        
          function [SpringConst] = GetSpringConstant(this, ChannelNumber)
			%Returns the Spring constant
			%Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%Output:
			%Spring constant
            if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
			end
			SpringConst = 1;
			[ret, SpringConst] = calllib('DataSourceDLL','DataSourceDllGetForceSpringConstant', ChannelNumber, SpringConst);
        end
		
		function [NumberOfChannels] = GetNumberOfChannels(this)
			%Returns the Number of Channels in Image file
			%Output:
			%Number of Channels in Image file
           	NumberOfChannels = 1;
			[ret, NumberOfChannels] = calllib('DataSourceDLL','DataSourceDllGetNumberOfChannels', NumberOfChannels);
        end
        
        function [HsdcRate] = GetHsdcRate(this, ChannelNumber)
			%Returns the Hsdc rate from the header
            %Input: 
			%ChannelNumber ranges from 1 to Number of Channels in the file
			%Output:
			%Hsdc Rate in Hsdc file
           	HsdcRate = 1;
			[ret, HsdcRate] = calllib('DataSourceDLL','DataSourceDllGetHsdcRate', ChannelNumber, HsdcRate);
        end
        
        function [PFTFreq] = GetPeakForceTappingFreq(this)
            %Return the peak force tapping frequency from the header
            %Output:
            %peak force tapping frequency (unit in Hz)
            PFTFreq = 0;
            if this.IsOpen
                [ret, PFTFreq] = calllib('DataSourceDLL', 'DataSourceDllGetPeakForceTappingFreq', PFTFreq);
            end;
        end
        
        function [ScanSize, ScanSizeUnit] = GetScanSize(this, ChannelNumber)
            %Return the scan size of the specific image channel
            %Input:
            %image channel >= 1, <= Number of Channels in the file
            %Output:
            %Scan size and unit
            if ChannelNumber ~= 0
				ChannelNumber = ChannelNumber - 1;
            end
            ScanSize = 0;
            ScanSizeUnit = '';
            if this.IsOpen
                [ret, ScanSize] = calllib('DataSourceDLL', 'DataSourceDllGetScanSize', ChannelNumber, ScanSize);
                ScanSizeUnit = calllib('DataSourceDLL', 'DataSourceDllGetScanSizeUnit', ChannelNumber);
            end
        end
        
        function [ScanSizeLabel] = GetScanSizeLabel(this)
            %Return the string label of scan size
            %(e.g. 'Scan Size: 2.5(um)')
            ScanSizeLabel = '';
            if this.IsOpen
                [scanSize, scanSizeUnit] = this.GetScanSize(1);
                ScanSizeLabel = sprintf('Scan Size: %.2f(%s)', scanSize, scanSizeUnit);
            end
        end
        
        function [xData, yData, xLabel, yLabel] = CreateForceTimePlot(this, ChannelNumber, UnitType)
            %Returns x, y trace and retrace values and their labels 
			%Input: 
			%ChannelNumber: ranges from 1 to Number of Channels in the file.
			%UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW
            yTrace = [];
			yRetrace = [];
			scale_units = '';
			type_desc = '';
			[yTrace, yRetrace, scale_units, type_desc] = this.GetForceCurveData(ChannelNumber, UnitType);
			sizeTrace = max(size(yTrace));
			sizeRetrace = max(size(yRetrace));
			xData = double(zeros(sizeTrace + sizeRetrace, 1));
			yData = double(zeros(sizeTrace + sizeRetrace, 1));
            %initialize variables to 0
            [RampSize, rampVelRev, rampVelFor, TraceTimeS, RetraceTimeS, tIncrR, tIncr, taccum] = deal(0);
            RampUnits = '';
            switch UnitType
                case {this.RAW, this.VOLTS}
                    [RampSize, RampUnits] = this.GetRampSize(ChannelNumber, 0);
                    rampVelFor = this.GetForwardRampVelocity(ChannelNumber, 0);
            		rampVelRev = this.GetReverseRampVelocity(ChannelNumber, 0);
                case {this.METRIC, this.FORCE}
                    [RampSize, RampUnits] = this.GetRampSize(ChannelNumber, 1);
                    rampVelFor = this.GetForwardRampVelocity(ChannelNumber, 1);
            		rampVelRev = this.GetReverseRampVelocity(ChannelNumber, 1);
	            otherwise
                    error('Wrong UnitType parameter.')
            end
        
            if rampVelFor ~=0
                TraceTimeS = RampSize/rampVelFor;
            end
            if rampVelRev ~=0
               RetraceTimeS = RampSize/rampVelRev;
            end
            if sizeTrace ~= 0
                tIncr = TraceTimeS / sizeTrace;
            end
            if sizeRetrace ~= 0
                tIncrR = RetraceTimeS / sizeRetrace;
            end
            yData = [yTrace(end:-1:1); yRetrace];    %merge reversed trace and retrace vectors for yData
            for i = 1:sizeTrace + sizeRetrace
                xData(i) = taccum;
                if i <= sizeTrace
                    taccum = taccum + tIncr;
                else
                    taccum = taccum + tIncrR;
                end
            end
            yLabel = sprintf('%s (%s)',type_desc, scale_units );
            xLabel = 'Time (s)';
        end
			
        function [xData, yData, xLabel, yLabel] = CreateForceVolumeForceCurveTimePlot(this, CurveNumber, UnitType)
            %Return force vs time plot of specified curve and their labels
            %Input:
            %CurveNumber ranges from 1 to Number of Curves in the FV file
            %UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW
            [yTrace, yRetrace, scale_units, type_desc] = this.GetForceVolumeForceCurveData(CurveNumber, UnitType);
            sizeTrace = max(size(yTrace));
            sizeRetrace = max(size(yRetrace));
            xData = double(zeros(sizeTrace + sizeRetrace, 1));
            yData = double(zeros(sizeTrace + sizeRetrace, 1));
            %initialize variables to 0
            [RampSize, rampVelFor, rampVelRev, TraceTimeS, RetraceTimeS, tIncr, tIncrR, tAccum] = deal(0);
            RampUnits = '';
            switch UnitType
                case {this.RAW, this.VOLTS}
                    [RampSize, RampUnits] = this.GetRampSize(2, 0);
                    rampVelFor = this.GetForwardRampVelocity(2, 0);
                    rampVelRev = this.GetReverseRampVelocity(2, 0);
                case {this.METRIC, this.FORCE}
                    [RampSize, RampUnits] = this.GetRampSize(2, 1);
                    rampVelFor = this.GetForwardRampVelocity(2, 1);
                    rampVelRev = this.GetReverseRampVelocity(2, 1);
                otherwise
                    error('Wrong UnitType parameter.')
            end
            
            if rampVelFor ~=0
                TraceTimeS = RampSize/rampVelFor;
            end
            if rampVelRev ~=0
               RetraceTimeS = RampSize/rampVelRev;
            end
            if sizeTrace ~= 0
                tIncr = TraceTimeS / sizeTrace;
            end
            if sizeRetrace ~= 0
                tIncrR = RetraceTimeS / sizeRetrace;
            end
            yData = [yTrace(end:-1:1); yRetrace];   %merge reversed trace and retrace vectors for yData
            for i = 1:(sizeTrace + sizeRetrace)
                xData(i) = tAccum;
                if  i <= sizeTrace
                    tAccum = tAccum + tIncr;
                else
                    tAccum = tAccum + tIncrR;
                end
            end
            yLabel = sprintf('%s (%s)',type_desc, scale_units );
            xLabel = 'Time (s)';
        end
        
        function [xData, yData, xLabel, yLabel] = CreatePeakForceForceCurveTimePlot(this, CurveNumber, UnitType)
            %Return force vs time plot of specified curve and their labels
            %Input:
            %CurveNumber ranges from 1 to Number of Curves in the PFC file
            %UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW
            [yTrace, yRetrace, scale_units, type_desc] = this.GetForceVolumeForceCurveData(CurveNumber, UnitType);
            sizeTrace = max(size(yTrace));
            sizeRetrace = max(size(yRetrace));
            xData = double(zeros(sizeTrace + sizeRetrace, 1));
            yData = double(zeros(sizeTrace + sizeRetrace, 1));
            %initialize variables to 0
            [freq, tInterval, tIncr, tAccum] = deal(0);
            [freq] = this.GetPeakForceTappingFreq();   %peak force tapping frequency (unit in Hz)
            
            if freq ~= 0
                tInterval = 1000000 / freq;    %tapping period (unit in us)
            end
            if tInterval ~= 0
                tIncr = tInterval / (sizeTrace + sizeRetrace);
            end
            yData = [yTrace(end:-1:1); yRetrace];   %merge reversed trace and retrace vectors for yData
            for i = 1:(sizeTrace + sizeRetrace)
                tAccum = tAccum + tIncr;
                xData(i) = tAccum;
            end
            yLabel = sprintf('%s (%s)',type_desc, scale_units );
            xLabel = 'Time (us)';
        end
        
		function [xTrace, xRetrace, yTrace, yRetrace, xLabel, yLabel] = CreateForceZPlot(this, ChannelNumber, UnitType, isSeparation)
            %Returns x, y trace and retrace values and their labels 
			%Input: 
			%ChannelNumber: ranges from 1 to Number of Channels in the file.
			%UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW
            %isSeperation: 1 if you want a separation plot
            yTrace = [];
			yRetrace = [];
			scale_units = '';
			type_desc = '';
			[yTrace, yRetrace, scale_units, type_desc] = this.GetForceCurveData(ChannelNumber, UnitType);
			sizeTrace = max(size(yTrace));
			sizeRetrace = max(size(yRetrace));
			xTrace = double(zeros(sizeTrace, 1));
			xRetrace = double(zeros(sizeRetrace, 1));
            RampSize = 0;
            RampUnits = '';
            switch UnitType
                case {this.RAW, this.VOLTS}
                    [RampSize, RampUnits] = this.GetRampSize(ChannelNumber, 0);
                case {this.METRIC, this.FORCE}
                    [RampSize, RampUnits] = this.GetRampSize(ChannelNumber, 1);
                otherwise
                    error('Wrong UnitType parameter.')
            end
            zIncr = RampSize / sizeRetrace;
            zAccum = 0;
            % Right align force curves
            if sizeTrace < sizeRetrace
                zAccum = (sizeRetrace - sizeTrace) * zIncr;
            end
            %reverse trace
            yTrace = yTrace(end:-1:1);
            yLabel = sprintf('%s (%s)',type_desc, scale_units );
            if isSeparation == 1 && (UnitType == this.FORCE || UnitType == this.METRIC)
                xLabel = sprintf('Separation (%s)', RampUnits);
                
                dSepScale = 1;
                if UnitType == this.FORCE
                    dSepScale = 1/this.GetSpringConstant(ChannelNumber);
                end
                delta = yTrace(sizeTrace);
                maxZ = zIncr * sizeRetrace;
                %xTrace
                for i = 1:sizeTrace
                    xTrace(i) = ((maxZ - zAccum) - (delta - yTrace(i)) * dSepScale);
                    zAccum = zAccum + zIncr;
                end
                zAccum = zAccum - zIncr;
                %xRetrace
                for i = 1:sizeRetrace
                    xRetrace(i) = ((maxZ - zAccum) - (delta - yRetrace(i)) * dSepScale);
                    zAccum = zAccum - zIncr;
                end
  
            else
                xLabel = sprintf('Z (%s)', RampUnits);
                %xTrace
                for i = 1:sizeTrace
                    xTrace(i) = zAccum;
                    zAccum = zAccum + zIncr;
                end
                zAccum = zAccum - zIncr;
                %xRetrace
                for i = 1:sizeRetrace
                    xRetrace(i) = zAccum;
                    zAccum = zAccum - zIncr;
                end
            end
        end
        
        function [xTrace, xRetrace, yTrace, yRetrace, xLabel, yLabel] = CreateForceVolumeForceCurveZplot(this, CurveNumber, UnitType, IsSeparation)
            %Returns x, y trace and retrace values and their labels of
            %Force curve Z plot in Force volume file
			%Input: 
			%CurveNumber: ranges from 1 to Number of Curves in the file.
			%UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW
            yTrace = [];
			yRetrace = [];
			scale_units = '';
			type_desc = '';
			[yTrace, yRetrace, scale_units, type_desc] = this.GetForceVolumeForceCurveData(CurveNumber, UnitType);
			sizeTrace = max(size(yTrace));
			sizeRetrace = max(size(yRetrace));
			xTrace = double(zeros(sizeTrace, 1));
			xRetrace = double(zeros(sizeRetrace, 1));
            RampSize = 0;
            RampUnits = '';
            switch UnitType
                case {this.RAW, this.VOLTS}
                    [RampSize, RampUnits] = this.GetRampSize(2, 0);
                case {this.METRIC, this.FORCE}
                    [RampSize, RampUnits] = this.GetRampSize(2, 1);
                otherwise
                    error('Wrong UnitType parameter.')
            end
            zIncr = RampSize / sizeRetrace;
            zAccum = 0;
            % Right align force curves
            if sizeTrace < sizeRetrace
                zAccum = (sizeRetrace - sizeTrace) * zIncr;
            end
            %reverse trace
            yTrace = yTrace(end:-1:1);
            yLabel = sprintf('%s (%s)',type_desc, scale_units );
            
            if IsSeparation == 1 && (UnitType == this.FORCE || UnitType == this.METRIC)
                xLabel = sprintf('Separation (%s)', RampUnits);
                
                dSepScale = 1;
                if UnitType == this.FORCE
                    dSepScale = 1/this.GetSpringConstant(2);
                end
                delta = yTrace(sizeTrace);
                maxZ = zIncr * sizeRetrace;
                %xTrace
                for i = 1:sizeTrace
                    xTrace(i) = ((maxZ - zAccum) - (delta - yTrace(i)) * dSepScale);
                    zAccum = zAccum + zIncr;
                end
                zAccum = zAccum - zIncr;
                %xRetrace
                for i = 1:sizeRetrace
                    xRetrace(i) = ((maxZ - zAccum) - (delta - yRetrace(i)) * dSepScale);
                    zAccum = zAccum - zIncr;
                end
  
            else
                xLabel = sprintf('Z (%s)', RampUnits);
                %xTrace
                for i = 1:sizeTrace
                    xTrace(i) = zAccum;
                    zAccum = zAccum + zIncr;
                end
                zAccum = zAccum - zIncr;
                %xRetrace
                for i = 1:sizeRetrace
                    xRetrace(i) = zAccum;
                    zAccum = zAccum - zIncr;
                end
            end
        end
        
        function [xTrace, xRetrace, yTrace, yRetrace, xLabel, yLabel] = CreatePeakForceForceCurveZplot(this, CurveNumber, UnitType, IsSeparation)
            %Returns x, y trace and retrace values and their labels of
            %Force curve Z plot in peak force file
			%Input: 
			%CurveNumber: ranges from 1 to Number of Curves in the file.
			%UnitType: this.METRIC, this.VOLTS, this.FORCE, this.RAW
            [yTrace, yRetrace, scale_units, type_desc] = this.GetForceVolumeForceCurveData(CurveNumber, UnitType);
            sizeTrace = max(size(yTrace));
            sizeRetrace = max(size(yRetrace));

            [xTrace, xRetrace, x_scale_units] = this.GetPeakForceCaptureZData(sizeTrace, sizeRetrace);
            yLabel = sprintf('%s (%s)',type_desc, scale_units);
            
            if IsSeparation == 1 && (UnitType == this.FORCE || UnitType == this.METRIC)
                xLabel = sprintf('Separation (%s)', x_scale_units);
                
                dSepScale = 1;
                if UnitType == this.FORCE
                    dSepScale = 1/this.GetSpringConstant(2);
                end
                %xTrace
                maxDefl = yTrace(1);
                maxZ = xTrace(1);
                for i = 1:sizeTrace
                    xTrace(i) = ((maxZ - xTrace(i)) - (maxDefl - yTrace(i)) * dSepScale);
                end
                %xRetrace
                maxDefl = yRetrace(1);
                maxZ = xRetrace(1);
                for i = 1:sizeRetrace
                    xRetrace(i) = ((maxZ - xRetrace(i)) - (maxDefl - yRetrace(i)) * dSepScale);
                end
            else
                xLabel = sprintf('Z (%s)', x_scale_units);
            end
        end
                       
		function [xData, yData, xLabel, yLabel] = CreateHSDCTimePlot(this, ChannelNumber, UnitType)
            %Returns x, y data and their labels 
			%Input: 
			%ChannelNumber: ranges from 1 to Number of Channels in the file.
			%UnitType: this.METRIC, this.VOLTS, this.RAW
         	scale_units = '';
			type_desc = '';
            [yData, scale_units, type_desc] = this.GetHSDCData(ChannelNumber, UnitType);
			sizeY = max(size(yData));
		    hsdcRate = this.GetHsdcRate(ChannelNumber);
            timeIncr = 0;
            taccum = 0;
            xData = double(zeros(sizeY, 1));
            if hsdcRate ~=0
                timeIncr = 1 / hsdcRate;
            end
            for i = 1:sizeY
                xData(i) = taccum;
                taccum = taccum + timeIncr;
            end
            yLabel = sprintf('%s (%s)',type_desc, scale_units );
            xLabel = 'Time (s)';
        end
        
        function [a, b, c, fitTypeStr] = GetPlanefitSettings(this, ChannelNumber)
			%Returns the planefit settings in Image file
			%Output:
            %a, b, c coefficients in z = ax + by + c
			%fitTypeStr: type of plane fit
           	a = 0;
            b = 0;
            c = 0;
            fitType = -1;
            fitTypeStr = '';
            if this.IsOpen
                if ChannelNumber ~= 0
                    ChannelNumber = ChannelNumber - 1;
                end
		        [ret, a, b, c, fitType] = calllib('DataSourceDLL','DataSourceDllGetPlanefitSettings', ChannelNumber, a, b, c, fitType);
                switch fitType
                    case 0
                        fitTypeStr = 'NEEDSFULL';    %full planefitting needs to be done
                    case 1
                        fitTypeStr = 'OFFSET';       %offset has been removed
                    case 2
                        fitTypeStr = 'LOCAL';        %actual plane in data has been removed
                    case 3
                        fitTypeStr = 'CAPTURED';     %captured plane has been removed
                    case 4
                        fitTypeStr = 'NEEDSOFFSET';  %offset removal needs to be done
                    case 5
                        fitTypeStr = 'NOTHING'       %no planefit has been removed
                    case 6
                        fitTypeStr = 'NEEDSNOTHING'  %don't do any planefitting            
                    otherwise
                        error('Wrong planefit fitType.');
                end
			end		
        end
        
		function [HalfAngle] = GetHalfAngle(this)
			%Returns the Half Angle parameter
			%Input: 
			HalfAngle = 0.0;
			if this.IsOpen
				[ret, HalfAngle] = calllib('DataSourceDLL','DataSourceDllGetHalfAngle', HalfAngle);
			end
		end
    end
end

		
