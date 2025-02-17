from String cimport *
from Software cimport *
from MetaInfoInterface cimport *

cdef extern from "<OpenMS/METADATA/MassAnalyzer.h>" namespace "OpenMS":

    cdef cppclass MassAnalyzer(MetaInfoInterface):
        # wrap-inherits:
        #    MetaInfoInterface

        MassAnalyzer() nogil except +
        MassAnalyzer(MassAnalyzer &) nogil except +

        # returns the analyzer type
        AnalyzerType getType() nogil except + # wrap-doc:Returns the analyzer type
        # sets the analyzer type
        void setType(AnalyzerType type) nogil except + # wrap-doc:Sets the analyzer type

        # returns the method used for determination of the resolution
        ResolutionMethod getResolutionMethod() nogil except + # wrap-doc:Returns the method used for determination of the resolution
        # sets the method used for determination of the resolution
        void setResolutionMethod(ResolutionMethod resolution_method) nogil except + # wrap-doc:Sets the method used for determination of the resolution

        # returns the resolution type
        ResolutionType getResolutionType() nogil except + # wrap-doc:Returns the resolution type
        # sets the resolution type
        void setResolutionType(ResolutionType resolution_type) nogil except + # wrap-doc:Sets the resolution type

        # returns the direction of scanning
        ScanDirection getScanDirection() nogil except + # wrap-doc:Returns the direction of scanning
        # sets the direction of scanning
        void setScanDirection(ScanDirection scan_direction) nogil except + # wrap-doc:Sets the direction of scanning

        # returns the scan law
        ScanLaw getScanLaw() nogil except + # wrap-doc:Returns the scan law
        # sets the scan law
        void setScanLaw(ScanLaw scan_law) nogil except + # wrap-doc:Sets the scan law

        # returns the reflectron state (for TOF)
        ReflectronState getReflectronState() nogil except + # wrap-doc:Returns the reflectron state (for TOF)
        # sets the reflectron state (for TOF)
        void setReflectronState(ReflectronState reflecton_state) nogil except + # wrap-doc:Sets the reflectron state (for TOF)

        # returns the resolution
        # The maximum m/z value at which two peaks can be resolved, according to one of the standard measures
        double getResolution() nogil except + # wrap-doc:Returns the resolution. The maximum m/z value at which two peaks can be resolved, according to one of the standard measures
        # sets the resolution
        void setResolution(double resolution) nogil except + # wrap-doc:Sets the resolution

        # returns the mass accuracy i.e. how much the theoretical mass may differ from the measured mass (in ppm)
        double getAccuracy() nogil except + # wrap-doc:Returns the mass accuracy i.e. how much the theoretical mass may differ from the measured mass (in ppm)
        # sets the accuracy  i.e. how much the theoretical mass may differ from the measured mass  (in ppm)
        void setAccuracy(double accuracy) nogil except + # wrap-doc:Sets the accuracy i.e. how much the theoretical mass may differ from the measured mass (in ppm)

        # returns the scan rate (in s)
        double getScanRate() nogil except + # wrap-doc:Returns the scan rate (in s)
        # sets the scan rate (in s)
        void setScanRate(double scan_rate) nogil except + # wrap-doc:Sets the scan rate (in s)

        # returns the scan time for a single scan (in s)
        double getScanTime() nogil except + # wrap-doc:Returns the scan time for a single scan (in s)
        # sets the scan time for a single scan (in s)
        void setScanTime(double scan_time) nogil except + # wrap-doc:Sets the scan time for a single scan (in s)

        # returns the path length for a TOF mass analyzer (in meter)
        double getTOFTotalPathLength() nogil except + # wrap-doc:Returns the path length for a TOF mass analyzer (in meter)
        # sets the path length for a TOF mass analyzer (in meter)
        void setTOFTotalPathLength(double TOF_total_path_length) nogil except + # wrap-doc:Sets the path length for a TOF mass analyzer (in meter)

        # returns the isolation width i.e. in which m/z range the precursor ion is selected for MS to the n (in m/z)
        double getIsolationWidth() nogil except + # wrap-doc:Returns the isolation width i.e. in which m/z range the precursor ion is selected for MS to the n (in m/z)
        # sets the isolation width i.e. in which m/z range the precursor ion is selected for MS to the n (in m/z)
        void setIsolationWidth(double isolation_width) nogil except + # wrap-doc:Sets the isolation width i.e. in which m/z range the precursor ion is selected for MS to the n (in m/z)

        # returns the final MS exponent
        Int getFinalMSExponent() nogil except + # wrap-doc:Returns the final MS exponent
        # sets the final MS exponent
        void setFinalMSExponent(Int final_MS_exponent) nogil except + # wrap-doc:Sets the final MS exponent

        # returns the strength of the magnetic field (in T)
        double getMagneticFieldStrength() nogil except + # wrap-doc:Returns the strength of the magnetic field (in T)
        # sets the strength of the magnetic field (in T)
        void setMagneticFieldStrength(double magnetic_field_strength) nogil except + # wrap-doc:Sets the strength of the magnetic field (in T)

        #
        #   @brief returns the position of this part in the whole Instrument.
        #
        #   Order can be ignored, as long the instrument has this default setup:
        #   - one ion source
        #   - one or many mass analyzers
        #   - one ion detector
        #
        #   For more complex instruments the order should be defined.
        Int getOrder() nogil except +
        # sets the order
        void setOrder(Int order) nogil except +

