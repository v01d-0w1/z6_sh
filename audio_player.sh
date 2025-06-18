#!/bin/bash

pkill ncmpcpp
cd ~/Music/
mpc update
ncmpcpp
