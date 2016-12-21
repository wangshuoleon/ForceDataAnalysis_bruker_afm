// Bruker Confidential  
// Copyright 2012. All rights reserved.
//

#if !defined(DataSourceDll_h)
#define DataSourceDll_h

#if defined(DataSourceDll_EXPORTS)
#define DataSourceDllDLLDIR    __declspec(dllexport)   // export DLL information
#else
#define DataSourceDllDLLDIR    __declspec(dllimport)   // import DLL information
#endif 


#if defined(__cplusplus)
class DataSourceDllDLLDIR DataSourceDll
{
public:
	DataSourceDll();
	~DataSourceDll(void);
	// For all functions with int return value: return 1 for success, -1 (< 0) upon failure
	static int Open(char * pFileName);
	static int Close();
	
	enum ScanUnits { VOLTS_UNITS, METRIC_UNITS, FORCE_UNITS, LSB_UNITS };
	
	//Metric data
	static int GetForceCurveData( int ChannelNumber, double * pTrace, double * pRetrace, enum ScanUnits unit );
	//Force Volume image data
	static int GetForceVolumeImageData( double * pImage, int MaxDataSize, int * ActualDataSize, enum ScanUnits unit );
	//Force Volume force curve data
	static int GetForceVolumeForceCurveData( int BufferNumber, double * pTrace, double * pRetrace,
											 int *tracePts, int *retracePts, int MaxDataSize, enum ScanUnits unit );
	//Peak force capture z data
	static int GetPeakForceCaptureZData(double * pTrace, double * pRetrace, int tracePts, int retracePts);
	//HSDC data
	static int GetHSDCForceCurveData( int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize, enum ScanUnits unit );
	//Image data
	static int GetImageData(int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize, enum ScanUnits unit);
	//Parameters
	static int GetSamplesPerLine( int ChannelNumber, int * SamplesPerLine );
	static int GetNumberOfLines( int ChannelNumber, int * NumberOfLines );
	static int GetForceSamplesPerLine( int ChannelNumber, int * SamplesPerLine );
	static int GetNumberOfTracePoints( int ChannelNumber, int * SamplesPerLine);
	static int GetNumberOfForceCurves( int * NumberOfCurves );
	static int GetZSensitivitySoftScale(int ChannelNumber, double* ZSensitivitySoftScale );
	static int GetZSensitivityUnits( int ChannelNumber, char* ZSensitivityUnits );
	static int GetNumberOfPointsPerCurve( int ChannelNumber, int * NumberOfPoints );
	static int GetDataBufferSize( int ChannelNumber, int * BufferSize );
	static int GetScalingFactor( int channel, double * ScalingFactor, bool isMetric = true );
	static int GetRampSize( int channel, double * RampSize, bool isMetric = true );
	static int GetZScaleInSwUnits( int channel, double * ZScale );
	static int GetZScaleInHwUnits( int channel, double * ZScale );
	static int GetPoissonRatio( double * PRatio );
	static int GetTipRadius( double * TipRadius );
	static int GetReverseRampVelocity( int Channel, double * Velocity, bool isMetric = true);
	static int GetForwardRampVelocity( int Channel, double * Velocity, bool isMetric = true);
	static int GetForceSpringConstant( int Channel, double * SpringConst );
	static int GetNumberOfChannels( int * NumberOfChannels );
	static char* GetRampUnits( int channel, bool isMetric = true );
	static char* GetDataScaleUnits( int ChannelNumber, bool isMetric );
	static char* GetDataTypeDesc( int ChannelNumber );
	static int GetHalfAngle( double * HalfAngle );
	static int GetHsdcRate(int channel, double * HsdcRate);
	static int GetImageAspectRatio(int channel, double * AspectRatio);
	static int GetPlanefitSettings( int Channel , double * a, double * b, double * c, int * FitType);
	static int GetPeakForceTappingFreq(double *freq);
	static int GetScanSize(int channel, double *scanSize);
	static char* GetScanSizeUnit(int channel);
	static int GetForcesPerLine(int *forcesPerLine);
};

#endif

