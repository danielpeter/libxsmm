#!/bin/sh

cat << EOM
/******************************************************************************
** Copyright (c) 2016, Intel Corporation                                     **
** All rights reserved.                                                      **
**                                                                           **
** Redistribution and use in source and binary forms, with or without        **
** modification, are permitted provided that the following conditions        **
** are met:                                                                  **
** 1. Redistributions of source code must retain the above copyright         **
**    notice, this list of conditions and the following disclaimer.          **
** 2. Redistributions in binary form must reproduce the above copyright      **
**    notice, this list of conditions and the following disclaimer in the    **
**    documentation and/or other materials provided with the distribution.   **
** 3. Neither the name of the copyright holder nor the names of its          **
**    contributors may be used to endorse or promote products derived        **
**    from this software without specific prior written permission.          **
**                                                                           **
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS       **
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT         **
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR     **
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT      **
** HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    **
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED  **
** TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR    **
** PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF    **
** LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING      **
** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS        **
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.              **
******************************************************************************/
/* Hans Pabst (Intel Corp.)
******************************************************************************/
#ifndef LIBXSMM_SOURCE_H
#define LIBXSMM_SOURCE_H

#if !defined(LIBXSMM_INTERNAL_API)
# if defined(__cplusplus)
#   define LIBXSMM_INTERNAL_API
# else
#   define LIBXSMM_INTERNAL_API static
# endif
# define LIBXSMM_INTERNAL_API_DEFINITION LIBXSMM_INLINE
#else
# error Please do not include any LIBXSMM header prior to libxsmm_source.h!
#endif

#if defined(LIBXSMM_BUILD)
# error LIBXSMM_BUILD cannot be defined for the header-only LIBXSMM!
#endif

#include "libxsmm.h"
#include "libxsmm_timer.h"

/**
 * This header is intentionally called "libxsmm_source.h" since the followings blocks
 * include *internal* header and source files, and thereby exposes LIBXSMM's implementation.
 * This so-called "header-only" usage model gives up the clearly defined binary interface
 * including the support for hot-fixes after deployment (shared library), and requires
 * to rebuild client code for every (internal) change within LIBXSMM. Please make sure to
 * only rely on the public interface as the internal implementation may change without
 * further notice.
 */

EOM

HERE=$(cd $(dirname $0); pwd -P)

for FILE in $(ls -1 ${HERE}/../src/*.h); do
  BASENAME=$(basename ${FILE})
  if [ "" != "$(echo ${BASENAME} | grep -v '.template.')" ]; then
    echo "#include \"../src/${BASENAME}\""
  fi
done

echo

# good-enough pattern to match a main function, and to exclude this translation unit
for FILE in $(grep -L "main\s*(.*)" ${HERE}/../src/*.c); do
  BASENAME=$(basename ${FILE})
  echo "#include \"../src/${BASENAME}\""
done

cat << EOM

#endif /*LIBXSMM_SOURCE_H*/
EOM
