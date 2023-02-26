package app

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/types/module"
	upgradetypes "github.com/cosmos/cosmos-sdk/x/upgrade/types"
)

func (app *App) RegisterUpgradeHandlers() {
	planName := "cosmovisor-test"
	app.UpgradeKeeper.SetUpgradeHandler(planName, func(ctx sdk.Context, plan upgradetypes.Plan, fromVM module.VersionMap) (module.VersionMap, error) {
		return app.mm.RunMigrations(ctx, app.configurator, fromVM)
	})

	// upgradeInfo, err := app.UpgradeKeeper.ReadUpgradeInfoFromDisk()
	// if err != nil {
	// 	panic(fmt.Errorf("failed to read upgrade info from disk: %w", err))
	// }

	// if app.UpgradeKeeper.IsSkipHeight(upgradeInfo.Height) {
	// 	return
	// }

	// var storeUpgrades *storetypes.StoreUpgrades

	// switch upgradeInfo.Name {
	// case v2.UpgradeName:
	// 	// ...
	// }

	// if storeUpgrades != nil {
	// 	app.SetStoreLoader(upgradetypes.UpgradeStoreLoader(upgradeInfo.Height, storeUpgrades))
	// }
}
