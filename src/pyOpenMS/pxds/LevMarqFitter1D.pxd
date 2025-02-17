from Fitter1D cimport *

cdef extern from "<OpenMS/TRANSFORMATIONS/FEATUREFINDER/LevMarqFitter1D.h>" namespace "OpenMS":
    
    cdef cppclass LevMarqFitter1D(Fitter1D):
        # wrap-ignore
        # no-pxd-import
        LevMarqFitter1D() nogil except + # wrap-doc:Abstract class for 1D-model fitter using Levenberg-Marquardt algorithm for parameter optimization
        LevMarqFitter1D(LevMarqFitter1D &) nogil except +
