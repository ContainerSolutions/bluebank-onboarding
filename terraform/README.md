
This folder contains the terraform part of the engineer day in the life of a blue bank.

## Tools needed
- [terraform](https://www.terraform.io/downloads)
- [az-cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [golang](https://go.dev/doc/install)

## First time setup (only needed once)
```
cd test/unittest
go mod tidy
```
## Running tests:
```
cd test/unittest
go test -v -timeout=30m ./...
```