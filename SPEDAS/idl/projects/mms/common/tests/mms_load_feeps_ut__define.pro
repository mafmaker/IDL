;+
;
; Unit tests for mms_load_feeps
;
; Requires both the SPEDAS QA folder (not distributed with SPEDAS) and mgunit
; in the local path
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-11-18 17:14:05 -0800 (Fri, 18 Nov 2016) $
; $LastChangedRevision: 22381 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/common/tests/mms_load_feeps_ut__define.pro $
;-

function mms_load_feeps_ut::test_pad_low_en
  mms_load_feeps
  mms_feeps_pad, energy=[30, 50]
  ; the previous call shouldn't have created a PAD variable
  assert, ~spd_data_exists('*keV_pad', '2015-12-15', '2015-12-16'), 'FEEPS PAD code is allowing energies less than 70 keV!'
  return, 1
end

function mms_load_feeps_ut::test_load_sitl_omni
  mms_load_feeps, probe=[2, 4], level='sitl', trange=['2016-09-15', '2016-09-16']
  assert, spd_data_exists('mms4_epd_feeps_srvy_sitl_electron_count_rate_omni mms4_epd_feeps_srvy_sitl_electron_count_rate_omni_spin mms4_epd_feeps_srvy_sitl_electron_intensity_omni mms4_epd_feeps_srvy_sitl_electron_intensity_omni_spin', '2016-09-15', '2016-09-16'), $
    'Problem loading omni-directional FEEPS spectra using SITL files'
  return, 1
end

function mms_load_feeps_ut::test_load_l1a_multi_datatypes
  mms_load_feeps, probes=4, level='l1a', datatype=['ion-top', 'electron-top']
  assert, spd_data_exists('mms4_epd_feeps_srvy_l1a_ion_top_sensor_counts_sensorid_6 mms4_epd_feeps_srvy_l1a_ion_top_sensor_counts_sensorid_7 mms4_epd_feeps_srvy_l1a_electron_top_sensor_counts_sensorid_3 mms4_epd_feeps_srvy_l1a_electron_top_sensor_counts_sensorid_4', '2015-12-15', '2015-12-16'), $
    'Problem loading FEEPS L1a data with multiple datatypes specified'
  return, 1
end

function mms_load_feeps_ut::test_load_l2_multi_datatypes
  mms_load_feeps, probe=2, level='l2', datatype=['ion', 'electron']
  assert, spd_data_exists('mms2_epd_feeps_srvy_l2_electron_top_count_rate_sensorid_3_clean_sun_removed mms2_epd_feeps_srvy_l2_electron_top_count_rate_sensorid_12_clean_sun_removed mms2_epd_feeps_srvy_l2_electron_bottom_count_rate_sensorid_3_clean_sun_removed mms2_epd_feeps_srvy_l2_electron_bottom_count_rate_sensorid_12_clean_sun_removed mms2_epd_feeps_srvy_l2_electron_bottom_intensity_sensorid_3_clean_sun_removed', '2015-12-15', '2015-12-16'), $
    'Problem with loading L2 FEEPS data with multiple datatypes'
  return, 1
end

function mms_load_feeps_ut::test_load_l1a_set_good_datatype
  mms_load_feeps, probes=3, level='l1a', datatype='ion-top'
  assert, spd_data_exists('mms3_epd_feeps_srvy_l1a_ion_top_sensor_counts_sensorid_6 mms3_epd_feeps_srvy_l1a_ion_top_sensor_counts_sensorid_7 mms3_epd_feeps_srvy_l1a_ion_top_sensor_counts_sensorid_8', '2015-12-15', '2015-12-16'), $
    'Problem loading FEEPS L1a data with valid datatype'
  assert, ~spd_data_exists('mms3_epd_feeps_srvy_l1a_ion_bottom_sensor_counts_sensorid_6 mms3_epd_feeps_srvy_l1a_ion_bottom_sensor_counts_sensorid_7 mms3_epd_feeps_srvy_l1a_ion_bottom_sensor_counts_sensorid_8', '2015-12-15', '2015-12-16'), $
    'Problem loading FEEPS L1a data with valid datatype'
  return, 1
end

function mms_load_feeps_ut::test_load_l1a_set_bad_datatype
  mms_load_feeps, probes=3, level='l1a', datatype='ion' ; ion isn't valid for L1a data, should load all
  assert, spd_data_exists('mms3_epd_feeps_srvy_l1a_electron_bottom_sensor_counts_sensorid_3 mms3_epd_feeps_srvy_l1a_electron_top_sensor_counts_sensorid_3 mms3_epd_feeps_srvy_l1a_ion_top_sensor_counts_sensorid_6 mms3_epd_feeps_srvy_l1a_ion_bottom_sensor_counts_sensorid_8', '2015-12-15', '2015-12-16'), $
    'Problem loading FEEPS L1a data with invalid datatype'
  return, 1
