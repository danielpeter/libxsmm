# Export all variables to sub-make processes.
#.EXPORT_ALL_VARIABLES: #export

# Automatically disable parallel builds
# depending on the version of GNU Make.
# MAKE_PARALLEL=0: disable explicitly
# MAKE_PARALLEL=1: enable explicitly
ifeq (0,$(MAKE_PARALLEL))
.NOTPARALLEL:
else ifeq (,$(MAKE_PARALLEL))
ifneq (3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
.NOTPARALLEL:
endif
endif

ROOTDIR = $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
DEPDIR = ../..
SRCDIR = $(ROOTDIR)
INCDIR = .
BLDDIR = build
OUTDIR = .

CXXFLAGS = $(NULL)
CFLAGS = $(NULL)
DFLAGS = $(NULL)
IFLAGS = -I$(INCDIR) -I$(DEPDIR)/include

BLAS = 1
OMP = 1
SYM = 1

BLAS_STATIC = 0

# include common Makefile artifacts
include $(DEPDIR)/Makefile.inc

ifneq (,$(strip $(wildcard $(LIBNAME).$(SLIBEXT))))
  DEPSTATIC = 1
else
  DEPSTATIC = 0
endif

WRAP ?= 0
ifneq (Darwin,$(UNAME))
ifneq (0,$(DEPSTATIC))
  WRAP = 1
endif
endif

OUTNAME := $(shell basename $(ROOTDIR))
HEADERS := $(shell ls -1 $(INCDIR)/*.h   2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(INCDIR)/*.hpp 2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(INCDIR)/*.hxx 2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(INCDIR)/*.hh  2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(SRCDIR)/*.h   2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(SRCDIR)/*.hpp 2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(SRCDIR)/*.hxx 2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(SRCDIR)/*.hh  2> /dev/null | tr "\n" " ")
CPPSRCS := $(shell ls -1 $(SRCDIR)/*.cpp 2> /dev/null | tr "\n" " ")
CXXSRCS := $(shell ls -1 $(SRCDIR)/*.cxx 2> /dev/null | tr "\n" " ")
CCXSRCS := $(shell ls -1 $(SRCDIR)/*.cc  2> /dev/null | tr "\n" " ")
CSOURCS := $(shell ls -1 $(SRCDIR)/*.c   2> /dev/null | tr "\n" " ")
FXXSRCS := $(shell ls -1 $(SRCDIR)/*.f   2> /dev/null | tr "\n" " ")
F77SRCS := $(shell ls -1 $(SRCDIR)/*.F   2> /dev/null | tr "\n" " ")
F90SRCS := $(shell ls -1 $(SRCDIR)/*.f90 2> /dev/null | tr "\n" " ") \
           $(shell ls -1 $(SRCDIR)/*.F90 2> /dev/null | tr "\n" " ")
CPPOBJS := $(patsubst %,$(BLDDIR)/%,$(notdir $(CPPSRCS:.cpp=-cpp.o)))
CXXOBJS := $(patsubst %,$(BLDDIR)/%,$(notdir $(CXXSRCS:.cxx=-cxx.o)))
CCXOBJS := $(patsubst %,$(BLDDIR)/%,$(notdir $(CCXSRCS:.cc=-cc.o)))
COBJCTS := $(patsubst %,$(BLDDIR)/%,$(notdir $(CSOURCS:.c=-c.o)))
FXXOBJS := $(patsubst %,$(BLDDIR)/%,$(notdir $(FXXSRCS:.f=-f.o)))
F77OBJS := $(patsubst %,$(BLDDIR)/%,$(notdir $(F77SRCS:.F=-f77.o)))
F90OBJS := $(patsubst %,$(BLDDIR)/%,$(notdir $(F90SRCS:.f90=-f90.o)))
F90OBJS := $(patsubst %,$(BLDDIR)/%,$(notdir $(F90OBJS:.F90=-f90.o)))
SOURCES := $(CPPSRCS) $(CXXSRCS) $(CCXSRCS) $(CSOURCS)
OBJECTS := $(CPPOBJS) $(CXXOBJS) $(CCXOBJS) $(COBJCTS)
FTNSRCS := $(FXXSRCS) $(F77SRCS) $(F90SRCS)
MODULES := $(addsuffix .mod,$(basename $(FTNSRCS))) $(addsuffix .modmic,$(basename $(FTNSRCS)))
FTNOBJS := $(FXXOBJS) $(F77OBJS) $(F90OBJS)
XFILES := $(OUTDIR)/dgemm-blas $(OUTDIR)/dgemm-wrap

.PHONY: all
all: $(XFILES)

$(OUTDIR)/dgemm-blas: $(BLDDIR)/dgemm-c.o $(OUTDIR)/.make
	$(LD) -o $@ $< $(SLDFLAGS) $(LDFLAGS) $(CLDFLAGS)
ifeq (Darwin,$(UNAME))
	$(info ================================================================================)
	$(info The static link-time wrapper mechanism is not supported under OS X!)
	$(info ================================================================================)
endif

ifneq (0,$(WRAP))
$(OUTDIR)/dgemm-wrap: $(BLDDIR)/dgemm-c.o $(OUTDIR)/.make
ifneq (0,$(OMP))
	$(LD) -o $@ $< $(call libdir,$(LIBNAME)ext.$(LIBEXT))  \
		$(call libdir,$(LIBNAME).$(LIBEXT)) $(SLDFLAGS) $(LDFLAGS) $(CLDFLAGS) -Wl,--wrap=dgemm_
else ifneq (,$(strip $(OMPLIB)))
	$(LD) -o $@ $< $(call libdir,$(LIBNAME)ext.$(LIBEXT))  \
		$(call libdir,$(LIBNAME).$(LIBEXT)) $(SLDFLAGS) $(LDFLAGS) $(CLDFLAGS) -Wl,--wrap=dgemm_ \
		$(XLIB_BEGIN) -l$(OMPLIB) $(XLIB_END)
else # should not happen
	$(LD) -o $@ $< $(call libdir,$(LIBNAME)ext.$(LIBEXT))  \
		$(call libdir,$(LIBNAME).$(LIBEXT)) $(SLDFLAGS) $(LDFLAGS) $(CLDFLAGS) -Wl,--wrap=dgemm_
endif
else
.PHONY: $(OUTDIR)/dgemm-wrap
endif

.PHONY: test
test: $(OUTDIR)/.make $(OUTDIR)/dgemm-test.sh $(XFILES)
	@bash $(OUTDIR)/dgemm-test.sh 500000

$(BLDDIR)/%-cpp.o: $(SRCDIR)/%.cpp .state $(BLDDIR)/.make $(HEADERS) $(ROOTDIR)/Makefile $(DEPDIR)/Makefile.inc $(LIBNAME).$(LIBEXT)
	$(CXX) $(CXXFLAGS) $(DFLAGS) $(IFLAGS) $(TARGET) -c $< -o $@

$(BLDDIR)/%-c.o: $(SRCDIR)/%.c .state $(BLDDIR)/.make $(HEADERS) $(ROOTDIR)/Makefile $(DEPDIR)/Makefile.inc $(LIBNAME).$(LIBEXT)
	$(CC) $(CFLAGS) $(DFLAGS) $(IFLAGS) $(TARGET) -c $< -o $@

$(BLDDIR)/%-f.o: $(SRCDIR)/%.f .state $(BLDDIR)/.make $(ROOTDIR)/Makefile $(DEPDIR)/Makefile.inc $(LIBNAME).$(LIBEXT)
	$(FC) $(FCMTFLAGS) $(FCFLAGS) $(DFLAGS) $(IFLAGS) $(TARGET) -c $< -o $@

$(BLDDIR)/%-f90.o: $(SRCDIR)/%.f90 .state $(BLDDIR)/.make $(ROOTDIR)/Makefile $(DEPDIR)/Makefile.inc $(LIBNAME).$(LIBEXT)
	$(FC) $(FCMTFLAGS) $(FCFLAGS) $(DFLAGS) $(IFLAGS) $(TARGET) -c $< -o $@

$(BLDDIR)/%-f90.o: $(SRCDIR)/%.F90 .state $(BLDDIR)/.make $(ROOTDIR)/Makefile $(DEPDIR)/Makefile.inc $(LIBNAME).$(LIBEXT)
	$(FC) $(FCMTFLAGS) $(FCFLAGS) $(DFLAGS) $(IFLAGS) $(TARGET) -c $< -o $@

$(BLDDIR)/%-f77.o: $(SRCDIR)/%.F .state $(BLDDIR)/.make $(ROOTDIR)/Makefile $(DEPDIR)/Makefile.inc $(LIBNAME).$(LIBEXT)
	$(FC) $(FCMTFLAGS) $(FCFLAGS) $(DFLAGS) $(IFLAGS) $(TARGET) -c $< -o $@

.PHONY: clean-minimal
clean-minimal:
	@rm -f $(OBJECTS) $(FTNOBJS)
	@rm -f fit.log *.dat

.PHONY: clean
clean: clean-minimal
ifneq ($(abspath $(BLDDIR)),$(ROOTDIR))
ifneq ($(abspath $(BLDDIR)),$(abspath .))
	@rm -rf $(BLDDIR)
endif
endif

.PHONY: realclean
realclean: clean
ifneq ($(abspath $(OUTDIR)),$(ROOTDIR))
ifneq ($(abspath $(OUTDIR)),$(abspath .))
	@rm -rf $(OUTDIR)
else
	@rm -f $(XFILES)
endif
else
	@rm -f $(XFILES)
endif
	@rm -f $(MODULES)
	@rm -f *.gcno *.gcda *.gcov
	@rm -f $(OUTDIR)/libxsmm.$(DLIBEXT)
	@rm -f $(OUTDIR)/*.bin
	@rm -f .make .state