// C wrappers for HarmoniXDll
#if defined(__cplusplus)
extern "C" {
#endif
DataSourceDllDLLDIR int DataSourceDllOpen( char * pFileName );
DataSourceDllDLLDIR int DataSourceDllClose();
DataSourceDllDLLDIR int DataSourceDllGetForceCurveData( int ChannelNumber, double * pTrace, double * pRetrace );
DataSourceDllDLLDIR int DataSourceDllGetForceCurveMetricData( int ChannelNumber, double * pTrace, double * pRetrace );
DataSourceDllDLLDIR int DataSourceDllGetForceCurveForceData( int ChannelNumber, double * pTrace, double * pRetrace );
DataSourceDllDLLDIR int DataSourceDllGetForceCurveVoltsData( int ChannelNumber, double * pTrace, double * pRetrace );

//force volume
DataSourceDllDLLDIR int DataSourceDllGetForceVolumeImageData( double * pImage, int MaxDataSize, int * ActualDataSize);
DataSourceDllDLLDIR int DataSourceDllGetForceVolumeMetricImageData( double * pImage, int MaxDataSize, int * ActualDataSize);
DataSourceDllDLLDIR int DataSourceDllGetForceVolumeVoltsImageData( double * pImage, int MaxDataSize, int * ActualDataSize);
DataSourceDllDLLDIR int DataSourceDllGetForceVolumeForceCurveData( int CurveNumber, double * pTrace, double * pRetrace, int * tracePts, int * retracePts, int MaxDataSize);
DataSourceDllDLLDIR int DataSourceDllGetForceVolumeMetricForceCurveData( int CurveNumber, double * pTrace, double * pRetrace, int * tracePts, int * retracePts, int MaxDataSize);
DataSourceDllDLLDIR int DataSourceDllGetForceVolumeVoltsForceCurveData( int CurveNumber, double * pTrace, double * pRetrace, int * tracePts, int * retracePts, int MaxDataSize);
DataSourceDllDLLDIR int DataSourceDllGetForceVolumeForceForceCurveData( int CurveNumber, double * pTrace, double * pRetrace, int * tracePts, int * retracePts, int MaxDataSize);
DataSourceDllDLLDIR int DataSourceDllGetPeakForceCaptureZData(double * pTrace, double * pRetrace, int tracePts, int retracePts);

//HSDC
DataSourceDllDLLDIR int DataSourceDllGetHSDCForceCurveData( int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize );
DataSourceDllDLLDIR int DataSourceDllGetHSDCMetricForceCurveData( int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize );
DataSourceDllDLLDIR int DataSourceDllGetHSDCVoltsForceCurveData( int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize );

//Image
DataSourceDllDLLDIR int DataSourceDllGetImageData( int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize );
DataSourceDllDLLDIR int DataSourceDllGetImageMetricData( int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize );
DataSourceDllDLLDIR int DataSourceDllGetImageVoltsData( int ChannelNumber, double * pBuffer, int MaxDataSize, int * ActualDataSize );

//Parameters
DataSourceDllDLLDIR int DataSourceDllGetForceSamplesPerLine( int ChannelNumber, int * SamplesPerLine );
DataSourceDllDLLDIR int DataSourceDllGetNumberOfTracePoints( int ChannelNumber, int * SamplesPerLine );
DataSourceDllDLLDIR int DataSourceDllGetNumberOfPointsPerCurve( int ChannelNumber, int * NumberOfPoints );
DataSourceDllDLLDIR int DataSourceDllGetNumberOfForceCurves(int * NumberOfChannels );
DataSourceDllDLLDIR int DataSourceDllGetZSensitivitySoftScale(int ChannelNumber, double* ZSensitivitySoftScale );
DataSourceDllDLLDIR int DataSourceDllGetZSensitivityUnits( int ChannelNumber, char* ZSensitivityUnits );
DataSourceDllDLLDIR int DataSourceDllGetNumberOfLines( int ChannelNumber, int * NumberOfLines );
DataSourceDllDLLDIR int DataSourceDllGetSamplesPerLine( int ChannelNumber, int * SamplesPerLine );
DataSourceDllDLLDIR int DataSourceDllGetDataBufferSize( int ChannelNumber, int * BufferSize );
DataSourceDllDLLDIR int DataSourceDllGetScalingFactor( int channel, double * ScalingFactor, bool isMetric );
DataSourceDllDLLDIR char* DataSourceDllGetMetricDataScaleUnits( int ChannelNumber );
DataSourceDllDLLDIR char* DataSourceDllGetVoltsDataScaleUnits( int ChannelNumber );
DataSourceDllDLLDIR char* DataSourceDllGetForceDataScaleUnits( int ChannelNumber );
DataSourceDllDLLDIR char* DataSourceDllGetDataTypeDesc( int ChannelNumber );
DataSourceDllDLLDIR char* DataSourceDllGetRampUnits( int ChannelNumber, bool isMetric );
DataSourceDllDLLDIR int DataSourceDllGetRampSize( int channel, double * RampSize, bool isMetric);
DataSourceDllDLLDIR int DataSourceDllGetZScaleInSwUnits( int channel, double * ZScale );
DataSourceDllDLLDIR int DataSourceDllGetZScaleInHwUnits( int channel, double * ZScale );
DataSourceDllDLLDIR int DataSourceDllGetTipRadius( double * TipRadius );
DataSourceDllDLLDIR int DataSourceDllGetPoissonRatio( double * PoissonRatio );
DataSourceDllDLLDIR int DataSourceDllGetForwardRampVelocity( int Channel, double * Velocity, bool isMetric );
DataSourceDllDLLDIR int DataSourceDllGetReverseRampVelocity( int Channel, double * Velocity, bool isMetric );
DataSourceDllDLLDIR int DataSourceDllGetForceSpringConstant( int Channel, double * SpringConst);
DataSourceDllDLLDIR int DataSourceDllGetHalfAngle( double * HalfAngle );
DataSourceDllDLLDIR int DataSourceDllGetNumberOfChannels( int * NumberOfChannels );
DataSourceDllDLLDIR int DataSourceDllGetHsdcRate( int Channel, double * HsdcRate);
DataSourceDllDLLDIR int DataSourceDllGetImageAspectRatio( int Channel, double * AspectRatio);
DataSourceDllDLLDIR int DataSourceDllGetPlanefitSettings( int Channel , double * a, double * b, double * c, int * FitType);
DataSourceDllDLLDIR int DataSourceDllGetPeakForceTappingFreq(double * freq); //return peak force tapping frequency in Hz
DataSourceDllDLLDIR int DataSourceDllGetScanSize(int channel, double *scanSize);
DataSourceDllDLLDIR char* DataSourceDllGetScanSizeUnit(int channel);
DataSourceDllDLLDIR int DataSourceDllGetForcesPerLine(int *forcesPerLine);
#if defined(__cplusplus)
}
#endif

#endif
