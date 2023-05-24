# Deploy the contracts on Ghostnet and update the dev indexer

## Deploy all contracts on the Ghostnet

- Checkout to the branch where the most updated contracts are (**probably not this branch**)

```bash
git checkout [REVISION]
```

- go to the contract folder

```bash
cd src/contracts
```

- Compile all contracts (it may slow your computer a lot)

```bash
yarn compile
```

- Deploy all contracts. In case of a failure during deployment

```bash
yarn test-net-deploy
```

## Index the new contracts

- Backup the deployment folder

```bash
cp -R ./deployments ./deployments-bckp
```

- Checkout to the branch where the most updated indexer is (**probably not this branch**)

```bash
git checkout [REVISION]
```

- Replace the deployments folder with your backup

```bash
rm -rf ./deployments
mv ./deployments-bckp ./deployments
```

- Go to the indexer folder

```bash
cd ../indexer
```

- Run Poetry

```bash
yarn shell
```

- Perform a poetry update and/or install of all dependencies

```bash
yarn setup-env
```

- Run the dipdup config update script

```bash
python import-contracts.py
```

- Commit and push all your changes

```bash
git add .
git commit -m "[YOUR COMMIT MESSAGE]"
git push
```