end

function mms_load_feeps_ut::test_load_l1a_data
  mms_load_feeps, probes=3, level='l1a'
  assert, spd_data_exists('mms3_epd_feeps_srvy_l1a_electron_bottom_sensor_counts_sensorid_3 mms3_epd_feeps_srvy_l1a_electron_bottom_sensor_counts_sensorid_12 mms3_epd_feeps_srvy_l1a_ion_top_sensor_counts_sensorid_7 mms3_epd_feeps_srvy_l1a_ion_bottom_sensor_counts_sensorid_7', '2015-12-15', '2015-12-16'), $
    'Problem loading FEEPS L1a data'
  return, 1
end

function mms_load_feeps_ut::test_load_multi_probe
  mms_load_feeps, probes=[1, 2, '3', 4], level='l2'
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_omni mms2_epd_feeps_srvy_l2_electron_intensity_omni mms3_epd_feeps_srvy_l2_electron_intensity_omni mms4_epd_feeps_srvy_l2_electron_intensity_omni', '2015-12-15', '2015-12-16'), 'Problem with feeps multi probe'
  return, 1
end

function mms_load_feeps_ut::test_smooth
  mms_load_feeps, num_smooth=3.0, level='l2'
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_omni_smth', '2015-12-15', '2015-12-16'), 'Problem with creating smooted spectra'
  return, 1
end

function mms_load_feeps_ut::test_load_ion
  mms_load_feeps, datatype='ion', level='l2'
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_ion_intensity_omni', '2015-12-15', '2015-12-16'), $
    'Problem with loading ion data'
  return, 1
end

function mms_load_feeps_ut::test_load_ion_brst
  mms_load_feeps, datatype='ion', data_rate='brst', level='l2'
  assert, spd_data_exists('mms1_epd_feeps_brst_l2_ion_intensity_omni', '2015-12-15', '2015-12-16'), $
    'Problem with loading ion burst data'
  return, 1
end

function mms_load_feeps_ut::test_suffix
  mms_load_feeps, level='l2', suffix='_test'
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_omni_test', '2015-12-15', '2015-12-16'), 'Problem with suffix'
  return, 1
end

function mms_load_feeps_ut::test_pad_limited_en
  mms_feeps_pad, probe=1, energy=[200, 400]
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_200-400keV_pad_spin', '2015-12-15', '2015-12-16'), 'Problem with FEEPS limited energy range PAD'
  return, 1
end

function mms_load_feeps_ut::test_pad_bad_en
  mms_feeps_pad, probe=1, energy=[700, 800]
  assert, ~spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_700-800keV_pad_spin', '2015-12-15', '2015-12-16'), 'Problem with FEEPS bad energy range PAD'
  return, 1
end

function mms_load_feeps_ut::test_brst_caps_pad
  mms_load_feeps, data_rate='BRST', level='l2'
  mms_feeps_pad, probe=1, data_rate='BRST'
  assert, spd_data_exists('mms1_epd_feeps_brst_l2_electron_intensity_70-1000keV_pad_spin', '2015-12-15', '2015-12-16'), 'Problem with FEEPS full energy range PAD (BRST)'
  return, 1
end

function mms_load_feeps_ut::test_brst_pad
  mms_load_feeps, data_rate='brst', level='l2'
  mms_feeps_pad, probe=1, data_rate='brst'
  assert, spd_data_exists('mms1_epd_feeps_brst_l2_electron_intensity_70-1000keV_pad_spin', '2015-12-15', '2015-12-16'), 'Problem with FEEPS full energy range PAD (brst)'
  return, 1
end

function mms_load_feeps_ut::test_pad
  mms_load_feeps, probe=4
  mms_feeps_pad, probe=4
  assert, spd_data_exists('mms4_epd_feeps_srvy_l2_electron_intensity_70-1000keV_pad_spin', '2015-12-15', '2015-12-16'), 'Problem with FEEPS full energy range PAD'
  return, 1
end

function mms_load_feeps_ut::test_load_spdf
  del_data,'*'
  mms_load_feeps, /spdf
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_omni_spin', '2015-12-15', '2015-12-16'), 'Problem loading L2 FEEPS data (SPDF)'
  return, 1
end

function mms_load_feeps_ut::test_load_l2
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_omni_spin', '2015-12-15', '2015-12-16'), 'Problem loading L2 FEEPS data'
  return, 1
end

function mms_load_feeps_ut::test_load_l1b
  del_data, '*'
  mms_load_feeps, level='l1b'
  assert, spd_data_exists('mms1_epd_feeps_srvy_l1b_electron_intensity_omni mms1_epd_feeps_srvy_l1b_electron_intensity_omni_spin', '2015-12-15', '2015-12-16'), $
    'Problem loading L1b FEEPS data'
  return, 1
