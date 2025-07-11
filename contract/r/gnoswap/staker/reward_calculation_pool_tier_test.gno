package staker

import (
	"std"
	"testing"

	"gno.land/p/demo/testutils"
	pl "gno.land/r/gnoswap/v1/pool"
	"gno.land/r/onbloc/bar"
	"gno.land/r/onbloc/baz"
	"gno.land/r/onbloc/qux"
)

func TestTierRatioFromCounts(t *testing.T) {
	t.Skip("fix insufficient allowance error")
	CreateSecondPoolWithoutFee(t)
	MakeMintPositionWithoutFee(t)

	user1Addr := testutils.TestAddress("user1")
	user1Realm := std.NewUserRealm(user1Addr)

	testing.SetRealm(user1Realm)
	func() {
		testing.SetRealm(user1Realm)
		bar.Approve(cross, routerAddr, maxApprove)
		baz.Approve(cross, routerAddr, maxApprove)
		qux.Approve(cross, routerAddr, maxApprove)
		TokenFaucet(t, barPath, user1Addr)
	}()

	tests := []struct {
		tier1Count uint64
		tier2Count uint64
		tier3Count uint64
		expected   TierRatio
	}{
		{1, 0, 0, TierRatio{Tier1: 100, Tier2: 0, Tier3: 0}},
		{1, 0, 1, TierRatio{Tier1: 80, Tier2: 0, Tier3: 20}},
		{1, 1, 0, TierRatio{Tier1: 70, Tier2: 30, Tier3: 0}},
		{1, 1, 1, TierRatio{Tier1: 50, Tier2: 30, Tier3: 20}},
	}

	for _, tt := range tests {
		result := TierRatioFromCounts(tt.tier1Count, tt.tier2Count, tt.tier3Count)
		if result != tt.expected {
			t.Errorf("TierRatioFromCounts(%d, %d, %d) = %v; want %v",
				tt.tier1Count, tt.tier2Count, tt.tier3Count, result, tt.expected)
		}
	}
}

func TestNewPoolTier(t *testing.T) {
	currentHeight := int64(100)
	mustExistsInTier1 := "testPool"

	poolTier := NewPoolTier(NewPools(), currentHeight, mustExistsInTier1, func() int64 { return 0 }, func(start, end int64) ([]int64, []int64) { return nil, nil })

	// Test initial counts
	if count := poolTier.CurrentCount(1); count != 1 {
		t.Errorf("Expected tier 1 count to be 1, got %d", count)
	}
	if count := poolTier.CurrentCount(2); count != 0 {
		t.Errorf("Expected tier 2 count to be 0, got %d", count)
	}
	if count := poolTier.CurrentCount(3); count != 0 {
		t.Errorf("Expected tier 3 count to be 0, got %d", count)
	}

	// Test membership
	if tier := poolTier.CurrentTier(mustExistsInTier1); tier != 1 {
		t.Errorf("Expected pool %s to be in tier 1, got %d", mustExistsInTier1, tier)
	}
}

func TestCacheReward(t *testing.T) {
	currentHeight := int64(250)
	// Simulate emission updates
	poolTier := NewPoolTier(NewPools(), currentHeight, "testPool", func() int64 { return 1000 }, func(startHeight int64, endHeight int64) ([]int64, []int64) {
		return []int64{100, 150, 200}, []int64{1000, 500, 250}
	})

	// Cache rewards
	poolTier.cacheReward(currentHeight, pools)

	// Verify rewards
	reward := poolTier.CurrentReward(1)
	if reward == 0 {
		t.Errorf("Expected reward for tier 1 at height 250, got 0")
	}
}

var test_gnousdc = pl.GetPoolPath("gno.land/r/demo/wugnot", "gno.land/r/gnoswap/v1/gns", 3000)

func SetupPoolTier(t *testing.T) *PoolTier {
	poolTier := NewPoolTier(NewPools(), 1, test_gnousdc, func() int64 { return 1000 }, func(start, end int64) ([]int64, []int64) { return nil, nil })

	poolTier.changeTier(1, pools, test_gnousdc, 1)
	return poolTier
}
