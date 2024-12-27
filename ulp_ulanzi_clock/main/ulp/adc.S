/*
 * SPDX-FileCopyrightText: 2022-2023 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Unlicense OR CC0-1.0
 */
/*
    ULP measurements for the Ulanzi clock
   based on ULP Example: using ADC in deep sleep

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.

   This file contains assembly code which runs on the ULP.
*/

/* ULP assembly files are passed through C preprocessor first, so include directives
   and C macros may be used in these files
 */
#include "soc/rtc_cntl_reg.h"
#include "soc/soc_ulp.h"
#include "example_config.h"
#include "soc/sens_reg.h"
#include "soc/rtc_io_reg.h"

	.set adc_channel_battery, 6
	.set adc_channel_light, 7

	/* Configure the number of ADC samples to average on each measurement.
	   For convenience, make it a power of 2. */
	.set adc_oversampling_factor_log, 4
	.set adc_oversampling_factor, (1 << adc_oversampling_factor_log)

	/* Define variables, which go into .bss section (zero-initialized data) */
	.bss

	/* Counter of measurements done */
	.global sample_counter
sample_counter:
	.long 0

	.global last_result_battery
last_result_battery:
	.long 0

	.global last_result_light
last_result_light:
	.long 0

	.global last_result_internal_temperature
last_result_internal_temperature:
	.long 0

	.global last_result_gpios_low
last_result_gpios_low:
	.long 0

	.global last_result_gpios_high
last_result_gpios_high:
	.long 0

	/* Code goes into .text section */
	.text
	.global entry
entry:
	/* increment sample counter */
	move r3, sample_counter
	ld r2, r3, 0
	add r2, r2, 1
	st r2, r3, 0

	/* do measurements using ADC */
	/* r0 will be used as accumulator */
	move r0, 0
	/* initialize the loop counter */
	stage_rst

measure_battery:
	/* measure and add value to accumulator */
	adc r1, 0, adc_channel_battery + 1
	add r0, r0, r1
	/* increment loop counter and check exit condition */
	stage_inc 1
	jumps measure_battery, adc_oversampling_factor, lt

	/* divide accumulator by adc_oversampling_factor.
	   Since it is chosen as a power of two, use right shift */
	rsh r0, r0, adc_oversampling_factor_log
	/* averaged value is now in r0; store it into last_result_battery */
	move r3, last_result_battery
	st r0, r3, 0

	/* r0 will be used as accumulator */
	move r0, 0
	/* initialize the loop counter */
	stage_rst

measure_light:
	/* measure and add value to accumulator */
	adc r1, 0, adc_channel_light + 1
	add r0, r0, r1
	/* increment loop counter and check exit condition */
	stage_inc 1
	jumps measure_light, adc_oversampling_factor, lt

	/* divide accumulator by adc_oversampling_factor.
	   Since it is chosen as a power of two, use right shift */
	rsh r0, r0, adc_oversampling_factor_log
	/* averaged value is now in r0; store it into last_result_light */
	move r3, last_result_light
	st r0, r3, 0

measure_tsens:
    /* Read 8-bit SENS_TSENS_OUT field of SENS_SAR_SLAVE_ADDR3_REG into R0 */
    READ_RTC_FIELD(SENS_SAR_SLAVE_ADDR3_REG, SENS_TSENS_OUT)
	/* value is now in r0; store it into last_result_internal_temperature */
	move r3, last_result_internal_temperature
	st r0, r3, 0

read_gpios:
    /* Read the value of lower 16 RTC IOs into R0 */
	READ_RTC_REG(RTC_GPIO_IN_REG, RTC_GPIO_IN_NEXT_S, 16)
	/* value is now in r0; store it into last_result_internal_temperature */
	move r3, last_result_gpios_low
	st r0, r3, 0
	/* Read the value of RTC IOs 16-17, into R0 */
	READ_RTC_REG(RTC_GPIO_IN_REG, RTC_GPIO_IN_NEXT_S + 16, 2)
	move r3, last_result_gpios_high
	st r0, r3, 0


	/* value within range, end the program */
	.global exit
exit:
	halt