end

function mms_load_feeps_ut::test_load_l1b_ion
  del_data, '*'
  mms_load_feeps, level='l1b', datatype='ion'
  assert, spd_data_exists('mms1_epd_feeps_srvy_l1b_ion_intensity_omni mms1_epd_feeps_srvy_l1b_ion_intensity_omni_spin', '2015-12-15', '2015-12-16'), $
    'Problem loading L1b FEEPS ion data'
  return, 1
end

function mms_load_feeps_ut::test_load_l1b_pad
  del_data, '*'
  mms_load_feeps, level='l1b', data_rate='Brst'
  mms_feeps_pad, level='l1B', data_rate='Brst'
  assert, spd_data_exists('mms1_epd_feeps_brst_l1b_electron_intensity_70-1000keV_pad_spin mms1_epd_feeps_brst_l1b_electron_intensity_70-1000keV_pad', '2015-12-15', '2015-12-16'), $
    'Problem loading burst mode FEEPS PAD for L1b data'
  return, 1
end

function mms_load_feeps_ut::test_load_l1b_pad_ion
  del_data, '*'
  mms_load_feeps, level='l1b', data_rate='Brst', datatype='Ion'
  mms_feeps_pad, level='l1B', data_rate='Brst', datatype='Ion'
  
  assert, spd_data_exists('mms1_epd_feeps_brst_l1b_ion_intensity_omni_spin mms1_epd_feeps_brst_l1b_ion_intensity_omni', '2015-12-15', '2015-12-16'), $
    'Problem loading burst mode FEEPS PAD for L1b data'
  return, 1
end

function mms_load_feeps_ut::test_load_suffix_pad
  del_data, '*'
  mms_load_feeps, level='l2', suffix='suffix_test'
  mms_feeps_pad, level='l2', suffix='suffix_test'
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_70-1000keV_padsuffix_test mms1_epd_feeps_srvy_l2_electron_intensity_70-1000keV_pad_spinsuffix_test', '2015-12-15', '2015-12-16'), $
    'Problem with suffix test in FEEPS PAD'
  return, 1
end

function mms_load_feeps_ut::test_load_timeclip
  del_data, '*'
  mms_load_feeps, level='l2', trange=['2015-12-15/11:00', '2015-12-15/12:00'], /time_clip
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_count_rate_omni_spin', '2015-12-15/11:00', '2015-12-15/12:00'), $
    'Problem with FEEPS time clipping'
  assert, ~spd_data_exists('mms1_epd_feeps_srvy_l2_electron_count_rate_omni_spin', '2015-12-15/10:00', '2015-12-15/11:00'), $
    'Problem with FEEPS time clipping'
  assert, ~spd_data_exists('mms1_epd_feeps_srvy_l2_electron_count_rate_omni_spin', '2015-12-15/12:00', '2015-12-15/13:00'), $
    'Problem with FEEPS time clipping'
  return, 1
end

function mms_load_feeps_ut::test_smooth_pad
  mms_load_feeps, num_smooth=30.0, level='l2'
  mms_feeps_pad, level='l2', num_smooth=30.0
  assert, spd_data_exists('mms1_epd_feeps_srvy_l2_electron_intensity_70-1000keV_pad_smth', '2015-12-15', '2015-12-16'), 'Problem with creating smooted PAD'
  return, 1
end

function mms_load_feeps_ut::test_pad_binsize
  mms_load_feeps, level='l2'
  mms_feeps_pad, bin_size=3
  get_data, 'mms1_epd_feeps_srvy_l2_electron_intensity_70-1000keV_pad_spin', data=d
  assert, n_elements(d.V) eq 61, 'Problem with bin_size keyword in FEEPS PAD' 
  return, 1
end

pro mms_load_feeps_ut::setup
  del_data, '*'
  timespan, '2015-12-15/00:00', 1, /day
  mms_load_feeps, probe=1, level='L2'
end

function mms_load_feeps_ut::init, _extra=e
  if (~self->MGutTestCase::init(_extra=e)) then return, 0
  ; the following adds code coverage % to the output
  self->addTestingRoutine, ['mms_load_feeps', 'mms_feeps_omni', $
                            'mms_feeps_pad_spinavg', 'mms_feeps_pad', $
                            'mms_feeps_remove_sun', 'mms_feeps_smooth', $
                            'mms_feeps_spin_avg', 'mms_feeps_split_integral_ch']
  self->addTestingRoutine, ['mms_read_feeps_sector_masks_csv'], /is_function
  return, 1
end

pro mms_load_feeps_ut__define

  define = { mms_load_feeps_ut, inherits MGutTestCase }
end