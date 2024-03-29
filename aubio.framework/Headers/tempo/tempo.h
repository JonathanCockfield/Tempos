/*
  Copyright (C) 2006-2013 Paul Brossier <piem@aubio.org>

  This file is part of aubio.

  aubio is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  aubio is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with aubio.  If not, see <http://www.gnu.org/licenses/>.

*/

/** \file

  Tempo detection object

  This object stores all the memory required for tempo detection algorithm
  and returns the estimated beat locations.

  \example tempo/test-tempo.c
  \example examples/aubiotrack.c

*/

#ifndef _AUBIO_TEMPO_H
#define _AUBIO_TEMPO_H

#ifdef __cplusplus
extern "C" {
#endif

/** tempo detection structure */
typedef struct _aubio_tempo_t aubio_tempo_t;

/** create tempo detection object

  \param method beat tracking method, unused for now (use "default")
  \param buf_size length of FFT
  \param hop_size number of frames between two consecutive runs
  \param samplerate sampling rate of the signal to analyze

  \return newly created ::aubio_tempo_t if successful, `NULL` otherwise

*/
aubio_tempo_t * new_aubio_tempo (const char_t * method,
    uint_t buf_size, uint_t hop_size, uint_t samplerate);

/** execute tempo detection

  \param o beat tracking object
  \param input new samples
  \param tempo output beats

*/
void aubio_tempo_do (aubio_tempo_t *o, fvec_t * input, fvec_t * tempo);

/** get the time of the latest beat detected, in samples

  \param o tempo detection object as returned by ::new_aubio_tempo

*/
uint_t aubio_tempo_get_last (aubio_tempo_t *o);

/** get the time of the latest beat detected, in seconds

  \param o tempo detection object as returned by ::new_aubio_tempo

*/
smpl_t aubio_tempo_get_last_s (aubio_tempo_t *o);

/** get the time of the latest beat detected, in milliseconds

  \param o tempo detection object as returned by ::new_aubio_tempo

*/
smpl_t aubio_tempo_get_last_ms (aubio_tempo_t *o);

/** set tempo detection silence threshold

  \param o beat tracking object
  \param silence new silence threshold, in dB

  \return `0` if successful, non-zero otherwise

*/
uint_t aubio_tempo_set_silence(aubio_tempo_t * o, smpl_t silence);

/** get tempo detection silence threshold

  \param o tempo detection object as returned by new_aubio_tempo()

  \return current silence threshold

*/
smpl_t aubio_tempo_get_silence(aubio_tempo_t * o);

/** set tempo detection peak picking threshold

  \param o beat tracking object
  \param threshold new threshold

  \return `0` if successful, non-zero otherwise

*/
uint_t aubio_tempo_set_threshold(aubio_tempo_t * o, smpl_t threshold);

/** get tempo peak picking threshold

  \param o tempo detection object as returned by new_aubio_tempo()

  \return current tempo detection threshold

*/
smpl_t aubio_tempo_get_threshold(aubio_tempo_t * o);

/** get current tempo

  \param o beat tracking object

  \return the currently observed tempo, or `0` if no consistent value is found

*/
smpl_t aubio_tempo_get_bpm(aubio_tempo_t * o);

/** get current tempo confidence

  \param o beat tracking object

  \return confidence with which the tempo has been observed, `0` if no
  consistent value is found.

*/
smpl_t aubio_tempo_get_confidence(aubio_tempo_t * o);

/** delete tempo detection object

  \param o beat tracking object

*/
void del_aubio_tempo(aubio_tempo_t * o);

#ifdef __cplusplus
}
#endif

#endif /* _AUBIO_TEMPO_H */
