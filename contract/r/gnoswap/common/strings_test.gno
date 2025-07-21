package common

import (
	"testing"

	"gno.land/p/demo/uassert"
)

func TestStrings_Split(t *testing.T) {
	tests := []struct {
		name                 string
		inputString          string
		inputSeparator       string
		inputLength          int
		expectedResult       []string
		expectedHasError     bool
		expectedErrorMessage string
	}{
		{
			name:             "Valid split with comma separator",
			inputString:      "a,b,c",
			inputSeparator:   ",",
			inputLength:      3,
			expectedResult:   []string{"a", "b", "c"},
			expectedHasError: false,
		},
		{
			name:             "Valid split with pipe separator",
			inputString:      "token1|token2",
			inputSeparator:   "|",
			inputLength:      2,
			expectedResult:   []string{"token1", "token2"},
			expectedHasError: false,
		},
		{
			name:             "Single element",
			inputString:      "single",
			inputSeparator:   ",",
			inputLength:      1,
			expectedResult:   []string{"single"},
			expectedHasError: false,
		},
		{
			name:                 "Invalid length - too many parts",
			inputString:          "a,b,c,d",
			inputSeparator:       ",",
			inputLength:          3,
			expectedResult:       nil,
			expectedHasError:     true,
			expectedErrorMessage: "invalid length: 4",
		},
		{
			name:                 "Invalid length - too few parts",
			inputString:          "a,b",
			inputSeparator:       ",",
			inputLength:          3,
			expectedResult:       nil,
			expectedHasError:     true,
			expectedErrorMessage: "invalid length: 2",
		},
		{
			name:             "Empty string with length 1",
			inputString:      "",
			inputSeparator:   ",",
			inputLength:      1,
			expectedResult:   []string{""},
			expectedHasError: false,
		},
		{
			name:             "String with empty parts",
			inputString:      "a,,c",
			inputSeparator:   ",",
			inputLength:      3,
			expectedResult:   []string{"a", "", "c"},
			expectedHasError: false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			inputStr := tc.inputString
			separator := tc.inputSeparator
			length := tc.inputLength

			// when
			result, err := Split(inputStr, separator, length)

			// then
			if tc.expectedHasError {
				uassert.Error(t, err)
				uassert.True(t, result == nil) // Check for nil specifically
				if tc.expectedErrorMessage != "" {
					uassert.Equal(t, tc.expectedErrorMessage, err.Error())
				}
			} else {
				uassert.NoError(t, err)
				uassert.Equal(t, len(tc.expectedResult), len(result))
				for i, expected := range tc.expectedResult {
					uassert.Equal(t, expected, result[i])
				}
			}
		})
	}
}

func TestStrings_EncodeUint(t *testing.T) {
	tests := []struct {
		name           string
		inputNumber    uint64
		expectedResult string
	}{
		{
			name:           "Small number",
			inputNumber:    12345,
			expectedResult: "00000000000000012345",
		},
		{
			name:           "Zero",
			inputNumber:    0,
			expectedResult: "00000000000000000000",
		},
		{
			name:           "Large number",
			inputNumber:    18446744073709551615, // max uint64
			expectedResult: "18446744073709551615",
		},
		{
			name:           "Medium number",
			inputNumber:    1000000000000,
			expectedResult: "00000001000000000000",
		},
		{
			name:           "Single digit",
			inputNumber:    7,
			expectedResult: "00000000000000000007",
		},
		{
			name:           "Exact 20 digits",
			inputNumber:    12345678901234567890,
			expectedResult: "12345678901234567890",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			inputNumber := tc.inputNumber

			// when
			result := EncodeUint(inputNumber)

			// then
			uassert.Equal(t, tc.expectedResult, result)
			uassert.Equal(t, 20, len(result)) // Always 20 characters
		})
	}
}

func TestStrings_DecodeUint(t *testing.T) {
	tests := []struct {
		name                 string
		inputString          string
		expectedResult       uint64
		expectedHasPanic     bool
		expectedPanicMessage string
	}{
		{
			name:             "Valid zero-padded string",
			inputString:      "00000000000000012345",
			expectedResult:   12345,
			expectedHasPanic: false,
		},
		{
			name:             "Zero string",
			inputString:      "00000000000000000000",
			expectedResult:   0,
			expectedHasPanic: false,
		},
		{
			name:             "Max uint64 string",
			inputString:      "18446744073709551615",
			expectedResult:   18446744073709551615,
			expectedHasPanic: false,
		},
		{
			name:             "Medium number string",
			inputString:      "00000001000000000000",
			expectedResult:   1000000000000,
			expectedHasPanic: false,
		},
		{
			name:             "Single digit string",
			inputString:      "00000000000000000007",
			expectedResult:   7,
			expectedHasPanic: false,
		},
		{
			name:                 "Invalid string with letters",
			inputString:          "0000000000000001234a",
			expectedResult:       0,
			expectedHasPanic:     true,
			expectedPanicMessage: "strconv.ParseUint: parsing \"0000000000000001234a\": invalid syntax",
		},
		{
			name:                 "Empty string",
			inputString:          "",
			expectedResult:       0,
			expectedHasPanic:     true,
			expectedPanicMessage: "strconv.ParseUint: parsing \"\": invalid syntax",
		},
		{
			name:                 "String with special characters",
			inputString:          "000000000000000123-5",
			expectedResult:       0,
			expectedHasPanic:     true,
			expectedPanicMessage: "strconv.ParseUint: parsing \"000000000000000123-5\": invalid syntax",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			inputString := tc.inputString

			// when & then
			if tc.expectedHasPanic {
				uassert.PanicsWithMessage(t, tc.expectedPanicMessage, func() {
					DecodeUint(inputString)
				})
			} else {
				result := DecodeUint(inputString)
				uassert.Equal(t, tc.expectedResult, result)
			}
		})
	}
}

func TestStrings_EncodeDecodeRoundTrip(t *testing.T) {
	tests := []struct {
		name        string
		inputNumber uint64
	}{
		{
			name:        "Round trip with small number",
			inputNumber: 12345,
		},
		{
			name:        "Round trip with zero",
			inputNumber: 0,
		},
		{
			name:        "Round trip with large number",
			inputNumber: 9999999999999999999,
		},
		{
			name:        "Round trip with medium number",
			inputNumber: 1000000000000,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			originalNumber := tc.inputNumber

			// when
			encoded := EncodeUint(originalNumber)
			decoded := DecodeUint(encoded)

			// then
			uassert.Equal(t, originalNumber, decoded)
			uassert.Equal(t, 20, len(encoded))
		})
	}
}