cdef extern from "<OpenMS/METADATA/MassAnalyzer.h>" namespace "OpenMS::MassAnalyzer":

    # analyzer type
    cdef enum AnalyzerType:
      # wrap-attach:
      #     MassAnalyzer
      ANALYZERNULL,                         #< Unknown
      QUADRUPOLE,                           #< Quadrupole
      PAULIONTRAP,                          #< Quadrupole ion trap / Paul ion trap
      RADIALEJECTIONLINEARIONTRAP,          #< Radial ejection linear ion trap
      AXIALEJECTIONLINEARIONTRAP,           #< Axial ejection linear ion trap
      TOF,                                  #< Time-of-flight
      SECTOR,                               #< Magnetic sector
      FOURIERTRANSFORM,                     #< Fourier transform ion cyclotron resonance mass spectrometer
      IONSTORAGE,                           #< Ion storage
      ESA,                                  #< Electrostatic energy analyzer
      IT,                                   #< Ion trap
      SWIFT,                                #< Stored waveform inverse fourier transform
      CYCLOTRON,                            #< Cyclotron
      ORBITRAP,                             #< Orbitrap
      LIT,                                  #< Linear ion trap
      SIZE_OF_ANALYZERTYPE


    # Which of the available standard measures is used to define whether two peaks are separate
    cdef enum ResolutionMethod:
      # wrap-attach:
      #     MassAnalyzer
      RESMETHNULL,                  #< Unknown
      FWHM,                         #< Full width at half max
      TENPERCENTVALLEY,             #< Ten percent valley
      BASELINE,                     #< Baseline
      SIZE_OF_RESOLUTIONMETHOD

    # Resolution type
    cdef enum ResolutionType:
      # wrap-attach:
      #     MassAnalyzer
      RESTYPENULL,              #< Unknown
      CONSTANT,                 #< Constant
      PROPORTIONAL,             #< Proportional
      SIZE_OF_RESOLUTIONTYPE

    # direction of scanning
    cdef enum ScanDirection:
      # wrap-attach:
      #     MassAnalyzer
      SCANDIRNULL,              #< Unknown
      UP,                       #< Up
      DOWN,                     #< Down
      SIZE_OF_SCANDIRECTION

    #Scan law
    cdef enum ScanLaw:
      # wrap-attach:
      #     MassAnalyzer
      SCANLAWNULL,              #< Unknown
      EXPONENTIAL,              #< Unknown
      LINEAR,                   #< Linear
      QUADRATIC,                #< Quadratic
      SIZE_OF_SCANLAW

    #Reflectron state
    cdef enum ReflectronState:
      # wrap-attach:
      #     MassAnalyzer
      REFLSTATENULL,            #< Unknown
      ON,                       #< On
      OFF,                      #< Off
      NONE,                     #< None
      SIZE_OF_REFLECTRONSTATE

