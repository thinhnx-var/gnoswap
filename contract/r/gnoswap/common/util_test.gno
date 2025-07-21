package common

import (
	"testing"

	"gno.land/p/demo/uassert"

	u256 "gno.land/p/gnoswap/uint256"
)

func TestUtil_assertOnlyNotNil(t *testing.T) {
	tests := []struct {
		name                 string
		inputValue           *u256.Uint
		expectedHasPanic     bool
		expectedPanicMessage string
	}{
		{
			name:             "Valid non-nil value",
			inputValue:       u256.NewUint(100),
			expectedHasPanic: false,
		},
		{
			name:             "Valid zero value",
			inputValue:       u256.NewUint(0),
			expectedHasPanic: false,
		},
		{
			name:                 "Nil value should panic",
			inputValue:           nil,
			expectedHasPanic:     true,
			expectedPanicMessage: "[GNOSWAP-COMMON-008] invalid input data || value is nil",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			inputValue := tc.inputValue

			// when & then
			if tc.expectedHasPanic {
				uassert.PanicsWithMessage(t, tc.expectedPanicMessage, func() {
					assertOnlyNotNil(inputValue)
				})
			} else {
				// Should not panic for valid values
				assertOnlyNotNil(inputValue)
				// If we reach here, test passed
				uassert.True(t, true)
			}
		})
	}
}

func TestUtil_getPrevRealm(t *testing.T) {
	tests := []struct {
		name            string
		setupRealm      func()
		expectedUser    bool
		expectedPkgPath string
	}{
		{
			name: "Get previous realm from user context",
			setupRealm: func() {
				// This will be called from test context which is a user realm
			},
			expectedUser:    true,
			expectedPkgPath: "",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			// Test execution context

			// when
			prevRealm := getPrevRealm()

			// then
			uassert.Equal(t, tc.expectedUser, prevRealm.IsUser())
			// Note: We can't easily test exact PkgPath in unit tests
			// as it depends on the test execution context
		})
	}
}

func TestUtil_getPrevAddr(t *testing.T) {
	tests := []struct {
		name         string
		setupContext func()
	}{
		{
			name: "Get previous address",
			setupContext: func() {
				// Test context setup
			},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			// Test execution context

			// when
			addr := getPrevAddr()

			// then
			// Just verify function doesn't panic and returns something
			// Note: In test context, address might be empty/zero value
			_ = addr.String() // This shouldn't panic
		})
	}
}

func TestUtil_getPrevAsString(t *testing.T) {
	tests := []struct {
		name         string
		setupContext func()
	}{
		{
			name: "Get previous realm as strings",
			setupContext: func() {
				// Test context setup
			},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			// Test execution context

			// when
			addrStr, _ := getPrevAsString()

			// then
			// Just verify function doesn't panic and returns something
			// Note: In test context, values might be empty
			_ = addrStr // This shouldn't panic
		})
	}
}

func TestUtil_IntegrationTest(t *testing.T) {
	tests := []struct {
		name           string
		testValue      uint64
		expectedResult bool
	}{
		{
			name:           "Integration test with valid value",
			testValue:      12345,
			expectedResult: true,
		},
		{
			name:           "Integration test with zero value",
			testValue:      0,
			expectedResult: true,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// given
			testValue := u256.NewUint(tc.testValue)

			// when - test that all util functions work together
			assertOnlyNotNil(testValue) // Should not panic
			prevRealm := getPrevRealm()
			addr := getPrevAddr()
			addrStr, _ := getPrevAsString()

			// then
			// Just verify functions work without panicking
			_ = prevRealm.IsUser() // Test context may vary
			_ = addr.String()      // Should not panic
			_ = addrStr            // Should not panic
			// All functions executed successfully
			uassert.True(t, true)
		})
	}
}
