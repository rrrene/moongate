#!/bin/bash

mix ecto.rollback Moongate.Repo --all
mix ecto.migrate Moongate.Repo
