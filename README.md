# CorpCorpCorp Starter Template

## Usage

Use this as a starter for new Rails applications. Primarily used for CorpCorpCorp projects.

To use, just clone or copy this repository and run the `rake template:reset` to reset the application to a new state for you.

## Process Management

To start the application, run `./bin/dev` from the root of the application. This will start the application and a guard process to watch for changes to the application.

## Resetting the Application

A rake task is provided to reset the application to your application such as renaming the main
application module, changing the database names, resetting the git repository to a new state, and resetting the README.md if you want.

Usage: `rake template:reset`

## Removing database support

If your application does not need a database, you can remove the need for a database (and thus simplify deployment), by running the following commands (note, this should be run _after_ `rake template:reset`):

```bash
rake template:remove_database_support

bundle
```
