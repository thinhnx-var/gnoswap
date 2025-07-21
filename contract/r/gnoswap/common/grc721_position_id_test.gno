package common

import (
	"testing"

	"gno.land/p/demo/grc/grc721"
	"gno.land/p/demo/uassert"
)

func TestGrc721PositionId_PositionIdFrom(t *testing.T) {
	tests := []struct {
		name                 string
		inputPositionId      any
		expectedResult       grc721.TokenID
		expectedHasPanic     bool
		expectedPanicMessage string
	}{
		{
			name:             "Valid string input",
			inputPositionId:  "123",
			expectedResult:   grc721.TokenID("123"),
			expectedHasPanic: false,
		},
		{
			name:             "Valid int input",
			inputPositionId:  123,
			expectedResult:   grc721.TokenID("123"),
			expectedHasPanic: false,
		},
		{
			name:             "Valid uint64 input",
			inputPositionId:  uint64(123),
			expectedResult:   grc721.TokenID("123"),
			expectedHasPanic: false,
		},
		{
			name:             "Valid grc721.TokenID input",
			inputPositionId:  grc721.TokenID("123"),
			expectedResult:   grc721.TokenID("123"),
			expectedHasPanic: false,
		},
		{
			name:                 "Nil input should panic",
			inputPositionId:      nil,
			expectedResult:       grc721.TokenID(""),
			expectedHasPanic:     true,
			expectedPanicMessage: "[GNOSWAP-COMMON-007] invalid positionId || can not be nil",
		},
		{
			name:                 "Unsupported type should panic",
			inputPositionId:      []byte("123"),
			expectedResult:       grc721.TokenID(""),
			expectedHasPanic:     true,
			expectedPanicMessage: "[GNOSWAP-COMMON-007] invalid positionId || unsupported positionId type: []byte",
		},
		{
			name:             "Zero int input",
			inputPositionId:  0,
			expectedResult:   grc721.TokenID("0"),
			expectedHasPanic: false,
		},
		{
			name:             "Large uint64 input with overflow",
			inputPositionId:  uint64(18446744073709551615),
			expectedResult:   grc721.TokenID("-1"),
			expectedHasPanic: false,
		},
		{
			name:             "Empty string input",
			inputPositionId:  "",
			expectedResult:   grc721.TokenID(""),
			expectedHasPanic: false,
		},
		{
			name:             "Negative int input",
			inputPositionId:  -123,
			expectedResult:   grc721.TokenID("-123"),
			expectedHasPanic: false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			inputPositionId := tc.inputPositionId

			// when & then
			if tc.expectedHasPanic {
				uassert.PanicsWithMessage(t, tc.expectedPanicMessage, func() {
					PositionIdFrom(inputPositionId)
				})
			} else {
				result := PositionIdFrom(inputPositionId)
				uassert.Equal(t, string(tc.expectedResult), string(result))
			}
		})
	}
}
